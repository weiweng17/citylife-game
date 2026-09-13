# Gameplay Agent Report

## Task
- ID: GAME-FIX-002
- Agent: gameplay
- Branch/worktree: `agent/game-fix-002-need-zero-cadence`
- Status: NEEDS_REVIEW

## Scope
Fix zero-need penalty cadence only. Authorized files for this task are `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression, and this report. No coordination files, save schema, data, scenes, assets, config, or `main` were modified.

## Summary
The zero-fullness / zero-energy penalties are now tied to the same explicit full-game-hour cadence that already drives need consumption.

Before this fix, `_sync_needs_to_time()` accumulated need drain by full hours, but the `health -2` / `mood -2` zero-need penalties sat outside that hourly loop. Any positive elapsed-minute delta could therefore reapply the penalty even when less than one full need hour had elapsed.

After this fix, each completed need hour performs the existing sequence:
1. fullness `-4`;
2. energy `-3`;
3. if fullness is now zero, health `-2`;
4. if energy is now zero, mood `-2`.

Sub-hour elapsed time only accumulates in `need_fraction`; repeated `_sync_needs_to_time()` calls with no elapsed time do not apply a penalty. Multi-hour advances still settle once per full elapsed hour.

## Changes
### `scripts/Game.gd`
- In `_sync_needs_to_time()`, moved the existing zero-fullness and zero-energy penalty checks inside `while need_fraction >= 1.0`.
- Preserved all current balance values:
  - `FULLNESS_PER_HOUR = 4`
  - `ENERGY_PER_HOUR = 3`
  - zero-fullness health penalty = `2`
  - zero-energy mood penalty = `2`
- Preserved `need_fraction`, low-need warning behavior, replenishment behavior, and save schema.
- No other effective `Game.gd` diff remains against the latest coordination baseline.

Primary source commit: `2e6ff6a8a069df259a8dd3469e57cc514202666d` (`fix: tie zero-need penalties to hourly cadence`).
Cleanup commit: `2d48781dfb8f0274656af835105eff61230958d7` removed one unrelated comment-only drift introduced during the GitHub full-file write. Final effective `Game.gd` diff is only the four indentation changes required by this task.

### `tools/verify_need_zero_cadence.gd`
Added a narrow runtime regression package that prepares these checks:
- zero needs + 30 minutes => no health/mood penalty;
- another 30 minutes => exactly one `-2/-2` penalty at the completed hour;
- repeated sync with no time advance => no duplicate penalty;
- 120-minute advance => exactly two additional hourly penalties;
- fullness/energy remain clamped at zero.

Regression test finalization commit: `84ed4abf1208e312cffd4318ee0a74e217388d9a`.

## Repository verification performed
Fresh GitHub inspection confirms:
- `_sync_needs_to_time()` still accumulates elapsed minutes into `need_fraction`.
- Existing `fullness - FULLNESS_PER_HOUR` and `energy - ENERGY_PER_HOUR` remain unchanged.
- Both zero-need penalties are inside the `while need_fraction >= 1.0` block.
- The warning call remains outside the hourly loop, preserving once-per-day low-need messaging behavior.
- Final branch comparison against `orchestrator/multi-agent-bootstrap` contains only:
  - `scripts/Game.gd` — effective 4 additions / 4 deletions from indentation only;
  - `tools/verify_need_zero_cadence.gd` — new narrow regression;
  - this report after the final report commit.

## Runtime validation not performed
No Godot/Web/browser runtime was available in this web-agent execution. No runtime PASS is claimed.

Prepared focused command for QA/local execution:
`godot --headless --path . --script res://tools/verify_need_zero_cadence.gd`

Expected successful output ends with:
`GAME-FIX-002 PASS: zero-need penalties are tied to the hourly need-drain cadence`

Recommended companion regression on the exact integrated SHA:
`godot --headless --path . --script res://tools/verify_needs.gd`

The existing `verify_needs.gd` covers normal multi-hour need drain, meal/rest replenishment, low-need warning behavior, and need state round-trip; it was inspected but not modified or run in this task.

## Integration note
This task branch was fast-forwarded to the latest `orchestrator/multi-agent-bootstrap` head before implementation. The coordination branch currently records `GAME-FIX-001` as DONE at repository-review level but does not itself contain that separate branch's `Game.gd` event/year patch. Therefore this task intentionally does not duplicate GAME-FIX-001 changes. The orchestrator should integrate both reviewed task branches onto the final target SHA and run their regressions together.

## Out of scope / unchanged
- Terminal-state/death evaluation remains for `GAME-FIX-003`.
- `need_fraction` save continuity remains a separate save-hardening concern.
- No annual-event behavior, location flow, UI, NPC, quest, economy, or save-format semantics were changed here.

## Handoff
GAME-FIX-002 implementation and its narrow regression package are ready for orchestrator review. Requested task status: `NEEDS_REVIEW`. Runtime/Godot acceptance remains pending QA/local execution and must not be inferred from this repository-only report.
