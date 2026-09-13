# Multi-Agent Task Board

## Sprint: Critical repair wave

Only the orchestrator edits this board. Workers read it and update only their own reports.

## Completed foundation
- ORCH-001 — DONE
- GAME-001 — DONE
- UI-001 — DONE
- NPC-001 — DONE
- QA-001 — DONE

## Gameplay pipeline

### GAME-FIX-001 — Separate daily event closure from annual progression
- Owner: gameplay
- Branch: `agent/game-fix-001-daily-event-separation`
- Status: DONE
- Priority: CRITICAL

### GAME-FIX-002 — Need-zero penalty cadence
- Owner: gameplay
- Branch: `agent/game-fix-002-need-zero-cadence`
- Status: DONE
- Priority: HIGH

### GAME-FIX-003 — Centralize terminal-state evaluation
- Owner: gameplay
- Branch: `agent/game-fix-003-terminal-state-evaluation`
- Status: DONE
- Priority: HIGH

### GAME-FIX-004 — Save/load terminal-state re-entry hardening
- Owner: gameplay
- Branch: `agent/game-fix-004-save-terminal-reentry`
- Status: DONE
- Priority: HIGH

### GAME-FIX-005 — Integration-ready gameplay contract audit
- Owner: gameplay
- Branch: `agent/game-fix-005-integration-contract-audit`
- Status: DONE
- Priority: MEDIUM

### GAME-FIX-006 — Gameplay integration callsite guard audit
- Owner: gameplay
- Branch: `agent/game-fix-006-integration-callsite-guard-audit`
- Status: DONE
- Priority: MEDIUM

### GAME-FIX-007 — Sleep settlement terminal guard
- Owner: gameplay
- Branch: `agent/game-fix-007-sleep-terminal-guard`
- Status: DONE
- Priority: HIGH
- Review result: repository-level accepted at `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344`. Branch changes only the explicitly authorized `scripts/Game.gd`, `tools/verify_sleep_terminal_guard.gd`, and gameplay report. The implementation routes overnight settlement through the existing authoritative evaluator before recovery and does not add a second death path. Runtime PASS is not inferred; all Gameplay regressions remain part of QA-002 on one frozen integration SHA.
- Integration note: this branch also reconstructs already accepted GAME-FIX-001..003 source semantics because the coordination branch is metadata-only. Do not blindly merge historical gameplay branches plus the full 007 branch; form one deterministic integrated `Game.gd` candidate.

### GAME-AUDIT-008 — Remaining terminal-sensitive time-settlement callsite audit
- Owner: gameplay
- Branch: `agent/game-audit-008-terminal-time-callsite-audit`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/gameplay.md` only.
- Objective: on top of the accepted GAME-FIX-007 semantic state, inventory every remaining `time_sys` advance / `_sync_needs_to_time()` / `_evaluate_terminal_state()` callsite and identify only concrete paths where need settlement, activity locking, recovery, or state mutation could still hide a terminal threshold before the authoritative evaluator observes it.
- Acceptance: report-only; exact function/callsite evidence; distinguish true bypasses from already safe process/year/sleep paths; propose at most the smallest follow-up Gameplay task if a concrete uncovered bypass exists; no source edits, no new thresholds or death paths, and no unrun Godot evidence.

## Scene/UI pipeline

### UI-FIX-001 — Active NPC grounding and animation integration
- Owner: scene-ui
- Branch: `agent/ui-fix-001-active-npc-integration`
- Status: NEEDS_REVIEW
- Priority: HIGH
- Hold: final visual acceptance requires exact-SHA Godot evidence.

### UI-FIX-002 — Home bed seam cleanup
- Owner: scene-ui
- Branch: `agent/ui-fix-002-home-bed-seam`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Hold: final visual acceptance requires exact-SHA Godot evidence.

### UI-FIX-003 — HUD/header layout decoupling
- Owner: scene-ui
- Branch: `agent/ui-fix-003-hud-header-decoupling`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Hold: final visual acceptance requires exact-SHA Godot evidence.

### UI-AUDIT-004 — Responsive presentation hotspot inventory
- Owner: scene-ui
- Branch: `agent/ui-audit-004-responsive-hotspots`
- Status: DONE
- Priority: MEDIUM

### UI-FIX-004 — Event panel overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-004-event-panel-overflow`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Hold: exact-SHA verifier plus rendered 1280x720 and 960x540 evidence required.

### UI-AUDIT-005 — Next responsive hotspot after EventUI
- Owner: scene-ui
- Branch: `agent/ui-audit-005-next-responsive-hotspot`
- Status: DONE
- Priority: MEDIUM

### UI-FIX-005 — Start screen vertical overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-005-start-screen-overflow`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Repository review: scope/ownership accepted. Branch delta is limited to `scripts/ui/StartUI.gd`, `tools/verify_start_screen_overflow.gd`, and scene-ui report; public StartUI lifecycle/signals remain intentionally preserved.
- Hold: task acceptance explicitly still requires real Godot execution and rendered 1280x720 + 960x540 evidence on the exact review/integration SHA. Source inspection or prepared headless assertions are not a rendered PASS.

