# ART-INGEST-004 — Generated Art Ingestion Handoff

Date authorized: 2026-09-15
Owner: `art-animation` / 05-Art-Animation
Execution mode: binary asset ingestion may use Codex/local; Scene/UI hookup is not included.

## User authorization
The user explicitly authorized 05-Art-Animation to ingest today’s generated art into these exact production trees:

- `assets/art/production/player/actions/**`
- `assets/art/production/npc/**`
- `assets/art/production/foreground/**`
- `assets/art/production/fx/**`

This authorization is already mirrored in `TASK_BOARD.md` and `FILE_OWNERSHIP.md`.

## Source location
Primary shared Library/workspace folder observed for this session:
- `/打工人模拟器开发团队/`

The current-generation session contains a large batch of model-generated PNG assets. 05 must treat the batch as an ingestion inventory, not just pick one or two images and leave the rest untracked.

## Explicitly observed source groups
Named production/action sources include:
- `《都市浮生》美术资源进度总览.png`
- `《都市浮生》主角动画资源包.png`
- `《都市浮生》美术资源包总览.png`
- `都市浮生：城市生活游戏美术资源包.png`
- `《都市浮生》第一批美术资源包.png`
- `《都市浮生》主角动作资源包.png`
- `动漫青年厨师烹饪动作序列.png`
- `动漫像素厨师烹饪动作序列精灵表.png`
- `像素风料理动画序列帧 Sprite 表.png`
- `少年烹饪动作精灵图表.png`
- `透明背景办公角色动画图集.png`
- `透明背景书桌阅读动作精灵图.png`
- `像素风角色动画精灵表.png`
- `像素风角色动作精灵表.png`
- `少年日常动作精灵图合集.png`
- `青年男子工作学习烹饪动作精灵图.png`
- `动漫游戏角色日常动作精灵图表.png`
- `透明背景三组日常动作精灵图.png`
- `四行四列动漫角色生活动作精灵表.png`
- `男子日常动作精灵图集.png`
- `三组八帧男生日常动作精灵图.png`

ART-PROD-002 candidates observed:
- `art_prod_002_home_kitchen_stirring_candidate_v1.png`
- `art_prod_002_home_study_reading_candidate_v1.png`
- `art_prod_002_workstation_typing_candidate_v1.png`
- `art_prod_002_first_hour_actions_mother_v1.png`
- `art_prod_002_first_hour_actions_candidate_v1.png`

Generic generated batches also observed and must be inspected/classified rather than ignored:
- `image-gen-1.png` … `image-gen-10.png`
- `image-gen-1(1).png` … `image-gen-9(1).png`
- `image-gen-1(2).png` … `image-gen-9(2).png` plus `image-gen-10(1).png`
- `image-gen-1(3).png` … `image-gen-9(3).png`
- additional UUID-named PNGs in the same project folder from the same work session.

## Ingestion rules
1. Inspect each source before placement. Do not infer category from generic filenames alone.
2. Rename generic/UUID source names to descriptive deterministic production names when the visual content can be identified.
3. Player/protagonist actions go under `player/actions/**`.
4. NPC-specific art goes under `npc/**`.
5. Foreground, occlusion, furniture masks and depth overlays go under `foreground/**`.
6. Visual effects, rain/weather/interaction feedback and effect frame sheets go under `fx/**`.
7. Preserve useful source sheets/candidates even when they are not integration-ready; place them in a clearly named candidate/source subfolder inside the correct authorized tree.
8. For every ingested file, record source filename -> repository destination, intended use, dimensions/hash if available, and status (`source-only`, `candidate`, `integration-ready`).
9. If a file in the shared batch is not actually relevant to this game, do not silently skip it. Record it as excluded with a short reason in the art-agent report.
10. No edits to `scenes/**`, `scripts/**`, `data/**`, `project.godot` or `main` under ART-INGEST-004.

## Completion criteria
ART-INGEST-004 may move to `NEEDS_REVIEW` only when:
- all observed current-session generated assets have either a repository destination or an explicit exclusion record;
- the four authorized directory trees contain the organized production/candidate assets;
- generic filenames have been normalized where practical;
- the art-agent report contains the ingestion manifest and branch tip;
- no scene/script integration is claimed.
