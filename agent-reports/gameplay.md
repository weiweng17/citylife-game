# Gameplay Agent Report

## Task
- ID: GAME-FIX-001
- Agent: gameplay
- Branch/worktree: `agent/game-fix-001-daily-event-separation`
- Status: IN_PROGRESS

## Scope
Separate regular event/no-event closure from annual progression. Authorized files: `scripts/Game.gd`, one narrowly scoped `tools/verify_*.gd` regression, and this report.

## Findings
- Confirmed the critical seam in `scripts/Game.gd`: `_close_event()` calls `_year_pass()` for every non-encounter event after the event UI closes.
- Confirmed two legacy no-event paths also call `_year_pass()`: `_enter_place()` when no event is picked and `_interior_boss()` when the office has no event.
- The current independent-location `_on_location_action()` no-event path already advances only 30 minutes and does not call `_year_pass()`; this is the desired semantic model for regular location activity.
- `_year_pass()` itself remains a distinct explicit annual entry point and calls `rules_sys.year_tick(st)`; GAME-FIX-001 should preserve that function while removing accidental regular-event callers.

## Changes made this run
- Added `tools/verify_event_year_separation.gd` as a narrow regression guard.
- The regression checks that `_close_event()`, legacy no-event `_enter_place()`, and `_interior_boss()` do not invoke `_year_pass()`, while verifying that the explicit `_year_pass()` function still retains `rules_sys.year_tick(st)`.
- The current source is expected to fail this regression until `scripts/Game.gd` is patched.

## Validation
- Repository/code inspection only; no Godot runtime was available or claimed.
- Regression command for QA/local execution after the source patch:
  `godot --headless --path . --script res://tools/verify_event_year_separation.gd`
- Expected result after repair: exit code 0 and `GAME-FIX-001 PASS`.
- Expected result on the pre-fix source: non-zero exit with one or more accidental `_year_pass()` caller failures.

## Remaining source patch
Apply the minimal source change in `scripts/Game.gd`:
1. `_close_event()`: after the encounter-specific time-cost branch, regular event closure must return without calling `_year_pass()`; do not add unrelated time or balance changes.
2. `_enter_place()`: when `events_sys.pick(...)` returns null, show the existing toast and return without `_year_pass()`.
3. `_interior_boss()`: when no office event exists, show the existing toast and return without `_year_pass()`.
4. Preserve explicit story-controlled `dark_result.get("pass_year", false)` → `_year_pass()` behavior and preserve `_year_pass()` itself.

## Evidence / limitations
- Fresh repository evidence confirms the source seam and the regression file was committed on the assigned branch.
- No runtime/build evidence was fabricated.
- Source patch is not yet committed in this run because the available GitHub write connector replaces whole files and `scripts/Game.gd` is large; a safe partial patch primitive was not available. The regression and exact minimal patch contract are now committed so the next capable local/Codex execution can make the source edit without ambiguity.

## Handoff
Keep GAME-FIX-001 `IN_PROGRESS` until the three accidental `_year_pass()` callers are removed and the regression passes under Godot. Then update this report to `NEEDS_REVIEW` for orchestrator acceptance.