### UI-AUDIT-006 — Next responsive hotspot after StartUI
- Owner: scene-ui
- Branch: `agent/ui-audit-006-next-responsive-hotspot`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/scene-ui.md` only.
- Objective: while UI-FIX-001..005 remain in exact-SHA render hold, inspect the remaining presentation surfaces for the smallest independent responsive/reachability defect that can be fixed without touching Gameplay, LocationManager, NPC content, save semantics, or currently held UI files.
- Acceptance: report-only; identify one smallest candidate with exact file/function/layout evidence and a narrow proposed writable boundary; explicitly avoid files already locked by UI-FIX-001..005; no source edits and no rendered/runtime PASS claims.

## NPC/Content pipeline

### NPC-CONTENT-002 — Narrative/mechanic alignment cleanup
- Owner: npc-content
- Branch: `agent/npc-content-002-narrative-alignment`
- Status: DONE

### NPC-CONTENT-003 — Core NPC naming and relationship-copy consistency audit
- Owner: npc-content
- Branch: `agent/npc-content-003-naming-consistency`
- Status: DONE

### NPC-CONTENT-004 — Relationship-neutral copy cleanup
- Owner: npc-content
- Branch: `agent/npc-content-004-relationship-neutral-copy`
- Status: DONE

### NPC-CONTENT-005 — Family-state ambiguity inventory
- Owner: npc-content
- Branch: `agent/npc-content-005-family-state-ambiguity-audit`
- Status: DONE
- Review: four hard cases remain deferred pending explicit family-state product policy.

### NPC-CONTENT-006 — Neutralize e_house relationship-loaded idiom
- Owner: npc-content
- Branch: `agent/npc-content-006-house-copy-neutralization`
- Status: DONE
- Priority: LOW

### NPC-CONTENT-007 — Remaining unconditional relationship-copy audit
- Owner: npc-content
- Branch: `agent/npc-content-007-remaining-neutral-copy-audit`
- Status: DONE
- Priority: LOW
- Review result: accepted as strict report-only audit. It identifies exactly two new safe copy-only candidates (`e_first_salary`, `e_sidejob`) and correctly leaves speaker/premise-level and family-policy cases untouched. No runtime/parser PASS is inferred.

### NPC-CONTENT-008 — Neutralize remaining incidental mother-specific copy
- Owner: npc-content
- Branch: `agent/npc-content-008-neutral-parent-copy`
- Status: READY
- Priority: LOW
- Writable: `data/events.json`, `agent-reports/npc-content.md`.
- Objective: remove only the unsupported mother-specific relationship assumptions identified by NPC-CONTENT-007 in `e_first_salary` and `e_sidejob`, preserving each event's action/tone and all mechanics.
- Acceptance: exactly two string-value edits only; no speaker, conditions, IDs, flags, rewards/effects, age/origin eligibility, jobs, counters, schema, or flow changes; keep the four family-policy events untouched; report exact old/new strings; do not claim unrun parser/Godot evidence.

## QA/Build pipeline

### QA-002 — Godot/Web runtime acceptance
- Owner: qa-build (local/Codex execution)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: actual Godot 4.7.2 + browser execution context.

### QA-003 — Headless regression gate specification
- Owner: qa-build
- Branch: `agent/qa-003-headless-gate-spec`
- Status: DONE

### QA-004 — Repair-wave acceptance matrix
- Owner: qa-build
- Branch: `agent/qa-004-repair-wave-acceptance-matrix`
- Status: DONE

### QA-005 — Next-wave acceptance manifest
- Owner: qa-build
- Branch: `agent/qa-005-next-wave-manifest`
- Status: DONE

### QA-006 — Integration merge/conflict manifest
- Owner: qa-build
- Branch: `agent/qa-006-integration-conflict-manifest`
- Status: DONE

### QA-007 — Next-wave branch freshness and acceptance delta
- Owner: qa-build
- Branch: `agent/qa-007-next-wave-delta`
- Status: DONE

### QA-008 — Exact-SHA runtime handoff refresh
- Owner: qa-build
- Branch: `agent/qa-008-runtime-handoff-refresh`
- Status: DONE
- Priority: MEDIUM

### QA-009 — Acceptance delta for GAME-FIX-007 / UI-FIX-005 / NPC-CONTENT-007
- Owner: qa-build
- Branch: `agent/qa-009-next-wave-acceptance-delta`
- Status: DONE
- Priority: MEDIUM
- Review result: accepted as report-only. It correctly captures exact tips, preserves the single-integration-SHA rule, keeps UI-FIX-001..005 rendered holds, and does not infer runtime/parser/Web PASS.

### QA-010 — Post-review integration and freshness delta
- Owner: qa-build
- Branch: `agent/qa-010-post-review-integration-delta`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: refresh the integration/acceptance manifest after repository acceptance of GAME-FIX-007, NPC-CONTENT-007, and QA-009 while UI-FIX-005 remains in render hold; include the newly queued GAME-AUDIT-008, UI-AUDIT-006, and NPC-CONTENT-008 boundaries and identify any deterministic integration-order/conflict hazards.
- Acceptance: report-only; capture exact branch tips and stale-SHA conditions; keep QA-002 blocked only on real Godot/browser context; no merges, worker-code edits, workflow edits, parser/Godot/Web/browser execution, or inferred PASS.

## Deferred product decisions
1. Family-state event-condition semantics for `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive behavior requires an explicit product/content decision.
2. Relationship-aware NPC dialogue/trust mechanics require explicit schema/ownership assignment.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`; use `BLOCKED` when execution context or another task prevents progress.
