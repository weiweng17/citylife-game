# Art / Animation Agent Report

## Agent
- Lane: 05-Art-Animation
- Owner key: `art-animation`
- Coordination branch: `orchestrator/multi-agent-bootstrap`

## Current task
- ID: ART-AUDIT-001
- Branch: `agent/art-audit-001-production-gap`
- Status: NEEDS_REVIEW

## Contract / scope respected
- Report-only audit. No production art, scene, script, gameplay value, NPC/content, QA, coordination file, or `main` changes.
- Repository evidence reviewed from `HANDOFF.md`, `docs/ARCHITECTURE.md`, `docs/ITERATION_PLAN.md`, `docs/agents/*`, `assets/**`, `scenes/**`, `scripts/world/**`, all current `*Activities.gd`, `LocationManager.gd`, `Game.gd`, and `scripts/ui/**`.
- This is a repository/source audit. No Godot 4.7.2 rendered run, browser run, or pixel-level screenshot acceptance was performed; those remain explicit runtime/manual visual gates.

# 《都市浮生美术与动画缺口审计 v1》

## 1. Executive conclusion

The project already has the **technical skeleton of a 2.5D game**: nine independent locations, foot-position movement, directional player walk sheet, depth scaling, collision/navigation, foreground occlusion, interaction anchors, click feedback, and a dedicated sleep presentation. The remaining gap is not “lack of backgrounds”; it is that the majority of player/NPC actions still read as **a standing sprite + timer/progress text + numerical settlement**.

Current production-state summary:
- Map maturity: **A = 0, B = 9, C = 0** by the requested A/B/C definition. Home is the strongest B; the other eight are structurally B because they do have walking/collision/hotspots, but still visibly depend on one painted background plus approximate extracted occluders.
- Player animation: four-direction walk is the only broadly reusable finished movement set. Sleep is the only activity with a dedicated pose/blanket presentation; even sleep entry/wake are still tween/fade transitions rather than a completed frame sequence.
- NPC animation: **0 current runtime NPCs have a playing idle/walk/talk animation**. Xiaoyu and Chenjie have higher-resolution candidate sheets but runtime takes only frame 0; the remaining NPCs use static sprites.
- Scene dynamics: current `LocationManager` locations use baked rainy-night backgrounds plus one static lighting tint. The older hidden `WorldManager` has scrolling rain/time atmosphere code, but those dynamics are not present in the active independent-location presentation.
- First-30-minute art bottleneck: **home action poses → subway commute transition → office interior/work animation → store embodied shopping/eating → NPC talk idles**.

## 2. Map maturity and 2.5D checklist

Rating definition used: A = complete 2.5D playable scene; B = collision/hotspots exist but scene still reads as background art; C = essentially background + buttons/hotspots.

