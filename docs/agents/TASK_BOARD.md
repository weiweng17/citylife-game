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
- Status: DONE
- Priority: CRITICAL
- Writable: `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression if needed, `agent-reports/gameplay.md`.
- Acceptance: regular event close must not advance year/age; annual progression stays separately callable; no unrelated semantics change; add regression; do not claim unrun runtime evidence.
- Review result: accepted at repository level. Branch diff is limited to the three authorized paths; the annual entry point is preserved; runtime execution remains part of QA/local acceptance rather than this repository-only task.

### GAME-FIX-002 — Need-zero penalty cadence
- Owner: gameplay
- Branch: `agent/game-fix-002-need-zero-cadence`
- Status: READY
- Priority: HIGH
- Writable: `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression if needed, `agent-reports/gameplay.md`.
- Objective: make zero-need penalties follow the intended time cadence rather than being reapplied on unrelated UI/event refresh paths. Preserve current balance values and save schema; do not redesign needs progression.
- Acceptance: penalty application is tied to one explicit time-advance cadence; no duplicate penalty from refresh/re-entry paths; existing need drain/replenish semantics remain unchanged; add a narrow regression and do not claim unrun runtime evidence.

### UI-FIX-001 — Active NPC grounding and animation integration
- Owner: scene-ui
- Branch: `agent/ui-fix-001-active-npc-integration`
- Status: NEEDS_REVIEW
- Priority: HIGH
- Writable: `scripts/systems/LocationManager.gd`, narrow helper under `scripts/world/` if needed, existing NPC visual refs, one narrow `tools/verify_*.gd` regression if needed, `agent-reports/scene-ui.md`.
- Acceptance: active NPC path uses walk-capable presentation where available; feet/shadow/scale/depth remain coherent; talk/click behavior stays intact; visual pass waits for rendered evidence.
- Review result: repository implementation and file ownership are acceptable, but final visual acceptance is intentionally withheld until rendered Godot evidence confirms grounding/scale/occlusion/click alignment on the exact task SHA.

### UI-FIX-002 — Home bed seam cleanup
- Owner: scene-ui
- Branch: `agent/ui-fix-002-home-bed-seam`
- Status: READY
- Priority: MEDIUM
- Writable: home sleep presentation files under `scenes/**` and/or existing home/sleep visual refs under `assets/**` only when required, one narrow helper/regression under `tools/` if needed, `agent-reports/scene-ui.md`.
- Objective: clean the remaining sleep/bed foreground seam without changing sleep gameplay, input routing, world navigation, or shared manager logic.
- Acceptance: lower-body/duvet/bed foreground composition has one coherent layering contract; no gameplay or navigation semantics change; repository changes stay limited to presentation-owned paths; rendered visual PASS must still wait for actual Godot evidence.

### NPC-CONTENT-002 — Narrative/mechanic alignment cleanup
- Owner: npc-content
- Branch: `agent/npc-content-002-narrative-alignment`
- Status: IN_PROGRESS
- Priority: MEDIUM
- Writable: `data/quests.json`, `data/events.json`, `agent-reports/npc-content.md`.
- Objective: without schema/logic changes, rewrite q3 so it does not claim a completed gift handoff when the mechanic only checks a store purchase; remove the ambiguous hospital naming conflict.
- Acceptance: JSON valid; IDs/counters/flow unchanged; only copy/content semantics change; report records exact edits.
- Review finding: q3 is accepted. The hospital replacement `老周` is not accepted because `老周` is already a core NPC; replace only that result copy with a non-core generic identity such as `隔壁床的病友`, then return to NEEDS_REVIEW.

### QA-002 — Godot/Web runtime acceptance
- Owner: qa-build (local/Codex execution)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: actual Godot 4.7.2 + browser execution context.
- Objective: run the QA-001 runtime package on one exact SHA and record commands, exit codes, regression summaries, export result and browser evidence.

### QA-003 — Headless regression gate specification
- Owner: qa-build
- Branch: `agent/qa-003-headless-gate-spec`
- Status: DONE
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: classify current `tools/verify_*.gd` scripts into headless-safe, windowed-only, deprecated/unsafe-as-gate, or unknown; propose the smallest ordered headless CI gate with exact commands. Do not edit workflows and do not claim tests were run.
- Review result: accepted. Report-only diff respects ownership, classifies all current verify scripts, proposes a six-script minimum gate, and clearly separates historical evidence from fresh execution.

### QA-004 — Repair-wave acceptance matrix
- Owner: qa-build
- Branch: `agent/qa-004-repair-wave-acceptance-matrix`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: prepare one exact, ordered acceptance matrix for GAME-FIX-001, UI-FIX-001 and NPC-CONTENT-002: branch/SHA to test, required headless scripts, required rendered checks, expected evidence, and stop conditions. Do not run Godot/Web, edit workflows, or alter worker code.
- Acceptance: matrix is branch/SHA-specific, separates repository checks from runtime/rendered checks, includes the new narrow regressions where present, and identifies which results are required before each task may be integrated.

## Deferred next repairs
1. GAME-FIX-003 — centralized terminal-state evaluation.
2. UI-FIX-003 — HUD/header layout decoupling.
3. SAVE-HARDEN-001 — save hardening.
4. Relationship-aware NPC dialogue/trust work after explicit schema ownership assignment.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`; use `BLOCKED` when execution context or another task prevents progress.

Only the orchestrator edits this board. Workers update only their own reports for review requests.
