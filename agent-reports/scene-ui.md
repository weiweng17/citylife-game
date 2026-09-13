# Scene/UI Agent Report

## Task
- ID: UI-001
- Agent: scene-ui
- Branch/worktree: `agent/ui-001-visual-audit`
- Status: NEEDS_REVIEW

## Scope
Repository audit only. Scene/script/assets were treated as read-only for this task. The only file changed by this agent is this report. `docs/agents/TASK_BOARD.md` and `main` were not modified.

## Summary
The current build has a workable scene/UI presentation skeleton, but the largest remaining risks are visual integration and layout coupling rather than missing gameplay logic.

Priority findings:
1. Home bed/sleep composition is explicitly still not visually accepted.
2. Active NPC rendering follows a different size/grounding pipeline from the player and mixes high-res candidate art with fallback sprites.
3. HUD height and location-header placement are manually coupled with fixed pixel offsets while objective text continues to grow.
4. Expanded-map interaction anchors are documented as only roughly calibrated; reachability tests do not prove visual alignment.
5. Non-home foreground occlusion is mostly coarse rectangular cropping.
6. Dialog/Event/Ending presentation is less styled than HUD/Shop/scene interaction UI.
7. Study/cook/work props are still procedural icon-like drawings rather than scene-integrated action art.

No scene/code/asset edit is required or allowed to finish UI-001. The practical next step is to split these into focused implementation tasks and validate them with the existing capture scripts.

## Findings