| Map | Grade | Ground / wall layer | Foreground / occlusion | Interactive furniture / facility | NPC integration | Dynamics / light / weather | Walk area | Character scale / furniture contact | Primary art gap |
|---|---|---|---|---|---|---|---|---|---|
| Home / 出租屋 | **B+** | One baked background; collision is separately authored with detailed polygons | Best in project: polygon crops plus dedicated bed blanket foreground | Bed, desk, kitchen, door | Xiaoyu is static runtime entity | Static warm tint; sleep has breathing/Z; no live room/rain loop | Detailed polygons; strongest calibration | Player depth scale works; **sleep contacts bed**, study “sit” is only scaled standing frame, cooking does not physically contact cooker | Dedicated study/cook/sit/leave animation; true furniture layer pack; ambient room loops |
| Subway / 地铁站 | **B-** | One platform background | 4 broad rectangular crops | No dedicated subway activity scene; travel is the functional core | LaoZhang / Azhe static | Baked night/rain; no train, doors, crowd, signal, tunnel movement | Walkable with rectangular blockers | Player depth scale; NPC fixed-size button art; no boarding contact | Train arrival/doors/boarding and commute transition |
| Office / 公司 | **B-** | Active background is `company_entrance_rain_night.webp`, while work hotspot represents a workstation | 3 broad rectangular crops | Work + negotiate hotspots | LaoZhang static | Static cool tint; no monitor/elevator/coworker ambient loop | Walkable with rectangular blockers | “Work” does not seat player at a desk; anchor was explicitly rough-calibrated | **Scene semantic mismatch: entrance art used for desk work**; replace/re-layer with office interior and desk contact |
| Park / 公园 | **B** | One baked pavilion/park background | 3 broad rectangular crops | Bench + pond | LaoZhou static | No live rain streaks, pond ripples, foliage motion, lamp pulse | Walkable with rectangular blockers | Bench action does not sit; pond action does not lean/look | Sit/rest pose + rain/water/foliage microloops |
| Store / 便利店 | **B** | One baked store background | 4 broad rectangular crops | Shelf shopping | Chenjie high-res candidate is displayed as frame 0 only | Static lighting; no fridge/light/door/product motion | Walkable with rectangular blockers | Player stands at shelf, then UI takes over; no reach/pick/checkout | Embodied shopping, product handoff, shelf/counter layer split |
| Cafe / 咖啡馆 | **B** | One baked cafe background | 4 broad rectangular crops | Coffee + idle table | Azhe static | No cup steam, grinder/bar motion, window rain motion | Walkable with rectangular blockers | No actual seated coffee/idle pose | Cup/steam + seated idle + table foreground/contact |
| Hospital / 医院 | **B** | One clinic background | 3 broad rectangular crops | Clinic desk + waiting bench | No current runtime NPC at this location | Static sterile tint; no monitor/curtain/staff ambience | Walkable with rectangular blockers | Clinic and bench actions remain standing-like; no examination contact | Exam/waiting presentation; visible service actor is a cross-lane dependency before art production |
| Rooftop / 天台 | **B-** | One baked rooftop background | 2 broad rectangular crops | Ledge + bench | None | No wind/rain/city-light/parallax motion | Walkable with rectangular blockers | No rail lean, no seated bench pose | Wind/city/rain loop + railing lean + sit pose |
| Alley / 旧巷 | **B-** | One baked alley background | 2 broad rectangular crops | Shrine + door rest | Daoshi static | No incense smoke/flame/light flicker/live rain runoff | Walkable with rectangular blockers | Shrine action stays standing; no kneel/bow/hand contact | Incense interaction + smoke/light/rain microloops |

**Map audit conclusion:** Home is closest to A but is not A yet because its non-sleep activities do not have dedicated action bodies and the room is still fundamentally one baked background with runtime crop-based occlusion. The other eight maps satisfy B structurally, but their blockers/occluders are broad rectangles and their activity anchors are mostly marked in source as rough, not frame-calibrated.

## 3. Player action gap audit — “standing + waiting + settlement” surface

Legend: `Missing` = production asset absent; `Partial` = some feedback exists but the body/object/contact is not a true action animation; `Present` = meaningful dedicated presentation exists.

