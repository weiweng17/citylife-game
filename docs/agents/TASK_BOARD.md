# Multi-Agent Task Board

## Sprint: Bootstrap & Stabilization Baseline

Current product context: `docs/ITERATION_PLAN.md` shows the game code has progressed through Phase 3 and into Phase 4 content work. The `*-001` tasks below are therefore **baseline audits of the current repository**, not permission to rewrite systems. Their purpose is to establish a shared, current bug/risk inventory before parallel fixes begin.

### ORCH-001 — Multi-agent control layer
- Owner: orchestrator
- Branch: `orchestrator/multi-agent-bootstrap`
- Status: DONE
- Objective: establish rules, task board, ownership, reporting, recovery and review process.
- Allowed: `docs/agents/**`, coordination/report metadata, `.github/**` only after explicit review.
- Forbidden: gameplay code/assets during bootstrap; direct changes to `main`.
- Acceptance:
  - Rules documented.
  - Ownership documented.
  - Worker roles documented.
  - Recovery workflow documented.
  - Worker/task-board ownership conflict removed.
  - First-wave tasks include branch, writable scope, forbidden scope, acceptance and validation procedure.
- Validation procedure: repository/document review only; no Godot/runtime claim required.

### GAME-001 — Current gameplay blocker inventory
- Owner: gameplay
- Branch: `agent/game-001-blocker-audit`
- Status: READY
- Objective: identify current gameplay/system blockers and risky seams before feature expansion, reconciling current code with the latest architecture/iteration/QA handoff.
- Read scope: `scripts/**`, `data/**`, `scenes/**`, relevant `tools/verify_*.gd`, `HANDOFF.md`, `docs/ARCHITECTURE.md`, `docs/ITERATION_PLAN.md`, latest handoff/QA.
- Writable files: `agent-reports/gameplay.md` only.
- Forbidden: all source/data/scene/asset/config edits; `docs/agents/**`; `main`; `project.godot`; `export_presets.cfg`; `.github/**`.
- Acceptance:
  - Player interaction, daily flow, save/state and scene-transition risks are inventoried.
  - Findings use exact file paths/symbols when available and are grouped by severity.
  - Known already-fixed/history-only items are not reported as current bugs without evidence.
  - Repository-verified findings are separated from runtime/manual checks still needed.
  - A prioritized set of narrowly scoped follow-up repair tasks is proposed with likely file ownership.
- Validation procedure: GitHub repository inspection only. Do not claim Godot tests were rerun. Reference historical QA evidence explicitly as historical evidence.

### UI-001 — Scene/UI visual integration audit
- Owner: scene-ui
- Branch: `agent/ui-001-visual-audit`
- Status: READY
- Objective: audit current scene composition, character/background integration, layering, positioning and HUD/UI risks, including areas that cannot be accepted without visual Godot verification.
- Read scope: `scenes/**`, `scripts/ui/**`, presentation-relevant `scripts/world/**` and `scripts/systems/LocationManager.gd`, `assets/backgrounds/**`, `assets/characters/**`, `assets/sprites/**`, relevant capture/visual verification tools and current QA/handoff docs.
- Writable files: `agent-reports/scene-ui.md` only.
- Forbidden: scene/script/asset edits; `docs/agents/**`; `main`; `project.godot`; `export_presets.cfg`.
- Acceptance:
  - Problem/risk scenes and UI surfaces are identified with exact paths.
  - Each item states target behavior, suspected owner/files and severity.
  - Text/repository-detectable defects are separated from issues that require rendered screenshots/manual play.
  - Current home/NPC/background integration risks are covered where supported by repository evidence.
  - Follow-up fixes are decomposed so visual work does not silently modify gameplay logic.
- Validation procedure: repository inspection only. Any visual assertion requiring rendering must be listed for Codex/local validation rather than marked passed.

### NPC-001 — NPC/content audit
- Owner: npc-content
- Branch: `agent/npc-001-content-audit`
- Status: READY
- Objective: establish the current NPC/content inventory and identify missing/broken presentation, schedule, dialogue/event/quest attachment gaps and content risks.
- Read scope: `scenes/world/NPC.tscn`, NPC-related `scripts/world/**`, `scripts/systems/NPCScheduleSystem.gd`, `NpcRelations.gd`, `StorySystem.gd`, `EventSystem.gd`, `EncounterSystem.gd`, `QuestSystem.gd`, relevant `data/**`, NPC assets and NPC/quest verification tools.
- Writable files: `agent-reports/npc-content.md` only.
- Forbidden: source/data/scene/asset edits; `docs/agents/**`; `main`; shared high-conflict files.
- Acceptance:
  - NPC inventory maps data/schedule/entity/presentation resources.
  - Missing/broken/unattached resources and content gaps are listed with exact paths.
  - Dialogue/event/quest risks are distinguished from engine/runtime presentation checks.
  - Recommended repair/content order is prioritized and split into non-overlapping follow-up tasks.
- Validation procedure: repository inspection only. Historical `verify_npc`/quest results may be cited as prior evidence but not as a new test run.

### QA-001 — Repository health audit
- Owner: qa-build
- Branch: `agent/qa-001-repo-health`
- Status: READY
- Objective: perform the GitHub-visible half of the health audit: project/export/workflow configuration, resource references, existing verification scripts, deployment setup and likely build blockers.
- Read scope: entire repository, with focus on `project.godot`, `export_presets.cfg`, `.github/workflows/**`, `scenes/**`, resource references, `tools/**`, latest QA/handoff docs.
- Writable files: `agent-reports/qa-build.md` only.
- Forbidden: config/workflow/source/asset changes; `docs/agents/**`; `main`; claims that Godot/Web export/browser checks were rerun.
- Acceptance:
  - GitHub-visible health findings are grouped Critical/High/Medium/Low.
  - Main scene/export/workflow/reference configuration is inspected and exact suspicious paths are recorded.
  - Existing historical QA evidence is summarized without presenting it as a fresh run.
  - A narrow runtime validation package is produced: exact Godot commands/checks, expected evidence and deployment checks needed next.
  - Any blocker needing local/Codex execution is explicitly escalated rather than guessed.
- Validation procedure: repository inspection only.

### QA-002 — Godot/Web runtime acceptance
- Owner: qa-build (Codex/local execution)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: QA-001 runtime-validation package and availability of a local Godot execution context.
- Objective: execute the minimum runtime/build checks required to establish a fresh baseline after the repository audits.
- Allowed: only files explicitly granted by the orchestrator after QA-001 review; default is validation-only/no source edits.
- Forbidden: broad refactors, unrelated fixes, direct `main` changes.
- Acceptance:
  - Godot 4.7.2 project startup result captured.
  - Orchestrator-selected verification scripts executed with exit/output evidence.
  - Web export result captured.
  - Browser/runtime console or deployment evidence captured when requested.
  - Failures become separate repair tasks; they are not silently fixed inside the validation task.
- Validation procedure: actual local/Codex/CI execution required; repository inspection alone cannot complete this task.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`

Use `BLOCKED` when another task, asset, permission, execution environment or decision prevents progress.

Only the orchestrator edits this task board. Workers request `NEEDS_REVIEW` or `BLOCKED` through their assigned report.
