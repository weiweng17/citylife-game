# Gameplay Agent Report

## Task
- ID: GAME-FIX-009
- Agent: gameplay
- Branch/worktree: `agent/game-fix-009-terminal-mutation-order`
- Status: NEEDS_REVIEW

## Scope
Close the two repository-level terminal-observation gaps accepted from GAME-AUDIT-008 while preserving GAME-FIX-001..007 semantics.

Authorized paths used:
- `scripts/Game.gd`
- `tools/verify_terminal_mutation_order.gd`
- `agent-reports/gameplay.md`

No coordination file, `main`, UI/LocationManager/NPC/data/save-schema file, workflow, or balance data was modified.

## Baseline / dependency handling
The 009 branch was created from current coordination SHA `86ea90c9742b31c8d562199f873ea0d0a6ca5a95`, whose `Game.gd` is still metadata-era/stale and does not contain the accepted authoritative evaluator stack.

To avoid reimplementing accepted history against a stale file, the branch first replaced only `scripts/Game.gd` with the exact accepted GAME-FIX-007 final blob:
- accepted GAME-FIX-007 SHA: `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344`
- accepted `scripts/Game.gd` blob: `32b76594b8e66c35b846c855e4f626d96198d10e`
- semantic-base commit on this branch: `ee48ff95da4c7f9821368f2eaee1ccf5f6c9bd0c`

This copied only the authorized `Game.gd` tree entry; it did not import GAME-FIX-007's report, verifier, or coordination history.

## Implementation

### 1. Settled-frame terminal observation now precedes quest rewards
Source commit:
- `f6356a70afcb8422bc5504df5b979ad94b349b6c`

`_process(delta)` no longer runs `_evaluate_quests()` before time/needs settlement.

The non-busy settled-frame order is now:
1. compute UI/activity busy state;
2. tick time;
3. `_sync_needs_to_time()`;
4. `_evaluate_terminal_state()`;
5. only if still playable, `_evaluate_quests()`.

Quest evaluation is also deferred while UI/activity is busy, matching the existing policy that ending presentation is deferred while busy. This prevents q1/q2/q3 positive rewards from mutating mood/money/fullness before an already-terminal or just-settled terminal state is observed.

No quest reward amount/content was changed.

### 2. Shop item time is synchronously settled/evaluated
`_on_shop_use(item_id)` now:
- rejects immediately when `game_over` is already true;
- preserves the existing item removal/effect application and time cost;
- immediately after `advance_minutes(minutes)`, calls `_sync_needs_to_time()`;
- then calls the existing `_evaluate_terminal_state()`;
- if terminal, closes the persistent shop/backpack panel, refreshes UI, and returns before normal continued item-use flow;
- if non-terminal, preserves the existing daily meal bookkeeping, shop refresh/status text, and continued-open backpack behavior.

This closes the accepted deterministic bypass where a first item advances enough time for zero-fullness need settlement to take health to 0 while the backpack remains open, followed by milk/cold medicine reviving health before the evaluator runs.

No item effect, item time cost, price, inventory schema, terminal threshold, or new death path was added.

### 3. Authoritative terminal path remains single-source
`Rules.death_reason()` is still consumed only inside `_evaluate_terminal_state()` in `Game.gd`.

GAME-FIX-007 overnight ordering remains unchanged:
`advance time -> _sync_needs_to_time() -> _evaluate_terminal_state() -> non-terminal sleep recovery`.

GAME-FIX-001 annual separation, GAME-FIX-002 hourly zero-need cadence, GAME-FIX-003 centralized evaluator, and GAME-FIX-004 save/load latch reset remain present in the assembled `Game.gd` semantic base.

## Regression package
Added:
- `tools/verify_terminal_mutation_order.gd`
- commit: `386734e5a3b1d65b16412fb65568893a4e45a763`

Prepared checks include:
1. static assertion that `rules_sys.death_reason(...)` remains centralized;
2. static `_process` order: needs settlement -> terminal evaluator -> quest evaluation;
3. static shop order: game-over guard -> item time -> need settlement -> evaluator -> normal completion;
4. static preservation of GAME-FIX-007 sleep ordering;
5. runtime-prepared q1-ready `mood == 0` case: q1 `mood +8` must not revive terminal mood;
6. runtime-prepared pending zero-energy need settlement case: mood reaches 0 before q1 reward;
7. healthy q1 completion still grants the existing `+8 mood` reward;
8. backpack case: canned-coffee elapsed time can make health terminal, backpack must close, then cold medicine must not consume or revive after `game_over`;
9. normal milk use still gives `health +4`, consumes one item, costs 6 minutes, and leaves the non-terminal backpack open.

Prepared command, **not run by this web worker**:

```bash
godot --headless --path . --script res://tools/verify_terminal_mutation_order.gd
```

Expected success line if an actual Godot run passes:

```text
GAME-FIX-009 PASS: settled terminal states precede quest rewards and repeated backpack recovery
```

For QA-002, run this only on the same frozen integration SHA as the previously accepted Gameplay regressions; any SHA movement invalidates the evidence.

## Repository validation actually performed
Performed:
- read latest TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, current task branch report;
- confirmed GAME-AUDIT-008 accepted and GAME-FIX-009 exact writable scope;
- confirmed initial 009 branch matched coordination (`ahead 0 / behind 0` at `86ea90c...`);
- confirmed coordination `Game.gd` lacked `_evaluate_terminal_state()` and therefore could not safely receive 009 in isolation;
- copied only the accepted GAME-FIX-007 `Game.gd` blob into the current coordination-derived branch;
- reviewed the exact source patch for `f6356a70...`; the task-specific code delta is limited to `_process()` and `_on_shop_use()`;
- reviewed the new narrow verifier source;
- reviewed branch scope against coordination.

Not performed:
- Godot launch;
- verifier execution;
- terminal/Codex execution;
- Web export;
- browser execution;
- runtime screenshot/render evidence.

No runtime PASS is claimed.

## Final branch-scope state before handoff
Before this report commit, comparison against `orchestrator/multi-agent-bootstrap` was:
- ahead: 3
- behind: 0
- changed paths: `scripts/Game.gd`, `tools/verify_terminal_mutation_order.gd` only.

After this report commit the expected authorized path set is exactly:
- `scripts/Game.gd`
- `tools/verify_terminal_mutation_order.gd`
- `agent-reports/gameplay.md`

## Handoff
GAME-FIX-009 repository implementation is complete and requests `NEEDS_REVIEW`.

The two accepted GAME-AUDIT-008 mutation-order bypasses are closed at repository level through the existing authoritative evaluator. Real acceptance still requires QA-002/Codex execution on one frozen integration SHA.