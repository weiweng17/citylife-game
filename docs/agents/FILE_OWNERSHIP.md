# File Ownership & Conflict Policy

This file defines default ownership boundaries. A task may temporarily override ownership only when the orchestrator explicitly records the exception in `TASK_BOARD.md`.

## Default ownership

### Orchestrator
- `docs/agents/**`
- Integration-only changes
- Review metadata and coordination files

### Gameplay agent
- `scripts/**` gameplay logic, unless assigned elsewhere
- Player interaction/state systems
- Gameplay data changes explicitly assigned by task

### Scene/UI agent
- `scenes/**` visual/layout work explicitly assigned by task
- HUD/menu/UI scene files
- Scene composition and presentation

### NPC/content agent
- NPC-specific scripts/scenes explicitly assigned by task
- Dialogue/event content
- Narrative data

### QA/build agent
- `.github/workflows/**`
- export/build validation scripts
- test documentation
- deployment verification

## High-conflict files
The following require explicit orchestrator assignment before editing:
- `project.godot`
- `export_presets.cfg`
- shared/autoload scripts
- shared scene roots
- shared data schemas

## Lock rule
When a task moves to `IN_PROGRESS`, its declared files/directories are considered locked to that task until it reaches `NEEDS_REVIEW`, `DONE`, or `BLOCKED` and the orchestrator releases the lock.

## Merge rule
No worker merges into `main`. Workers submit reviewable changes. The orchestrator checks diffs, build status, conflicts, acceptance criteria and regressions before integration.
