# Gameplay Agent Report

## Task
- ID: GAME-FIX-005
- Agent: gameplay
- Branch/worktree: `agent/game-fix-005-integration-contract-audit`
- Status: NEEDS_REVIEW

## Scope
Repository-only gameplay integration contract audit for orchestrator-accepted `GAME-FIX-001` through `GAME-FIX-004`.

Per the task contract, this task modifies only `agent-reports/gameplay.md`. No source, regression, coordination, data, scene, asset, workflow, `main`, or task-board file was modified.

No Godot/Web/browser/runtime execution was performed or claimed.

## Captured repository state
Coordination branch and this audit branch started from the same exact commit:
- `orchestrator/multi-agent-bootstrap`: `ecb3b9331ef1b94095529a083c12636e47983176`
- initial `agent/game-fix-005-integration-contract-audit`: `ecb3b9331ef1b94095529a083c12636e47983176`

Accepted gameplay task tips inspected:

| Task | Branch | Captured tip | Source delta class |
| --- | --- | --- | --- |
| GAME-FIX-001 | `agent/game-fix-001-daily-event-separation` | `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7` | `Game.gd` event/year routing + regression/report |
| GAME-FIX-002 | `agent/game-fix-002-need-zero-cadence` | `ef88708a3ab120da4129fea7e0efad125fb7b0a6` | `Game.gd` need cadence + regression/report |
| GAME-FIX-003 | `agent/game-fix-003-terminal-state-evaluation` | `9ae0e807a59cba366a6013f61f22ab8d76000c82` | `Game.gd` centralized terminal evaluation + regression/report |
| GAME-FIX-004 | `agent/game-fix-004-save-terminal-reentry` | `20d80444487074be89a7cf80cf078f6f36a98a32` | descendant of FIX-003; adds save/re-entry regression + report only |

Important: accepted task status does not mean the source deltas are already present on the coordination branch. At the captured coordination SHA, `scripts/Game.gd` still shows the pre-repair behavior: ordinary no-event/event-close paths can call `_year_pass()`, zero-need penalties sit outside the completed-hour loop, and `_year_pass()` still consumes `rules_sys.death_reason()` directly. That is an integration-state fact, not a new gameplay defect beyond GAME-FIX-001/002/003.

## Smallest authoritative gameplay contract
An integration candidate is gameplay-correct for this repair wave only if it preserves all of the following simultaneously.

### Contract A — daily event closure is not annual progression
Owned by GAME-FIX-001.

1. `func _enter_place(d: Dictionary) -> void`
   - the normal `events_sys.pick(...) == null` path may show its toast and return;
   - it must **not** call `_year_pass()`.
2. `func _interior_boss() -> void`
   - the normal office no-event path may show its toast and return;
   - it must **not** call `_year_pass()`.
3. `func _close_event() -> void`
   - encounter close may advance its explicit minute cost and return;
   - ordinary event close must return without annual progression.
4. Explicit story-owned annual progression remains callable. In particular, the existing dark-story `pass_year` branch may still call `_year_pass()`.
5. `_year_pass()` remains the annual settlement entry; FIX-001 does not remove or redesign it.

### Contract B — zero-need penalties occur once per completed gameplay hour
Owned by GAME-FIX-002.

`func _sync_needs_to_time() -> void` must retain the existing accumulator model:
- add elapsed minute delta into `need_fraction`;
- while `need_fraction >= 1.0`, subtract one accumulated hour, drain fullness/energy by the existing values, and apply the existing zero-fullness health penalty / zero-energy mood penalty **inside that same completed-hour loop**;
- keep the existing warning call after settlement.

The accepted effective delta is only this cadence move. A transient comment change near `_is_sleep_hour()` was explicitly reverted before the final task tip and is not part of the integration contract.

### Contract C — one authoritative terminal-state evaluator
Owned by GAME-FIX-003.

