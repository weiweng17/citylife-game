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
- Re-read latest `docs/agents/TASK_BOARD.md`, `docs/agents/FILE_OWNERSHIP.md`, `docs/agents/WEB_AGENT_LAUNCHPAD.md` and this lane report before continuing.
- Repository writable scope respected: **only `agent-reports/art-animation.md` changed**.
- No `assets/**`, scene, script, gameplay, UI, data, coordination, or `main` edit was made.
- Actual candidate visual output was generated in the 05 chat as required. It is **not** claimed to exist in GitHub, Godot, Web export, or the running game.
- No Godot 4.7.2, Web export, browser, rendered screenshot, or animation-playback validation was performed.

# ART-PROD-002 — First-hour embodied action candidate pack

## 1. Candidate pack produced in this continuation

Preferred current-turn contact sheet:
- candidate name: `ART002_first_hour_actions_contact_sheet_B`;
- image-generation id: `8fd1fe6c-cbfe-47e0-a547-f70108a31505`;
- generated source metadata: **RGBA, transparent background, 1448 × 1086 px**;
- visual layout: **4 columns × 3 action rows**;
- row 0: office workstation typing;
- row 1: home desk study / reading;
- row 2: home kitchen cooking / stirring.

A chat-workspace normalization pass was also prepared from the generated source; it is still **not a repository asset**:
- `art_prod_002_first_hour_actions_candidate_v1.png` — normalized 1024 × 768 contact sheet;
- `office_work_typing_4f_candidate_v1.png` — 1024 × 256 strip;
- `home_study_reading_4f_candidate_v1.png` — 1024 × 256 strip;
- `home_cooking_stirring_4f_candidate_v1.png` — 1024 × 256 strip;
- each strip is cut into four logical **256 × 256 RGBA** cells;
- workspace bundle: `ART-PROD-002_first-hour-actions_candidate-pack_v1.zip`.

The 4-column semantics are candidate key poses, not final animation timing:
1. enter / approach-contact;
2. contact / loop A;
3. loop B / gesture variation;
4. disengage / exit reference.

## 2. Canonical identity boundary

Repository identity target remains the active protagonist sheet:
- `assets/characters/sprites/gameplay/protagonist_walk_4x4.png`;
- active `LocationManager` frame convention: `256 × 256` per walk cell;
- current runtime uses a soft illustrated / non-pixel 2D sprite treatment inside fixed-camera 2.5D backgrounds.

**Important limitation:** the image generator did not receive the canonical repository sprite as a direct visual-conditioning image in this chat. The generated pack is internally coherent, but canonical face/outfit identity is **not proven**. Treat it as **pose/contact blocking + visual-direction candidate**, not final protagonist pixels. Final promotion needs an authorized identity-lock cleanup against the actual protagonist reference.

## 3. Shared production contract

Target production format after approval:
- `256 × 256` RGBA action cells;
- fixed logical actor/root anchor; recommended starting anchor `(128, 248)` for upright/root-normalized cells, then hand-calibrate seated actions in Godot;
- no camera or full background baked into actor frames;
- furniture in the generated contact sheet is reference geometry only;
- contact props must meet the hands/furniture, not float as the current procedural icon layer does;
- final split should be `actor` + optional `contact_prop` + `fixture_foreground` + optional `fx`.

Recommended frame budget for production, beyond this 4-pose candidate:
| Action | Enter | Loop | Exit | Facing |
|---|---:|---:|---:|---|
| Work typing | 3–4f | 4–6f | 3–4f | up / workstation-facing |
| Study reading | 3–4f | 4–6f | 3–4f | up |
| Cook / stir | 3–4f | 4–6f | 3–4f | 3/4 right-up |

## 4. Candidate A — office workstation typing

Repository contact target:
- `OfficeActivities.work.position = Vector2(700, 470)`;
- facing `Vector2(0, -1)`;
- current active `LocationManager` office background is `company_entrance_rain_night.webp`;
- repository also contains `open_office_rain_night.webp`, which is semantically more suitable for actual workstation contact.

Pose/contact intent:
- enter: settle into chair/workstation;
- contact: pelvis meets chair, torso leans toward desk;
- loop A/B: shoulders/wrists/head move subtly while both hands remain on one keyboard plane;
- exit: hands release and body rises/withdraws without root teleport.

**Blocking scene issue:** the current active office is an entrance image. A typing animation cannot be visually accepted until 00/02 authorizes a workstation-capable office composition. 05 does not change that scene in this task.

## 5. Candidate B — home study / reading

Repository contact target:
- `HomeActivities.study.position = Vector2(690, 365)`;
- facing `Vector2(0, -1)`;
- pose currently `sit`;
- interaction depth `402`;
- current home desk foreground/occlusion is around visual depth ~430.

Pose/contact intent:
- enter: lower into chair and bring arms forward;
- contact: pelvis/chair and forearms/desk contact become visible instead of scaling a standing frame;
- loop A/B: book stays on one desk plane while head/hand/page motion changes;
- exit: retract hand, rise, restore gameplay root at `(690, 365)`.

## 6. Candidate C — home cooking / stirring

Repository contact target:
- `HomeActivities.meal.position = Vector2(930, 440)`;
- facing `Vector2(1, -0.35)`;
- current pose `interact`;
- interaction depth `488`;
- kitchen/cabinet foreground reaches visual depth ~505.

Pose/contact intent:
- enter: angle torso toward cooker and reach for utensil;
- contact: utensil visibly enters pan/pot and off-hand stabilizes the vessel/counter relationship;
- loop A/B: elbow/wrist stirring changes while pan origin stays locked;
- exit: utensil retracts and actor restores standing root `(930, 440)`.

Steam should be separable FX, not the primary proof that cooking occurred.

