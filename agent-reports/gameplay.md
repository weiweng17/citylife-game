# Gameplay Agent Report

## Task
- ID: GAME-AUDIT-008
- Agent: gameplay
- Branch/worktree: `agent/game-audit-008-terminal-time-callsite-audit`
- Status: NEEDS_REVIEW

## Scope
Report-only audit of remaining terminal-sensitive time-settlement/state-mutation callsites after the repository acceptance of `GAME-FIX-007`.

Per `TASK_BOARD.md`, the only writable path for this task is:
- `agent-reports/gameplay.md`

No gameplay source, verifier, coordination file, data file, scene/UI file, workflow, `main`, or integration branch was modified.

## Baseline / semantic source of truth
The audit branch was created from the current coordination state and was identical to coordination before this report-only commit:
- coordination / audit branch comparison anchor: `46d1ab5ce72331ef20c2260c29dccdd0a4b250f2`
- initial diff: ahead `0`, behind `0`

The coordination branch is still metadata-oriented and is not the authoritative assembled gameplay source. `TASK_BOARD.md` explicitly accepted GAME-FIX-007 at:
- `agent/game-fix-007-sleep-terminal-guard`
- exact accepted SHA: `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344`

Therefore all callsite semantics below were inspected against `Game.gd` and its supporting gameplay data/scripts at accepted SHA `ff08ce9d...`, which already preserves GAME-FIX-001..004 plus the sleep guard.

## Executive summary
Two concrete terminal-observation gaps remain after GAME-FIX-007:

1. **HIGH — quest rewards are applied before the authoritative terminal observation in `_process()`.** `_evaluate_quests()` currently runs at the very start of `_process()`, before `_sync_needs_to_time()` and before `_evaluate_terminal_state()`. Existing quest rewards include positive mood and money. A state that is already terminal, or would become terminal during the pending elapsed-time settlement, can therefore be raised back above the threshold before the authoritative evaluator sees it.

2. **HIGH — the persistent backpack UI can settle health to zero while suppressing the evaluator, then allow another health-restoring item to revive the player.** `_process()` always calls `_sync_needs_to_time()` even while the shop/backpack UI is open, but it calls `_evaluate_terminal_state()` only when `not ui_busy`; `shop_ui.is_open()` contributes to `ui_busy`. `_on_shop_use()` advances time and leaves the bag open, so a later click can mutate health again before terminal observation.

No additional terminal-revival bypass was found in ordinary travel, event-close, annual, standard activity, or the now-guarded overnight sleep paths.

## Authoritative terminal/settlement callsite inventory

### Direct `_sync_needs_to_time()` callsites — 2
1. `_process(delta)`
   - normal continuous/one-shot elapsed time is settled here every frame;
   - settlement happens even while UI/activity is busy;
   - terminal evaluation immediately after settlement is currently gated by `not ui_busy`.

2. `_sleep_through_night()`
   - GAME-FIX-007 explicitly performs overnight `advance_minutes(...)` -> `_sync_needs_to_time()` -> `_evaluate_terminal_state()` -> recovery only if non-terminal;
   - **SAFE** against same-flow sleep recovery revival.

There is no third gameplay caller of `_sync_needs_to_time()` in the accepted GAME-FIX-007 source.

### Direct `_evaluate_terminal_state()` callsites — 3
1. `_process(delta)` — shared settled-frame path; currently only when `not ui_busy`.
2. `_sleep_through_night()` — synchronous overnight guard added by GAME-FIX-007.
3. `_year_pass()` — annual settlement calls the same authoritative evaluator immediately after `year_tick()` and state sync.

`_evaluate_terminal_state()` remains the only direct `rules_sys.death_reason(...)` consumer in `Game.gd`; no second threshold/death implementation was found.

## `time_sys.advance_minutes(...)` inventory
The accepted source contains **20 direct `advance_minutes(...)` call expressions grouped across 13 gameplay functions**.

