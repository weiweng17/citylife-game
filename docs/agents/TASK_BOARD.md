# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **PAUSED BY USER** as of 2026-09-14.
- READY tasks are preserved for planning/next resume, but local Dispatcher / scheduled automation must not wake workers until the user explicitly resumes development.
- `main` remains untouched by the multi-agent control plane.

## Current product priority — V1.0 experience conversion
User试玩反馈 establishes four P0 experience gaps:
1. Many interactions are still static (`站着不动 + 等待 + 数值结算`) instead of embodied actions/animation.
2. The game lacks a clear life/mainline guide: players do not reliably know why they work/live or what to do next.
3. Multiple maps still function primarily as background images + hotspots rather than mature 2.5D spaces with layering, occlusion, dynamics and lived-in interaction.
4. The project lacks a coherent music/ambience/SFX layer.

05-Art-Animation, 06-Audio-Music and 07-Game-Director are added as first-class worker lanes. Their first tasks are **audit/report only** so 00 can review the plans before authorizing production files.

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
- Review: no new deterministic repository-proven terminal revival/masking bypass. Cafe immediate-reentry remains QA-002 runtime stress only.

### GAME-AUDIT-011 — Cross-midnight daily-boundary audit
- Owner: gameplay
- Branch: `agent/game-audit-011-cross-midnight-daily-boundaries`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/gameplay.md` only.
- Objective: audit travel/work/meal/rest minute advances crossing midnight, `day_changed`, DailyRoutine reset/mark ordering, pending need settlement and save payload state. Identify concrete objective loss/double-count/wrong-day association only.
- Acceptance: report-only; exact ordering and concrete state sequence for any finding; at most one smallest follow-up; no source edits or unrun Godot claims.

## Scene/UI — exact-SHA runtime holds
- UI-FIX-001 — BLOCKED — `07a4d159e073e9f810cf1c3007ba907a49299ae3`.
- UI-FIX-002 — BLOCKED — `b480befaedc3a3b0cbdaca1916e31dbba7283121`.
- UI-FIX-003 — BLOCKED — `51124e758877750d01f8b72429ead0075a73c596`.
- UI-FIX-004 — BLOCKED — `4a2ce2473dd05691fc2e1368b381497a5768d3e6`.
- UI-FIX-005 — BLOCKED — `a0402610cef12455dfc970641e4273c8b246d6d1`.
- UI-FIX-006 — BLOCKED — repository-reviewed exact tip `d328f227b8473297d4b74c058dfd1a7101a68074`; needs exact-SHA Godot verifier + rendered 1280x720 / 960x540 evidence.

### UI-AUDIT-007 — Next unlocked presentation hotspot after ShopUI
- Owner: scene-ui
- Branch: `agent/ui-audit-007-next-presentation-hotspot`
- Status: DONE
- Accepted exact tip: `83f1b0f4003359ceb4da7f263b29916986888f1c`.
- Accepted next isolated repair: DialogUI wrapped-body overflow containment while preserving speaker/action and exact busy/signal lifecycle.

### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: READY
- Priority: MEDIUM
- Writable: `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: give only dialogue body a bounded vertical overflow path; speaker and continue/end action stay fixed/reachable.
- Preserve: `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression, button copy and exactly-once final emission.
- Final PASS requires actual Godot/rendered evidence on exact frozen integration SHA.

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
- Exactly three authorized string substitutions; no condition/effect/flag/ID/schema/flow change.

### NPC-AUDIT-011 — Post-genericization pronoun consistency audit
- Owner: npc-content
- Branch: `agent/npc-audit-011-post-genericization-pronouns`
- Status: READY
- Priority: LOW
- Writable: `agent-reports/npc-content.md` only.
- Objective: inspect safe family-neutral copy near `e_parents_call` / `e_parent_sick` for residual wording conflicts after generic callers.
- Acceptance: report-only; at most one smallest safe follow-up; no data edits/parser/Godot claims.

## QA/Build
### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- Consolidate terminal/parser/Godot/headless/rendered/Web-export/browser/screenshot evidence here. Any candidate SHA movement invalidates affected evidence.

### QA-012 — Post-review integration manifest
- Owner: qa-build
- Branch: `agent/qa-012-post-review-integration-manifest`
- Status: DONE
- Accepted exact tip: `996e2e5146d9aa65a65c81c5e2c8f5e8b8b82cc1`.

### QA-013 — Next-wave candidate / Codex preflight
- Owner: qa-build
- Branch: `agent/qa-013-next-wave-candidate-preflight`
- Status: READY
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Objective: refresh exact reviewed inputs and deterministic integration/QA-002 handoff; incorporate GAME-AUDIT-011, UI-FIX-007, NPC-AUDIT-011 and the new 05-07 audit lanes as planning dependencies without claiming runtime evidence.
- Acceptance: report-only; no merges/source/workflow edits or inferred PASS.

## Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Branch: `agent/art-audit-001-production-gap`
- Status: READY
- Priority: HIGH
- Writable: `agent-reports/art-animation.md` only.
- Read scope: `assets/**`, `scenes/**`, `scripts/world/**`, `scripts/systems/*Activities.gd`, `scripts/ui/**`, map/player/NPC interaction resources.
- Objective: produce `《都市浮生美术与动画缺口审计 v1》` covering all player/NPC action gaps, every static-settlement interaction, map maturity A/B/C, foreground/occlusion/dynamic-scene gaps, prioritized action asset plan and first three map reworks.
- Required deliverables: map maturity table; player action gap table; NPC action gap table; dynamic-scene gap table; first 10 animations; first 3 map reworks; asset-production order; AI-generatable vs Godot/manual-correction classification; first-30-minute impact ranking.
- No production asset/source edits in this task. No image generation may be represented as integrated game work. No runtime/render PASS claims.

## Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: READY
- Priority: HIGH
- Writable: `agent-reports/audio-music.md` only.
- Read scope: full repository audio inventory, relevant scenes/scripts/configuration, current AudioStreamPlayer / bus / volume / transition infrastructure.
- Objective: produce `《都市浮生声音设计与资产需求表 v1》` covering location BGM, ambience, interaction/UI SFX, loop/fade rules, production/source strategy and Godot handoff points.
- Required deliverables for each sound: name, scene/use, BGM/Ambience/SFX, mood, length, loop, BPM if relevant, enter/exit rule, fade, priority, current availability, production/licensing/procedural path, Godot integration point.
- Copyright provenance must be explicit. No unverified commercial/YouTube assets. No playback/integration PASS claims.

## Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: READY
- Priority: P0
- Writable: `agent-reports/game-director.md` only.
- Read scope: gameplay/UI/NPC/content/maps/save/endings and all coordination/iteration/handoff docs needed for product audit.
- Objective: produce `《都市浮生 V1.0 游戏导演方案》` that solves why the player lives/works/continues, and turns the current feature set into a guided life-simulation experience.
- Required deliverables: core fantasy/identity; first 1/5/15/30/60 minute experience; first day/week/month; chapter structure; onboarding/UI guidance; map unlock/purpose; NPC motivation; work/money/health/mood/relationship/skill coupling; systems to hide/delay; maps without narrative purpose; random-noise vs mainline events; low-point/failure feedback; 5–10 minute reward cadence; V1.0 must-do; V1.1 defer; explicit do-not-do list.
- No production source/data/art/audio edits. 07 proposes direction; 00 reviews and decomposes accepted direction to 01-06.

## Deferred product decisions
- `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`: married-household-only vs co-parent-inclusive policy.
- `e_roommate` / Xiaoyu housing canon.
- `e_parent_gone`: parent-existence/alive state contract.
- Relationship-aware NPC dialogue/trust schema and ownership.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; use `BLOCKED` when real execution/dependency context prevents completion. User-level execution pause is recorded separately under Control state and does not erase READY work.
