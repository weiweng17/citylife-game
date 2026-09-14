# Art / Animation Agent Report

## Agent
- Lane: 05-Art-Animation
- Owner key: `art-animation`
- Coordination branch: `orchestrator/multi-agent-bootstrap`

## Current task
- ID: `ART-PROD-003`
- Title: First-day action cleanup candidates: cooking + typing
- Branch: `agent/art-prod-003-first-day-action-cleanup`
- Status: **NEEDS_REVIEW**
- Priority: HIGH
- Task type: player-visible art cleanup candidate + deterministic ingestion handoff

## Scope / contract compliance
- Re-read current `HANDOFF.md`, `docs/agents/MASTER_PLAN.md`, `docs/agents/AGENT_RULES.md`, `docs/agents/TASK_BOARD.md`, `docs/agents/FILE_OWNERSHIP.md`, `docs/agents/WEB_AGENT_LAUNCHPAD.md`, and this lane report before editing.
- Latest task board still grants **`agent-reports/art-animation.md` only** as repository writable scope for ART-PROD-003.
- No `assets/**`, scene, script, gameplay, UI, data, coordination file, or `main` edit was made.
- Actual visual outputs remain chat/workspace deliverables only. They are **not** claimed to exist in the repository, Godot runtime, Web export, or running game.
- Study remains deferred exactly as assigned; this task covers **home cooking/stirring first, office typing second**.

# ART-PROD-003 — Cooking + typing cleanup handoff

## 1. Repository state re-check

Task branch head at start of this continuation:
- `agent/art-prod-003-first-day-action-cleanup`
- exact head: `9fbeb0628eda40f93a72f96150508113e2c8fbcc`
- this was still the accepted ART-PROD-002 baseline, matching TASK_BOARD.

Current runtime contact targets re-checked from source:

### Home cooking
- `HomeActivities.meal.position = Vector2(930, 440)`
- facing `Vector2(1, -0.35)`
- pose `interact`
- depth `488`
- home kitchen foreground/occluder depth around `505`

### Office work
- `OfficeActivities.work.position = Vector2(700, 470)`
- facing `Vector2(0, -1)`
- current active office background remains `company_entrance_rain_night.webp`
- therefore a final typing animation still cannot receive visual/runtime acceptance until a workstation-capable office composition is explicitly authorized by 00/02.

Canonical protagonist target remains:
- `assets/characters/sprites/gameplay/protagonist_walk_4x4.png`
- active logical player-cell convention: `256 × 256`.

## 2. ART-PROD-003 chat candidate package produced

Workspace/chat package:
- `ART-PROD-003_cooking_typing_candidate_handoff.zip`
- size: `788790` bytes
- SHA-256: `799548187e42d01284a09dcaccb45cc195a041b338b951b095e76f01c30e8668`
- package is **not** a repository asset.

Contents include:
- exact-256 individual cells for `enter`, `contact`, `loopA`, `loopB`, `exit`;
- one 5-pose 1280×256 strip per action;
- one 256×256 fixture-reference crop per action;
- `manifest.json` with source hashes, selected source frames, common scale, paste coordinates and limitations;
- `README.md` defining the promotion boundary.

Normalization applied to both actions:
- transparent RGBA output;
- generated frame-number/footer area removed from selected logical cells;
- one common scale per action instead of per-frame scaling;
- logical cell size fixed to exactly `256 × 256`;
- blocking baseline aligned to `y = 248`;
- recommended upright/root starting anchor remains `(128, 248)`;
- no scene background baked into the normalized canvas.

Important boundary: the source generations still bake workstation/kitchen fixture geometry together with the actor. The package therefore provides **cleaner deterministic contact-blocking candidates plus separate fixture references**, not final actor-only production pixels. Final actor/fixture/prop separation requires the later explicit ingestion task.

## 3. Candidate A — home cooking / stirring