| Player behavior | Current presentation | Character animation | Interactive object animation | Foreground/contact | Action feedback | Scene dynamics | Transition presentation | Missing degree |
|---|---|---|---|---|---|---|---|---|
| Work / 上班 | Faces anchor; programmatic laptop; 10-step progress text | **Missing** seated typing | **Partial** laptop icon only | **Missing** real desk/chair contact | Present text/progress | Missing | Missing sit-in/out | **95%** |
| Study / 学习 | `pose=sit`, but same walk frame is merely scaled/offset; programmatic book | **Missing** sit/read/page-turn | Partial book icon | Partial desk occluder; chair contact fake | Present | Missing | Missing sit transition | **90%** |
| Cook / 做饭 | Standing/interact frame with tiny pulse; programmatic pot | **Missing** reach/stir/chop | **Partial** pot/steam icon | Partial counter occlusion; hands do not meet cooker | Present | Missing stove/steam loop | Missing start/finish | **90%** |
| Eat / 吃饭 | Inventory `use` button directly settles item/time/state | **Missing** | **Missing** food/cup use | Missing | UI status only | Missing | Missing | **100%** |
| Sleep / 睡觉 | Dedicated side pose + blanket foreground + fade/tween + subtle breathing | **Present/Partial** sleep loop | Present blanket | **Present** best contact in project | Present | Partial breathing/Z | **Partial** entry is tween/fade | **35%** |
| Wake / 起床 | Sleep layer fades; standing sprite fades in at bedside | **Missing** dedicated wake sequence | Partial blanket fade | Partial | Present fade | Missing | **Missing** wake body transition | **80%** |
| Rest / 休息 | Park/cafe/hospital/rooftop “rest” hotspots mainly keep normal body | **Missing** generic sit/lean/rest | Missing | Missing furniture contact | Present text/progress | Missing | Missing | **95%** |
| Shop / 购物 | Walk to shelf → ShopUI panel | **Missing** reach/pick/hold | Missing product/shelf response | Partial shelf occlusion | Strong UI feedback | Missing | Missing in-world checkout | **90%** |
| NPC talk / 交谈 | Click static NPC → bottom dialog | **Missing** player turn/talk/gesture | N/A | Missing pair-facing/contact spacing | Dialog text present | Missing | Missing conversation enter/exit | **90%** |
| Hospital interaction | Clinic/bench hotspot + timer | **Missing** exam/waiting pose | Missing equipment response | Missing | Present text/progress | Missing | Missing | **95%** |
| Cafe interaction | Coffee/idle hotspot + timer | **Missing** sip/seated idle | Missing cup/steam | Missing table/bar contact | Present text/progress | Missing | Missing | **95%** |
| Park interaction | Bench/pond hotspot + timer | **Missing** sit/look/lean | Missing | Missing | Present text/progress | Missing pond/rain/foliage loop | Missing | **95%** |
| Subway / commute | Location travel and time settlement | **Missing** board/stand/exit | **Missing** train/door | Missing | Arrival toast/time | **Missing** | **Missing** travel cinematic/short transition | **100%** |
| Rooftop interaction | Ledge/bench hotspot + timer | **Missing** lean/sit/wind response | Missing | Missing railing/bench contact | Present | Missing wind/city/rain | Missing | **95%** |
| Alley interaction | Shrine/door hotspot + timer | **Missing** incense/bow/rest | **Missing** incense/smoke | Missing shrine/door contact | Present | Missing smoke/flame/rain | Missing | **95%** |

## 4. NPC animation gap audit

The active `LocationManager` renders NPCs as a shadow + clickable Button + TextureRect. Xiaoyu/Chenjie load a high-resolution 4-column candidate sheet but only atlas frame 0 is returned. LaoZhang/LaoZhou/Azhe/Daoshi use static fallback sprites. Therefore the current runtime has no ambient NPC locomotion or talk animation.

| NPC | Current locations | Current runtime art | Missing idle | Missing walk | Missing talk/turn | Missing context action | Priority |
|---|---|---|---|---|---|---|---|
| Xiaoyu | Home | High-res candidate sheet, **frame 0 only** | Yes | Yes (candidate source may be reusable) | Yes | Home idle / sit / small domestic action | P1 |
| Chenjie | Store | High-res candidate sheet, **frame 0 only** | Yes | Yes (candidate source may be reusable) | Yes | Store browse/hold item | P1 |
| LaoZhang | Office, Subway | Static fallback sprite | Yes | Yes | Yes | Office desk/stand + commute idle | **P0** |
| LaoZhou | Park | Static fallback sprite | Yes | Yes | Yes | Bench/umbrella/look-rain idle | P2 |
| Azhe | Cafe, Subway | Static fallback sprite | Yes | Yes | Yes | Cafe seated/cup + commute idle | P1 |
| Daoshi | Alley | Static fallback sprite | Yes | Yes | Yes | Shrine/incense idle | P2 |
| Hospital service actor | Hospital | None in active location configuration | N/A | N/A | N/A | Requires orchestrator/NPC-content decision before 05 creates a new canonical character | Dependency |