1. `func _evaluate_terminal_state() -> bool` is the only direct `rules_sys.death_reason(...)` consumer in `Game.gd`.
2. It must retain the `game_over` idempotency guard before recomputing or reopening an ending.
3. Thresholds and reason priority remain delegated to `Rules.death_reason()`; do not duplicate health/mood/money/age thresholds in `Game.gd`.
4. Ending presentation still routes through the existing `_show_ending(reason, st)` path.
5. `func _year_pass() -> void` must call the shared evaluator after `rules_sys.year_tick(st)` and `_sync_from_state(st)` instead of maintaining its own death-reason block.
6. `func _process(delta: float) -> void` must perform `_sync_needs_to_time()` first, then—once the interaction/UI state is settled—call `_evaluate_terminal_state()` and return when terminal.

The ordering in point 6 is part of the cross-task contract: a completed-hour zero-need penalty from GAME-FIX-002 can reduce health/mood to terminal, and GAME-FIX-003 must see that updated state in the same settled gameplay pass.

### Contract D — save/load re-entry uses the same evaluator, not a save-specific ending path
Owned by GAME-FIX-004 as an inherited-contract regression, not a new `Game.gd` source delta.

1. `apply_save_payload(payload)` must continue clearing the stale runtime `game_over` latch and restoring `game_started = true` after state replacement.
2. `_load_game()` must continue routing replacement through `apply_save_payload()`.
3. `_load_game()` must not add a second direct `death_reason()` or `_show_ending()` path.
4. After load, the settled gameplay loop from Contract C evaluates the loaded state through `_evaluate_terminal_state()`.
5. Once a terminal state is settled, repeated refresh/process/evaluator re-entry must remain idempotent because of the shared `game_over` guard.
6. Loading a later non-terminal payload must be able to clear the previous runtime terminal latch and resume play.
7. No new save field is required; `build_save_payload()` schema remains unchanged by GAME-FIX-004.

## Function-level collision / dependency map

| Function / area | FIX-001 | FIX-002 | FIX-003 | FIX-004 | Integration meaning |
| --- | --- | --- | --- | --- | --- |
| `_enter_place()` | removes normal no-event `_year_pass()` | — | — | — | preserve FIX-001; keep explicit dark `pass_year` route |
| `_interior_boss()` | removes no-event `_year_pass()` | — | — | — | preserve FIX-001 |
| `_close_event()` | ordinary close returns instead of `_year_pass()` | — | — | — | preserve FIX-001 |
| `_sync_needs_to_time()` | — | moves zero penalties inside hourly loop | called immediately before terminal evaluation | observed by regression | semantic dependency, not same-function source collision |
| `_process()` | — | state producer is `_sync_needs_to_time()` | adds settled-frame `_evaluate_terminal_state()` after need sync | post-load settlement depends on it | preserve order: need sync → evaluator |
| `_year_pass()` | remains explicit annual entry, adjacent to FIX-001 `_close_event()` change | — | replaces direct `death_reason()` block with shared evaluator | inherits | likely patch-context collision near FIX-001, but contracts are compatible |
| `_evaluate_terminal_state()` | — | — | new authoritative evaluator | inherited/verified | only direct `death_reason()` call in `Game.gd` |
| `apply_save_payload()` | — | — | existing baseline behavior | relies on `game_over = false`, `game_started = true` | no new source edit required |
| `_load_game()` | — | — | existing baseline behavior | relies on payload route + no direct ending check | no new source edit required |

### Collision interpretation
- **FIX-001 vs FIX-003:** both touch the event/year neighborhood of `Game.gd`, but their accepted semantic edits are compatible. FIX-001 owns whether ordinary event flows reach `_year_pass()`; FIX-003 owns what `_year_pass()` does once it is explicitly called. Do not resolve a nearby patch conflict by restoring `_year_pass()` to ordinary event closure or by dropping the shared evaluator.
- **FIX-002 vs FIX-003:** no accepted same-function edit, but there is a deliberate producer/consumer dependency. `_sync_needs_to_time()` must finish the hourly health/mood update before `_evaluate_terminal_state()` runs in `_process()`.
- **FIX-003 vs FIX-004:** FIX-004 is a descendant of the accepted FIX-003 line. Comparing FIX-003 → FIX-004 shows no new `Game.gd` file delta; FIX-004 adds its own regression/report. Do not transplant FIX-004 as if it contained a second terminal implementation.
- **FIX-001 vs FIX-002:** independent accepted source areas; preserve both.