| Function | Time advance(s) | Terminal-sensitive behavior | Audit result |
| --- | --- | --- | --- |
| `_on_home_activity()` | daytime rest `120`, study `60`, meal `30` | activity lock is released in the same continuation; rest/meal recovery is applied before elapsed time, not after need settlement | **SAFE as a time callsite**, but study/meal can expose Finding 1 if they complete a reward-bearing quest before the next settled-frame evaluator |
| `_sleep_through_night()` | variable minutes to 07:30 | direct need settlement and evaluator occur before `health +12`, `mood +8`, `energy = 100` | **SAFE — GAME-FIX-007** |
| `_do_work_shift()` | `240` | health/mood loss happens before the advance; activity unlocks before next frame; no post-settlement recovery inside the function | **SAFE by itself**, but work/skill progression can expose Finding 1 |
| `_do_negotiate()` | `JobGrowth.NEGOTIATE_MINUTES = 30` | mood mutation precedes time advance; no same-flow post-settlement recovery | **SAFE by itself** |
| `_on_park_activity()` | `30`, `20` | mood/energy recovery precedes advance; activity ends before next frame | **SAFE** |
| `_on_cafe_activity()` | `30`, `20` | mood/energy recovery precedes advance; activity ends before next frame | **SAFE** |
| `_on_hospital_activity()` | `60`, `15` | health/mood recovery precedes advance; activity ends before next frame | **SAFE** |
| `_on_alley_activity()` | `15`, `20` | mood recovery precedes advance; activity ends before next frame | **SAFE** |
| `_on_rooftop_activity()` | `25`, `20` | mood/energy recovery precedes advance; activity ends before next frame | **SAFE** |
| `_on_shop_use()` | item-defined `5..15` minutes | shop remains open across frames; process settles needs while evaluator is suppressed by shop `ui_busy`; another item remains clickable | **UNSAFE — Finding 2** |
| `_on_location_travel()` | subway `20`, other `35` | no health/mood/money recovery after the advance; next ordinary frame settles/evaluates | **SAFE** |
| `_on_location_action()` | no-event `30` | no survival-state recovery after the advance; next ordinary frame settles/evaluates | **SAFE** |
| `_close_event()` | encounter `time_cost` | EventUI is closed before time is advanced; no later recovery before next frame; ordinary event close no longer advances a year | **SAFE** |

### Continuous time
`_process(delta)` also calls `time_sys.tick(delta)` before `_sync_needs_to_time()`. On an ordinary non-busy frame the resulting need delta is observed by the shared evaluator in the same process pass. The remaining ordering problem is not `tick()` itself; it is that reward-bearing `_evaluate_quests()` has already run earlier in that pass.

## Finding 1 — quest reward mutation precedes terminal observation
**Severity: HIGH**

### Repository-visible ordering
The accepted `_process()` begins with:
- `if not game_started: return`
- `_evaluate_quests()`

Only later does it compute `ui_busy`, tick time, call `_sync_needs_to_time()`, and finally call `_evaluate_terminal_state()` when not busy.

`_evaluate_quests()` applies quest completion rewards through `_apply_quest_reward(...)` before returning.

Current quest rewards are not presentation-only:
- `q1_stand_firm`: `mood +8`
- `q2_laozhang`: `money +150`, `mood +6`
- `q3_someone_waits`: `mood +10`, `fullness +20`

### Concrete normal-gameplay bypass
`q1_stand_firm` is sequential, but its counter/state conditions can already be satisfied before the final evaluation pass. A normal reachable sequence is:
1. the player has already completed the work counter and meal counter and has at least 3000 money;
2. skill is just below 55;
3. mood is `3`;
4. the player studies for one hour;
5. study applies `skill +3` and `mood -3`, so mood becomes `0`, then advances 60 minutes and ends the activity;
6. on the next `_process()`, `_evaluate_quests()` sees skill >= 55 plus the already satisfied later conditions and completes q1;
7. q1 applies `mood +8` **before** `_evaluate_terminal_state()` is allowed to observe mood `0`.

