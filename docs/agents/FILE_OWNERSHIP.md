# File Ownership & Conflict Policy

This file defines default ownership boundaries. A task may temporarily override ownership only when the orchestrator explicitly records the exception in `TASK_BOARD.md`.

## Default ownership

### Orchestrator
- `docs/agents/**`
- `agent-reports/orchestrator.md`
- Integration-only changes
- Review metadata and coordination files

### Gameplay agent
- `scripts/**` gameplay logic, unless assigned elsewhere
- Player interaction/state systems
- Gameplay data changes explicitly assigned by task
- `agent-reports/gameplay.md`

### Scene/UI agent
- `scenes/**` visual/layout work explicitly assigned by task
- HUD/menu/UI scene files
- Scene composition and presentation
- `agent-reports/scene-ui.md`

### NPC/content agent
- NPC-specific scripts/scenes explicitly assigned by task
- Dialogue/event content
- Narrative data
- `agent-reports/npc-content.md`

### QA/build agent
- `.github/workflows/**`
- export/build validation scripts
- test documentation
- deployment verification
- `agent-reports/qa-build.md`

### Art/Animation agent
- `agent-reports/art-animation.md`
- New or revised visual asset files under `assets/**` only when the task board grants exact subpaths / filenames.
- Animation sprite sheets, cutout parts, foreground/occlusion layers and visual-production source assets only when explicitly assigned.
- May inspect `scenes/**`, `scripts/world/**`, `scripts/systems/*Activities.gd` and UI code to derive asset requirements, but does not own gameplay integration code by default.
- Any edit to scene composition or script integration must be explicitly co-assigned by 00 to avoid conflict with Scene/UI or Gameplay.

#### Current explicit production grant — ART-INGEST-004
User-approved on 2026-09-15 for the current generated-art ingestion wave. While `ART-INGEST-004` is active, `art-animation` may create, replace, rename, organize and delete production asset files only under these exact paths:
- `assets/art/production/player/actions/**`
- `assets/art/production/npc/**`
- `assets/art/production/foreground/**`
- `assets/art/production/fx/**`

This grant includes binary image ingestion, sprite sheets, separated actor/prop parts, foreground/occlusion layers, VFX frames and per-folder manifests needed to identify today’s generated assets. It does **not** grant edits to `scenes/**`, `scripts/**`, `project.godot`, gameplay data, UI integration, or `main`.

### Audio/Music agent
- `agent-reports/audio-music.md`
- Audio assets under `assets/audio/**` when explicitly assigned.
- Music, ambience and SFX production specifications and source files.
- Audio bus/layout/configuration changes only when explicitly assigned because `project.godot` and shared configuration are high-conflict.
- Does not own gameplay trigger logic by default; implementation hooks must be separately assigned.

### Game Director agent
- `agent-reports/game-director.md`
- Product/experience design documents under `docs/design/**` only when explicitly assigned.
- Mainline structure, onboarding, pacing, map purpose, progression priorities and V1.0 scope recommendations.
- Read-only access to gameplay/UI/NPC/art/audio source for product audit.
- No default ownership of production source, assets, narrative data, TASK_BOARD or other coordination files.

## Coordination-file rule
`docs/agents/TASK_BOARD.md`, `MASTER_PLAN.md`, `AGENT_RULES.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md`, `ORCHESTRATOR_LOOP.md`, and recovery/review metadata are orchestrator-only. Workers may read them but must not edit them. To request a task-state change, a worker updates only its own report; the orchestrator mirrors the state after review.

## High-conflict files
The following require explicit orchestrator assignment before editing:
- `project.godot`
- `export_presets.cfg`
- shared/autoload scripts
- shared scene roots
- shared data schemas
- `scripts/Game.gd`
- `scripts/systems/LocationManager.gd`
- shared audio bus/configuration resources
- production files already locked by another active art/UI/gameplay task

## Cross-discipline handoff rule
- `07-Game-Director` defines the intended player experience and priority; 00 converts accepted direction into executable tasks.
- `05-Art-Animation` produces/defines visual assets; `02-Scene-UI` or an explicitly assigned integration task connects them into scenes when code/scene edits are needed.
- `06-Audio-Music` produces/defines audio assets; Gameplay/Scene/UI integration hooks require separate task authorization.
- Workers may not silently expand their scope just because another discipline is blocked.

## Lock rule
When a task moves to `IN_PROGRESS`, its declared writable files/directories are considered locked to that task until it reaches `NEEDS_REVIEW`, `DONE`, or `BLOCKED` and the orchestrator releases the lock. Read-only inspection does not create a lock.

## Merge rule
No worker merges into `main`. Workers submit reviewable changes. The orchestrator checks diffs, build status, conflicts, acceptance criteria and regressions before integration.
