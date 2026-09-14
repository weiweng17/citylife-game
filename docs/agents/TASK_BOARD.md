# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012 are DONE.

## Gameplay
### GAME-FIX-009 — Pre-terminal mutation ordering guard
- Owner: gameplay
- Branch: `agent/game-fix-009-terminal-mutation-order`
- Status: DONE
- Accepted exact tip: `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`.
- Runtime verifier execution remains part of QA-002 on one frozen integration SHA.

### GAME-AUDIT-010 — Post-009 terminal-sensitive mutation surface audit
- Owner: gameplay
- Branch: `agent/game-audit-010-terminal-mutation-surface`
- Status: DONE
- Accepted exact tip: `fee1ee8072aeea821fd78881fbb4b0a06404526b`.
- Review: report-only scope respected. No new repository-proven deterministic terminal revival/masking bypass was found after GAME-FIX-009. The cafe immediate-reentry / deferred travel-settlement scenario is retained only as a QA-002 runtime stress case; it is not a source-level failure and no speculative source fix is authorized.

### GAME-AUDIT-011 — Cross-midnight daily-boundary audit
- Owner: gameplay
- Branch: `agent/game-audit-011-cross-midnight-daily-boundaries`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/gameplay.md` only.
- Objective: audit the daily-loop boundary when travel, work, meal, rest or other accepted minute advances cross midnight. Focus on `day_changed`, `DailyRoutine` reset/mark ordering, commute/work/meal/rest completion bookkeeping, pending need settlement and save payload state. Determine whether any concrete normal-play path loses a just-completed objective, double-counts an objective, or associates completion with the wrong day.
- Acceptance: report-only; exact functions/signal ordering and at least one concrete reproducible state sequence for any finding; distinguish known/intentional reset behavior from real objective-state loss; propose at most one smallest follow-up if a repository-proven defect exists; no source/data/UI edits and no unrun Godot claims.

## Scene/UI — exact-SHA runtime holds
The following repository implementations are `BLOCKED` only because final acceptance requires real exact-SHA Godot/rendered evidence:
- UI-FIX-001 — BLOCKED — `07a4d159e073e9f810cf1c3007ba907a49299ae3`.
- UI-FIX-002 — BLOCKED — `b480befaedc3a3b0cbdaca1916e31dbba7283121`.
- UI-FIX-003 — BLOCKED — `51124e758877750d01f8b72429ead0075a73c596`.
- UI-FIX-004 — BLOCKED — `4a2ce2473dd05691fc2e1368b381497a5768d3e6`.
- UI-FIX-005 — BLOCKED — `a0402610cef12455dfc970641e4273c8b246d6d1`.
- UI-FIX-006 — BLOCKED — repository-reviewed exact tip `d328f227b8473297d4b74c058dfd1a7101a68074`; needs `verify_shop_panel_overflow.gd` plus rendered 1280x720 and 960x540 evidence on the frozen integration SHA.

### UI-AUDIT-007 — Next unlocked presentation hotspot after ShopUI
- Owner: scene-ui
- Branch: `agent/ui-audit-007-next-presentation-hotspot`
- Status: DONE
- Accepted exact tip: `83f1b0f4003359ceb4da7f263b29916986888f1c`.
- Review: report-only scope respected. Accepted next isolated repair: bound only the DialogUI wrapped body while preserving speaker/action reachability and the exact `dialog_finished` / `is_busy()` lifecycle contract. No rendered/runtime PASS inferred.

### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: READY
- Priority: MEDIUM
- Writable: `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: keep the existing bottom-dialog panel bounded while giving only the wrapped dialogue body a vertical overflow path. Speaker and `继续` / `结束` action must stay outside the scroll region and reachable.
- Preserve: `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line-at-a-time progression, button copy, exactly-once final emission, and Game-facing busy-state behavior.
- Required repository checks: scroll resets on next line and reopen; normal and deliberately long lines remain contained; no Game/Data/NPC/content/queue/clue/relationship/navigation/save edits.
- Forbidden: `scripts/Game.gd`, `scripts/Data.gd`, LocationManager, NPC/content/event data, UI-FIX-001..006 files, main, coordination files.
- Final PASS requires actual Godot verifier/rendered evidence on the exact frozen integration SHA; the web worker must not claim it.

## NPC/Content
### NPC-AUDIT-009 — Remaining speaker/premise consistency triage
- Owner: npc-content
- Branch: `agent/npc-audit-009-speaker-premise-triage`
- Status: DONE
- Accepted exact tip: `a16920be7462436c1070e79e833cbadb7bdd0bd1`.

### NPC-CONTENT-010 — Genericize safe parent-specific callers
- Owner: npc-content
- Branch: `agent/npc-content-010-generic-family-callers`
- Status: DONE
- Accepted exact tip: `923e43541303a4f66a643bddef3a993a1ed234b5`.
- Accepted source commit: `46264de61d72c6b8a51bbe54003f665c36226f4a`.
- Review: exactly three authorized string-value substitutions in `data/events.json`: both safe caller speakers become `家里来电`, and the father-specific first-option result in `e_parent_sick` is neutralized. No condition/effect/flag/ID/schema/flow change. Parser/runtime PASS is not inferred.

### NPC-AUDIT-011 — Post-genericization pronoun consistency audit
- Owner: npc-content
- Branch: `agent/npc-audit-011-post-genericization-pronouns`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/npc-content.md` only.
- Objective: inspect `e_parents_call` and `e_parent_sick` after the accepted generic-speaker edits, plus immediately adjacent safe family-neutral copy, for residual gendered/relationship-specific pronouns or wording that now conflicts with generic callers. Classify each finding as safe copy-only vs state/schema/product-policy dependent.
- Acceptance: report-only; exact event/string evidence; propose at most one smallest safe copy-only follow-up; do not touch `e_parent_gone`, `e_roommate`, or the four deferred spouse/child-policy events except to mark them out of scope; no data edits and no parser/Godot claims.

