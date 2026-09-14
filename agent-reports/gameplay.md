# Gameplay Agent Report

## Task
- ID: GAME-AUDIT-010
- Agent: gameplay
- Branch/worktree: `agent/game-audit-010-terminal-mutation-surface`
- Status: NEEDS_REVIEW

## Scope
Report-only audit of terminal-sensitive mutation surfaces after repository acceptance of GAME-FIX-009.

Per the latest `TASK_BOARD.md`, the only writable path for this task is:
- `agent-reports/gameplay.md`

No gameplay source, verifier, coordination file, UI/scene file, LocationManager file, NPC/content data, workflow, `main`, or integration branch was modified.

## Baseline / source of truth
- Coordination branch at audit start: `orchestrator/multi-agent-bootstrap` exact SHA `96a202796d5b454f730bf84c566367e8564db7f4`.
- `agent/game-audit-010-terminal-mutation-surface` initially compared identical to coordination: ahead `0`, behind `0`.
- GAME-FIX-009 is repository-accepted at exact tip `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`.
- Because coordination remains metadata/control-plane oriented, the semantic audit below uses `Game.gd` and supporting gameplay systems/data at accepted GAME-FIX-009 tip `8ff9a36e...`.

## Executive summary
**No new repository-proven terminal revival/masking bypass was found after GAME-FIX-009.**

The remaining callbacks/signals that can touch `health`, `mood`, `money`, `fullness`, or `energy` were inspected against the exact accepted 009 ordering. They now fall into one of these safe classes:
1. terminal observation occurs synchronously before a later recovery can run (sleep, shop-use, annual settlement);
2. a busy transaction can create a terminal value, but exposes no later survival-restoring mutation inside that same transaction before the busy surface closes (event choice, negative activity result);
3. mutation is positive-only or cannot reach the active terminal threshold from a valid entry state (shop buy, relation mood reward under normal dialog flow, stage/day signals);
4. lifecycle replacement intentionally resets the whole run (`_choose_origin`, `_restart`, `apply_save_payload`) and is not an in-run revival path.

GAME-FIX-009 remains effective:
- settled non-busy process path is `_sync_needs_to_time()` -> `_evaluate_terminal_state()` -> `_evaluate_quests()`;
- shop-use elapsed time is settled/evaluated synchronously before another item can be used;
- `game_over` rejects further shop-use mutation;
- the existing GAME-FIX-007 sleep guard still evaluates after overnight settlement and before sleep recovery.

I found one **runtime-only re-entry stress candidate**, described below, where a second input would have to be delivered after a deferred `advance_minutes(...)` callback but before the next `Game._process()` pass. Source inspection alone does not prove that real Godot input/idle ordering permits a player-visible revival, so it is **not promoted to a repository finding** and no new source task is proposed from this audit.

## Authoritative terminal boundary after GAME-FIX-009
### `_process(delta)`
Accepted ordering:
1. game-start guard;
2. near-target/UI refresh;
3. `_check_stage()`;
4. compute `ui_busy` (dialog/event/ending/activity/shop);
5. pause/tick time;
6. `_sync_needs_to_time()`;
7. when non-busy, `_evaluate_terminal_state()`;
8. only if non-terminal, `_evaluate_quests()`;
9. weather/NPC/dark/location/world presentation updates.

Important classifications:
- `_refresh_ui()` is presentation/context sync and does not mutate the five audited survival values.
- `_check_stage()` calls `StorySystem.check_and_advance_stage()`; that system only advances `stage_idx` and does not change health/mood/money/fullness/energy.
- quest completion rewards are now behind the authoritative evaluator on settled non-busy frames, closing the GAME-AUDIT-008 q1/q2/q3 pre-observation reward gap.
- post-evaluator weather/NPC/location visual/update systems inspected here do not write the five audited survival values back into GameState.

## Mutation surface inventory

### 1. Shop / backpack signals
#### `_on_shop_use(item_id)` — SAFE after GAME-FIX-009
Current exact ordering:
- reject if `game_over`;
- remove current item;
- apply item effects;
- advance item minutes;
- `_sync_needs_to_time()`;
- `_evaluate_terminal_state()`;
- on terminal: close persistent shop UI, refresh, return;
- only otherwise complete meal bookkeeping/status/normal continued backpack flow.

This closes the previous deterministic `health=2/fullness=0` coffee -> hidden settlement -> medicine revival path.

Current item catalog was rechecked:
- milk: health `+4`, fullness `+12`, 6 minutes;
- cold medicine: health `+18`, mood `-3`, 10 minutes;
- remaining items restore fullness/energy only.

Cold medicine can itself make low mood terminal, but the same callback now evaluates immediately after its elapsed-time settlement, so the panel is closed before another item action.

