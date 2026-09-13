# Multi-Agent Task Board

## Sprint: Baseline accepted → critical repair wave

Current product context: Phase 3 code is substantially complete and Phase 4 content work has begun. First-wave repository audits are now accepted for Gameplay, Scene/UI and NPC/Content. QA repository health audit remains outstanding. Critical repairs may start before QA-001 finishes when their file ownership does not conflict.

### ORCH-001 — Multi-agent control layer
- Owner: orchestrator
- Branch: `orchestrator/multi-agent-bootstrap`
- Status: DONE
- Objective: establish rules, task board, ownership, reporting, recovery and review process.
- Validation: repository/document review only.

### GAME-001 — Current gameplay blocker inventory
- Owner: gameplay
- Branch: `agent/game-001-blocker-audit`
- Status: DONE
- Result: accepted report-only audit. Highest priority finding is the daily-event → `_year_pass()` seam; additional findings cover need-zero penalty cadence, terminal-state checks, partial-hour need persistence and save hardening.
- Evidence: branch diff touches only `agent-reports/gameplay.md`; no source/config ownership violation.

### UI-001 — Scene/UI visual integration audit
- Owner: scene-ui
- Branch: `agent/ui-001-visual-audit`
- Status: DONE
- Result: accepted report-only audit. Highest priorities are unresolved home-bed composition, NPC grounding/scale mismatch, HUD/header layout coupling and expanded-location visual calibration.
- Evidence: branch diff touches only `agent-reports/scene-ui.md`; no source/config ownership violation.

### NPC-001 — NPC/content audit
- Owner: npc-content
- Branch: `agent/npc-001-content-audit`
- Status: DONE
- Result: accepted report-only audit. Six core NPCs and schedules exist; active NPC rendering is static, walk assets are unattached, schedule position data is detached from the formal renderer, and several relationship/quest/content integration gaps were identified.
- Evidence: branch diff touches only `agent-reports/npc-content.md`; no source/config ownership violation.

### QA-001 — Repository health audit
- Owner: qa-build
- Branch: `agent/qa-001-repo-health`
- Status: READY
- Objective: inspect project/export/workflow configuration, resource references, verification scripts and deployment setup, then package exact runtime checks for QA-002.
- Writable files: `agent-reports/qa-build.md` only.
- Forbidden: config/workflow/source/asset changes; `docs/agents/**`; `main`; claims that Godot/Web checks were rerun.
- Acceptance:
  - Findings grouped Critical/High/Medium/Low.
  - Main scene/export/workflow/reference configuration inspected.
  - Historical QA separated from fresh evidence.
  - Narrow QA-002 runtime package produced with exact commands/checks and expected evidence.

### GAME-FIX-001 — Separate daily event closure from annual progression
- Owner: gameplay
- Branch: `agent/game-fix-001-daily-event-separation`
- Status: READY
- Priority: CRITICAL
- Source: GAME-001 / G-001.
- Objective: normal independent-location regular events must not call annual progression, increment age, or run `Rules.year_tick()`.
- Writable files: `scripts/Game.gd`; one narrowly scoped new or existing `tools/verify_*.gd` regression file if needed; `agent-reports/gameplay.md`.
- Forbidden: `LocationManager.gd`, UI, assets, content rebalance, unrelated refactors, `main`, `docs/agents/**`.
- Acceptance:
  - Closing a regular independent-location event does not change age merely because the event closed.
  - Annual progression remains explicit and separately callable where intentionally retained.
  - No unrelated event/encounter semantics change.
  - Add a regression that fails on the previous event→year behavior.
  - Worker report distinguishes repository/code reasoning from actual Godot runtime evidence.
- Runtime gate: requires QA-002/local Godot execution before final product acceptance.

### UI-FIX-001 — Active NPC grounding and animation integration
- Owner: scene-ui
- Branch: `agent/ui-fix-001-active-npc-integration`
- Status: READY
- Priority: HIGH
- Source: UI-001 / UI-AUD-02 and NPC-001 P1.
- Objective: replace the active independent-location NPC "static sticker" presentation with a player-compatible visual contract using existing NPC walk resources where practical: feet anchor, scale/depth behavior, shadow contact, tint/lighting, click target and idle/walk-capable rendering.
- Writable files: `scripts/systems/LocationManager.gd`; narrowly scoped helper under `scripts/world/` if created; existing NPC visual resource references only; `agent-reports/scene-ui.md`.
- Forbidden: gameplay settlement, quest/content semantics, `Game.gd`, unrelated scene/HUD refactors, replacing art wholesale, `main`, `docs/agents/**`.
- Acceptance:
  - Active formal NPC path no longer depends on a single static atlas frame where a walk sheet is available.
  - Grounding/shadow/scale logic is consistent with the current scene depth model.
  - Click/talk request behavior remains intact.
  - Legacy `NPC.tscn` is not treated as the authoritative active path.
  - Visual PASS is withheld until rendered/local capture evidence exists.
- Runtime gate: requires rendered Godot captures for representative NPCs/locations before final product acceptance.

### QA-002 — Godot/Web runtime acceptance
- Owner: qa-build (Codex/local execution)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: QA-001 runtime-validation package and availability of actual Godot/browser execution context.
- Objective: run fresh project startup, selected verification scripts, Web export and browser/runtime checks. Failures become separate repair tasks rather than silent fixes.

## Deferred next repairs
After GAME-FIX-001 / UI-FIX-001 and QA-001 evidence are reviewed, orchestrator should queue, in order:
1. GAME-FIX-002 — need-zero penalty cadence.
2. GAME-FIX-003 — centralized terminal-state evaluation.
3. UI-FIX-002 — home bed seam cleanup.
4. UI-FIX-003 — HUD/header layout decoupling.
5. NPC-CONTENT-002 — q3 narrative/mechanic alignment and low-conflict content cleanup.
6. SAVE-HARDEN-001 — backup/atomic-ish single-slot save hardening.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`

Use `BLOCKED` when another task, permission, execution environment or decision prevents progress.

Only the orchestrator edits this task board. Workers request review/blocking through their assigned report.