### Minimum reusable NPC animation package
A production-efficient first pass should avoid bespoke full acting for every NPC. Define one shared animation contract first: `idle` 4–6f, `walk` 4f × 4 dirs, `talk` 4–6f × 2 useful facings, and one location-specific context loop where justified. Then adapt silhouettes/outfits per NPC while preserving identical foot anchor and frame cell.

## 5. Scene dynamic gap audit

| Scene system | Current active implementation | Production gap | Recommended art/animation response | Priority |
|---|---|---|---|---|
| Rain / weather | Rain is baked into independent-location backgrounds; active locations do not use legacy scrolling rain | Scenes feel frozen despite rainy-night theme | Reusable transparent rain near/far layers, puddle/ripple overlays, intensity variants | **P0** |
| Time / lighting | One static tint per location | No lived time-of-day shift or localized light response | Per-scene light masks/gradients + lamp/window emissive layers; keep gameplay time logic unchanged | P1 |
| Furniture response | Hotspots exist; furniture is mostly baked | Player does not appear to physically use desk/chair/counter/bench | Split contact-critical furniture into back/front layers; animate only moving parts | **P0** |
| Ambient NPCs | Static click targets | Rooms feel like staged illustrations | Idle/blink/breath + small context loops | **P0/P1** |
| Office ambience | None in active location | Work has no visual rhythm | Monitor glow, keyboard/typing, chair contact, subtle coworker/elevator motion | **P0** |
| Subway ambience | None | Commute is a numerical teleport | Train approach, door open/close, platform light sweep, boarding/exit transition | **P0** |
| Store ambience | None | Shopping becomes a modal UI interruption | Fridge/fluorescent microloop, shelf reach/product handoff, short checkout feedback | P1 |
| Home ambience | Sleep breath only | Home is mechanically rich but visually still | Window rain, lamp/monitor/kitchen microloops; keep subtle | P1 |
| Cafe ambience | None | Coffee action lacks sensory cues | Cup steam, pendant/window rain loop, seated idle | P1 |
| Park ambience | None | Pond/rain text not visible in world | Pond ripples, foliage/water/rain loops | P1 |
| Hospital ambience | None | Clinic reads empty/static | Monitor/light/curtain microloops after actor dependency is resolved | P2 |
| Alley ambience | None | Shrine action has no ritual feedback | Incense smoke/flame/light flicker + rain runoff | P2 |
| Rooftop ambience | None | “wind / night view” is text-only | Wind/rain, city-light twinkle/parallax, clothing/hair response if feasible | P2 |
| Scene travel | Immediate location replacement | No sense of moving through a city | 0.4–1.2s location-specific transition, subway gets a dedicated short sequence | **P0** |

Important reusable opportunity: the hidden legacy `WorldManager` already contains scrolling rain, weather tint, vignette and time-atmosphere ideas. 05 should treat it as a visual reference/source of reusable effect logic, not as proof that active `LocationManager` scenes already have those dynamics.

## 6. Action asset manifest

Baseline art contract proposed for planning only (no assets generated in this task): upright player action cells should stay compatible with the current **256×256 per-frame player convention**, RGBA transparent, feet on a fixed anchor, no camera baked into sprite. Wider bed poses may use **384×256 per frame**. Scene-specific foregrounds should be authored against the 1280×720 gameplay viewport and retain alpha.