#### `_on_shop_buy(item_id)` — SAFE
A successful buy requires `money >= price` where every current price is positive, then subtracts exactly that price. Therefore successful purchase leaves `money >= 0`; it cannot cross the Rules bankruptcy threshold (`money < bankrupt_limit`, default data value far below zero). It has no health/mood/fullness/energy recovery and does not mask another terminal dimension.

### 2. Overnight sleep — SAFE after GAME-FIX-007
`_sleep_through_night()` remains:
- advance overnight minutes;
- `_sync_needs_to_time()`;
- `_evaluate_terminal_state()`;
- only if non-terminal: health `+12`, mood `+8`, energy `100`.

No post-settlement sleep recovery can revive health/mood zero.

### 3. Standard location activities while `activity_running` — SAFE in their normal transaction order
Audited functions:
- `_on_home_activity()`
- `_do_work_shift()`
- `_do_negotiate()`
- `_on_park_activity()`
- `_on_cafe_activity()`
- `_on_hospital_activity()`
- `_on_alley_activity()`
- `_on_rooftop_activity()`

The common `_begin_activity()` sets `activity_running = true`, so the shared process evaluator is intentionally deferred while the activity presentation runs.

For each current activity, source ordering still does **not** contain the pre-FIX-007 pattern “settle pending need damage to terminal, then later in the same callback recover the same terminal dimension”:
- daytime home rest: recovery happens before its own 120-minute advance;
- meal: health/fullness recovery happens before its own 30-minute advance;
- study: mood only decreases; no later mood recovery in the callback;
- work: health/mood decrease before its time advance; no later health/mood recovery;
- failed negotiate: mood decreases; no later recovery;
- successful negotiate / park / cafe / hospital / alley / rooftop recovery happens before each activity's own time advance;
- all standard activities then call `_end_activity()` and return to the shared process path.

Thus the activity itself does not hide a terminal result with a later same-transaction recovery.

### 4. Event option mutation while EventUI is busy — SAFE as one atomic choice transaction
`_choose_option()` passes one state snapshot to either `EventSystem.apply_choice()` or `EncounterSystem.apply_choice()`, then writes the completed state back once through `_sync_from_state(st)`.

Both systems apply one option's effects to the supplied dictionary. They can change money/health/mood (plus non-terminal skill/network/flags/job), but there is no second reward/recovery phase after `_sync_from_state` inside `_choose_option()`.

`EventUI.show_result()` clears the option buttons and exposes only Continue. Therefore after a choice produces a terminal final state, the same event surface has no normal second survival-restoring choice before closure.

`_close_event()`:
- ordinary event: closes and returns without another survival mutation;
- encounter: closes first, advances encounter time, then returns. That extra time can only add pending need loss; it does not restore a terminal stat.

Delayed ending presentation while the result panel is visible is therefore presentation deferral, not a repository-proven revival path.

### 5. Dialog completion / NPC relation mood reward — SAFE in the normal dialog transaction
`NpcRelations.talk()` can return mood gain `0..3` depending on relationship tier, and `_on_dialog_finished()` applies it through `_apply_talk_result()`.

DialogUI behavior was checked:
- while visible, `dialog_ui.is_busy()` keeps game time paused and shared terminal presentation deferred;
- pressing the last line calls `close_dialog()` first and then emits `dialog_finished`;
- the dialog flow itself contains no health/mood/money/fullness/energy loss before the relation mood reward;
- clue completion only changes clue metadata.

Therefore an ordinary NPC conversation cannot create its own terminal mood state and then revive it with the relation reward.

### 6. Stage progression — SAFE
`_check_stage()` is before terminal evaluation in `_process`, so it was inspected specifically.

`StorySystem.check_and_advance_stage()` only updates `stage_idx` when a stage condition is satisfied. It does not mutate health, mood, money, fullness, or energy. It cannot mask a terminal value.

### 7. Day-change signal — SAFE
`time_sys.day_changed` is connected to `_on_day_changed(day)`.

That callback only resets `DailyRoutine` and shows a toast. It does not touch any audited survival value or annual age progression.

### 8. Save/load re-entry — SAFE under accepted FIX-004 + FIX-009 contract
`apply_save_payload()` can restore arbitrary saved survival values and intentionally clears stale `game_over`, then resets the time baseline and transient dialog/event state.

`_load_game()` closes the backpack before applying the payload, closes start/ending UI, refreshes presentation, and does not issue any reward/recovery mutation.

On the next settled non-busy `_process`, GAME-FIX-009 now guarantees terminal evaluation before quest rewards. `_check_stage()` before that evaluator is metadata-only as documented above. No newly found automatic survival mutation sits between load re-entry and that process terminal observation.

This preserves the accepted FIX-004 “clear stale latch, re-enter through the shared evaluator” contract; this audit does not propose a new load-specific death path.

### 9. Annual progression — SAFE under the already accepted atomic annual-settlement contract
`_year_pass()` calls `rules_sys.year_tick(st)`, writes the completed annual state back, and immediately invokes `_evaluate_terminal_state()` before annual result presentation.