## 7. Generated-sheet consistency findings

This output is **candidate-only**, not production-ready.

Observed defects / cleanup requirements:
1. Canonical identity match is unverified because direct repository sprite conditioning was unavailable.
2. Original generated canvas is 1448 × 1086 rather than a deterministic production atlas; the 1024 × 768 / 256-cell version is only a normalized chat-workspace derivative.
3. Furniture is baked into the generated cells; final actor sprites must be separated from desks/chairs/counter/cooker.
4. Root/foot placement shifts between some key poses. Alpha-bounds analysis of normalized 256 cells confirms differing bottom extents; action roots need manual alignment.
5. Office desk/chair geometry changes slightly between columns.
6. Study book/hand silhouettes and page geometry vary slightly; lock the book spine/contact plane before in-betweens.
7. Cooking pan/counter/utensil contact varies; lock one pan origin before interpolation.
8. Small hand/finger topology requires cleanup.
9. Generated lighting is too scene-specific in places; neutralize actor colors enough for warm-home and cool-office runtime tinting.
10. Work candidate is semantically ahead of the current active office entrance scene.

Normalized-cell alpha bounds measured during this task, useful only as drift evidence (not as final anchors):
- work cells: `(36,32)-(241,235)`, `(1,32)-(248,242)`, `(2,33)-(245,235)`, `(12,33)-(232,253)`;
- study cells: `(23,3)-(248,243)`, `(9,13)-(256,243)`, `(0,7)-(253,256)`, `(2,7)-(245,256)`;
- cook cells: `(0,8)-(246,228)`, `(2,13)-(253,242)`, `(6,0)-(256,239)`, `(2,1)-(211,221)`.

## 8. Exact integration handoff required from 02 / Codex

### 02 Scene/UI
1. Resolve a workstation-capable office presentation before final work-animation calibration; prefer reusing/composing the existing open-office art rather than inventing gameplay changes.
2. Author/confirm fixed contact foreground layers for home study desk/chair and home kitchen counter/cooker.
3. Author/confirm office desk/chair front layer after workstation scene selection.
4. Keep gameplay hotspot semantics and settlement values unchanged.

### Codex / Godot action integration
Requires a later explicit source/asset writable grant; **not performed here**.
1. Identity-lock the approved actor pixels against the canonical protagonist sheet.
2. Cut/clean deterministic `256 × 256` RGBA actor cells.
3. Normalize root/pivot and transparent edges.
4. Create states such as:
   - `work_type_enter`, `work_type_loop`, `work_type_exit`;
   - `study_read_enter`, `study_read_loop`, `study_read_exit`;
   - `cook_stir_enter`, `cook_stir_loop`, `cook_stir_exit`.
5. Keep book/utensil/contact props attached to hands and fixture coordinates.
6. Home study calibration baseline: `(690,365)`, facing up, depth `402`.
7. Home cooking calibration baseline: `(930,440)`, 3/4 right-up, depth `488`.
8. Office `(700,470)` is only an approach reference until the workstation composition is approved.
9. Verify action exit restores normal walk/idle scale, root and occlusion with no pop.

## 9. Runtime / rendered validation package — PREPARED, NOT RUN

No verifier file was added because ART-PROD-002 grants report-only repository writes.

Later exact-SHA Godot/Codex evidence should capture for work/study/cook:
- first enter frame;
- first contact frame;
- at least two loop poses;
- last exit frame;
- immediate return to walk/idle.

Acceptance checks:
- no root/foot slide during loop;
- hands stay attached to laptop/book/utensil;
- seated pelvis does not float over chair;
- book/pan/laptop do not change size/perspective across the loop;
- desk/counter foreground cuts the body at believable depth;
- no one-frame scale/root pop in walk → action → walk;
- loop endpoints do not visibly snap;
- canonical identity/outfit stays constant;
- existing activity input blocking and exactly-once settlement remain unchanged;
- office typing is tested against the final workstation-capable composition, not the current entrance image alone.

Runtime evidence boundary:
- Godot 4.7.2 launch: **NOT RUN**;
- rendered 1280×720 / 960×540 captures: **NOT RUN**;
- animation-loop playback: **NOT RUN**;
- Web export/browser smoke: **NOT RUN**.

## 10. Suggested next narrow task

After 00 review, safest next art-only step:

**ART-PROD-003 — canonical identity lock + cleaned exact-256 keyframes for Home Study and Home Cook first.**

Home already has the strongest 2.5D contact geometry and does not need to wait on the office-scene semantic fix. Work can enter final cleanup after 00/02 selects the workstation presentation.

## Files changed
- `agent-reports/art-animation.md` only.

## Validation performed in this task
- latest coordination scope re-read: PASS;
- active 256 px player-cell convention re-checked by source inspection: PASS;
- Home study/cook anchors re-checked: PASS;
- Office work anchor and entrance/workstation semantic mismatch re-checked: PASS;
- candidate source inspected: RGBA transparent, 1448 × 1086: PASS;
- chat-workspace normalized derivative prepared: 1024 × 768, 4 × 3 grid, 256 × 256 logical cells: PASS;
- alpha-bound drift audit: performed and recorded above;
- repository production assets modified: **none**;
- Godot/render/Web/browser validation: **NOT RUN**.

## Handoff
`ART-PROD-002` requests 00-Orchestrator review at **NEEDS_REVIEW**. Preferred current-turn candidate is `ART002_first_hour_actions_contact_sheet_B` (generation id `8fd1fe6c-cbfe-47e0-a547-f70108a31505`). The generated/normalized images exist only as chat/workspace deliverables and are **not** GitHub/Godot assets. Promotion to `assets/**`, scene composition, or animation-state integration requires a later explicit task grant.
