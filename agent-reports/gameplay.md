# Gameplay Agent Report

## Task
- ID: GAME-FIX-006
- Agent: gameplay
- Branch/worktree: `agent/game-fix-006-integration-callsite-guard-audit`
- Status: NEEDS_REVIEW

## Scope
Report-only audit of the coordination baseline plus accepted GAME-FIX-001..004 behavior. Per TASK_BOARD, only this report is writable.

No source, regression, task-board, orchestration, scene, UI, NPC/content, build, or `main` file was modified. No Godot/Web/browser/runtime execution was performed or claimed.

## Exact repository state inspected
- Coordination/task branch baseline: `4249687c2c20a5680ed5914c01f4f55665d397d9`
- Accepted GAME-FIX-001 tip recorded by GAME-FIX-005: `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7`
- Accepted GAME-FIX-002 tip recorded by GAME-FIX-005: `ef88708a3ab120da4129fea7e0efad125fb7b0a6`
- Accepted GAME-FIX-003 tip recorded by GAME-FIX-005: `9ae0e807a59cba366a6013f61f22ab8d76000c82`
- Accepted GAME-FIX-004 tip recorded by GAME-FIX-005: `20d80444487074be89a7cf80cf078f6f36a98a32`

The coordination baseline still contains stale pre-integration `Game.gd` behavior. That baseline is used only to inventory current callsites; accepted task branches define Contracts A-D that the eventual integration candidate must preserve.

## Callsite inventory

### 1. Annual progression (`_year_pass`)
Repository-visible callsites relevant to GAME-FIX-001 are:

1. `_enter_place(d)` dark-story branch: `dark_result.get("pass_year", false)` -> `_year_pass()`.
   - This is an explicit story-owned annual path and is allowed by Contract A.
2. `_enter_place(d)` ordinary `events_sys.pick(...) == null` branch.
   - Coordination baseline still calls `_year_pass()` here.
   - Accepted GAME-FIX-001 removes this call. This is stale coordination behavior, not a new uncovered defect.
3. `_interior_boss()` ordinary office no-event branch.
   - Coordination baseline still calls `_year_pass()` here.
   - Accepted GAME-FIX-001 removes this call. Again, stale baseline only.
4. `_close_event()` ordinary event close path.
   - Coordination baseline falls through to `_year_pass()`.
   - Accepted GAME-FIX-001 changes ordinary close to `return`; encounter close remains minute-based. Stale baseline only.

No additional direct `_year_pass()` callsite was found in the inspected `Game.gd` content beyond the explicit dark-story route and the three stale paths already owned by GAME-FIX-001.

### 2. Need settlement (`_sync_needs_to_time`)
Direct callsites are:

1. `_process(delta)` after `time_sys.tick(delta)`.
   - On accepted GAME-FIX-003, terminal evaluation follows this need settlement once UI/activity state is settled.
2. `_sleep_through_night()` after `time_sys.advance_minutes(minutes)` and before sleep recovery (`health +12`, `mood +8`, `energy = 100`).
   - This is a separate direct settlement callsite outside `_process()`.

GAME-FIX-002 correctly places zero-fullness health penalty and zero-energy mood penalty inside the completed-hour loop. However, the sleep callsite creates a new integration guard concern described below.

### 3. Terminal evaluation (`_evaluate_terminal_state`)
Accepted GAME-FIX-003 has two direct evaluator callsites:

1. `_process(delta)` after `_sync_needs_to_time()`, gated by settled/non-busy UI state.
2. `_year_pass()` immediately after `rules_sys.year_tick(st)` and `_sync_from_state(st)`.

Within accepted GAME-FIX-003, `_evaluate_terminal_state()` is the only direct `rules_sys.death_reason(st)` consumer in `Game.gd`; it owns the `game_over` idempotency guard and routes presentation to `_show_ending(reason, st)`.