| Action asset | Frames | Direction requirement | Actor | Props | Foreground needed | Suggested resolution | Intended Godot hookup | Priority | Current missing |
|---|---:|---|---|---|---|---|---|---|---|
| Work typing loop | 8 loop + 4 sit-enter | 1 fixed workstation facing | Player | Laptop/keyboard | Desk/chair front | 256×256/frame | New `work_up` SpriteFrames; anchor from OfficeActivities; desk front above player | **P0** | 95% |
| Study reading loop | 8 loop + 4 sit-enter | 1 fixed desk facing | Player | Book/notebook | Desk/chair front | 256×256/frame | `study_up`; replace fake `sit` scaling at study anchor | **P0** | 90% |
| Cooking loop | 8 loop + 4 reach/start | 1 fixed 3/4 facing | Player | Pot/pan/utensil + steam | Counter front | 256×256/frame + ≤128px prop FX | `cook` action state at meal anchor | **P0** | 90% |
| Eat / drink reusable | 6–8 per action | Prefer 4 dirs because inventory can be used anywhere | Player | Food/cup | No, unless seated variant | 256×256/frame | Non-spatial short action state, return to idle once | **P0** | 100% |
| Generic sit/rest enter | 6 enter | 2 useful furniture facings first | Player | Optional cup/phone | Bench/chair front where needed | 256×256/frame | Shared `sit_enter_*` state | **P0** | 100% |
| Generic sit/rest loop | 4–6 loop | 2 facings | Player | Optional | Same as above | 256×256/frame | Shared `sit_idle_*`; reused in cafe/park/hospital/rooftop | **P0** | 100% |
| Sleep enter | 6–8 | 1 bed orientation | Player | Pillow/blanket | Blanket foreground | 384×256/frame | Sequence before existing sleep loop | P1 | 80% |
| Sleep loop polish | 4 loop or retain procedural breath | 1 | Player | Blanket | Yes | 384×256/frame if frame-based | Existing HomeInteractionVisual can remain if visually accepted | P2 | 30% |
| Wake up | 6–8 | 1 bed orientation | Player | Blanket | Yes | 384×256/frame | Sequence before restoring walk sprite | P1 | 80% |
| Shopping reach/pick | 6–8 | 1 shelf facing | Player | Product + bag | Shelf front | 256×256/frame | Short action before/after ShopUI; no gameplay-value change | P1 | 100% |
| Talk idle / gesture | 4–6 loop | 4 dirs for player, 2 dirs acceptable for NPC first pass | Player + NPC | None | Usually no | 256×256/frame | Dialogue state faces counterpart; exits exactly once | P1 | 100% |
| NPC walk base | 4 × 4 dirs | 4 dirs | NPC | None | Scene-dependent | 256×256/frame contract | AnimatedSprite2D instead of TextureRect frame-0 rendering | P1 | 100% runtime |
| Cafe cup / sip | 6–8 | 1–2 facings | Player/NPC | Cup + steam | Table/bar front | 256×256/frame | Reuse sit state + cup overlay | P1 | 100% |
| Clinic wait/exam | 6–8 | 1–2 facings | Player; NPC actor only after cross-lane decision | Clinic prop | Desk/bench front | 256×256/frame | Dedicated clinic/wait action state | P2 | 100% |
| Shrine incense | 8 loop + 4 enter | 1 facing | Player/Daoshi | Incense + smoke | Shrine front | 256×256/frame + 128–256px FX | Alley action state + FX node | P2 | 100% |
| Rooftop rail lean | 4 enter + 4 idle | 1 facing | Player | None | Rail front | 256×256/frame | Ledge-specific pose | P2 | 100% |
| Subway board/exit | 6–8 each | 1–2 facings | Player + scene | Train/door | Door/train front | Player 256×256/frame; train authored as separate wide scene layer | AnimationPlayer + scene-layer transition, not a giant full-screen sprite sheet | **P0** | 100% |

## 7. First 10 animations worth producing

