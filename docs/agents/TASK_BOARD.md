# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` exact tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- `main` remains untouched by the multi-agent control plane.

## Scheduling rule
At least **60% of active work must create player-visible content or directly unblock player-visible content**. Non-blocking speculative audits remain BACKLOG. Every execution lane has at most one active `READY/IN_PROGRESS` task. A blocked historical task may coexist with one non-overlapping active task. Real Godot/render/browser/Web/audio-playback evidence stays centralized in QA-002 on one frozen SHA.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012, QA-CONTENT-014,
ART-AUDIT-001, AUDIO-AUDIT-001, DIRECTOR-001 are DONE.

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
- Owner: gameplay
- Branch: `agent/game-content-012-daily-economy-hooks`
- Status: IN_PROGRESS
- Priority: HIGH
- Player-visible: YES.
- Latest observed exact tip: `2f294fce52c7d2b0acd523b69c4f2642eec2187f` (`GAME-CONTENT-012 add livelihood regression package`).
- Current diff against the CONTENT-WAVE-01 task baseline is limited to the four authorized production/verifier paths: `scripts/Game.gd`, `scripts/systems/OfficeActivities.gd`, `scripts/systems/CafeActivities.gd`, `tools/verify_livelihood_actions.gd`. The earlier unauthorized temporary marker is gone.
- Worker report is still the inherited GAME-001 template, so the current source is **not accepted** and no Godot/runtime PASS is inferred.
- Writable: `scripts/systems/OfficeActivities.gd`, `scripts/systems/CafeActivities.gd`, narrow Office/Cafe livelihood sections of `scripts/Game.gd`, `tools/verify_livelihood_actions.gd`, `agent-reports/gameplay.md`.
- Objective: office overtime + cafe temporary side-gig, once/day, repeatable across days, clear money/time/health/mood tradeoffs, no save-schema change, preserve GAME-FIX-001..009 terminal ordering.
- Next required worker action: freeze current source unless self-review finds a real defect; update `agent-reports/gameplay.md` to `GAME-CONTENT-012 / NEEDS_REVIEW` with exact tip, files changed, static reasoning and explicit QA-002 runtime handoff. Do not create another feature/audit before that handoff.

### GAME-AUDIT-011
- Owner: gameplay
- Status: BACKLOG
- Reason: non-blocking audit during CONTENT-WAVE-01.

## Lane 02 — Scene/UI
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: BLOCKED
- Blocked by: exact-SHA Godot/headless + rendered 1280×720 and 960×540 evidence on the frozen integration candidate.
- Repository-accepted exact tip: `fe2e527616e18868df0900c3b6b8b1f2db9599d4`.
- Repository review: authorized three-file surface only; body-only scroll, fixed speaker/action, next/reopen reset and Game-facing lifecycle are preserved. No runtime/render PASS inferred.

### UI-CONTENT-008 — Pack A event-choice readability pass
- Owner: scene-ui
- Branch: `agent/ui-content-008-event-choice-readability`
- Status: READY
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Activation reason: Pack A source now exists on 03 (`fe1625c7...`) and UI-FIX-007 production source is frozen. This task explicitly excludes `DialogUI.gd`, so it does not invalidate the held dialog evidence package.
- Writable: `scripts/ui/EventUI.gd`, `tools/verify_event_choice_readability.gd`, `agent-reports/scene-ui.md` only.
- Objective: keep Pack A 2–3 choice events readable and operable at 1280×720 and 960×540 when title/body/result/choice copy is longer than legacy content. Event content must remain bounded; wrapped choice text must not overlap/disappear; all choices and continue flow remain reachable.
- Preserve EventUI public signals/lifecycle and exactly-once option/continue behavior. Do not touch `DialogUI.gd`, HUD, Game, event data, LocationManager, or coordination files.
- Prepare a narrow static verifier; rendered PASS remains QA-002 exact-SHA work.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: IN_PROGRESS
- Priority: HIGH
- Player-visible: YES.
- Latest observed exact tip: `fe1625c7a302ac6fc0c902f55145772fa5521580` (`NPC-CONTENT-012 add city event pack A`).
- Diff against task baseline is only `data/events.json` (+720 lines), within authorized production scope. Worker report is still the inherited NPC-001 template, so no content acceptance is recorded yet.
- Writable: `data/events.json`, `agent-reports/npc-content.md` only.
- Objective remains exactly 20 ordinary-life events, 4 each for park/cafe/hospital/alley/rooftop; 2–3 choices each; real downside/cost; at least 5 remembered-choice acknowledgements; at least 6 natural existing-NPC references; supported schema/effects/conditions only; deferred family/roommate/Xiaoyu-romance canon untouched.
- Next required worker action: self-check the current data delta and update `agent-reports/npc-content.md` to `NPC-CONTENT-012 / NEEDS_REVIEW` with exact 20 IDs, 4/4/4/4/4 counts, remembered-flag chains, NPC-reference list, deferred-policy confirmation and explicit statement that parser/Godot/runtime PASS belongs to QA. Do not add more events before handoff unless self-check finds a requirement failure.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG / NEXT AFTER NPC-CONTENT-012 REVIEW.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG / AFTER RELATIONSHIP PACK REVIEW.