No extra direct `death_reason()` consumer was found in the accepted GAME-FIX-003 source inspected for this audit.

### 4. Save/load re-entry
Relevant paths are:

1. HUD setup: `hud.load_requested.connect(_load_game)`.
2. Start screen setup: `start_ui.load_requested.connect(_load_game)`.
3. `_load_game()` reads the save, closes transient shop UI, then calls `apply_save_payload(result.get("payload", {}))`.
4. `apply_save_payload(payload)` replaces game state/system state and resets runtime latch state including `game_over = false` and `game_started = true`.
5. `_load_game()` then closes start/ending UI and refreshes UI; it does not directly call `death_reason()` or `_show_ending()` in the accepted contract.
6. A later settled `_process()` is therefore the normal post-load terminal evaluation route through `_evaluate_terminal_state()`.

Both user-facing load triggers converge on the same `_load_game()` implementation; no alternate UI-specific load path was found. This matches GAME-FIX-004's regression contract; no second save-specific ending path was found.

### 5. Ending presentation (`_show_ending`) and terminal-latch reset boundaries
On accepted GAME-FIX-003, `_show_ending(reason, st)` is called only from `_evaluate_terminal_state()`.

`_show_ending` itself sets `game_over = true` before resolving/presenting the ending, which is consistent with the evaluator's re-entry guard.

Intentional `game_over = false` lifecycle boundaries observed in accepted source are:

1. `_show_start_screen()` — clears the prior run when returning to the start lifecycle.
2. `_choose_origin()` — starts a new origin/run and clears the terminal latch.
3. `apply_save_payload()` — replaces the runtime with loaded state and clears the old run's terminal latch before shared re-evaluation.

EndingUI `restart_requested` routes through `_restart()`, which closes the ending and returns through `_show_start_screen()` rather than creating a second ending transition path.

These reset sites are lifecycle replacement paths, not terminal-evaluation bypasses. No separate direct ending presentation callsite was found in the inspected accepted source.

## Concrete uncovered guard gap
A repository-visible bypass remains around sleep settlement:

`_sleep_through_night()` performs this semantic order:

1. advance game time to morning;
2. call `_sync_needs_to_time()`;
3. then add sleep recovery (`health + 12`, `mood + 8`, `energy = 100`);
4. only later can the settled `_process()` path call `_evaluate_terminal_state()`.

Under GAME-FIX-002, `_sync_needs_to_time()` can reduce `health` or `mood` to `0` during the completed-hour loop. `Rules.death_reason()` treats `health <= 0` and `mood <= 0` as terminal. Because sleep recovery occurs before the shared evaluator sees that state, a terminal value reached during overnight need settlement can be raised above zero and therefore disappear before Contract C's `_process()` evaluation.

This is not the same stale-baseline problem as GAME-FIX-001/002/003. It survives the accepted contracts because the sleep function is a second direct need-settlement callsite that GAME-FIX-003's settled-frame evaluator does not observe until after recovery.

There is an additional guard reason this cannot be assumed to be caught concurrently by `_process()`: home rest runs under the shared `activity_running` lock, and GAME-FIX-003 defines `ui_busy = ui_busy or activity_running`; its process evaluator runs only when `not ui_busy`. Therefore the activity frame cannot reliably observe the temporary zero between sleep need settlement and sleep recovery.

### Minimal reproducible state sequence (repository reasoning; not runtime execution)
A narrow case can be constructed without changing balance values:
- enter `_sleep_through_night()` with sufficiently low `health` (or `mood`) and zero fullness (or zero energy);
- overnight elapsed hours make GAME-FIX-002 apply enough per-hour zero-need penalties for health/mood to reach `0` inside `_sync_needs_to_time()`;
- `_sleep_through_night()` then applies `health +12` / `mood +8` before any `_evaluate_terminal_state()` call;
- subsequent `_process()` observes the recovered non-terminal value and cannot know that a terminal threshold was crossed.

