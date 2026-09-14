# Gameplay Agent Report

## Task
- ID: GAME-CONTENT-012
- Agent: gameplay
- Branch/worktree: `agent/game-content-012-daily-economy-hooks`
- Status: NEEDS_REVIEW

## Scope
CONTENT-WAVE-01 player-visible economy slice: add two normal-play livelihood choices without changing the save schema or weakening accepted GAME-FIX-001..009 terminal semantics.

Authorized files used:
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- narrow Office/Cafe livelihood context/handler additions in `scripts/Game.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

No coordination file, `main`, LocationManager, quest/event data, relationship data, UI redesign file, workflow or save-schema file was modified in the final tree.

## Baseline / dependency handling
The CONTENT-WAVE coordination branch is still metadata/control-plane oriented and its `scripts/Game.gd` does not itself contain the full accepted gameplay repair stack. To satisfy this task's explicit `Preserve GAME-FIX-001..009` requirement, the task branch first reconstructs the accepted `GAME-FIX-009` final Game semantics, then layers only the new livelihood hooks on top.

Accepted gameplay reference used:
- `GAME-FIX-009` exact accepted tip: `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`
- accepted Game blob: `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`

During this web turn the branch was also being updated concurrently. I did not force-push or overwrite newer work; each follow-up continued from the latest branch head. A temporary task marker appeared in branch history and was removed again before the implementation tree; it is not present in the final tree.

## Implementation
### 1. Office overtime
`OfficeActivities.gd` adds a normal interaction point:
- id: `overtime`
- label: `工位 · 再加会儿班`
- 2 hours
- health −4
- mood −8
- once per in-game day
- hidden until today's ordinary `work` objective has been completed

`Game.gd` settlement:
- overtime pay is 60% of the player's current ordinary shift wage, so it scales with skill/raise progression;
- the current day is recorded under the existing persisted `flags` dictionary (`cw01_overtime_day`);
- a same-day repeat is rejected before activity settlement;
- no extra work-shift quest count or skill growth is granted by overtime;
- after its 120-minute advance, needs are synchronously settled and the existing authoritative terminal evaluator is called before normal completion feedback.

At the initial town-origin skill tier, normal shift wage is 120 and overtime is 72.

### 2. Cafe temporary side gig
`CafeActivities.gd` adds a normal interaction point:
- id: `side_gig`
- label: `吧台后 · 临时帮工`
- 90 minutes
- pay +55
- health −2
- mood −4
- once per in-game day

The spot is placed at `Vector2(760, 520)`, below the cafe's existing central blocked rectangle rather than inside/against the bar collision region.

`Game.gd` records the completion day in the existing `flags` dictionary (`cw01_cafe_gig_day`). A same-day repeat is rejected before settlement. The fixed 55 pay is below the existing minimum ordinary work-shift wage of 90.

### 3. Shared daily/persistence semantics
No new save section or schema field was added. Both actions reuse `GameState.flags`, which already participates in the existing `game_state` save payload. The stored day is compared with `time_sys.day`, so the action naturally reopens on a later in-game day without a new reset subsystem.

### 4. Terminal-state preservation
The branch keeps the accepted single `Rules.death_reason()` consumer through `_evaluate_terminal_state()`.

New livelihood settlement uses:
1. advance elapsed minutes;
2. `_sync_needs_to_time()`;
3. `_evaluate_terminal_state()`;
4. only if still alive, release the activity and show ordinary completion feedback.

Thus health/mood costs and elapsed-time need penalties cannot be revived/masked by a later reward-bearing step in the same livelihood flow.

## Validation package prepared
Added `tools/verify_livelihood_actions.gd`.

Repository/source assertions cover:
- one centralized direct `death_reason()` consumer;
- settled-frame terminal observation remains before quest reward mutation;
- livelihood minute advance -> needs settlement -> authoritative terminal observation ordering;
- Office/Cafe labels expose time, reward and primary health/mood costs;
- overtime visibility depends on normal work completion.

Prepared runtime assertions cover:
- overtime hidden before normal work and available after normal work;
- overtime spot is reachable through normal office navigation;
- overtime pays 60% of current wage, costs 120 minutes / health 4 / mood 8;
- second same-day overtime produces no second pay or time advance;
- daily marker survives an isolated/deep-copied existing save payload without a new top-level schema key;
- cafe side-gig spot is reachable through normal cafe navigation;
- side gig pays 55 (< minimum normal shift 90), costs 90 minutes / health 2 / mood 4;
- second same-day side gig produces no second pay or time advance;
- both actions reopen on a later in-game day.

The verifier deliberately deep-copies the in-memory save payload before mutation because `GameState.to_dict()` exposes nested dictionary references; this models the isolation that real serialization provides and avoids a false save-persistence failure in the test itself.

Prepared command:
`godot --headless --path . --script res://tools/verify_livelihood_actions.gd`

## Runtime / build evidence
- Godot executed by this web worker: **NO**.
- Browser/Web export executed by this web worker: **NO**.
- Verifier PASS claimed: **NO**.
- Real execution remains assigned to QA-002 on one frozen integration SHA.

## Balance / product notes
- Overtime is intentionally more lucrative than the cafe gig but also much harsher on mood and requires first completing the normal workday.
- Cafe gig is a lower-pay fallback that gives the cafe a reason to revisit beyond consuming coffee / resting.
- Both expose their tradeoffs directly in labels/tooltips and use deterministic rewards; no random success roll was introduced.
- Recurring rent/fixed expenses are not part of this task and remain a later product decision.

## Known risks for runtime QA
- New spot coordinates were selected against current `LocationManager` navigation rectangles without editing LocationManager. The narrow verifier now performs actual `walk_to()` reachability assertions, but those assertions have not been run by this web worker.
- Both actions can cross midnight. Their completion marker records the action's start day; on the next calendar day the flag naturally reopens. Overtime still requires the next day's normal work completion before it becomes available again.
- Full rendered label layout remains a runtime/UI observation, not inferred here.

## Handoff
Repository implementation and the narrow regression package are complete for worker review.

Please review the branch against the current CONTENT-WAVE coordination base, then include `tools/verify_livelihood_actions.gd` in the frozen QA-002 runtime package. Do not infer Godot PASS from this report.
