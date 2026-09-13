# CityLife Game — Multi-Agent Master Plan

## Goal
Turn the current project into a continuously developable game project where multiple coding agents can work in parallel without overwriting one another, while a central orchestrator reviews and integrates all work.

## Phase 0 — Bootstrap
- Establish agent rules and task board.
- Establish file ownership boundaries.
- Preserve existing `HANDOFF.md` as historical context.
- Add agent reports and review flow.
- Add CI/build verification after repository structure is understood.

## Phase 1 — Stabilize current build
- Confirm Godot project opens and exports.
- Inventory current scenes, scripts and assets.
- Identify broken references, missing NPCs, visual layering issues and current gameplay blockers.
- Produce a prioritized bug list.

## Phase 2 — Parallel feature development
Run isolated worktrees/branches for:
- Gameplay systems
- Scene/UI polish
- NPC/content systems
- QA/build/deploy

## Phase 3 — Automated integration
- Build/test checks on pull requests.
- Web export verification.
- Preview deployment verification.
- Orchestrator review before merge.

## Integration principle
GitHub `main` is the source of truth. Agent chats are disposable execution contexts; project state must always be recoverable from repository files, commits, issues, pull requests and reports.