| ID | Severity | Repo-detectable vs runtime-only | Finding | Exact paths | Smallest practical follow-up |
| --- | --- | --- | --- | --- | --- |
| UI-AUD-01 | HIGH | Repo-confirmed known gap | Home bed/sleep visual QA is still `MIXED`. Legacy sleep + legacy blanket remain default; candidate/v2/v3 variants are test-only. The unresolved issue is lower-body/leg-edge blending into the baked bed foreground. | `docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md`; `scripts/world/HomeInteractionVisual.gd`; `scripts/systems/HomeActivities.gd`; `assets/characters/sprites/interactions/`; `assets/backgrounds/interactions/` | Dedicated bed-visual task. Keep gameplay/anchors stable. Clean the sleep-pose lower alpha/leg silhouette first, then use only a tiny foreground blanket edge extracted from the official background. Compare with `tools/capture_activity_props.gd`. Do not re-enable a whole-bed overlay. |
| UI-AUD-02 | HIGH | Structural risk visible in repo; final visual judgement runtime-only | NPCs can read as stickers/icons because the active location NPC path differs from the player. Player uses `AnimatedSprite2D`, foot anchoring, depth scaling, lighting and moving shadow; NPCs are fixed-size `Button + TextureRect` entities using a static texture frame and separately positioned shadow. Only Xiaoyu/Chenjie use high-res candidate sheets; the rest use fallback sprites. | `scripts/systems/LocationManager.gd`; `assets/characters/sprites/prototype/xiaoyu_walk_candidate.png`; `assets/characters/sprites/prototype/chenjie_walk_candidate.png`; `assets/sprites/npc_laozhang.png`; `npc_laozhou.png`; `npc_azhe.png`; `npc_daoshi.png`; `tools/capture_npc.gd` | Unify NPC visual contract first: foot origin, depth scale, shadow contact and tint should match the player. Capture every active NPC in its real location before deciding whether art replacement is also needed. |
| UI-AUD-03 | HIGH | Layout coupling repo-confirmed; overlap requires runtime stress check | HUD and location header are manually locked together. HUD has fixed 112 px height; comments explicitly forbid adding a row because the location header offset depends on it. Stage goal + clues + dark-state + quest are concatenated into one wrapping label, while `LocationManager` hard-codes header top at 132 to clear the HUD. | `scripts/ui/HUD.gd`; `scripts/systems/LocationManager.gd`; `scripts/Game.gd`; `project.godot` | Decouple layout: derive/measure HUD content height and place the location header below it instead of duplicating magic offsets. Stress-test longest goal + clue/dark-state + quest at 1280x720 and resized web windows. |
| UI-AUD-04 | MEDIUM-HIGH | Calibration gap repo-confirmed; visual correctness runtime-only | Office/store/park/cafe/hospital/alley/rooftop interaction stand points are explicitly documented as roughly calibrated and not frame-by-frame aligned to art. Existing verification can prove reachability, not correct feet-to-furniture contact, facing or label placement. | `scripts/systems/OfficeActivities.gd`; `StoreActivities.gd`; `ParkActivities.gd`; `CafeActivities.gd`; `HospitalActivities.gd`; `AlleyActivities.gd`; `RooftopActivities.gd`; common presentation in `scripts/systems/SpotActivities.gd` | One screenshot-driven calibration pass across these locations; adjust presentation coordinates only where visual evidence shows a mismatch. Use `capture_store.gd`, `capture_park.gd`, `capture_cafe.gd`, `capture_hospital.gd`, `capture_alley_rooftop.gd`. |
| UI-AUD-05 | MEDIUM | Implementation difference repo-confirmed; visible severity runtime-only | Foreground occlusion quality is uneven. Home uses hand-shaped polygon occluders; most other locations use broad rectangular crops. Rectangles risk hard cut lines or covering too much character around furniture. | `scripts/systems/LocationManager.gd` (`OCCLUDERS`, `_rebuild_foreground`) | Fold into location calibration. Keep navigation unchanged; only replace a rectangular occluder with a tighter polygon where a screenshot demonstrates a real cut/cover problem. |
| UI-AUD-06 | MEDIUM | Repo-confirmed implementation inconsistency; aesthetic impact runtime-only | UI surfaces do not share one visual language. HUD, Shop and scene interaction buttons use deliberate dark/gold styling, while Dialog/Event/Ending mostly rely on default `PanelContainer`/`Button` presentation. Start screen is partly styled. | `scripts/ui/HUD.gd`; `ShopUI.gd`; `DialogUI.gd`; `EventUI.gd`; `EndingUI.gd`; `StartUI.gd`; `scripts/systems/SpotActivities.gd`; `project.godot` | Shared UI presentation helper/theme for panel background, border, button states and typography. Apply first to Dialog/Event/Ending without changing behavior. Capture all major UI surfaces side by side. |
| UI-AUD-07 | MEDIUM | Repo-confirmed art method; visual impact runtime-only | Study/cook/work activity props are procedural drawings (book/pot/laptop) positioned near the player, not integrated action art. Against painted backgrounds they may read as floating UI tokens. Sleep already bypasses this with a dedicated composition. | `scripts/world/ActivityProp.gd`; `scripts/systems/LocationManager.gd`; `tools/capture_activity_props.gd`; `tools/capture_interaction_polish.gd` | Keep current props as fallback. Later polish one activity at a time with matched transparent prop art or dedicated action poses. Do not bundle with bed repair. |
| UI-AUD-08 | LOW | Repo-detectable | Two NPC presentation paths exist. `scenes/world/NPC.tscn` + `scripts/world/NPC.gd` define an Area2D/Sprite2D NPC, while the active location presentation is built directly in `LocationManager`. Repository search did not show the scene/class in the current location path, which increases drift risk. | `scenes/world/NPC.tscn`; `scripts/world/NPC.gd`; `scripts/systems/LocationManager.gd` | After NPC grounding is stable, make one path authoritative or explicitly mark/remove the legacy path in a separate cleanup task. |

