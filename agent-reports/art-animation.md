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

## Scope / contract respected
- Latest coordination task board was re-read before production.
- Repository writable scope for this pass is **only** `agent-reports/art-animation.md`.
- No `assets/**`, scene, script, gameplay, UI, data, coordination or `main` file is modified by 05 in this task.
- Chat image-generation output is the actual visual candidate deliverable for this pass; it is **not** claimed to exist in GitHub or Godot.
- No Godot, Web export, browser, screenshot-in-engine, animation playback or runtime validation was performed.

# ART-PROD-002 — First-hour embodied action candidate pack

## 1. Production goal

Produce one coherent first-pass candidate sheet covering the three highest-frequency missing first-hour player actions:

1. `work_type` — office workstation typing;
2. `study_read` — home desk study / reading;
3. `cook_stir` — home kitchen cooking / stirring.

The goal is not final polish. The goal is to replace the current “standing body + floating programmatic prop + progress text” presentation with an animation-ready body/hand/prop contact concept that 02/Codex can later integrate and calibrate.

## 2. Canonical player identity locked for this pack

Reference identity is the current runtime protagonist, not a redesign:
- source runtime sheet: `assets/characters/sprites/gameplay/protagonist_walk_4x4.png`;
- runtime action cell convention: `256×256`;
- young dark-haired protagonist;
- messy/soft dark hair silhouette;
- dark charcoal/gray casual jacket/hoodie silhouette, dark trousers and simple shoes;
- compact anime/chibi game sprite proportions rather than realistic portrait proportions;
- soft painted/non-pixel sprite rendering compatible with the current 2.5D illustrated backgrounds;
- no costume swap, age change, facial redesign or promotional-poster rendering.

Known limitation of this web production pass: the image generator is being driven from the canonical repository/style specification and previously established character identity rather than a Godot-rendered frame capture. Therefore exact facial pixels, jacket seam details and sub-pixel silhouette continuity must remain a manual acceptance item before any asset becomes canonical.

## 3. Candidate sheet layout

Chat visual deliverable name:
- `ART002_first_hour_actions_candidate_v01`

Logical sheet layout:
- transparent RGBA background;
- `4 columns × 3 rows`;
- each logical cell: `256×256`;
- row order:
  - row 0 = `work_type`;
  - row 1 = `study_read`;
  - row 2 = `cook_stir`;
- frame order for every row:
  - F0 `enter`;
  - F1 `contact / loop_A`;
  - F2 `loop_B`;
  - F3 `exit`.

This is intentionally a **candidate key-pose pack**, not a claim that four frames are enough for final production. F1↔F2 must already read as a believable micro-loop. If accepted, the production refinement pass may interpolate/paint additional in-betweens without changing anchor/contact geometry.

## 4. Shared geometry contract

### 4.1 Cell anchor
- fixed logical action anchor: `(128, 248)` inside every `256×256` cell;
- the anchor corresponds to the current runtime foot/base convention implied by `LocationManager` using `offset = Vector2(-128, -248)`;
- no frame may vertically drift the whole body around this anchor;
- seated frames may move knees/hips, but the chair/floor relation must remain anchored to the same base reference.

### 4.2 Scale / camera
- no camera perspective baked into the sprite;
- no scene background inside the cells;
- same 2.5D / three-quarter visual language as current gameplay sprites;
- intended runtime scale remains compatible with current `0.32` player scale before scene-specific calibration.

### 4.3 Contact rule
Props are not decorative badges. In every contact/loop frame:
- wrists terminate at the actual prop/contact surface;
- fingers/forearms point into the laptop/book/spoon interaction;
- prop remains at a stable contact plane across the loop;
- no floating halo/circular UI backing;
- desk/counter itself should be represented only by the minimum contact edge/guide needed for pose readability, because final furniture foreground comes from the scene layer.

## 5. Candidate A — `work_type`

