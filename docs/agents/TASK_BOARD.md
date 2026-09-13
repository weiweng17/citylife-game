# Multi-Agent Task Board

## Sprint: Critical repair wave

### ORCH-001
- Owner: orchestrator
- Branch: `orchestrator/multi-agent-bootstrap`
- Status: DONE

### GAME-001
- Owner: gameplay
- Branch: `agent/game-001-blocker-audit`
- Status: DONE

### UI-001
- Owner: scene-ui
- Branch: `agent/ui-001-visual-audit`
- Status: DONE

### NPC-001
- Owner: npc-content
- Branch: `agent/npc-001-content-audit`
- Status: DONE

### QA-001 — Repository health audit
- Owner: qa-build
- Branch: `agent/qa-001-repo-health`
- Status: DONE
- Result: accepted. Diff is report-only (`agent-reports/qa-build.md`). No Critical repository-visible blocker was found. Fresh Godot/Web runtime evidence is still outstanding.

### GAME-FIX-001 — Separate daily event closure from annual progression
- Owner: gameplay
- Branch: `agent/game-fix-001-daily-event-separation`
- Status: READY
- Priority: CRITICAL
- Writable: `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression if needed, `agent-reports/gameplay.md`.
- Acceptance: regular event close must not advance year/age; annual progression stays separately callable; no unrelated semantics change; add regression; do not claim unrun runtime evidence.

### UI-FIX-001 — Active NPC grounding and animation integration
- Owner: scene-ui
- Branch: `agent/ui-fix-001-active-npc-integration`
- Status: READY
- Priority: HIGH
- Writable: `scripts/systems/LocationManager.gd`, narrow helper under `scripts/world/` if needed, existing NPC visual refs, `agent-reports/scene-ui.md`.
- Acceptance: active NPC path uses walk-capable presentation where available; feet/shadow/scale/depth remain coherent; talk/click behavior stays intact; visual pass waits for rendered evidence.

### NPC-CONTENT-002 — Narrative/mechanic alignment cleanup
- Owner: npc-content
- Branch: `agent/npc-content-002-narrative-alignment`
- Status: READY
- Priority: MEDIUM
- Writable: `data/quests.json`, `data/events.json`, `agent-reports/npc-content.md`.
- Objective: without schema/logic changes, rewrite q3 so it does not claim a completed gift handoff when the mechanic only checks a store purchase; remove the ambiguous hospital `老张` naming conflict.
- Acceptance: JSON valid; IDs/counters/flow unchanged; only copy/content semantics change; report records exact edits.

### QA-002 — Godot/Web runtime acceptance
- Owner: qa-build (local/Codex execution)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: actual Godot 4.7.2 + browser execution context.
- Objective: run the QA-001 runtime package on one exact SHA and record commands, exit codes, regression summaries, export result and browser evidence.

### QA-003 — Headless regression gate specification
- Owner: qa-build
- Branch: `agent/qa-003-headless-gate-spec`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: classify current `tools/verify_*.gd` scripts into headless-safe, windowed-only, deprecated/unsafe-as-gate, or unknown; propose the smallest ordered headless CI gate with exact commands. Do not edit workflows and do not claim tests were run.

## Deferred next repairs
1. GAME-FIX-002 — need-zero penalty cadence.
2. GAME-FIX-003 — centralized terminal-state evaluation.
3. UI-FIX-002 — home bed seam cleanup.
4. UI-FIX-003 — HUD/header layout decoupling.
5. SAVE-HARDEN-001 — save hardening.
6. Relationship-aware NPC dialogue/trust work after explicit schema ownership assignment.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`; use `BLOCKED` when execution context or another task prevents progress.

Only the orchestrator edits this board. Workers update only their own reports for review requests.