Expected Contract-C-consistent behavior: terminal state produced by need settlement must be observed by the authoritative evaluator before later same-flow recovery can erase it.

Observed repository call order: evaluator is not called between sleep's `_sync_needs_to_time()` and recovery.

## Recommended minimal follow-up
Recommend a new gameplay task only for this concrete bypass:

### Proposed GAME-FIX-007 — Sleep settlement terminal guard
Suggested writable boundary:
- `scripts/Game.gd`
- one narrow `tools/verify_*.gd` regression
- `agent-reports/gameplay.md`

Suggested objective:
Preserve existing sleep duration/recovery values and all Contracts A-D, but ensure overnight `_sync_needs_to_time()` cannot cross a terminal threshold and then be silently revived by sleep recovery before the authoritative terminal evaluator runs.

Smallest likely source shape:
- immediately after the sleep-specific `_sync_needs_to_time()` call, route through the existing `_evaluate_terminal_state()`;
- if terminal, return without applying sleep recovery;
- in `_on_home_activity()`, if the overnight helper returns with `game_over`, finish/unlock the activity and return without normal post-sleep toast/completion flow;
- otherwise keep the existing health/mood/energy recovery unchanged.

Do not introduce a sleep-specific `death_reason()` call, duplicate thresholds, new save fields, or a second ending presentation path.

A narrow regression should prove:
1. overnight need settlement that reaches a health terminal threshold routes once through the shared evaluator before recovery;
2. the same is true for a mood terminal threshold;
3. non-terminal overnight sleep still receives the existing recovery values and remains playable; and
4. repeated terminal evaluation remains idempotent.

## Existing regressions and why they do not close the gap
- `verify_need_zero_cadence.gd` validates hourly penalty cadence and repeated `_sync_needs_to_time()` behavior, but does not execute overnight sleep recovery.
- `verify_terminal_state_evaluation.gd` validates centralized evaluation/idempotency on explicit terminal states, but does not exercise `_sleep_through_night()` between need settlement and recovery.
- `verify_save_terminal_reentry.gd` covers loaded terminal/non-terminal state re-entry, not overnight need settlement.

A dedicated overnight regression is therefore warranted rather than stretching the existing task regressions beyond their original contracts.

## Integration guard summary
After assembling GAME-FIX-001 -> 002 -> 003 and adding GAME-FIX-004 regression coverage, the combined candidate should satisfy:

- ordinary no-event/event-close flows do not reach `_year_pass()`;
- only explicit annual story flow reaches `_year_pass()` among the audited event paths;
- zero-need penalties remain inside the completed-hour loop;
- `_process()` preserves `_sync_needs_to_time()` -> `_evaluate_terminal_state()` ordering;
- `_year_pass()` uses the same evaluator;
- HUD and StartUI load requests both converge on `_load_game()`;
- `_load_game()` / `apply_save_payload()` do not create a second ending path;
- `_show_ending()` is reachable from gameplay terminal logic only through `_evaluate_terminal_state()`;
- `game_over` resets only at intentional new-run/start/load lifecycle replacement boundaries identified above;
- additionally, the newly identified sleep-specific need-settlement path must not erase a terminal crossing before shared evaluation.

## Validation
No Godot process, browser, Web export, local terminal, CI, or headless verifier was run in this report-only task.

Prepared future regression command if GAME-FIX-007 is authorized and its verifier is added:

```bash
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

It must be run on the exact integrated candidate SHA together with the existing gameplay package:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
```

No PASS is claimed for any command above.

## Handoff
GAME-FIX-006 repository audit is complete and requests `NEEDS_REVIEW`.

Unlike the stale coordination callsites already covered by GAME-FIX-001..003, the sleep settlement ordering is a concrete uncovered path and should be split into the minimal GAME-FIX-007 source repair described above by the orchestrator. Until then, do not change gameplay source from this report-only branch.