## Inherited branch history vs task delta
Integration must not merge worker branches wholesale.

- Each worker branch contains its fork-point history and its own report history; those inherited commits are not automatically product deltas.
- GAME-FIX-001 task delta is the event/year routing change plus `verify_event_year_separation.gd`.
- GAME-FIX-002 task delta is the final effective `_sync_needs_to_time()` indentation/cadence change plus `verify_need_zero_cadence.gd`; the unrelated sleep-comment drift was reverted and must not be reintroduced.
- GAME-FIX-003 task delta is the `_process()` settled terminal call, `_year_pass()` shared evaluator call, the new `_evaluate_terminal_state()` function, plus `verify_terminal_state_evaluation.gd`.
- GAME-FIX-004 inherits GAME-FIX-003 source history. Its own delta relative to the accepted FIX-003 tip is `tools/verify_save_terminal_reentry.gd` plus its worker report; no new `Game.gd` semantics belong to FIX-004.
- Coordination/task-board/orchestrator-report differences carried by historical branch bases are metadata noise for product integration and remain orchestrator-owned.

## Required dependency/application order
For one fresh integration candidate, apply accepted gameplay **task deltas**, not whole branch tips:

1. GAME-FIX-001 event/year-routing delta.
2. GAME-FIX-002 hourly need-penalty delta while retaining step 1.
3. GAME-FIX-003 centralized terminal-evaluation delta while retaining steps 1-2.
4. Add GAME-FIX-004's save/load re-entry regression package; no additional gameplay source transplant is required from FIX-004.

This is consistent with QA-006, but the function-level reason is explicit here: FIX-003's `_process()` contract consumes the state produced by FIX-002, and its `_year_pass()` contract must coexist with FIX-001's restriction on which flows are allowed to call annual settlement.

## Minimal gameplay verification package for the integrated SHA
Prepared commands only; **not run by this web agent**:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
```

All five must be run on the **same exact integrated candidate SHA**. A PASS on isolated worker tips is insufficient to prove the combined `Game.gd` contract.

After the narrow gameplay package passes, QA may run the broader shared headless gate defined by QA-006. This report does not replace QA-006's build/runtime acceptance responsibilities.

## Repository-visible gap assessment
No new gameplay repair is recommended from this repository-only audit.

Reason:
- the four accepted task contracts are mutually compatible at function level;
- the only source-overlap risk is integration/reconciliation of separate historical `Game.gd` branches, not a missing gameplay rule;
- GAME-FIX-004 intentionally closes the save/load re-entry coverage gap with a regression package rather than a duplicate source path;
- the current coordination branch still showing pre-repair `Game.gd` behavior means the accepted deltas have not yet been assembled into an integration candidate. That is an integration task, not evidence that a fifth source repair is required.

Open a new GAME-FIX only if the future combined candidate cannot satisfy one of Contracts A-D simultaneously or a repository/runtime regression exposes a concrete new semantic mismatch. Do not pre-emptively redesign thresholds, save schema, annual progression, need balance, or ending behavior.

## Runtime validation not performed
No Godot process, browser, Web export, local terminal command, or CI execution was available/performed in this task. No runtime PASS is claimed.

Repository evidence only was used: task-board contracts, accepted branch tips, accepted source commit diffs, branch lineage comparison, current coordination `Game.gd`, and QA-006's repository conflict manifest.

## Handoff
GAME-FIX-005 repository audit is complete and requests `NEEDS_REVIEW`.

For integration, preserve Contracts A-D exactly, apply gameplay deltas in 001 → 002 → 003 order, include FIX-004's regression without treating its inherited FIX-003 history as a new source patch, and run the five narrow gameplay checks on one recorded exact candidate SHA before promotion.