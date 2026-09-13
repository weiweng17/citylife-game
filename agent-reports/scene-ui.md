# Scene/UI Agent Report

## Task
- ID: UI-FIX-003
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-003-hud-header-decoupling`
- Status: NEEDS_REVIEW

## Scope
Decouple the top HUD's presentation ownership from the location header without changing gameplay or the shared location manager. The task contract authorizes HUD/header presentation files under `scenes/**`, directly owned UI helpers under `scripts/ui/**` only when required, one narrow `tools/verify_*.gd` regression if needed, and this report.

`Game.gd`, `scripts/systems/LocationManager.gd`, gameplay settlement, NPC/content, navigation semantics, `main`, and `docs/agents/TASK_BOARD.md` were treated as read-only.

## Summary
UI-FIX-003 is complete at repository/layout-contract level and ready for coordinator review.

The repository-visible coupling was explicit in the old implementation:
- `HUD.gd` hard-coded a 112px panel but allowed the long goal label to word-wrap vertically.
- The HUD comments said extra rows could not be added because the location header offset was watching the HUD height.
- Read-only inspection of `LocationManager.gd` confirmed `LocationHeader` independently starts at y=132 and historically carried a comment saying it was moved down to make room for the HUD's extra row.

Because `LocationManager.gd` is outside this task's writable scope, this repair does not move or rewrite the header. Instead it gives the HUD a stable presentation contract of its own so common content growth cannot silently expand into the header area:
1. Added explicit HUD-owned layout constants for side margin, top margin and `HUD_RESERVED_HEIGHT = 112`.
2. Enabled `clip_contents` on the HUD so unexpected child overflow cannot paint into the independently owned location-header region.
3. Converted dynamic HUD labels that can grow with content (age/stage, time, weather, money, skill, daily target and stage/quest goal) to single-line clipped/ellipsis presentation.
4. Preserved full long daily/goal/time/weather/age/money text in tooltips where appropriate instead of gaining vertical rows.
5. Kept existing primary/status/daily/goal node structure; no gameplay-facing refresh API was changed.
6. Added stable names for the backpack/save/load/quit buttons so layout regressions can verify that controls remain inside the HUD reservation and reachable.
7. Added `get_reserved_height()` as a narrow presentation contract for regression/inspection; it does not affect gameplay data.
8. Added `tools/verify_hud_header_layout.gd`, which injects intentionally long content and checks the HUD reservation, actual `LocationHeader` separation, single-line overflow policy and top-row button containment.

## Files changed
- `scripts/ui/HUD.gd`
  - owns a stable 112px top reservation rather than describing itself in terms of `LocationManager` offsets;
  - clips unexpected child overflow;
  - prevents long dynamic labels from wrapping vertically;
  - preserves clipped full text in tooltips;
  - adds stable action-button node names and a read-only reserved-height accessor.
- `tools/verify_hud_header_layout.gd`
  - narrow headless-prepared layout/contract regression using the actual `Main.tscn`, HUD and `LocationHeader`.
- `agent-reports/scene-ui.md`
  - this completion/review request.

No `scenes/**` change was required. No `Game.gd`, `LocationManager.gd`, gameplay data, navigation data, NPC/content, `main`, task board, or other coordination files were modified.

## Repository-verified layout contract
- The task branch started identical to the latest orchestrator baseline `6215005b34e860a5d346fa38ee339537a819cd66` (ahead 0 / behind 0).
- The existing location header remains read-only and still owns its own placement (`LocationHeader` at y=132..204 in `LocationManager.gd`).
- The HUD now explicitly owns `HUD_TOP_MARGIN = 10`, `HUD_SIDE_MARGIN = 14` and `HUD_RESERVED_HEIGHT = 112` rather than referencing the header offset in its internal comments.
- The HUD external layout remains `y=10..122` at the normal contract height, leaving the existing 10px separation before the independently placed header at y=132.
- Dynamic goal/daily copy no longer uses vertical word wrapping; it is constrained to one line with ellipsis and full text available by tooltip.
- The existing public refresh entry points/signals remain unchanged (`refresh`, `refresh_daily`, `refresh_skill`, `refresh_bag`, `refresh_time`, `refresh_weather`; save/load/quit/backpack signals unchanged).
- Primary and status rows retain their existing node paths (`HUDContent/PrimaryRow`, `HUDContent/StatusRow`), and daily remains `HUDContent/DailyRow`; the goal row now also has the stable name `HUDContent/GoalRow` for verification.

## Validation
### Performed in this web worker
- Read the latest `TASK_BOARD`, `FILE_OWNERSHIP`, `WEB_AGENT_LAUNCHPAD`, `MASTER_PLAN`, `AGENT_RULES`, `HANDOFF`, current task branch report and branch comparison before editing.
- Confirmed UI-FIX-003 is `READY`, owned by `scene-ui`, and grants `scripts/ui/**` presentation edits plus one narrow regression.
- Read-only inspected `LocationManager.gd` to confirm the actual location-header offsets and the historical coupling comment; did not modify it.
- Inspected existing `tools/verify_locations.gd` so the repair preserves its `HUDContent/PrimaryRow` and `HUDContent/StatusRow` layout assertions.
- Re-read the edited HUD and narrow regression for repository-visible path/type/layout consistency.
- Final branch diff was checked against `orchestrator/multi-agent-bootstrap` and remained limited to the authorized HUD helper, narrow regression and this report.

### Not performed
- Godot was **not** launched.
- `tools/verify_hud_header_layout.gd` was **not** executed.
- Existing `tools/verify_locations.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No rendered visual PASS is claimed.

### Prepared headless commands
Run on this exact task branch/SHA in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_hud_header_layout.gd`

Then run the existing location regression to prove the wider location/UI contract still holds:

`godot --headless --path . --script res://tools/verify_locations.gd`

### Required rendered evidence before visual PASS
On the exact review SHA, inspect the running game at the normal 1280×720 target and at at least one narrower common desktop/web viewport. Confirm all of the following:
1. HUD bottom and location header remain visually separated with no overlap or drift.
2. A long stage goal + quest does not increase HUD height or cover the location title/subtitle.
3. Long daily/time/weather/skill text stays within the HUD; clipped goal/daily text exposes the full string by tooltip.
4. Backpack, Save, Load and Quit remain visible, clickable and aligned in the primary row.
5. Health/mood/fullness/energy bars and skill text remain on the status row without vertical collision.
6. Location title/subtitle and location action/travel controls keep their existing interaction behavior.

## Known risks / review notes
- The location header's y=132 placement remains an existing implementation detail inside `LocationManager.gd`; this task deliberately does not edit that high-conflict file. The decoupling achieved here is one-way: common HUD content changes can no longer grow vertically into the header. Moving the header itself to a shared layout coordinator would require a separately authorized change to `LocationManager.gd` or a larger UI-root refactor.
- Very narrow/mobile-sized viewports were not claimed as supported by this task. The repair targets the existing desktop/Web presentation and common width/content variation while preserving the fixed four action controls.
- Ellipsis is an intentional tradeoff for stable top-band ownership; full long copy remains available through tooltips.
- Actual container minimum-size behavior and button reachability still require the prepared Godot regression/runtime check before final acceptance.

## Commits
- `4fd828d32f4bd4024a6a3461d8c038e57d7a3024` — `fix: stabilize HUD reserved layout envelope`
- `770d06e704aa2a82c97271ace9f7dba89be9927d` — `test: guard HUD header layout contract`
- `fa9f135774a98b71e0af86d724e0e8762d1cec48` — `test: avoid narrowing HUD helper type`

## Handoff
UI-FIX-003 is ready for orchestrator review at repository level. The safe web-worker portion is complete: HUD height/content ownership is now explicit and a task-specific layout regression is prepared. Do not mark rendered visual acceptance complete until the two Godot commands above run on the exact review SHA and a real HUD/header capture confirms the separation and action-button reachability.