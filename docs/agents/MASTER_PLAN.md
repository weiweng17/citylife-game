# CityLife Game — Multi-Agent Master Plan

## Goal
Turn the current project into a continuously developable game project where multiple agents can work in parallel without overwriting one another, while a central orchestrator reviews and integrates all work.

The V1.0 goal is not merely “more systems”. The project must become a guided life-simulation game with readable mainline progression, embodied interactions, mature 2.5D scenes and a complete sound layer.

## Team topology
- `00-Orchestrator` — control plane, review, integration, release gates.
- `01-Gameplay` — gameplay/state systems and interaction logic.
- `02-Scene-UI` — scene composition, UI and presentation integration.
- `03-NPC-Content` — NPCs, dialogue, events and narrative content.
- `04-QA-Review` — verification, build, export and release evidence.
- `05-Art-Animation` — visual-production audit, action animation assets, scene-layer art and dynamic visual feedback.
- `06-Audio-Music` — BGM, ambience, SFX, audio-system requirements and production.
- `07-Game-Director` — mainline, onboarding, pacing, map purpose, player motivation and V1.0 scope.

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

## Phase 2.5 — Experience conversion
Convert the current feature-heavy prototype into an authored game experience:
- Game Director defines the first 30/60 minutes, first day/week/month and V1.0 chapter structure.
- Art/Animation inventories every static-number-settlement interaction and produces a prioritized action/scene asset plan.
- Audio/Music defines the complete BGM/ambience/SFX map and Godot handoff requirements.
- Existing 01-04 lanes implement and validate accepted director/art/audio handoffs without violating ownership boundaries.
- Maps are rated by actual 2.5D playability, not by whether a background image exists.

## Phase 3 — Automated integration
- Build/test checks on pull requests / frozen candidates.
- Web export verification.
- Preview deployment verification.
- Orchestrator review before merge.
- One frozen integration SHA for final runtime/render/browser evidence.

## V1.0 release principle
- Mainline and onboarding are P0, not post-polish.
- High-frequency interactions must have visible action feedback; “stand still + timer + numbers” is not a finished interaction.
- Core maps must feel spatially integrated with collision, occlusion, hotspots, NPC presence and scene dynamics rather than functioning as wallpaper.
- Sound is part of the minimum shippable experience: at least a coherent BGM/ambience/SFX layer must exist before V1.0.
- Scope growth that does not improve the first 60 minutes or release stability is deferred to V1.1+.

## Integration principle
GitHub `main` is the source of truth for released code. Agent chats are disposable execution contexts; project state must always be recoverable from repository files, commits, issues, branches and reports.
