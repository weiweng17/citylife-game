# Scene/UI Agent Report

## Task
- ID: UI-FIX-002
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-002-home-bed-seam`
- Status: NEEDS_REVIEW

## Scope
Clean the remaining home sleep/bed foreground seam only. The task contract authorizes home sleep presentation paths under `scenes/**`, existing home/sleep visual references under `assets/**` when required, one narrow helper/regression under `tools/`, and this report. Sleep gameplay, input routing, world navigation, `scripts/**`, shared manager logic, `main`, and `docs/agents/TASK_BOARD.md` were treated as read-only.

## Summary
UI-FIX-002 is complete at repository/presentation level and ready for coordinator review.

The previous default blanket asset was a large foreground composition. Existing visual QA already established that continuing with a whole-bed overlay was the wrong direction and that the remaining repair should use only a small official-background waist/leg occluder.

This task therefore keeps the current runtime contract completely unchanged and repairs only the default foreground asset:
1. Reused the existing `home_bed_blanket_foreground_v3.png` source, which was extracted from the official `rental_apartment_rain_night.webp` background and represents only the waist/leg bed foreground region.
2. Baked the existing v3 A/B scale/offset relationship into a transparent canvas that still fits the unchanged legacy `LEGACY_BLANKET_TEXTURE` scale/position contract. No sleep script, anchor, gameplay, navigation, or manager coordinate was changed.
3. Cleaned the crop boundary with a small alpha feather and preserved edge RGB into transparent border pixels to reduce dark/rectangular seam artifacts when linearly filtered.
4. Replaced only the contents of the existing default path `assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png`, so `HomeInteractionVisual.gd` continues to use its existing default reference without source-code changes.
5. Added `tools/verify_home_bed_seam.gd` to guard the presentation contract: the default foreground must remain a localized transparent waist/leg patch with feathered alpha rather than regress into a whole-bed overlay.

## Files changed
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png` — replaced the large default foreground composition with the localized official-background waist/leg patch, baked into the existing default transform contract.
- `tools/verify_home_bed_seam.gd` — narrow asset-contract regression; checks canvas dimensions, visible bounding box/footprint and presence of soft-alpha seam pixels.
- `agent-reports/scene-ui.md` — completion report / review request.

No `scripts/**`, `scenes/**`, gameplay data, navigation data, `main`, task board, or other coordination files were modified.

## Repository-verified presentation contract
- The repaired default asset uses the same file path already referenced by `HomeInteractionVisual.gd`; no gameplay/presentation script API changed.
- The visible foreground is localized to the bed waist/leg region rather than spanning a whole-bed composition.
- The replacement transparent canvas is `1200x900`; its visible patch is approximately `709x295`, occupying under 20% of the canvas bounding-footprint ratio used by the guard test.
- The patch is derived from the repository's existing v3 official-background crop rather than the mismatched candidate bed-group artwork.
- The alpha edge includes partially transparent pixels so the local occluder can blend under linear filtering instead of ending in a hard rectangular crop.
- The existing v3/candidate A/B assets were left intact for historical comparison; no candidate whole-bed resource was enabled.
- The sleep pose asset `protagonist_sleep_side_v6.png` was intentionally not changed in the same repair, following the handoff rule to avoid simultaneously changing both pose and duvet.

## Validation
### Performed in this web worker
- Read the latest task contract / ownership / web-agent rules and the existing home-bed visual QA handoff.
- Confirmed the task branch initially had no task-specific commits and was two commits behind the latest orchestrator baseline; fast-forwarded it to `125419dac51af9539e0fcd5c1da34bb4824d64c0` before making changes.
- Inspected the existing v3 PNG structure and alpha extent before reuse.
- Inspected the generated replacement asset before upload: `1200x900` transparent canvas, visible bounding region approximately `(475,28)-(1184,323)`, visible bounding footprint about `19.37%`, and a non-zero soft-alpha edge population.
- Added a headless-checkable regression that encodes those broad presentation constraints without asserting rendered appearance.

### Not performed
- Godot was **not** launched.
- `tools/verify_home_bed_seam.gd` was **not** executed.
- Existing home presentation/activity regressions were **not** executed.
- `tools/capture_activity_props.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No rendered visual PASS is claimed.

### Prepared headless commands
Run on this exact branch/SHA in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_home_bed_seam.gd`

Then re-run the existing presentation/gameplay guards to prove the asset-only repair did not disturb the sleep flow:

`godot --headless --path . --script res://tools/verify_home_presentation.gd`

`godot --headless --path . --script res://tools/verify_home_activities.gd`

### Required rendered evidence before visual PASS
Run the existing `tools/capture_activity_props.gd` default/legacy path on this exact task SHA and inspect the real home scene for all of the following:
1. No duplicated/second bed and no large whole-bed foreground overlay.
2. Lower body and duvet read as one composition; the local foreground edge does not appear as a hard rectangular/polygon seam.
3. Sleep pose head still relates correctly to the original pillow/background at the existing anchor.
4. The local foreground covers only the intended waist/leg region and does not cover the face, pillow, floor, or unrelated furniture.
5. Only the programmatic Z/z effect is visible; no duplicate sleep symbol appears from artwork.
6. Enter-sleep fade, breathing pulse and wake/return transition remain visually coherent.

## Known risks / review notes
- Rendered acceptance remains mandatory. A repository asset-contract check can prevent obvious regressions such as restoring a whole-bed overlay, but it cannot prove the seam is invisible against the final scaled/composited scene.
- `HomeInteractionVisual.gd`'s historical v3 A/B mode also adjusted the sleep-pose transform. This task intentionally did **not** copy those sleep-pose changes into the default path because scripts are outside the task's writable scope and the bed handoff explicitly advised against changing pose and duvet simultaneously. If the rendered default pose is still a few pixels off after this asset cleanup, that should be handled only after screenshot evidence and a new explicitly authorized presentation task.
- Godot import regeneration may rewrite the `.import` cache locally when the PNG changes; the committed source `.png.import` remains untouched because its source path/import settings are still valid.

## Commits
- `c93edc090b1eec13af92500ad2e83bcb3f53f697` — `fix: clean home bed foreground seam asset`
- `4ed70ea5033d47e692a166a8c83971ae03258fed` — `test: guard localized home bed seam asset`

## Handoff
UI-FIX-002 is ready for orchestrator review at repository level. The implementation deliberately stops before claiming visual acceptance. The next step is runtime/QA on the exact review SHA: execute the three headless checks above, then produce and inspect a real home sleep capture. If the capture is clean, the coordinator can accept the repair; if a visible seam remains, use the screenshot to decide whether the sleep-pose lower silhouette needs a separately authorized art-only cleanup rather than introducing more runtime transform magic numbers.