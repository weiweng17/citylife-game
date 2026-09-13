# Scene/UI Agent Report

## Task
- ID: UI-FIX-001
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-001-active-npc-integration`
- Status: NEEDS_REVIEW

## Scope
Implement the assigned active-NPC presentation repair only. Writable scope follows the task board: `scripts/systems/LocationManager.gd`, a narrow helper under `scripts/world/`, existing NPC visual references, one narrow `tools/verify_*.gd` regression, and this report. `main`, `TASK_BOARD`, `Game.gd`, gameplay settlement logic and NPC content semantics remain untouched.

## Summary
UI-FIX-001 implementation is complete at repository level and ready for coordinator review.

The active location NPC path now uses a grounded visual helper instead of rendering the avatar inside a fixed-size `Button + TextureRect`:
1. `scripts/world/ActiveNpcVisual.gd` defines one foot-origin presentation contract. Xiaoyu/Chenjie use complete four-direction 4x4 `AnimatedSprite2D` sheets when available; legacy NPC art uses a static `Sprite2D` fallback.
2. Grounding uses the same depth-scale curve as the protagonist (`0.292..0.342`), normalizes source art to the protagonist's 256 px frame contract, applies the same warm/neutral lighting blend, and keeps a contact shadow at the foot origin.
3. `LocationManager._add_npc_entity()` now creates `NpcVisual_<id>` at the configured `NPC_LOCATION_POS` foot coordinate and leaves the existing transparent `Npc_<id>` button as the click/talk layer.
4. The button name, tooltip text, relationship hover label and `npc_requested` routing are preserved.
5. Stationary scheduled NPCs intentionally stop on a down-facing idle frame instead of looping a walk cycle in place. The helper exposes and regression-checks four-direction `play_walk()` for actual movement-capable use.

## Files changed
- `scripts/systems/LocationManager.gd` — integrates the grounded helper into the active NPC path while preserving click/talk behavior.
- `scripts/world/ActiveNpcVisual.gd` — new grounded/animated NPC presentation helper.
- `tools/verify_active_npc_visual.gd` — narrow helper + active `LocationManager` integration regression, including click-signal routing.
- `agent-reports/scene-ui.md` — completion/report status.

No NPC data, schedule, relationship, dialogue, navigation, gameplay settlement, scene root, task board or `main` changes were made.

## Repository-verified acceptance coverage
- Walk-capable presentation is selected from `NPC_HIRES_SHEETS` for Xiaoyu/Chenjie instead of extracting only frame 0.
- Static fallback presentation remains available for Lao Zhang/Lao Zhou/Azhe/Daoshi.
- The visual node origin equals the configured NPC foot coordinate.
- Visual z-index derives from foot `y`; the helper shadow is one relative depth step below the body.
- The helper uses the protagonist-compatible depth-scale curve and lighting blend.
- The existing `Npc_<id>` button contract remains separate from the visual and retains tooltip/pressed/hover-label behavior.
- `_clear_npcs()` detaches both visual and button because both are direct children of `npc_layer`.

## Validation
### Performed in this web worker
- GitHub source/diff inspection only.
- Confirmed the task branch is based on the latest `orchestrator/multi-agent-bootstrap` baseline used for this repair wave.
- Confirmed the final branch diff is limited to the four task-authorized files listed above.
- Inspected the `LocationManager` integration diff to verify the old fixed avatar `TextureRect` is removed from the active path and the click/talk layer is preserved.

### Not performed
- Godot was **not** launched.
- Headless regression was **not** executed.
- `capture_npc.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No rendered visual PASS is claimed.

### Prepared regression command
`godot --headless --path . --script res://tools/verify_active_npc_visual.gd`

The regression is designed to check:
- Xiaoyu walk sheet creates `AnimatedSprite2D` with 4 directions × 4 frames.
- `play_walk()` selects/plays the expected direction and idle reset returns to stopped down-facing frame 0.
- Static fallback remains `Sprite2D`.
- Helper origin/shadow grounding contract.
- `LocationManager` actually creates `NpcVisual_xiaoyu` at the configured foot coordinate/depth.
- Existing `Npc_xiaoyu` tooltip contract remains intact.
- Pressing the button still emits `npc_requested("xiaoyu")`.
- `_clear_npcs()` removes the visual and click layer together.

### Required rendered evidence before visual PASS
Run the existing `tools/capture_npc.gd` on this exact branch/SHA and inspect at minimum:
1. Xiaoyu at home and Chenjie at store: feet contact, character scale, idle frame, tint and shadow.
2. One static fallback NPC such as Lao Zhang: source-size normalization and contact shadow.
3. Foreground occlusion where an NPC is near furniture/scene foreground.
4. Hover relationship label visibility and tooltip/click target alignment.
5. Clicking the NPC still opens the expected dialog through the existing route.

## Known risks / review notes
- Rendered acceptance is still required. Repository structure can verify the grounding contract but cannot prove that the candidate walk sheets visually match every painted background.
- The active scheduled NPCs currently stand at fixed positions; therefore the implementation does not fake movement by playing a walk cycle in place. Full walk animation is prepared for actual NPC motion but is not continuously played while stationary.
- `LocationManager._npc_texture()` is now legacy/dead for the active location avatar path but was intentionally left untouched to keep this repair narrow; cleanup can be a separate low-risk task after integration.
- Two comment-only quote-style changes exist in `LocationManager.gd` from the contents-API full-file replacement; they have no runtime effect and are not part of acceptance semantics.

## Commits from this continuation
- `8977c78ac45c5262cf665caeb062b7056e863871` — expands the narrow regression to cover helper animation plus real `LocationManager` click/integration contract.
- `d5f7e80f4a492f9d7150b36545832af98fd31f46` — integrates grounded active NPC visuals into `LocationManager`.

Earlier commits on the same task branch contain the helper and initial regression scaffold.

## Handoff
UI-FIX-001 is ready for orchestrator review. Do not mark visual acceptance complete until Godot renders/captures are inspected. If the coordinator accepts the repository implementation, the next execution step belongs to local/Codex/QA runtime: run `verify_active_npc_visual.gd`, then `capture_npc.gd`, and record exact SHA/commands/results. No further source change is required from this web agent unless review finds a concrete defect.
