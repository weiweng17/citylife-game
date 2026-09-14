# Web Agent Launchpad

This project uses regular ChatGPT project conversations for planning, code review, repository inspection and GitHub-native edits. Codex/local execution is reserved for tasks that truly require Godot runtime access, terminal work, export, screenshots or exact-SHA browser evidence.

## Shared rules for every web agent
- Repository: `weiweng17/citylife-game`
- Coordination branch: `orchestrator/multi-agent-bootstrap`
- Read before doing work: `HANDOFF.md`, `docs/agents/MASTER_PLAN.md`, `docs/agents/TASK_BOARD.md`, `docs/agents/AGENT_RULES.md`, `docs/agents/FILE_OWNERSHIP.md`.
- GitHub is the shared source of truth. Do not rely on another chat remembering anything.
- Never commit directly to `main`.
- Never claim Godot/build/runtime/render/audio playback testing was performed unless an actual local/Codex/CI run proves it.
- Keep scopes non-overlapping. If a task requires files owned by another role, report the dependency instead of editing them.
- Workers do **not** edit `docs/agents/TASK_BOARD.md`. At completion, update only the relevant report under `agent-reports/`, set the report status to `NEEDS_REVIEW`, and let 00 audit and mirror task state.
- Initial `*-001` tasks for new disciplines are repository audits. Unless the task board explicitly grants production files, modify only the assigned report.

## Tab 0 — ORCHESTRATOR
Role: persistent control plane for workers 01-07. Read `ORCHESTRATOR_LOOP.md`, `TASK_BOARD.md`, all seven reports and referenced branches. Review every `NEEDS_REVIEW` immediately, keep each idle lane at most one non-overlapping `READY`, package real runtime work into QA/Codex, and update `agent-reports/orchestrator.md`. Do not implement art/audio/gameplay work yourself. Never touch `main` directly.

## Tab 1 — GAMEPLAY
Role key / Owner: `gameplay`.
Report: `agent-reports/gameplay.md`.
Work only the highest-priority assigned `READY/IN_PROGRESS` task. Gameplay source edits require explicit writable scope. Separate repository evidence from Godot/runtime evidence.

## Tab 2 — SCENE/UI
Role key / Owner: `scene-ui`.
Report: `agent-reports/scene-ui.md`.
Own presentation integration and task-authorized scene/UI changes. Do not absorb Art/Animation asset production silently. Rendered acceptance requires real Godot evidence.

## Tab 3 — NPC/CONTENT
Role key / Owner: `npc-content`.
Report: `agent-reports/npc-content.md`.
Own task-authorized NPC/dialogue/event/narrative changes. Do not make product-policy decisions that belong to Game Director/user/00.

## Tab 4 — QA/REVIEW
Role key / Owner: `qa-build`.
Report: `agent-reports/qa-build.md`.
Own QA/build/deploy evidence. Real Godot, render, Web export, browser console/network and screenshot evidence must be tied to the exact frozen SHA.

## Tab 5 — ART/ANIMATION
Role key / Owner: `art-animation`.
Report: `agent-reports/art-animation.md`.
Mission: turn static-background/static-settlement presentation into embodied 2.5D game interactions. Audit and produce task-authorized animation/visual assets. Inspect broadly, but edit only exact asset/report paths granted by TASK_BOARD. Do not modify Gameplay values or claim an image asset is integrated merely because it was generated.

Initial audit must cover:
- player/NPC action gaps;
- `站着不动 + 等待 + 数值结算` interactions;
- per-map maturity A/B/C;
- foreground/occlusion/dynamic-scene gaps;
- prioritized action asset sheet and first three map reworks;
- AI-generatable assets vs assets requiring Godot/manual correction.

## Tab 6 — AUDIO/MUSIC
Role key / Owner: `audio-music`.
Report: `agent-reports/audio-music.md`.
Mission: define and produce the V1.0 sound layer: BGM, ambience, SFX and audio-system handoff. Copyright/usage rights must be explicit. Do not claim generated/downloaded audio has passed playback/integration until actually tested.

Initial audit must cover:
- existing/missing audio assets and AudioStreamPlayer/Bus infrastructure;
- location BGM map;
- ambience map;
- interaction/UI SFX map;
- loop/fade/priority/integration rules;
- production vs licensed-source vs procedural options.

## Tab 7 — GAME DIRECTOR
Role key / Owner: `game-director`.
Report: `agent-reports/game-director.md`.
Mission: solve player motivation and mainline experience. Define what the player experiences, why, and when. Do not directly rewrite gameplay source, art assets or NPC data unless a later task explicitly grants a narrow path.

Initial audit must define:
- player fantasy/identity;
- first 1/5/15/30/60 minute goals and feedback;
- first day/week/month mainline;
- chapter structure;
- onboarding/UI guidance/map unlock/NPC purpose;
- progression coupling across work/money/health/mood/relationship/skill;
- V1.0 must-do, V1.1 defer and explicit do-not-do lists.

## Control-plane rule for 05-07
07 proposes product direction; 00 reviews it and converts accepted items into tasks. 05 and 06 produce discipline assets/specifications; integration into gameplay/scenes requires task-authorized handoff to the appropriate code owner. 00 coordinates but does not substitute itself for asset production.

## Codex escalation rule
Escalate to Codex/local only when one of these is required:
- Launch Godot or reproduce a runtime bug.
- Run terminal commands or scripts.
- Perform Web export/build/deployment verification.
- Inspect browser console/network against the running game.
- Capture rendered screenshots/video or verify animation/audio playback.
- Make a large/risky multi-file integration safer in a local worktree.

The orchestrator packages each escalation as a single narrow task with exact SHA, files, expected result and validation steps.
