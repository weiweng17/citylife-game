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
- Review: accepted at repository level; fresh integrated Godot execution remains QA work.

### GAME-FIX-002 — Need-zero penalty cadence
- Owner: gameplay
- Branch: `agent/game-fix-002-need-zero-cadence`
- Status: DONE
- Priority: HIGH
- Review: accepted at repository level; hourly need settlement contract retained.

### GAME-FIX-003 — Centralize terminal-state evaluation
- Owner: gameplay
- Branch: `agent/game-fix-003-terminal-state-evaluation`
- Status: DONE
- Priority: HIGH
- Review: accepted at repository level; `_evaluate_terminal_state()` remains authoritative.

### GAME-FIX-004 — Save/load terminal-state re-entry hardening
- Owner: gameplay
- Branch: `agent/game-fix-004-save-terminal-reentry`
- Status: DONE
- Priority: HIGH
- Review: accepted as regression coverage; no second save-specific terminal path.

### GAME-FIX-005 — Integration-ready gameplay contract audit
- Owner: gameplay
- Branch: `agent/game-fix-005-integration-contract-audit`
- Status: DONE
- Priority: MEDIUM
- Review: accepted report-only integration contract audit.

### GAME-FIX-006 — Gameplay integration callsite guard audit
- Owner: gameplay
- Branch: `agent/game-fix-006-integration-callsite-guard-audit`
- Status: DONE
- Priority: MEDIUM
- Writable: `agent-reports/gameplay.md` only.
- Review result: accepted. Diff is report-only and identifies one concrete uncovered bypass: sleep settlement can cross a terminal threshold inside `_sync_needs_to_time()` and then apply sleep recovery before the authoritative evaluator observes that state. No runtime PASS is inferred.

### GAME-FIX-007 — Sleep settlement terminal guard
- Owner: gameplay
- Branch: `agent/game-fix-007-sleep-terminal-guard`
- Status: READY
- Priority: HIGH
- Writable: `scripts/Game.gd`, one narrow `tools/verify_sleep_terminal_guard.gd`, `agent-reports/gameplay.md`.
- Objective: preserve GAME-FIX-001..004 contracts while ensuring the sleep-specific `_sync_needs_to_time()` path cannot cross a terminal health/mood threshold and then be revived by same-flow sleep recovery before `_evaluate_terminal_state()` runs.
- Acceptance: use the existing authoritative evaluator; if overnight settlement is terminal, stop sleep recovery and normal completion/toast flow after unlocking/finishing the activity safely; preserve existing sleep duration and non-terminal recovery values; no new thresholds, save fields, ending path, annual behavior, UI semantics, or LocationManager changes; add a narrow regression; do not claim unrun Godot evidence.

## Scene/UI pipeline

### UI-FIX-001 — Active NPC grounding and animation integration
- Owner: scene-ui
- Branch: `agent/ui-fix-001-active-npc-integration`
- Status: NEEDS_REVIEW
- Priority: HIGH
- Review: repository scope accepted; final visual acceptance requires exact-SHA Godot evidence.

### UI-FIX-002 — Home bed seam cleanup
- Owner: scene-ui
- Branch: `agent/ui-fix-002-home-bed-seam`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Review: repository scope accepted; final visual acceptance requires exact-SHA Godot evidence.

### UI-FIX-003 — HUD/header layout decoupling
- Owner: scene-ui
- Branch: `agent/ui-fix-003-hud-header-decoupling`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Review: repository scope accepted; final visual acceptance requires exact-SHA Godot evidence.

### UI-AUDIT-004 — Responsive presentation hotspot inventory
- Owner: scene-ui
- Branch: `agent/ui-audit-004-responsive-hotspots`
- Status: DONE
- Priority: MEDIUM
- Review: accepted report-only audit; led to UI-FIX-004.

### UI-FIX-004 — Event panel overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-004-event-panel-overflow`
- Status: NEEDS_REVIEW
- Priority: MEDIUM
- Review: repository scope/ownership accepted; final task acceptance requires real Godot execution and rendered 1280x720 + 960x540 evidence on the exact review/integration SHA.