## QA/Build
### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- Consolidate all terminal/parser/Godot/headless/rendered/Web-export/browser/screenshot evidence here. Any candidate SHA movement invalidates affected evidence.
- Include accepted GAME-FIX-009 regressions, UI-FIX-001..006 verifiers/rendered checks, accepted content parse/diff gates, and the GAME-AUDIT-010 cafe immediate-reentry runtime stress case.

### QA-012 — Post-review integration manifest for 009/006/009
- Owner: qa-build
- Branch: `agent/qa-012-post-review-integration-manifest`
- Status: DONE
- Accepted exact tip: `996e2e5146d9aa65a65c81c5e2c8f5e8b8b82cc1`.
- Review: report-only scope respected. Accepted deterministic semantic assembly rules, one-frozen-SHA/stale-evidence stop conditions, and the QA-002 command/evidence structure. Its statements treating GAME-AUDIT-010/UI-AUDIT-007/NPC-CONTENT-010 as unreviewed are now superseded by this heartbeat.

### QA-013 — Next-wave candidate / Codex preflight
- Owner: qa-build
- Branch: `agent/qa-013-next-wave-candidate-preflight`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: refresh exact reviewed inputs after acceptance of GAME-AUDIT-010, UI-AUDIT-007, NPC-CONTENT-010 and QA-012; incorporate the newly queued GAME-AUDIT-011, UI-FIX-007 and NPC-AUDIT-011 boundaries; state the deterministic integration order, which deltas enter the next frozen candidate, and the minimal QA-002 handoff including the cafe immediate-reentry stress.
- Acceptance: report-only; exact tips/stale-SHA rules; keep real runtime evidence exclusively in QA-002; no merges, source/data/workflow edits, parser/Godot/Web/browser execution or inferred PASS.

## Deferred product decisions
- `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive policy.
- `e_roommate` / Xiaoyu housing canon: canonical roommate vs separate roommate vs explicit shared-rent state.
- `e_parent_gone`: parent-existence/alive state contract before unconditional parent-death mechanics are changed.
- Relationship-aware NPC dialogue/trust schema and ownership.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; use `BLOCKED` when real execution/dependency context prevents completion.