| Rank | Animation | Why it should be early | Reuse |
|---:|---|---|---|
| 1 | Work — sit + typing loop | Core daily objective; current “work” is almost entirely numeric | Office, future desk jobs |
| 2 | Cook — reach/stir loop | Core home action and meal objective | Home, future kitchens |
| 3 | Study — sit/read/page loop | Home action already has desk anchor but fake sit pose | Home, library/cafe later |
| 4 | Generic sit/rest enter + idle | Fixes park, cafe, hospital, rooftop in one shared asset family | 4+ maps |
| 5 | Eat/drink quick action | Inventory currently changes needs with no body response | Anywhere |
| 6 | Sleep enter | Existing sleep loop is the strongest action; entry is the obvious remaining seam | Home |
| 7 | Wake-up sequence | Prevents abrupt “lying → standing beside bed” cut | Home |
| 8 | Shopping reach/pick/hold | Bridges in-world shelf to ShopUI | Store/future shops |
| 9 | Player/NPC talk idle + turn-to-face | Every NPC interaction currently reads as static portrait-button + dialog | All NPC maps |
| 10 | Subway train arrival / door / boarding | Converts commute from teleport/time settlement into a lived city moment | Daily loop |

## 8. First 3 maps worth reworking

| Rank | Map | Why before the others | Minimum art rework |
|---:|---|---|---|
| 1 | **Office** | It is in the first daily loop, but the active map uses a **company entrance** background while the hotspot claims the player is doing workstation labor. The repo already contains `open_office_rain_night.webp`, so the highest-value first move is to establish a real desk/work scene rather than animate work in a lobby. | Pick/prepare office interior source; split back floor/walls, desk/chair front, interaction zone; calibrate player scale/contact; add subtle work ambience |
| 2 | **Subway** | Commute is mandatory early and currently has no embodied transition; every day repeats this weakness. | Platform back/mid/front split; train + doors as separate layer; short arrival/boarding/exit AnimationPlayer sequence; keep logic/time settlement untouched |
| 3 | **Store** | First-day shopping is mechanically complete but visually jumps from standing at shelf to a large modal panel. | Shelf/counter/fridge front layers; pick/hold handoff; short return-to-idle; calibrate Chenjie sprite scale and depth |

**Why Home is not in the first three map rebuilds:** Home already has the most detailed collision/occlusion and the only dedicated furniture-contact presentation (sleep). It should receive the **first animation pass**, but a full environment rebuild produces less gain than fixing Office/Subway/Store, where the structural mismatch is larger.

## 9. Art production order

| Stage | Production unit | Exit condition before next stage |
|---|---|---|
| 0 | Visual contract lock | 1280×720 scene space, 256×256 upright frame cell, foot anchor, pivot, naming, alpha, scale band, light-tint rules written down |
| 1 | First-30-minute player action pack | Work, cook, study, sit/rest, eat/drink, sleep-enter, wake all pass frame-consistency review as raw assets |
| 2 | Office → Subway → Store re-layering | Back/mid/front/contact layers exist and each interaction has a defined anchor/foreground relationship |
| 3 | Runtime NPC base pack | Shared idle/walk/talk contract applied to first high-value NPCs; no first-frame-only runtime presentation |
| 4 | Ambient weather/light FX pack | Reusable rain near/far, ripple, steam, smoke, light-pulse overlays with low visual noise |
| 5 | Secondary-location action pass | Cafe, park, hospital, alley, rooftop get their specific contact pose + scene FX |
| 6 | Travel/conversation polish | Short transitions, turn-to-face, enter/exit action staging |
| 7 | Godot calibration/acceptance | Every frame is anchored, z-sorted, lit, collision-safe, non-jittering, and checked at target viewport sizes |

## 10. What AI generation can safely accelerate

AI generation is useful **before integration** for: action key-pose exploration; transparent prop source art; foreground furniture cutout candidates; steam/smoke/rain/light effect source textures; office/subway/store environment variants; NPC idle/talk keyframe concepts; and controlled repainting of scene layers while preserving the existing camera/perspective.

AI output must not be called “finished game art” until continuity and integration gates are passed. For animation, generate/approve **key poses first**, then normalize silhouette, clothing, hands, face, camera, frame cell, foot anchor, lighting, palette and transparency across every frame. Do not generate poster-like full compositions and then crop them into gameplay assets.

## 11. What must be manually corrected in Godot