### NPC-AUDIT-011
- Owner: npc-content
- Status: BACKLOG.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Branch: `agent/qa-content-014-content-pack-acceptance`
- Status: DONE
- Accepted exact tip: `de16911e877ceb02469ed4ad6b6d8d0291308d72`.
- Review this heartbeat: the post-`8c61bf...` delta is report-only and remains within authorized web scope. The latest report preserves the deterministic Pack A JSON/schema/count/deferred-policy gate, livelihood anti-spam/save compatibility checklist, UI-FIX-007 verifier/render requirements, stale-SHA stop rule and the single frozen QA-002 runtime/Web/browser package.
- The latest report's producer observations are explicitly snapshots and already instruct QA to re-read exact tips before freeze; later producer movement therefore does not invalidate the accepted **gate specification**.
- No parser/Godot/render/Web/browser PASS is inferred.

### QA-CONTENT-015 — Pack A producer acceptance consolidation
- Owner: qa-build
- Status: BLOCKED
- Blocked by: final orchestrator-reviewed GAME-CONTENT-012 and NPC-CONTENT-012 `NEEDS_REVIEW` exact tips.
- Objective after unblock: apply accepted QA-CONTENT-014 gates to exact accepted producer tips, record deterministic integration inputs, then hand one frozen candidate to QA-002. Do not poll or create speculative audit churn while producer handoffs are stale.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- CONTENT-WAVE-01 package must eventually include:
  - `verify_dialog_panel_overflow.gd` plus rendered 1280×720 / 960×540 evidence for UI-FIX-007;
  - UI-CONTENT-008 verifier/render evidence if accepted before freeze;
  - livelihood verifier + both actions incl. once/day/day-rollover + save/load after Gameplay acceptance;
  - at least one accepted Pack A event from each of five locations + JSON/schema/count/diff gates after NPC acceptance;
  - all earlier terminal/UI exact-SHA regressions;
  - integrated art animation checks only after explicit asset-ingestion/integration;
  - audio playback/mix/Web checks only after licensed assets and runtime audio integration;
  - Web export + real browser smoke/runtime evidence.

### QA-013
- Owner: qa-build
- Status: BACKLOG / superseded for now.

## Lane 05 — Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Branch: `agent/art-audit-001-production-gap`
- Status: DONE
- Accepted exact tip: `727c81b7afaf3d46f03a5048fcfda37715bfb11c`.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: READY
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Latest branch tip: `689ba1e5e831c6a210a2afcef81cf91c0ac2570f`; there is no task-specific production delta yet. Worker report is still the inherited ART-AUDIT-001 template.
- Writable repository scope: `agent-reports/art-animation.md` only in this pass. Image-generation outputs are expected art-lane deliverables but are not integrated assets.
- Objective: actual candidate visuals for office typing, home study/reading, and home cooking/stirring; preserve current player identity, 2.5D view, body proportions and fixed foot anchor; target reusable 256×256 RGBA cells unless documented otherwise.
- Report must record frame/layout, enter/contact/loop/exit, prop/furniture contact geometry, consistency defects and exact later integration filenames.
- No scene/script/gameplay edits; no promotional-poster art; no false integration claim.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: IN_PROGRESS
- Priority: HIGH
- Player-visible direct-unblock: YES.
- Direct GitHub retrieval succeeds; the Dispatcher `report fetch failed` warning is not a missing-branch blocker.
- Latest observed exact tip: `aaf872c24fd7ca3cd59699da564463931cee032b` (`audio: curate first-hour CC0 source pack`).
- Branch delta from task base is only the authorized `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`. The manifest contains the requested home music candidate, office/subway/indoor-rain ambience candidates, 10 frequent SFX candidates plus an optional subway-arrival layer, with source/license/preparation/hook fields and explicit NOT DOWNLOADED / NOT INTEGRATED / NOT PLAYBACK-VERIFIED boundaries.
- `agent-reports/audio-music.md` on this branch is still the inherited AUDIO-AUDIT-001 template; therefore AUDIO-CONTENT-002 is **not accepted** despite useful manifest progress.
- Writable: `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`, `agent-reports/audio-music.md`.
- Next required worker action: verify the manifest against the task contract, then update `agent-reports/audio-music.md` to `AUDIO-CONTENT-002 / NEEDS_REVIEW` with exact tip/source count/license summary and narrow later local/Codex acquisition/playback handoff. Do not add binaries or claim playback.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Branch: `agent/director-content-002-first-30m-map`
- Status: READY
- Priority: HIGH
- Player-visible direct-unblock: YES.
- Direct GitHub retrieval succeeds; the Dispatcher `report fetch failed` warning is not a missing-branch blocker.
- Latest branch tip: `689ba1e5e831c6a210a2afcef81cf91c0ac2570f`; no task-specific implementation-map delta exists yet. Worker report is still the inherited DIRECTOR-001 template.
- Writable: `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`, `agent-reports/game-director.md`.
- Objective: one deterministic 0–30 minute implementation-ready sequence: exact objectives at 0–1 / 1–5 / 5–15 / 15–30, location reasons, NPC return motivation, livelihood-action timing, Pack A onboarding eligibility/suppression, HUD/tutorial hierarchy and smallest-task handoff to 01/02/03/05/06.
- No Game/data/UI/art/audio source changes and no silent decision on Xiaoyu/family/rent/supernatural-marketing canon.

## Active ratio after this heartbeat
Active non-runtime lanes: 01,02,03,05,06,07 = 6. Player-visible/direct-unblock lanes: all six = **100%**. Lane 04 has an accepted gate specification and is intentionally blocked until producer handoffs. This remains above the CONTENT-WAVE-01 minimum.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Whether V1.0 formally narrows to the first month or keeps long-life mode visible; DIRECTOR-001 does not by itself authorize an irreversible scope change.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime blocker; `BACKLOG` = intentionally non-active work the Dispatcher must not dispatch.