### UI-AUDIT-005 — Next responsive hotspot after EventUI
- Owner: scene-ui
- Branch: `agent/ui-audit-005-next-responsive-hotspot`
- Status: DONE
- Priority: MEDIUM
- Writable: `agent-reports/scene-ui.md` only.
- Review result: accepted. Diff is report-only, respects ownership, and identifies StartUI as the next smallest responsive repair while preserving the pre-tree `setup()` and post-ready `set_load_available()` lifecycle contract. No rendered/runtime PASS is inferred.

### UI-FIX-005 — Start screen vertical overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-005-start-screen-overflow`
- Status: READY
- Priority: MEDIUM
- Writable: `scripts/ui/StartUI.gd`, one narrow `tools/verify_start_screen_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: give StartUI an explicit bounded vertical overflow/scroll owner so all four current origin cards and the optional load action remain reachable at 1280x720 and 960x540 without changing start/save/origin semantics.
- Acceptance: `setup(origins, money_formatter)` remains valid before `add_child`; `origin_selected(origin)`, `load_requested`, `open()`, `close()`, and `set_load_available(value)` remain compatible; post-ready load-button toggling remains safe; all four cards and load button are reachable through a vertical scroll path when needed; full-card hit targets preserve the exact supplied origin dictionary; no `Game.gd`, `Data.gd`, gameplay, navigation, NPC, or save semantics changes; rendered PASS still requires actual Godot evidence.

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
- Review result: accepted. Branch delta is limited to `data/events.json` plus the NPC report; the source change is exactly one string substitution in `e_house` (`掏空六个钱包，买` → `凑够首付，买`) with mechanics/conditions/IDs/flags/effects unchanged. No parser/runtime PASS is inferred.

### NPC-CONTENT-007 — Remaining unconditional relationship-copy audit
- Owner: npc-content
- Branch: `agent/npc-content-007-remaining-neutral-copy-audit`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/npc-content.md` only.
- Objective: inspect remaining event/quest strings for relationship or household claims that are unconditionally asserted without supporting eligibility, excluding the four explicitly policy-dependent family-state events (`e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`) and excluding already accepted fixes. Identify only additional copy-only candidates that can be neutralized without changing speakers, conditions, IDs, flags, rewards/effects, counters, schema, or flow.
- Acceptance: report-only; exact IDs/strings and eligibility evidence; clearly separate safe copy-only candidates from mechanic/policy-dependent cases; do not edit data or invent family-state rules; no runtime/parser PASS claimed.

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
- Writable: `agent-reports/qa-build.md` only.
- Review result: accepted. Diff is report-only, refreshes exact branch tips/stale-SHA hazards, preserves rendered-evidence requirements, and correctly escalates GAME-FIX-006's sleep-settlement gap without patching gameplay. No runtime/Web/parser PASS is inferred.

### QA-009 — Acceptance delta for GAME-FIX-007 / UI-FIX-005 / NPC-CONTENT-007
- Owner: qa-build
- Branch: `agent/qa-009-next-wave-acceptance-delta`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: prepare the exact repository-only acceptance matrix for GAME-FIX-007, UI-FIX-005, and NPC-CONTENT-007 while refreshing the current UI-FIX-001..004 hold tips. Define narrow verifier commands, rendered requirements, stale-SHA stop conditions, and how the new tasks extend the existing single-integration-SHA runtime handoff.
- Acceptance: report-only; capture exact branch tips; no merges, workflow edits, worker-code edits, Godot/Web/browser/parser execution, or inferred PASS; UI-FIX-005 must retain rendered 1280x720 + 960x540 evidence requirements; GAME-FIX-007 must be validated through the existing authoritative terminal evaluator contract rather than a new sleep-specific death path.

## Deferred product decisions
1. Family-state event-condition semantics for `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive behavior requires an explicit product/content decision.
2. Relationship-aware NPC dialogue/trust mechanics require explicit schema/ownership assignment.

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`; use `BLOCKED` when execution context or another task prevents progress.
