# Gameplay Agent Report

## Task
- ID: GAME-FIX-007
- Agent: gameplay
- Branch/worktree: `agent/game-fix-007-sleep-terminal-guard`
- Status: NEEDS_REVIEW

## Scope
Implement the narrow overnight sleep terminal guard identified by GAME-FIX-006, while preserving the accepted GAME-FIX-001..004 gameplay contracts.

Writable paths used:
- `scripts/Game.gd`
- `tools/verify_sleep_terminal_guard.gd`
- `agent-reports/gameplay.md`

No coordination file, scene/UI file, `LocationManager.gd`, save schema, data file, workflow, or `main` file was modified.

## Repository baseline and dependency handling
The task branch was created from the current coordination SHA:
- `orchestrator/multi-agent-bootstrap`: `e60060cd559c46ff73af81354fafa50e3a8a7245`
- initial `agent/game-fix-007-sleep-terminal-guard`: `e60060cd559c46ff73af81354fafa50e3a8a7245`

That coordination SHA still carries pre-integration `scripts/Game.gd`; it does not contain the source deltas already accepted in GAME-FIX-001/002/003. A sleep guard that simply called `_evaluate_terminal_state()` on that stale baseline would therefore be invalid because the authoritative evaluator does not exist there.

Following QA-006's deterministic integration rule, this branch composes the accepted gameplay source contracts in task order and then adds GAME-FIX-007. It does **not** merge historical worker branches wholesale or import their coordination/report history.

Accepted dependency tips used as semantic references:
- GAME-FIX-001: `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7`
- GAME-FIX-002: `ef88708a3ab120da4129fea7e0efad125fb7b0a6`
- GAME-FIX-003: `9ae0e807a59cba366a6013f61f22ab8d76000c82`
- GAME-FIX-004: `20d80444487074be89a7cf80cf078f6f36a98a32` — regression/report only relative to FIX-003; no additional `Game.gd` source semantics.

## Implementation

### Preserved accepted contracts
The resulting `Game.gd` keeps all required prior behavior together:

1. **GAME-FIX-001 — daily event / annual separation**
   - ordinary `_enter_place()` no-event path no longer advances a year;
   - ordinary `_interior_boss()` no-event path no longer advances a year;
   - ordinary `_close_event()` returns without `_year_pass()`;
   - explicit dark-story `pass_year` still reaches `_year_pass()`.

2. **GAME-FIX-002 — completed-hour zero-need cadence**
   - zero-fullness health damage and zero-energy mood damage remain inside the `while need_fraction >= 1.0` loop;
   - balance values remain unchanged.

3. **GAME-FIX-003 — authoritative terminal evaluator**
   - `_process()` settles needs first and then, once non-busy, calls `_evaluate_terminal_state()`;
   - `_year_pass()` uses the same evaluator;
   - `_evaluate_terminal_state()` remains the only direct `rules_sys.death_reason(...)` consumer in `Game.gd` and retains the `game_over` idempotency guard;
   - ending presentation still routes through `_show_ending()`.

4. **GAME-FIX-004 — save/load re-entry contract**
   - `apply_save_payload()` still clears the stale `game_over` latch and restores `game_started = true`;
   - `_load_game()` still has no direct death/ending path; post-load settlement uses the shared evaluator through the gameplay loop;
   - no save field/schema was added.

### GAME-FIX-007 — overnight settlement guard
`_sleep_through_night()` now performs:

1. existing overnight time advance;
2. existing `_sync_needs_to_time()` settlement;
3. **immediate `_evaluate_terminal_state()` through the existing authoritative path**;
4. if terminal, return before any sleep health/mood/energy recovery;
5. if non-terminal, retain the existing `health +12`, `mood +8`, `energy = 100` recovery and wake feedback unchanged.

The night-rest caller `_on_home_activity()` now checks `game_over` immediately after `_sleep_through_night()`. If terminal, it calls `_end_activity()` to release the active activity state and then returns, so the normal wake/completion toast path is not executed. `_end_activity()` retains `game_over` in its `still_busy` calculation, so ending-state input remains blocked even though `activity_running` itself is safely cleared.

No new terminal threshold, direct `death_reason()` call, save field, ending presentation route, annual progression behavior, or sleep balance value was introduced by GAME-FIX-007.

## Regression package
Added `tools/verify_sleep_terminal_guard.gd`.

The verifier is prepared to check both source contract and runtime behavior:
- `death_reason()` remains centralized;
- sleep ordering is `_sync_needs_to_time()` -> `_evaluate_terminal_state()` -> recovery;
- terminal sleep returns before recovery;
- `_on_home_activity()` releases the activity and returns on `game_over`;
- health reaching zero during overnight zero-fullness settlement is not revived by `+12`;
- mood reaching zero during overnight zero-energy settlement is not revived by `+8`;
- repeated terminal evaluation remains idempotent;
- a healthy non-terminal overnight sleep still receives the original +12 health / +8 mood / energy-to-100 recovery and remains playable.

Prepared command, **not run by this web agent**:

```bash
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

Expected success summary if a real Godot run passes:

```text
GAME-FIX-007 PASS: overnight settlement observes terminal thresholds before sleep recovery
```

For final integration QA, run this on the same exact integrated candidate SHA together with the existing gameplay package:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

No PASS is claimed for any command above.

## Self-review / diff hygiene
An early intermediate write on this branch reformatted too much of `Game.gd`; it was immediately superseded before handoff. The final source tree restores the accepted file formatting and the coordination-to-branch `Game.gd` diff is limited to the cumulative accepted gameplay contracts plus the new sleep guard (33 additions / 10 deletions at the source-review point), not a wholesale rewrite.

Review the final tree/branch diff rather than the transient intermediate commit.

## Validation actually performed
Performed:
- read latest TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, MASTER_PLAN, AGENT_RULES and HANDOFF;
- inspected the current coordination/task branch base;
- inspected QA-006 integration-order guidance and QA-008's sleep-gap handoff;
- inspected accepted GAME-FIX-003 source and reconstructed the previously accepted 001/002/003 semantics without merging whole worker branches;
- repository-level source/call-order review;
- branch diff review during implementation.

Not performed:
- Godot launch;
- headless verifier execution;
- Web export;
- browser execution;
- local terminal/CI execution;
- runtime screenshot/render validation.

## Known integration risk
Because the coordination branch still lacks the accepted gameplay source deltas, this branch's `Game.gd` diff versus coordination necessarily contains GAME-FIX-001/002/003 semantics in addition to the new 007 guard. The task-specific GAME-FIX-007 delta is only the sleep helper/caller guard plus `verify_sleep_terminal_guard.gd` and this report.

The orchestrator should treat this branch as a focused gameplay integration-ready candidate for Contracts A-D + sleep guard, not as evidence that historical worker branches can now be merged wholesale. Final acceptance still requires all six gameplay regressions on one exact integrated SHA in a real Godot environment.

## Handoff
GAME-FIX-007 repository implementation is complete and requests `NEEDS_REVIEW`.

The sleep-specific bypass identified by GAME-FIX-006 is now closed at repository level: overnight need settlement must be observed by the existing authoritative evaluator before sleep recovery can raise health/mood again, while normal non-terminal sleep keeps its existing duration and recovery values.