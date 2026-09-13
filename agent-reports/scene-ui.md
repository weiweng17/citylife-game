# Scene/UI Agent Report

## Task
- ID: UI-FIX-001
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-001-active-npc-integration`
- Status: IN_PROGRESS

## Scope
Implement the assigned active-NPC presentation repair only. Writable scope follows the task board: `scripts/systems/LocationManager.gd`, a narrow helper under `scripts/world/`, existing NPC visual references, one narrow `tools/verify_*.gd` regression, and this report. `main`, `TASK_BOARD`, `Game.gd`, gameplay settlement logic and NPC content semantics remain untouched.

## Summary
The branch has been fast-forwarded to the current orchestrator baseline and UI-FIX-001 has started.

Two reviewable building blocks were added:
1. `scripts/world/ActiveNpcVisual.gd` defines one grounded NPC visual contract with a foot-origin coordinate, player-compatible depth scaling/tint, a contact shadow, four-direction 4x4 `AnimatedSprite2D` support for Xiaoyu/Chenjie walk sheets, and a static `Sprite2D` fallback for legacy NPC art.
2. `tools/verify_active_npc_visual.gd` is a narrow regression that verifies the walk-capable and fallback node contracts without claiming rendered visual acceptance.

The active `LocationManager` path still needs to instantiate this helper instead of the existing fixed-size `Button + TextureRect` avatar before the task can move to `NEEDS_REVIEW`.

## Repository findings
- Current active NPC rendering in `LocationManager._add_npc_entity()` still creates a separate shadow plus fixed `84x110` button and `TextureRect`, then extracts only frame 0 from Xiaoyu/Chenjie walk sheets. That is the remaining integration gap.
- The new helper normalizes source art to the protagonist's 256 px source-frame contract before applying the same depth-scale curve (`0.292..0.342`) and warm/neutral scene-light blend.
- Click/talk behavior remains owned by `LocationManager` and has not been changed.

## Files changed
- `scripts/world/ActiveNpcVisual.gd` — new grounded/animated NPC presentation helper.
- `tools/verify_active_npc_visual.gd` — new narrow contract regression.
- `agent-reports/scene-ui.md` — this progress report.

## Validation
- Godot/runtime commands executed in this web worker: none.
- Rendered screenshot evidence: none; visual acceptance is explicitly still pending.
- Required regression command after integration: `godot --headless --path . --script res://tools/verify_active_npc_visual.gd`.
- Required visual evidence after integration: run `tools/capture_npc.gd` and inspect NPC feet contact, shadow, scale, tint, z/depth/foreground occlusion and hover/click/dialog behavior in the real location.

## Remaining implementation
Replace only the visual portion of `LocationManager._add_npc_entity()` with `ActiveNpcVisual` while preserving the existing `Button` name, tooltip, pressed signal and hover label contract. The helper origin must be placed at the configured `NPC_LOCATION_POS` foot coordinate and the button/label must stay clickable above the visual. Do not change schedules, relationship notes, navigation, dialog routing or NPC content.

## Known risks
- The GitHub contents write interface available to this worker replaces whole files; `LocationManager.gd` is a large high-conflict file. This run did not overwrite it with a hand-reconstructed full copy because that would create avoidable corruption risk.
- Runtime visual acceptance is still required even after static/helper regression passes.

## Handoff
Continue UI-FIX-001 on this branch. The next safe edit is the narrow `LocationManager._add_npc_entity()` integration described above. Keep status `IN_PROGRESS` until that active path is integrated and the regression is ready for execution; then request `NEEDS_REVIEW` without editing `docs/agents/TASK_BOARD.md`.