Source used in this continuation:
- source chat file: `像素厨师烹饪动画序列.png`
- source: RGBA, `2172 × 724`
- source SHA-256: `dfa1b4c48b55bed957052d348b51a8d96d45ba1401a140f64e54367cf7318292`

Selected source-frame semantics:
1. source frame 1 → `enter`
2. source frame 2 → `contact`
3. source frame 4 → `loopA`
4. source frame 8 → `loopB`
5. source frame 12 → `exit`

Normalized deliverables:
- `cook_5pose_1280x256.png`
- sheet SHA-256: `9825c72040e087fd5682a65846fce786b063ac5fe8df2f668afd1e41c35a90c2`
- `cook_fixture_reference_256.png`
- fixture-ref SHA-256: `cb9bfd851b789911c88c6c8d744cba0bcf097e3352873f70bcb6298284157109`

Common scale used across selected cooking poses:
- `0.6723646723646723`

Normalized logical cells:
| Pose | Source frame | Normalized content px | Paste `(x,y)` |
|---|---:|---:|---:|
| enter | 1 | 114×235 | (71,13) |
| contact | 2 | 119×235 | (68,13) |
| loopA | 4 | 104×235 | (76,13) |
| loopB | 8 | 122×236 | (67,12) |
| exit | 12 | 101×236 | (78,12) |

Contact-plane intent locked for later redraw/ingestion:
- one cooker/pan origin throughout contact + loop poses;
- utensil remains on the same pan/contact side;
- off-hand stays in the same vessel/counter relationship;
- steam/fire remain optional separable FX and must not carry the action readability alone.

Known candidate limitation:
- fixture is still present in actor source cells, so the pan/utensil plane is a **selected reference plane**, not yet a pixel-perfect production lock.

## 4. Candidate B — office workstation typing

Source used in this continuation:
- source chat file: `办公桌前打字动画序列.png`
- source: RGBA, `2172 × 724`
- source SHA-256: `d9750a15b2d6ea5fffa369d5218610ebcc537bdc1ed2737b0dda13e0790bba34`

Selected source-frame semantics:
1. source frame 1 → `enter`
2. source frame 2 → `contact`
3. source frame 5 → `loopA`
4. source frame 8 → `loopB`
5. source frame 12 → `exit`

Normalized deliverables:
- `typing_5pose_1280x256.png`
- sheet SHA-256: `3ae2fb7e5cc61965ba0874593655231584b4b94986d0dbddc39884a3a0043745`
- `typing_fixture_reference_256.png`
- fixture-ref SHA-256: `ce2065ef9418a0307e755c06e643e2dea531ab7eb74d075634e85794a78ee452`

Common scale used across selected typing poses:
- `0.6840579710144927`

Normalized logical cells:
| Pose | Source frame | Normalized content px | Paste `(x,y)` |
|---|---:|---:|---:|
| enter | 1 | 113×235 | (72,13) |
| contact | 2 | 124×203 | (66,45) |
| loopA | 5 | 124×205 | (66,43) |
| loopB | 8 | 124×205 | (66,43) |
| exit | 12 | 113×236 | (72,12) |

Contact-plane intent locked for later redraw/ingestion:
- one desk/keyboard plane for `contact`, `loopA`, `loopB`;
- seated pelvis must stay fixed to one chair-contact position;
- typing variation should come from wrists/shoulders/head, not keyboard/desk motion;
- exit releases hands before restoring the gameplay root.

Known candidate limitation:
- the generated fixture remains baked into the source; the hand/keyboard relation is suitable as a cleanup reference but still requires actor-only separation and workstation scene calibration.

## 5. Exact production promotion contract

A later asset-ingestion task should promote approved art as:

### Cooking
- actor cells: exact 256×256 RGBA;
- `cook_enter`, `cook_contact`, `cook_loop_a`, `cook_loop_b`, `cook_exit`;
- separate kitchen fixture foreground;
- optional separate utensil/pan/contact-prop layer if needed for hand lock;
- optional separate steam/fire FX;
- baseline gameplay calibration: `(930,440)`, facing 3/4 right-up, depth `488`, kitchen foreground around depth `505`.

