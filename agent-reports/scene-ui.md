# Scene/UI Agent Report

## Task
- ID: UI-FIX-002
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-002-home-bed-seam`
- Status: NEEDS_REVIEW

## Scope
Clean the remaining home sleep/bed foreground seam only. The task contract authorizes home sleep presentation files under `scenes/**`, existing home/sleep visual references under `assets/**` when required, one narrow helper/regression under `tools/`, and this report. Sleep gameplay, input routing, world navigation, `scripts/**`, shared manager logic, `main`, and `docs/agents/TASK_BOARD.md` were treated as read-only.

## Summary
UI-FIX-002 is complete at repository/presentation level and ready for coordinator review.

The repair keeps the runtime contract unchanged and replaces the previous large default blanket composition with a localized waist/leg foreground derived from the repository's official-background v3 crop. The crop relationship is baked into the existing legacy default asset canvas, so `HomeInteractionVisual.gd` continues to use the same default path/scale/position contract with no script or gameplay changes. Crop edges were alpha-feathered to reduce hard seam artifacts under linear filtering.

`tools/verify_home_bed_seam.gd` now guards both halves of the intended composition contract:
1. Asset contract: localized transparent patch, bounded footprint, low actual visible-pixel density, meaningful feathered-alpha density, and transparent margin on every canvas edge.
2. Default layering contract: the cleaned legacy-path asset is actually selected by default; candidate/v2/v3 A/B switches remain off; sleep pose renders below duvet foreground; programmatic Z/z renders above it; the presentation remains hidden before `begin_sleep`.

## Files changed
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png` — localized official-background waist/leg foreground baked into the unchanged default transform contract.
- `tools/verify_home_bed_seam.gd` — narrow asset + default-layering contract regression.
- `agent-reports/scene-ui.md` — completion/review handoff.

No `scripts/**`, `scenes/**`, gameplay data, navigation data, `main`, task board, or other coordination files were modified.

## Repository-verified presentation contract
- The repaired default asset remains at `res://assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png`, the existing path used by `HomeInteractionVisual.gd`.
- The replacement transparent canvas is `1200x900`; the inspected visible patch is approximately `709x295`, localized to the intended waist/leg region rather than a whole-bed composition.
- The patch derives from the repository's v3 official-background crop, not the mismatched candidate bed-group artwork.
- The alpha edge contains partially transparent pixels to blend under linear filtering instead of ending at a hard rectangular crop.
- The regression rejects a visible-pixel ratio above 16%, a feathered-pixel ratio below 2%, or visible bounds within 8 px of a canvas edge.
- The prepared runtime contract check instantiates the existing `HomeInteractionVisual` read-only and verifies all three A/B switches are false by default, the cleaned legacy-path texture is selected, and z-order remains sleep pose < local duvet foreground < programmatic Z/z.
- `protagonist_sleep_side_v6.png` was intentionally not changed in this repair, following the bed handoff rule not to change pose and duvet simultaneously without rendered evidence.

## Validation
### Performed in this web worker
- Re-read latest `TASK_BOARD`, `FILE_OWNERSHIP`, `WEB_AGENT_LAUNCHPAD`, the branch report, branch diff, and current `HomeInteractionVisual.gd` from GitHub.
- Confirmed the latest task board still lists UI-FIX-002 as `READY` and provides no new review finding or expanded write scope.
- Confirmed the task branch is not behind the current orchestrator baseline `125419dac51af9539e0fcd5c1da34bb4824d64c0`.
- Confirmed branch changes remain limited to the three authorized paths listed above.
- Repository-inspected the cleaned PNG source identity and dimensions/alpha extent used by the guard.
- Extended the narrow regression to cover the default runtime layering/selection contract without modifying the read-only presentation script.

### Not performed
- Godot was **not** launched.
- `tools/verify_home_bed_seam.gd` was **not** executed.
- Existing `verify_home_presentation.gd` / `verify_home_activities.gd` regressions were **not** executed.
- `tools/capture_activity_props.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No rendered visual PASS is claimed.

### Prepared headless commands
Run on this exact review branch/head in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_home_bed_seam.gd`

`godot --headless --path . --script res://tools/verify_home_presentation.gd`

`godot --headless --path . --script res://tools/verify_home_activities.gd`

The first command now checks both PNG seam constraints and the default `HomeInteractionVisual` selection/z-order contract.

### Required rendered evidence before visual PASS
Run the existing `tools/capture_activity_props.gd` default/legacy path on this exact task head and inspect the real home scene for:
1. no duplicated/second bed and no large whole-bed foreground overlay;
2. lower body/duvet reading as one composition without a hard rectangular/polygon seam;
3. head remaining correctly related to the original pillow/background anchor;
4. foreground covering only the waist/leg region, not face/pillow/floor/unrelated furniture;
5. only the programmatic Z/z effect being visible;
6. enter-sleep fade, breathing pulse and wake/return transition remaining coherent.

## Known risks / review notes
- Rendered acceptance remains mandatory. The strengthened regression can verify the intended asset and layering contract but cannot prove the seam is visually invisible in the final scaled composition.
- Historical v3 A/B mode also changes sleep-pose transform. This task deliberately does not copy that transform into the default path because `scripts/**` is outside writable scope and the handoff explicitly advises against changing pose and duvet simultaneously. If rendered evidence still shows pose misalignment, it should become a separately authorized art/presentation follow-up rather than more transform magic numbers.
- Godot may regenerate local import cache metadata after the PNG source changes; committed `.png.import` settings were left untouched because source path/import configuration did not change.

## Commits
- `c93edc090b1eec13af92500ad2e83bcb3f53f697` — `fix: clean home bed foreground seam asset`
- `4ed70ea5033d47e692a166a8c83971ae03258fed` — `test: guard localized home bed seam asset`
- `58e62748b9158b17529b29379dc4f16f92157fc6` — `test: harden home bed seam asset guard`
- `adff4cf087468a451b7815781301505ad6d088ba` — `test: guard default bed layering contract`

## Handoff
UI-FIX-002 remains `NEEDS_REVIEW` from the worker side. This continuation found no coordinator rework finding, so the presentation asset was not changed again; the remaining safe repository work was completed by extending the narrow regression to the default layering/selection contract. No further source/presentation edit is justified without actual Godot rendered evidence. The next step is local/QA execution of the three headless commands and a real default-path home sleep capture on the exact review head.