## Files inspected
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `HANDOFF.md`
- `docs/agents/MASTER_PLAN.md`
- `docs/agents/TASK_BOARD.md`
- `docs/agents/AGENT_RULES.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/ARCHITECTURE.md`
- `docs/ITERATION_PLAN.md`
- `docs/TODAY_HANDOFF_2026-09-13.md`
- `docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md`
- `project.godot`
- `scenes/Main.tscn`
- `scenes/world/NPC.tscn`
- `scripts/Game.gd`
- `scripts/ui/HUD.gd`
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EventUI.gd`
- `scripts/ui/ShopUI.gd`
- `scripts/ui/StartUI.gd`
- `scripts/ui/EndingUI.gd`
- `scripts/systems/LocationManager.gd`
- `scripts/systems/SpotActivities.gd`
- `scripts/systems/HomeActivities.gd`
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/StoreActivities.gd`
- `scripts/systems/ParkActivities.gd`
- `scripts/systems/CafeActivities.gd`
- `scripts/systems/HospitalActivities.gd`
- `scripts/systems/AlleyActivities.gd`
- `scripts/systems/RooftopActivities.gd`
- `scripts/world/HomeInteractionVisual.gd`
- `scripts/world/ActivityProp.gd`
- `scripts/world/NPC.gd`
- Relevant `tools/capture_*.gd` / `tools/verify_*.gd` inventory

## Validation
- Commands/tests run: none. This web audit does not claim rendered/Godot validation.
- Repository comparison confirmed `agent/ui-001-visual-audit` initially matched `orchestrator/multi-agent-bootstrap` before report-only work.
- Source/docs audit completed against the assigned branch.
- Existing capture tools were inventoried so the implementation/QA pass has an explicit runtime validation route.
- `build/qa/` screenshots are repository-ignored/local outputs, so they were not available for direct visual inspection through GitHub.

### Manual/runtime checks required before visual PASS
1. Home sleep: inspect legacy/v2/v3 captures for duplicated bed, alpha seams, floating body, wrong pillow relation and duplicate Zzz.
2. NPC grounding: inspect each NPC in its real location for feet, scale, shadow, tint and foreground occlusion versus the player.
3. HUD stress: longest goal + clue/dark state + quest string; verify no wrap below HUD or overlap with `LocationHeader`.
4. Expanded locations: inspect interaction anchor, facing, label position and occlusion in office/store/park/cafe/hospital/alley/rooftop. Reachability alone is insufficient.
5. UI consistency: compare Start/Dialog/Event/Shop/Ending at 1280x720 and narrower browser widths; test the longest dialog/event body because the panels use fixed-height presentation areas without scrolling.
6. Fully unlocked footer: unlock all nine locations and verify the travel `HBoxContainer` remains readable/clickable without crowding or overflow.

## Evidence
- Repository evidence: exact files and code/documented constraints are listed in the findings table above.
- Screenshot/runtime evidence: none produced by this web agent; visual claims that need rendering are explicitly marked runtime-only.
- Strongest existing repository evidence: the home-bed handoff already records visual acceptance as `MIXED`, and multiple expanded-location scripts explicitly state that interaction points are only rough art calibration.

## Known issues / risks
- Fixed 1280x720-era pixel layout assumptions exist across HUD/header/prompt/footer presentation. `project.godot` uses a 1280x720 viewport with `canvas_items`; resized browser behavior still needs a real runtime check.
- `LocationManager._refresh_travel_buttons()` can place up to nine unlocked destinations in one horizontal box; this is a runtime crowding check, not a confirmed bug.
- `DialogUI` and `EventUI` use fixed-height text/panel regions without a scroll strategy; current content may fit, but longest-content testing is required.
- Large z-index ladders and foreground depth values are manually coordinated; do not change them opportunistically during unrelated visual tasks.

## Proposed follow-up tasks for coordinator
These are proposals only; this agent did **not** edit `TASK_BOARD`.

1. `UI-002` — Home bed seam cleanup and visual acceptance.
2. `UI-003` — NPC grounding / scale unification.
3. `UI-004` — HUD/header layout decoupling.
4. `UI-005` — Expanded-location visual calibration and occlusion pass.
5. `UI-006` — Shared UI presentation theme for Dialog/Event/Ending.
6. `UI-007` — Interaction prop / action-pose polish, one activity at a time.

## Handoff
UI-001 repository audit is complete and ready for coordinator review. Highest priority is `UI-002` because the bed visual failure is already documented and confirmed. After that, prioritize NPC grounding because its active presentation path structurally differs from the player and directly affects scene integration quality.
