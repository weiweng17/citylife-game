# Gameplay Agent Report

## Task
- ID: GAME-FIX-003
- Agent: gameplay
- Branch/worktree: `agent/game-fix-003-terminal-state-evaluation`
- Status: NEEDS_REVIEW

## Scope
Centralize terminal-state evaluation only. Authorized files are `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression, and this report. No `main`, coordination files, `LocationManager.gd`, UI/NPC assets, data/schema, or unrelated gameplay systems were modified.

## Summary
`Game.gd` now has one authoritative `_evaluate_terminal_state()` path for consuming `Rules.death_reason()` and triggering the existing ending transition.

The evaluator:
1. returns immediately when `game_over` is already true, making repeated refresh/re-entry checks idempotent;
2. delegates all terminal thresholds and priority ordering to the existing `Rules.death_reason()` implementation;
3. routes the transition through the existing `_show_ending(reason, st)` path;
4. returns a boolean so callers can stop further frame/year work after a terminal transition.

Normal gameplay evaluates terminal state from `_process()` only when UI/activity interaction has settled (`not ui_busy`), so a terminal result is not opened underneath an active dialog/event/activity layer. Annual progression calls the same evaluator immediately after `Rules.year_tick()` and state synchronization, preserving the prior behavior where an annual terminal result suppresses the annual-summary toast.

## Changes
### `scripts/Game.gd`
- Added `_evaluate_terminal_state() -> bool` as the only direct `rules_sys.death_reason(...)` consumer in `Game.gd`.
- Replaced `_year_pass()`'s private death-reason block with the shared evaluator.
- Added a settled-frame evaluation after `_sync_needs_to_time()` in `_process()` so health/mood/financial terminal states caused outside annual settlement can reach the existing ending path.
- Added a `game_over` guard inside the evaluator to prevent duplicate ending transitions from repeated frame/re-entry evaluation.
- Did not alter `Rules.gd`, thresholds, ending selection, balance values, save schema, or progression data.

Primary implementation commit: `77fae0f8bf6139e932a7c77908941e4ce4143559` (`fix: centralize terminal-state evaluation`).

### `tools/verify_terminal_state_evaluation.gd`
A narrow regression already present on the assigned branch verifies the GAME-FIX-003 contract:
- exactly one direct `rules_sys.death_reason(...)` call site in `Game.gd`;
- `_evaluate_terminal_state()` owns that call and has a `game_over` guard;
- `_year_pass()` and `_process()` both route through the shared evaluator;
- a non-terminal state remains playable;
- zero health and zero mood still reach the existing ending UI;
- a second evaluation after `game_over` is idempotent and does not replace the ending text.

## Repository verification performed
Fresh GitHub inspection confirms the implementation commit's `Game.gd` diff is limited to:
- one settled-frame call to `_evaluate_terminal_state()`;
- replacement of the annual duplicate `death_reason` block with the shared call;
- the new evaluator function itself.

Fresh branch comparison against `orchestrator/multi-agent-bootstrap` shows only the task-owned source and regression paths before this report update:
- `scripts/Game.gd` — modified;
- `tools/verify_terminal_state_evaluation.gd` — added.

No unrelated source/data/scene/asset diff was observed.

## Runtime validation not performed
No Godot/Web/browser runtime was available in this web-agent execution. No runtime PASS is claimed.

Prepared focused command for QA/local execution:
`godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd`

Expected successful output ends with:
`GAME-FIX-003 PASS: terminal-state evaluation is centralized and idempotent`

Because GAME-FIX-001 and GAME-FIX-002 live on separate reviewed task branches, integration QA should run their regressions together on the exact integrated SHA rather than infer cross-task compatibility from this isolated branch.

## Integration note
This task branch is based on the current coordination branch and intentionally does not duplicate source changes from the separate GAME-FIX-001 / GAME-FIX-002 branches. The orchestrator should integrate the reviewed gameplay fixes onto one candidate SHA and run the combined headless gate there.

## Handoff
GAME-FIX-003 repository implementation and narrow regression package are ready for orchestrator review. Requested task status: `NEEDS_REVIEW`. Fresh Godot execution remains pending QA/local acceptance and must not be inferred from repository inspection.