`year_tick()` does contain income/cost, promotion/rehire/IPO bonuses and annual health/mood recovery, but those operations are the single annual settlement transaction. No player/UI callback can interleave between its internal calculations and `_year_pass()` terminal evaluation.

This remains the accepted GAME-FIX-003/005/008 contract and is not reclassified as an intermediate-threshold death path.

### 10. Lifecycle state replacement — intentional, not a bypass
The following intentionally replace/reset a run rather than mutate a continuing terminal run:
- `_choose_origin()` / `GameState.reset_from_origin()`;
- `_restart()` / `GameState.reset_default()`;
- `apply_save_payload()` re-entry as separately classified above.

They should not be treated as in-run revival mechanics.

## Runtime-only re-entry stress candidate — NOT a repository finding
There is still a narrow scheduling question around deferred elapsed-time settlement:
- `_on_location_travel()` and some other ordinary callbacks can call `time_sys.advance_minutes(...)` and rely on the next `_process()` for `_sync_needs_to_time()`;
- `LocationManager.travel_to()` refreshes the destination and emits `travel_requested` while `input_blocked` can remain false;
- at the cafe, destination spawn `(610, 470)` is already within 82px of the coffee interaction `(640, 485)`;
- a recovery activity sets `activity_running = true` at `_begin_activity()`, which would defer terminal presentation during its activity animation.

A theoretical sequence is therefore: travel leaves pending elapsed minutes -> a second input starts coffee before the next `Game._process()` -> the first process during the activity settles pending zero-energy mood damage to 0 but defers evaluator due `activity_running` -> coffee later adds mood `+6`.

**Why this is not promoted to a source finding here:** the critical edge requires the second UI/input callback to be delivered after the travel callback but before the next idle `Game._process()` pass. Repository inspection cannot establish that real Godot 4.7.2 input/idle scheduling plus the actual UI interaction produces that ordering for a player. Normal walking-to-spot paths run process frames before activation; the cafe spawn is the strongest stress case because it removes that walking gate, but it still needs real event-loop reproduction.

QA-002 may deliberately stress this exact ordering on the frozen integration SHA. If real runtime evidence proves it reachable, then the smallest repair should be designed from that evidence; this audit does **not** create a speculative source task.

## Concrete bypass decision
- New repository-proven terminal revival/masking bypass after GAME-FIX-009: **NONE FOUND**.
- New Gameplay source task proposed: **NONE**.
- Existing GAME-FIX-009 verifier should remain in QA-002's exact-SHA package.
- Suggested extra runtime stress (not a PASS requirement invented by this worker): travel-to-cafe pending need fraction near an hourly boundary, attempt immediate coffee activation before the next settled frame, and verify a terminal mood/health state cannot be revived. Record exact SHA and event ordering if reproduced.

## Validation actually performed
Performed:
- read latest coordination `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md`;
- confirmed GAME-FIX-009 repository acceptance at exact SHA `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`;
- confirmed audit branch initially matched current coordination exactly;
- inspected accepted GAME-FIX-009 `Game.gd` process, activity, shop, event, dialog, save/load, annual and quest ordering;
- inspected `Rules.gd` terminal authority/threshold flow;
- inspected `StorySystem.gd` stage mutations;
- inspected `NpcRelations.gd` mood reward behavior;
- inspected `EventSystem.gd` and `EncounterSystem.gd` choice mutation semantics;
- inspected `EventUI.gd` and `DialogUI.gd` busy/close signal sequencing;
- inspected `Inventory.gd` current item effects/time costs;
- inspected `LocationManager.gd` travel/input blocking behavior;
- inspected `SpotActivities.gd` activation/proximity/blocking behavior and cafe/hospital spot placement;
- inspected current event/origin data where needed to classify positive/negative mutation surfaces.

Not performed:
- Godot launch;
- verifier execution;
- local/Codex terminal execution;
- Web export;
- browser runtime/input scheduling test;
- screenshot/render validation;
- runtime PASS/FAIL claim.

## Known risks / boundaries
- This is a repository audit, not an engine scheduling proof. The sub-frame input candidate is intentionally left as runtime-only until QA-002 can establish actual ordering.
- Coordination remains metadata/control-plane oriented; future frozen integration must semantically assemble accepted Gameplay deltas rather than blindly stacking full historical branch snapshots.
- No terminal thresholds, death consumers, save fields, balance values, event effects, item effects, quest rewards, UI behavior, LocationManager behavior or NPC/content data were changed.

## Handoff
GAME-AUDIT-010 is complete and requests `NEEDS_REVIEW`.

Repository-level conclusion: GAME-FIX-009 closes the two accepted pre-observation mutation gaps, and this audit found no additional deterministic terminal revival/masking path in the accepted semantic state. Keep the cafe immediate-reentry scenario as an exact-SHA QA-002 runtime stress case rather than creating speculative Gameplay source work.