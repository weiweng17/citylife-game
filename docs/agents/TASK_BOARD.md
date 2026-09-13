# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008,
UI-AUDIT-004..006,
NPC-CONTENT-002..008,
QA-003..010 are DONE.

### GAME-AUDIT-008 review
- Accepted at `54edcdd2b3dbaf98ce1511d4acd7a9657c920903`.
- Report-only scope was respected.
- Accepted findings: quest rewards can mutate before terminal observation; persistent backpack use can allow post-settlement healing before terminal observation.

## Gameplay — next task
### GAME-FIX-009 — Pre-terminal mutation ordering guard
- Owner: gameplay
- Branch: `agent/game-fix-009-terminal-mutation-order`
- Status: READY
- Priority: HIGH
- Writable: `scripts/Game.gd`, `tools/verify_terminal_mutation_order.gd`, `agent-reports/gameplay.md`.
- Objective: use the existing `_evaluate_terminal_state()` before reward-bearing quest mutation on settled frames; synchronously settle/evaluate shop-use elapsed time before another item can revive a terminal state; reject further shop-use mutation after `game_over`.
- Preserve: existing thresholds, item effects/time costs, quest rewards, save schema, GAME-FIX-001..007 semantics.
- Forbidden: new death thresholds/consumers, UI/LocationManager/NPC edits, balance changes, main, coordination files.
- Runtime evidence belongs to QA-002/Codex, not the web worker.

## Scene/UI — held work
- UI-FIX-001 — NEEDS_REVIEW — requires exact-SHA Godot rendered evidence.
- UI-FIX-002 — NEEDS_REVIEW — requires exact-SHA Godot rendered evidence.
- UI-FIX-003 — NEEDS_REVIEW — requires exact-SHA Godot rendered evidence.
- UI-FIX-004 — NEEDS_REVIEW — requires verifier + rendered 1280x720 and 960x540 evidence.
- UI-FIX-005 — NEEDS_REVIEW — repository scope accepted; requires exact-SHA verifier + rendered 1280x720 and 960x540 evidence.

### UI-AUDIT-006 review
- Accepted at `9fac5a93af60cbeb00ef390bc5b3d877d319b619`.
- Report-only scope was respected.
- Accepted next repair: bounded vertical ShopUI list region.

## Scene/UI — next task
### UI-FIX-006 — Shop list vertical overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-006-shop-list-overflow`
- Status: READY
- Priority: MEDIUM
- Writable: `scripts/ui/ShopUI.gd`, `tools/verify_shop_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: only the item-list region scrolls; title/status/footer/close remain fixed/reachable at 1280x720 and 960x540.
- Preserve all ShopUI public signals/methods and inventory/gameplay semantics.
- Forbidden: `Game.gd`, `Inventory.gd`, item data/effects/prices/order, gameplay settlement, UI-FIX-001..005 files, sub-660px horizontal redesign, main, coordination files.
- Final PASS requires real Godot evidence on the exact integration SHA.

## NPC/Content
### NPC-CONTENT-008 review
- Accepted at `a787d4ab237af9db2d85eac47b9c9db504786951`.
- Diff is exactly two authorized relationship-neutral string substitutions in `data/events.json` plus report; no mechanics/schema changes.
- Parser/runtime PASS is not inferred.

### NPC-AUDIT-009 — Remaining speaker/premise consistency triage
- Owner: npc-content
- Branch: `agent/npc-audit-009-speaker-premise-triage`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/npc-content.md` only.
- Objective: inspect remaining non-family-policy speaker/premise assumptions, including `e_parents_call`, `e_parent_sick`, `e_parent_gone`, `e_roommate`; classify each as safe copy-only, condition/schema-dependent, or product-policy-dependent.
- Acceptance: report-only, exact IDs/evidence, at most one smallest safe follow-up; no source/data edits and no runtime/parser claims.

## QA/Build
### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: real Godot 4.7.2/browser context and a frozen post-review integration SHA.
- All Godot, terminal, parser, Web export, browser, screenshot and rendered validation is consolidated here on one exact SHA.
- Minimum package: SHA/worktree capture; JSON parse; all accepted Gameplay narrow regressions; all accepted UI task verifiers; shared headless gate (`verify_locations`, `verify_navigation`, `verify_day_cycle`, `verify_day_flow`, `verify_npc`, `verify_quests`); rendered UI acceptance; Web export/browser evidence.
- Any SHA movement invalidates affected evidence.

### QA-010 review
- Accepted at `60bba20cbb9b159e583079a87cf59b1d61b36054`.
- Report-only scope respected; single-SHA and stale-evidence rules remain authoritative.

### QA-011 — Next-wave exact-SHA/Codex package delta
- Owner: qa-build
- Branch: `agent/qa-011-next-wave-codex-package`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: refresh exact tips, conflict hazards, deterministic integration order and the minimal QA-002 handoff after this heartbeat, including GAME-FIX-009, UI-FIX-006 and NPC-AUDIT-009 boundaries.
- No merges, code/workflow edits, parser/Godot/Web/browser execution or inferred PASS.

## Deferred product decisions
- `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive policy.
- Relationship-aware NPC dialogue/trust schema and ownership.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; use `BLOCKED` for real execution/dependency blockers.