The authoritative evaluator therefore sees mood `8`, not the terminal mood state produced by the activity.

The same root ordering can also mask a threshold that would have been reached by the pending need settlement: q1's `mood +8` can be awarded before `_sync_needs_to_time()` applies zero-energy hourly mood damage.

### Save/load implication
GAME-FIX-004 correctly routes loaded state back toward the shared evaluator and does not create a save-specific death path, but `_process()` still mutates quest rewards first. A loaded terminal mood state with a pending q1/q3 completion, or a below-bankrupt-limit money state with a pending q2 reward, can be mutated before the next shared terminal observation. This is an ordering gap in `_process()`, not a failure of the save/load reset contract itself.

### Why this is not a new threshold rule
No threshold is wrong. `Rules.death_reason()` remains authoritative. The problem is simply that reward-bearing mutation occurs before the first permitted observation of an already-terminal/pending-terminal state.

## Finding 2 — open backpack can revive health after hidden need settlement
**Severity: HIGH**

### Repository-visible ordering
When `shop_ui` is open:
- `_process()` includes `shop_ui.is_open()` in `ui_busy`;
- time ticking is paused, but `_sync_needs_to_time()` is still called every frame;
- `_evaluate_terminal_state()` is skipped because it is guarded by `if not ui_busy`.

`_on_shop_use()`:
- removes the item;
- applies its effects;
- calls `time_sys.advance_minutes(item_minutes)`;
- leaves the backpack panel open;
- has no synchronous `_sync_needs_to_time()` + `_evaluate_terminal_state()` guard before another use action can occur.

The inventory contains both:
- `canned_coffee`: 5 minutes, no health/fullness recovery;
- `milk`: `health +4`;
- `cold_medicine`: `health +18`.

### Concrete deterministic bypass
A repository-valid state is:
- `health = 2`
- `fullness = 0`
- `need_fraction = 55.0 / 60.0`
- backpack open with canned coffee plus milk or cold medicine available.

Sequence:
1. use canned coffee;
2. it advances 5 minutes while the backpack remains open;
3. the next `_process()` runs `_sync_needs_to_time()`; the fractional hour reaches one completed hour, fullness is still zero, and health falls from `2` to `0`;
4. because the backpack is still open, `ui_busy == true` and `_evaluate_terminal_state()` is skipped;
5. the backpack remains interactive, so milk/cold medicine can be used and health rises above zero;
6. after closing the backpack, the shared evaluator sees only the recovered non-terminal health.

This is the same semantic class as the pre-FIX-007 overnight bug, but through a persistent busy UI rather than the sleep activity lock.

### Related shop paths that are not bypasses
- `_on_shop_buy()` does not advance time. It requires `money >= item price` before subtracting the small positive price, so a successful purchase leaves money >= 0 and cannot cross the negative bankruptcy threshold.
- Cold medicine can directly reduce mood by 3 while the bag remains open, so terminal observation can be delayed, but no current inventory item restores mood. The concrete same-panel **revival** demonstrated above is the health path.

## Paths explicitly classified safe

### GAME-FIX-007 overnight sleep
Safe by synchronous settlement/evaluation before recovery. No further change recommended.

### Standard locked activities
Home daytime actions, office work/negotiate, park, cafe, hospital, alley, and rooftop all apply their recovery/cost/stat mutations before their `advance_minutes(...)` call and call `_end_activity()` without another await after the advance. There is no opportunity for `_process()` to settle needs mid-function and then for that same function to apply a later recovery. Their only remaining exposure is the global quest-before-terminal ordering in Finding 1.

### Travel and no-event location time
Travel and no-event location action advance time but perform no later survival-state recovery. The next ordinary frame settles/evaluates.

### Encounter close
The event panel closes before encounter time advances. No choice/recovery action remains available between that advance and the next settled-frame evaluator.

### Ordinary event close
GAME-FIX-001 remains intact: ordinary event close does not call `_year_pass()`.