### Runtime target
- gameplay location: `office`;
- current interaction anchor: player foot point `(700, 470)`;
- facing: up `(0, -1)`;
- current active background is `company_entrance_rain_night.webp`, which is semantically unsuitable for desk work;
- intended visual contact target for later integration: existing `assets/backgrounds/dialogue/company/open_office_rain_night.webp`.

### Four key poses
- F0 enter: character turns/settles toward chair/workstation, hands moving toward keyboard;
- F1 contact/loop_A: seated/forward-working pose, both hands contacting keyboard/laptop, shoulders slightly forward;
- F2 loop_B: alternate typing pose with small wrist/shoulder/head change, laptop stays fixed;
- F3 exit: hands leave keyboard, torso begins to rise/withdraw without teleporting.

### Contact geometry
- back/up-facing workstation pose;
- laptop/keyboard contact is centered slightly above the torso hand line;
- both hands must visibly land on the keyboard plane;
- chair/desk foreground is not baked as a full object; 02/Codex should place the final desk-front occluder above the lower body.

### Known production risk
Because the currently active office map is an entrance background, final acceptance of `work_type` requires a scene integration decision. 05 does not change that scene in this task.

## 6. Candidate B — `study_read`

### Runtime target
- gameplay location: `home`;
- interaction anchor: player foot point `(690, 365)`;
- facing: up `(0, -1)`;
- home desk foreground is already represented by the detailed home occlusion geometry around the desk region.

### Four key poses
- F0 enter: character lowers/settles toward desk, arms come forward;
- F1 contact/loop_A: seated reading pose, open book lies on desk plane, both hands touch/steady pages;
- F2 loop_B: subtle page-turn / hand-shift pose; book spine and desk contact stay fixed;
- F3 exit: book closes/hand retracts and torso starts returning to standing.

### Contact geometry
- the open book remains at one stable desk plane across F1/F2;
- one hand may hold the page while the other traces/writes, but neither floats away from the book;
- the body reads as genuinely seated rather than the current fake “standing sprite scaled down” pose;
- lower legs/chair edge are allowed to be partly hidden by the existing foreground desk layer.

## 7. Candidate C — `cook_stir`

### Runtime target
- gameplay location: `home`;
- interaction anchor: player foot point `(930, 440)`;
- facing: right/up `(1, -0.35)`;
- kitchen foreground/cabinet occlusion begins immediately to the right of this interaction area, with front-depth around the existing kitchen foreground.

### Four key poses
- F0 enter: body angles toward counter, dominant hand reaches for spoon/utensil;
- F1 contact/loop_A: spoon visibly enters pot; off-hand stabilizes pot/counter edge;
- F2 loop_B: alternate stirring arc with small shoulder/elbow movement; pot position remains locked;
- F3 exit: utensil lifts/retracts while body begins returning from the counter.

### Contact geometry
- 3/4 right-back pose, matching the existing right/up interaction facing;
- pot sits on a fixed counter/stove plane;
- utensil tip must overlap the pot interior in loop frames;
- steam is optional secondary FX and must not carry the action readability by itself;
- final counter-front occlusion should cover part of the hands/waist only where scene geometry requires it.

## 8. Consistency acceptance checklist for the generated candidate

Before promotion to a repository asset, 02/Codex/manual art review must reject or correct any frame with:
- hair silhouette changing between frames;
- jacket/hoodie hem, sleeves or shoe design changing;
- face/ear placement changing unnaturally;
- hand count/finger/arm topology errors;
- laptop/book/pot changing size or perspective during the loop;
- body center drifting away from `(128,248)` anchor convention;
- seated poses changing apparent character scale;
- contact props floating or clipping through the torso;
- lighting baked so strongly that it cannot work in both warm home and cooler office tint;
- opaque/matte background contamination.

## 9. Exact integration work required from 02 / Codex

No integration is performed here. The narrow follow-up should:

1. Export/crop the accepted chat candidate into separate RGBA cells or a deterministic sprite sheet under a **new 00-authorized `assets/**` path**.
2. Verify exact `256×256` cell boundaries and `(128,248)` base anchor; correct transparent-edge artifacts.
3. Add action animations without replacing the existing walk sheet:
   - `work_type_enter`, `work_type_loop`, `work_type_exit`;
   - `study_read_enter`, `study_read_loop`, `study_read_exit`;
   - `cook_stir_enter`, `cook_stir_loop`, `cook_stir_exit`.
