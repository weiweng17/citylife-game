# Art / Animation Agent Report

## Agent
- Lane: 05-Art-Animation
- Owner key: `art-animation`
- Coordination branch: `orchestrator/multi-agent-bootstrap`

## Current task
- ID: `ART-PROD-002`
- Title: First-hour embodied action candidate pack
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: **NEEDS_REVIEW**
- Priority: HIGH
- Task type: player-visible art candidate production + integration manifest

## Scope / contract compliance
- Re-read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md`, and this lane report before production.
- Repository writable scope respected: **only `agent-reports/art-animation.md` changed**.
- No `assets/**`, scene, script, gameplay, UI, data, coordination, or `main` edit was made.
- Actual visual candidate output was generated in the 05 chat, as required. It is **not** claimed to exist in GitHub, Godot, a Web export, or the running game.
- No Godot 4.7.2, Web export, browser, rendered screenshot, animation playback, or exact-SHA runtime validation was performed.

# ART-PROD-002 — First-hour embodied action candidate pack

## 1. Generated candidate output

Chat-generated candidate contact sheet:
- working name: `ART002_first_hour_actions_contact_sheet_A`;
- image-generation id: `9366ef7c-33c5-425e-8297-56b11836a268`;
- actual generated image metadata checked in this task: **RGBA, transparent background, 1448 × 1086 px**;
- visual layout: **4 columns × 3 action rows**;
- row 0: office workstation typing;
- row 1: home desk study / reading;
- row 2: home kitchen cooking / stirring;
- column semantics for every row:
  1. `enter / approach-contact`,
  2. `contact / loop_A`,
  3. `loop_B`,
  4. `exit / disengage`.

Generated candidate names:
- `ART002_work_type_v01` — row 0;
- `ART002_study_read_v01` — row 1;
- `ART002_cook_stir_v01` — row 2.

This is a **key-pose/contact candidate sheet**, not a production sprite atlas. The production target remains exact `256 × 256` RGBA action cells with fixed actor/root anchors. The generated canvas is not a deterministic 1024 × 768 atlas and must not be imported as-is.

## 2. Canonical identity / style contract

Repository identity target remains the current runtime protagonist:
- source runtime sheet: `assets/characters/sprites/gameplay/protagonist_walk_4x4.png`;
- current action-cell convention: `256 × 256`;
- soft painted / non-pixel 2D sprite treatment compatible with the current illustrated 2.5D backgrounds;
- preserve the current protagonist's age, body proportions, dark-hair silhouette, clothing identity, and foot/base convention;
- no costume redesign, age change, promotional-poster rendering, or alternate character concept.

**Known identity limitation of this generated contact sheet:** the image generator did not receive the repository's canonical protagonist sheet as a direct visual reference in this chat. The sheet is internally coherent but should therefore be treated as **motion/contact blocking**, not final canonical face/outfit pixels. An authorized identity-lock cleanup pass is required before repository promotion.

## 3. Shared frame / anchor contract

### Logical production cell
- target cell: `256 × 256` RGBA;
- fixed logical base anchor: `(128, 248)` inside each cell, matching the current runtime foot/base convention implied by `LocationManager`'s 256 px player frame and bottom-biased offset;
- no whole-body vertical drift during loop frames;
- no camera/background baked into actor frames;
- furniture in the concept sheet is **contact reference geometry**, not final actor-sprite content.

### Recommended production split
- `actor` sheet;
- `contact_prop` layer where a prop must travel with the hands (book / utensil, optionally laptop if not scene-fixed);
- `fixture_foreground` for desk/counter/chair occlusion;
- optional separable `fx` layer (steam, screen glow).

### Initial frame budget
| Action | Enter | Loop | Exit | Production cell | Facing |
|---|---:|---:|---:|---|---|
| Work typing | 3–4f | 4–6f | 3–4f | 256×256 RGBA | up / workstation-facing |
| Study reading | 3–4f | 4–6f | 3–4f | 256×256 RGBA | up |
| Cook / stir | 3–4f | 4–6f | 3–4f | 256×256 RGBA | 3/4 right-up |

The 4-column generated contact sheet is a pose-language candidate, not a claim that four frames are enough for final motion.

## 4. Candidate A — workstation typing

### Repository target
Current office activity source:
- `OfficeActivities.work.position = Vector2(700, 470)`;
- facing = `Vector2(0, -1)`;
- active `LocationManager` office background = `company_entrance_rain_night.webp`;
- repository also contains `assets/backgrounds/dialogue/company/open_office_rain_night.webp`, which is semantically more suitable for a workstation scene.

### Contact / motion intent
- enter: turn/settle into chair/workstation;
- contact: pelvis meets chair seat and torso leans naturally toward desk;
- loop A/B: alternating shoulder/wrist/head micro-movement while **both hands remain on the keyboard/laptop plane**;
- exit: hands release keyboard and body rises/withdraws without a root teleport.

### Critical dependency
The candidate depicts a real workstation. The currently active office map is an **entrance**. Therefore `work_type` cannot be visually accepted against the present active office background. 02/00 must authorize the smallest workstation-capable office presentation before final calibration. 05 does not change scene composition in this task.

## 5. Candidate B — study / reading

### Repository target
- `HomeActivities.study.position = Vector2(690, 365)`;
- facing = `Vector2(0, -1)`;
- current pose is `sit`;
- depth = `402`;
- current home desk foreground/occluder is authored around visual depth approximately `430`.

### Contact / motion intent
- enter: body lowers/settles into chair and arms come forward;
- contact: seated body genuinely meets chair/desk instead of scaling a standing frame;
- loop A/B: open book stays on one stable desk plane while one/both hands steady/turn/read the page;
- exit: hand retracts, torso rises, root returns to the gameplay approach point.

### Geometry requirement
- return anchor after exit: `(690,365)`;
- desk foreground should cover the appropriate lower-body segment;
- book position/spine must not drift between loop frames.

## 6. Candidate C — cooking / stirring

### Repository target
- `HomeActivities.meal.position = Vector2(930, 440)`;
- facing = `Vector2(1, -0.35)`;
- current pose is `interact`;
- depth = `488`;
- kitchen/cabinet foreground reaches visual depth around `505`.

### Contact / motion intent
- enter: body angles toward cooker and dominant hand reaches for utensil;
- contact: utensil visibly enters the pan/pot; off-hand stabilizes the vessel/counter contact;
- loop A/B: stirring arc changes through shoulder/elbow/wrist while pan/pot origin stays locked;
- exit: utensil retracts and actor returns to normal standing root.

### Geometry requirement
- return anchor after exit: `(930,440)`;
- pan/pot must remain on a single cooker plane;
- steam should be separated as an FX layer rather than baked as the primary action cue;
- counter foreground should occlude body/arms only where the scene geometry actually requires it.

## 7. Consistency defects in the generated candidate

The output is intentionally **not production-ready**. Known defects/risks recorded for review:

1. Canonical identity match is not proven because no direct canonical sprite image reference was supplied to generation.
2. Output canvas is `1448 × 1086`, not twelve exact `256 × 256` cells.
3. Actor root/foot placement drifts between some enter/contact/exit poses and requires manual normalization.
4. Furniture dimensions/perspective vary slightly between columns; desks/chairs/counter should not be baked into final actor cells.
5. Work row is semantically ahead of the current active office entrance scene.
6. Study hand/book silhouettes vary between frames; page edge and wrist continuity need cleanup.
7. Cooking steam is oversized/variable; separate it from actor art and reduce amplitude.
8. Cooking pan/counter placement changes slightly; lock one contact origin before any in-betweens.
9. Small hand/finger topology requires manual cleanup before loop interpolation.
10. Scene lighting in the generated art must be neutralized enough to accept warm-home and cool-office runtime tinting.

## 8. Exact integration work required from 02 / Codex

No integration was performed here. A later explicitly authorized task should:

### 02 Scene/UI presentation work
1. Resolve the office workstation presentation before `work_type` integration:
   - use/compose the existing open-office art, or
   - provide another explicitly authorized workstation contact layer.
2. Create fixed contact/foreground layers for:
   - home study desk/chair;
   - home kitchen counter/cooker;
   - office workstation desk/chair after the office target is decided.
3. Furniture must stay static while actor/contact props animate.
4. Preserve existing hotspot/gameplay semantics; do not change timers, costs, rewards, or stats as part of visual integration.

### Codex / Godot action-state work
Requires a new script/asset writable grant; **not performed here**.
1. Clean/crop approved art into deterministic `256 × 256` RGBA action cells.
2. Normalize the base anchor and eliminate transparent-edge/matte artifacts.
3. Create action states such as:
   - `work_type_enter`, `work_type_loop`, `work_type_exit`;
   - `study_read_enter`, `study_read_loop`, `study_read_exit`;
   - `cook_stir_enter`, `cook_stir_loop`, `cook_stir_exit`.
4. Route current activity presentation into those animation states without modifying settlement values.
5. Home study calibration baseline: `(690,365)`, facing up, depth `402`.
6. Home cooking calibration baseline: `(930,440)`, 3/4 right-up, depth `488`.
7. Office work baseline: current `(700,470)` only as an approach reference; recalibrate to the chosen workstation art.
8. Ensure action exit restores normal player scale/root/occlusion with no visible pop.

## 9. Runtime / rendered validation package — PREPARED, NOT RUN

No verifier file was added because `TASK_BOARD.md` grants **report-only repository writes** for ART-PROD-002.

A later exact-SHA Codex/QA package should capture, for each of work / study / cook:
- first enter frame;
- first contact frame;
- loop A;
- loop B;
- last exit frame;
- immediate return to walk/idle.

Minimum rendered acceptance checks:
- actor root/feet do not slide during loop;
- hands stay attached to laptop/book/utensil;
- seated pelvis does not float over chair;
- book/pan/laptop do not change size/perspective across loop frames;
- desk/counter foreground cuts the body at believable depth;
- no one-frame scale/root jump during walk → action → walk;
- first/last loop frames do not visibly snap;
- actor identity/outfit remains constant;
- existing activity input blocking and exactly-once settlement remain unchanged;
- exit restores normal movement and occlusion.

Office-specific gate:
- do **not** accept `work_type` because it animates in isolation;
- it must be rendered against the final authorized workstation-capable office composition;
- current company-entrance background is not sufficient workstation-contact evidence.

Runtime evidence boundary:
- Godot 4.7.2 launch: **NOT RUN**;
- rendered 1280×720 / 960×540 captures: **NOT RUN**;
- animation-loop playback: **NOT RUN**;
- Web export/browser smoke: **NOT RUN**.

## 10. Recommended next narrow art task

After 00 review, safest next 05-only production step:

**ART-PROD-003 — canonical identity lock + cleaned exact-256 keyframes for Home Study and Home Cook first.**

Reason: Home already has the strongest 2.5D contact geometry and can validate the action pipeline without waiting on the office-scene semantic fix. Work can enter final cleanup once 00/02 chooses the workstation presentation.

## Files changed
- `agent-reports/art-animation.md` only.

## Validation performed in this web task
- coordination scope re-read: PASS;
- runtime player `256` px convention re-checked by source inspection: PASS;
- Home study/cook anchors re-checked in `HomeActivities.gd`: PASS;
- Office work anchor/background semantic mismatch re-checked in `OfficeActivities.gd` + `LocationManager.gd`: PASS;
- generated candidate metadata checked: RGBA transparent, `1448 × 1086`: PASS;
- repository production assets modified: **none**;
- Godot/render/Web/browser validation: **not run**.

## Handoff
`ART-PROD-002` requests 00-Orchestrator review at **NEEDS_REVIEW**. The visual candidate exists in this 05 chat (generation id `9366ef7c-33c5-425e-8297-56b11836a268`) but is not a GitHub/Godot asset. Promotion to `assets/**`, scene composition, or animation-state integration requires a later explicit task grant.