The following cannot be considered complete from generated PNGs alone:
- final foot/pivot anchor and per-frame jitter correction;
- action-state timing, loop boundaries, once-only enter/exit sequencing;
- z-index/depth ordering with furniture and NPCs;
- exact foreground masks/polygons and collision alignment;
- player-to-chair/desk/bed/counter/rail physical contact;
- per-location scale/depth calibration and NPC scale parity;
- lighting/modulate compatibility against each background;
- hitbox/click target alignment after moving from static Button art to AnimatedSprite2D-style entities;
- UI/interaction-label overlap at 1280×720 and smaller QA viewport;
- runtime performance/memory of new sprite sheets and effect layers;
- visual acceptance in actual Godot, which this web audit did not claim to perform.

## 12. Highest-impact improvements to the first 30 minutes

| Impact | Project | Why it changes the experience immediately |
|---|---|---|
| **Very High** | Home cook/study/sleep-enter/wake action pack | The player learns the game at home; multiple early actions stop looking like the same standing sprite |
| **Very High** | Office interior + seated work loop | Turns the main daily objective from a numeric timer into recognizable labor; fixes entrance/workstation mismatch |
| **Very High** | Subway train/boarding transition | Gives the city a sense of distance and makes the repeated commute memorable instead of instant teleport |
| **High** | Store reach/pick + eat/drink | Closes the visual loop between buying, carrying and consuming necessities |
| **High** | NPC talk idle / turn-to-face for LaoZhang + first-day encountered NPCs | Stops NPCs reading as stickers/buttons and makes relationship systems feel embodied |
| **High** | Reusable rain + small environmental loops on early maps | Adds life without changing any gameplay values; one FX pack benefits several locations |
| **Medium/High** | Generic sit/rest pose | One asset family fixes cafe/park/hospital/rooftop contact quality when those maps appear |

## 13. Dependencies / ownership boundaries

- 05 should not modify `Game.gd`, `LocationManager.gd`, gameplay values, NPC narrative/canon, UI-owned files, QA files or coordination files without an explicit follow-up task contract.
- Any new hospital doctor/nurse or new canonical NPC identity requires NPC/content/orchestrator approval first.
- Scene/UI changes needed to replace static NPC TextureRect/Button composition, change map layering, or alter interaction UI must be handed to/paired with the appropriate owner after 00 review.
- Runtime verification of frame timing, z-order, contact, visual scale, Web export and screenshots belongs in a Codex/local/QA execution package after assets are produced.

## 14. Files changed

- `agent-reports/art-animation.md` only.

## 15. Tests / evidence performed

- Repository source/asset inventory audit only.
- Cross-checked active location backgrounds, navigation, occlusion, NPC rendering, activity anchors, player pose code, sleep presentation, UI presentation and legacy atmosphere code.
- **Not performed:** Godot launch, rendered screenshots, browser/Web export, local asset pixel inspection. No runtime PASS is claimed.

## 16. Known risks

- A/B/C grades are repository-implementation maturity grades, not pixel-level art-quality scores. A rendered exact-SHA pass may lower or raise individual map confidence.
- Existing candidate sprite sheets may contain useful motion frames, but because current runtime only uses frame 0 for NPC candidates, reuse quality still needs actual frame-by-frame inspection before production commitment.
- Current foreground occlusion outside Home is generated from broad rectangles cut from the background; replacing it with precise art layers can expose collision/anchor mismatches that require Scene/UI + QA coordination.

## 17. Suggested next task for 00-Orchestrator review only

If this audit is accepted, the smallest high-value production follow-up is **one tightly scoped P0 protagonist interaction pack**: define and produce the raw transparent-frame assets/spec for `work`, `study`, and `cook` only, with no Godot source edits. Integration should be a separate orchestrator-assigned task after the asset pack is reviewed.

---

**Worker request:** `NEEDS_REVIEW`. Stop here and wait for 00-Orchestrator. Do not self-expand scope.
