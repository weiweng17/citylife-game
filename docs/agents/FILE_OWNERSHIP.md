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

## Coordination-file rule
`docs/agents/TASK_BOARD.md`, `MASTER_PLAN.md`, `AGENT_RULES.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md`, and recovery/review metadata are orchestrator-only. Workers may read them but must not edit them. To request a task-state change, a worker updates only its own report; the orchestrator mirrors the state after review.

## High-conflict files
The following require explicit orchestrator assignment before editing:
- `project.godot`
- `export_presets.cfg`
- shared/autoload scripts
- shared scene roots
- shared data schemas
- `scripts/Game.gd`
- `scripts/systems/LocationManager.gd`

## Lock rule
When a task moves to `IN_PROGRESS`, its declared writable files/directories are considered locked to that task until it reaches `NEEDS_REVIEW`, `DONE`, or `BLOCKED` and the orchestrator releases the lock. Read-only inspection does not create a lock.

## Merge rule
No worker merges into `main`. Workers submit reviewable changes. The orchestrator checks diffs, build status, conflicts, acceptance criteria and regressions before integration.