### Typing
- actor cells: exact 256×256 RGBA;
- `work_type_enter`, `work_type_contact`, `work_type_loop_a`, `work_type_loop_b`, `work_type_exit`;
- separate desk/chair/monitor foreground/reference;
- fixed keyboard contact plane;
- baseline approach reference: `(700,470)`, facing up;
- final calibration blocked until a workstation-capable office composition is authorized.

Shared production rules:
- canonical identity must be locked against the active protagonist sheet before calling these final protagonist pixels;
- no frame numbers, grid lines, labels or scene background in production actor sheets;
- fixed logical crop, scale and pivot across each action;
- no one-frame root/scale pop on walk → action → walk;
- fixture perspective and size must not mutate across loop frames.

## 6. Validation package — PREPARED, NOT RUN

No repository verifier file was added because ART-PROD-003 grants report-only writes.

Local/chat validation performed:
- latest coordination scope re-read: PASS;
- branch head re-checked: PASS;
- Home cooking contact target re-checked from source: PASS;
- Office work contact target re-checked from source: PASS;
- active 256 px player-cell convention re-checked: PASS;
- source image mode/dimensions inspected: PASS;
- exact 256×256 logical candidate cells generated in workspace: PASS;
- one common scale per action: PASS;
- transparent RGBA candidate canvases: PASS;
- frame-number/footer excluded from normalized logical cells: PASS;
- deterministic SHA-256 manifest prepared: PASS.

Runtime/render evidence boundary:
- Godot 4.7.2 launch: **NOT RUN**;
- Godot import / SpriteFrames creation: **NOT RUN**;
- animation playback: **NOT RUN**;
- rendered 1280×720 / 960×540 captures: **NOT RUN**;
- Web export/browser smoke: **NOT RUN**.

Required later Godot/Codex evidence on one frozen exact SHA:
1. walk → cooking enter/contact/loopA/loopB/exit → walk;
2. walk → typing enter/contact/loopA/loopB/exit → walk;
3. no root slide or scale pop;
4. hands remain attached to prop/keyboard plane;
5. foreground occlusion cuts legs/body at believable depth;
6. loop endpoints do not snap;
7. canonical face/outfit identity is constant;
8. activity lock and exactly-once settlement remain unchanged;
9. typing is accepted only against the final workstation-capable office presentation.

## 7. Known issues / risks

1. Canonical protagonist identity is still unproven because these chat sources were not generated by direct conditioning on the repository protagonist sprite.
2. Source generations still contain fixture geometry in actor poses; this task provides normalized blocking candidates + separate fixture references, not final actor-only sheets.
3. Small hand/finger topology remains AI-generated and requires cleanup before production promotion.
4. Cooking utensil/pan and typing hand/keyboard planes are selected as the preferred reference geometry but are not claimed pixel-perfect until fixture/actor separation.
5. Office remains semantically mismatched: active runtime background is the company entrance, not a real workstation interior.
6. No runtime/render/Web evidence exists yet; final acceptance belongs to the later explicit ingestion/integration task plus QA-002.

## Files changed
- `agent-reports/art-animation.md` only.

## Suggested next task
After 00 review of ART-PROD-003:

**ART-INGEST-004 — first-day action asset ingestion: cooking + typing**
- explicitly grant exact `assets/**` output paths;
- canonical-identity lock;
- actor/fixture/prop separation;
- import exact 256×256 sheets;
- Scene/UI workstation + kitchen foreground calibration as separately authorized;
- then hand one frozen SHA to QA-002 for real Godot/render/Web evidence.

Do not expand to study or additional actions before the cooking + typing ingestion path is proven.

## Handoff
`ART-PROD-003` is ready for 00-Orchestrator review at **NEEDS_REVIEW**. Repository delta is report-only and within the exact writable scope. The visual candidate package exists only in chat/workspace and is explicitly non-integrated. No Godot/runtime/render/Web PASS is claimed.
