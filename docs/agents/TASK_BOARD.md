# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009,
UI-AUDIT-004..006,
NPC-CONTENT-002..008, NPC-AUDIT-009,
QA-003..011 are DONE.

## Gameplay
### GAME-FIX-009 — Pre-terminal mutation ordering guard
- Owner: gameplay
- Branch: `agent/game-fix-009-terminal-mutation-order`
- Status: DONE
- Accepted exact tip: `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`.
- Review: authorized scope only (`scripts/Game.gd`, `tools/verify_terminal_mutation_order.gd`, gameplay report). The worker correctly rebuilt from accepted GAME-FIX-007 semantic `Game.gd`, then moved settled-frame terminal evaluation before quest rewards and synchronously settled/evaluated shop-use elapsed time before another item use. No new terminal threshold/death authority was introduced. Runtime PASS is not inferred; verifier execution belongs to QA-002 on the frozen integration SHA.

### GAME-AUDIT-010 — Post-009 terminal-sensitive mutation surface audit
- Owner: gameplay
- Branch: `agent/game-audit-010-terminal-mutation-surface`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/gameplay.md` only.
- Objective: from the accepted GAME-FIX-009 semantic state, audit remaining callbacks/signals/systems that can mutate health, mood, money, fullness or energy while terminal observation is deferred; identify only concrete paths capable of reviving or masking a terminal state before the existing `_evaluate_terminal_state()` observes it.
- Acceptance: report-only; exact functions/callsites and state ordering; distinguish harmless delayed presentation from real pre-observation mutation; propose at most one smallest follow-up if a concrete bypass remains; no source edits, thresholds, death paths or unrun runtime claims.

## Scene/UI — exact-SHA runtime holds
The following repository implementations were already reviewed for scope/contract and are now normalized to `BLOCKED` because final acceptance explicitly requires real exact-SHA Godot/rendered evidence. Their branch tips are unchanged from the last manifest.

- UI-FIX-001 — BLOCKED — `07a4d159e073e9f810cf1c3007ba907a49299ae3`; needs exact-SHA Godot rendered evidence for active NPC grounding/scale/occlusion/click alignment.
- UI-FIX-002 — BLOCKED — `b480befaedc3a3b0cbdaca1916e31dbba7283121`; needs exact-SHA rendered bed/duvet seam evidence.
- UI-FIX-003 — BLOCKED — `51124e758877750d01f8b72429ead0075a73c596`; needs exact-SHA rendered HUD evidence at declared viewports.
- UI-FIX-004 — BLOCKED — `4a2ce2473dd05691fc2e1368b381497a5768d3e6`; needs verifier plus rendered 1280x720 and 960x540 evidence.
- UI-FIX-005 — BLOCKED — `a0402610cef12455dfc970641e4273c8b246d6d1`; repository scope accepted; needs exact-SHA verifier plus rendered 1280x720 and 960x540 evidence.

### UI-FIX-006 — Shop list vertical overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-006-shop-list-overflow`
- Status: BLOCKED
- Repository-reviewed exact tip: `d328f227b8473297d4b74c058dfd1a7101a68074`.
- Review: authorized scope only (`scripts/ui/ShopUI.gd`, `tools/verify_shop_panel_overflow.gd`, Scene/UI report). The list-only `ScrollContainer`, fixed header/status/footer/close regions, viewport-relative panel-height target, and rebuild scroll reset satisfy the repository/layout contract without touching gameplay/inventory semantics.
- Blocked by: actual Godot execution of `verify_shop_panel_overflow.gd` and rendered 1280x720 + 960x540 evidence on the exact frozen integration SHA. Headless source inspection is not rendered PASS.

### UI-AUDIT-007 — Next unlocked presentation hotspot after ShopUI
- Owner: scene-ui
- Branch: `agent/ui-audit-007-next-presentation-hotspot`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/scene-ui.md` only.
- Objective: while UI-FIX-001..006 wait on QA-002 runtime evidence, inspect only currently unlocked presentation helpers (for example DialogUI/EndingUI) and identify one smallest independent reachability/responsiveness defect that does not touch any held UI file, Gameplay, LocationManager, NPC/content or save semantics.
- Acceptance: report-only; exact file/function/layout evidence; one narrow proposed writable boundary at most; no source edits and no rendered/runtime PASS claims.

## NPC/Content
### NPC-AUDIT-009 — Remaining speaker/premise consistency triage
- Owner: npc-content
- Branch: `agent/npc-audit-009-speaker-premise-triage`
- Status: DONE
- Accepted exact tip: `a16920be7462436c1070e79e833cbadb7bdd0bd1`.
- Review: report-only scope respected. Accepted classification: `e_parents_call` and `e_parent_sick` are safe copy-only; `e_parent_gone` is condition/state-schema dependent; `e_roommate` is product-policy dependent. No runtime/parser PASS inferred.

### NPC-CONTENT-010 — Genericize safe parent-specific callers
- Owner: npc-content
- Branch: `agent/npc-content-010-generic-family-callers`
- Status: READY
- Priority: LOW
- Writable: `data/events.json`, `agent-reports/npc-content.md`.
- Objective: apply only the three safe string-value edits accepted from NPC-AUDIT-009: genericize `e_parents_call.speaker`, genericize `e_parent_sick.speaker`, and neutralize the father-specific phrase in `e_parent_sick` first-option result while preserving the caregiving beat.
- Acceptance: exactly three string-value edits only; no conditions, age/origin eligibility, effects, flags, jobs, counters, IDs, schema or flow changes; leave `e_parent_gone`, `e_roommate` and the four deferred spouse/child-policy events untouched; report exact old/new strings; no unrun parser/Godot claims.

## QA/Build
### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: a frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- All terminal/parser/Godot/headless/rendered/Web-export/browser/screenshot evidence is consolidated here on one exact SHA.
- Minimum package now includes accepted GAME-FIX-009 verifier and repository-reviewed UI-FIX-006 verifier in addition to the previously accepted regression matrix. Any SHA movement invalidates affected evidence.

### QA-011 — Next-wave exact-SHA/Codex package delta
- Owner: qa-build
- Branch: `agent/qa-011-next-wave-codex-package`
- Status: DONE
- Accepted exact tip: `a7410aee34c8382d4d67870c01efe3e242ff883d`.
- Review: report-only scope respected; accepted single-SHA/stale-evidence rules, deterministic Gameplay semantic integration warning, UI evidence coupling, and QA-002 handoff structure. Its captured READY tips are now stale and superseded by this heartbeat's reviewed tips.

### QA-012 — Post-review integration manifest for 009/006/009
- Owner: qa-build
- Branch: `agent/qa-012-post-review-integration-manifest`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: refresh exact tips and deterministic integration/runtime handoff after repository review of GAME-FIX-009, UI-FIX-006 and NPC-AUDIT-009; incorporate the new GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 boundaries; state precisely what source deltas belong in the next frozen candidate and what remains runtime-blocked.
- Acceptance: report-only; no merges, source/workflow edits, parser/Godot/Web/browser execution or inferred PASS; retain the one-frozen-SHA rule and exact stale-evidence stop conditions.

## Deferred product decisions
- `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive policy.
- `e_roommate` / Xiaoyu housing canon: canonical roommate vs separate roommate vs explicit shared-rent state.
- `e_parent_gone`: parent-existence/alive state contract before unconditional parent-death mechanics are changed.
- Relationship-aware NPC dialogue/trust schema and ownership.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; use `BLOCKED` when real execution/dependency context prevents completion.