### Annual progression
`_year_pass()` performs the annual settlement and immediately calls the authoritative evaluator before returning to ordinary gameplay. Intermediate calculations inside one `year_tick()` are treated as one annual settlement transaction; no external recovery/action can interleave.

### Event/dialog busy states
Terminal evaluation is intentionally delayed while EventUI/DialogUI is busy to prevent overlapping ending presentation. Those flows do not expose a repeated survival-recovery action after need settlement while remaining busy. ShopUI is different because its item buttons remain state-mutating and repeatedly usable while the busy gate remains active.

## Smallest recommended follow-up
Recommend **one** narrow Gameplay repair task rather than separate threshold/death implementations:

### `GAME-FIX-009 — Pre-terminal mutation ordering guard`
Suggested writable boundary:
- `scripts/Game.gd`
- one narrow `tools/verify_terminal_mutation_order.gd`
- `agent-reports/gameplay.md`

Suggested objective:
1. ensure pending need settlement and the authoritative terminal evaluator run before reward-bearing `_evaluate_quests()` on a non-busy settled frame, so quest rewards cannot revive a terminal state before observation;
2. in `_on_shop_use()`, synchronously settle the item's elapsed minutes and run the **existing** `_evaluate_terminal_state()` before allowing normal backpack completion/continued item use; if terminal, safely close/finish the shop flow and return;
3. reject further `_on_shop_use()` mutation once `game_over` is true;
4. preserve all existing item effects/time costs, quest rewards, UI semantics for non-terminal play, GAME-FIX-001..007 contracts, Rules thresholds, save schema, and ending presentation.

A narrow regression should cover at minimum:
- q1 completion cannot turn a pre-evaluator `mood == 0` into a surviving mood through the +8 reward;
- pending zero-energy/fullness need settlement is observed before quest rewards;
- open-backpack item time can make health terminal and must not permit a second health item to revive it;
- normal non-terminal quest reward and item-use behavior remains unchanged;
- `rules_sys.death_reason(...)` remains centralized in `_evaluate_terminal_state()`.

This is one ordering/guard repair in `Game.gd`; it should not introduce a quest-specific or shop-specific death threshold.

## Validation actually performed
Performed:
- read the latest coordination `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, and `WEB_AGENT_LAUNCHPAD.md`;
- confirmed GAME-FIX-007 is repository-accepted at exact SHA `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344`;
- confirmed GAME-AUDIT-008 initially matched the current coordination branch with zero diff;
- inspected accepted GAME-FIX-007 `Game.gd` call ordering;
- inspected `Rules.gd` terminal thresholds;
- inspected `Inventory.gd` item effects/time costs;
- inspected `ShopUI.gd` persistent use-button behavior;
- inspected `QuestSystem.gd` reward timing/serial progression;
- inspected `data/quests.json` concrete reward values;
- inspected `JobGrowth.gd` negotiate time constant;
- repository-only callsite/order analysis.

Not performed:
- Godot launch;
- any verifier execution;
- local terminal/Codex execution;
- Web export;
- browser execution;
- screenshot/render validation;
- runtime PASS/FAIL claim.

## Known risks / boundaries
- This audit intentionally does not patch either finding because GAME-AUDIT-008 is report-only.
- The coordination branch still does not itself represent the assembled gameplay source; integration must continue using accepted semantic deltas/exact candidate rules rather than blindly merging historical branches.
- The two findings above are repository-visible ordering paths. Actual Godot execution is still required to produce runtime evidence on a frozen integration SHA.
- No new Rules threshold, save field, annual behavior, quest reward, inventory balance, or ending path is proposed.

## Handoff
GAME-AUDIT-008 repository audit is complete and requests `NEEDS_REVIEW`.

The already accepted GAME-FIX-007 sleep guard remains valid and should not be reopened. The next smallest Gameplay source task should address the two remaining pre-observation mutation paths through the existing authoritative evaluator, with no second death implementation.