4. Map F1/F2 to loop playback; final frame count may expand after in-between cleanup.
5. Connect action state to existing activity feedback only under explicit Gameplay/Scene authorization; 05 does not alter `LocationManager.gd`.
6. Home study calibration:
   - foot/base anchor at `(690,365)`;
   - face up;
   - verify desk foreground covers lower body naturally and book lands on the desk plane.
7. Home cook calibration:
   - base anchor at `(930,440)`;
   - 3/4 right-up orientation;
   - verify pot/counter contact and existing kitchen foreground depth.
8. Office work calibration:
   - do **not** approve final work contact against the current entrance background;
   - use/compose `open_office_rain_night.webp` only in a later explicitly authorized Scene/UI task;
   - recalibrate the current rough `(700,470)` work anchor to the actual workstation in that scene.
9. Preserve current walk/idle behavior and free movement when no activity is active.
10. Add no gameplay-value or settlement changes as part of art integration.

## 10. QA / validation package — prepared, not run

Required exact-SHA Godot/Codex validation after integration:

### Asset checks
- texture has alpha and no matte fringe;
- imported sheet cell dimensions are exact;
- no accidental filtering/region bleed between cells;
- action names and loop ranges are deterministic.

### Home study
- approach to `(690,365)` still works;
- activity starts with enter, reaches F1/F2 loop, exits cleanly;
- book is visibly contacted by both body and desk;
- existing desk foreground covers the correct lower-body segment;
- cancelling/completing activity returns to normal walk/idle without anchor jump.

### Home cooking
- approach to `(930,440)` still works;
- spoon/pot contact holds through the loop;
- body does not clip visibly through the cabinet foreground;
- exit returns to the same foot point.

### Office work
- validate only after an authorized workstation-capable office composition exists;
- typing loop must visually align to a real desk/laptop/chair;
- current `company_entrance_rain_night.webp` is not acceptable evidence for workstation contact.

### Runtime evidence boundary
- Godot 4.7.2 headless/manual launch: **NOT RUN**;
- rendered 1280×720 / 960×540 screenshots: **NOT RUN**;
- Web export/browser smoke: **NOT RUN**;
- animation-loop playback: **NOT RUN**.

These checks belong to the single exact-SHA QA/Codex lane after integration; source/chat inspection is not a runtime PASS.

## 11. Handoff summary

Generated candidate names recorded for this pass:
- `ART002_work_type_v01` — row 0;
- `ART002_study_read_v01` — row 1;
- `ART002_cook_stir_v01` — row 2;
- combined chat sheet: `ART002_first_hour_actions_candidate_v01`.

Recommended disposition after 00 review:
- accept as **candidate key-pose direction**, not final production-ready sprites;
- next art step should be consistency cleanup/in-betweens only after 02/Codex confirms scene contact geometry;
- do not generate a second divergent character design before the first candidate has been tested against Home/Office contact.

## Validation performed in this web task
- coordination scope re-read: PASS;
- runtime protagonist path / 256px cell convention re-checked in `LocationManager.gd`: PASS by source inspection;
- Home study/cook anchors re-checked in `HomeActivities.gd`: PASS by source inspection;
- Office work anchor and semantic background mismatch re-checked in `OfficeActivities.gd` + `LocationManager.gd`: PASS by source inspection;
- existing `open_office_rain_night.webp` availability re-checked: PASS by repository inspection;
- repository production assets modified: **none**;
- actual candidate art: delivered in the 05 chat for this task, not stored in GitHub;
- Godot/render/Web validation: **not run**.

## Handoff
`ART-PROD-002` requests 00-Orchestrator review at **NEEDS_REVIEW**. Repository handoff is intentionally report-only per task authorization; the visual candidate is the chat artifact and must be explicitly promoted by a later task before it becomes a repository/Godot asset.
