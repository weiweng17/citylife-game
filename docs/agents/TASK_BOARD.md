# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` exact tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- `main` remains untouched by the multi-agent control plane.

## Scheduling rule
At least **60% of active work must create player-visible content or directly unblock player-visible content**. Non-blocking speculative audits remain BACKLOG. Every execution lane has at most one active `READY/IN_PROGRESS` task. A blocked historical/runtime task may coexist with one non-overlapping active task. Real Godot/render/browser/Web/audio-playback evidence stays centralized in QA-002 on one frozen SHA.

Machine-readable coordination rule: active task status lines use plain tokens (`Status: READY` / `Status: IN_PROGRESS`) with no Markdown emphasis around the token, so Dispatcher parsing cannot mistake a scheduled task for an idle lane.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012, QA-CONTENT-014,
ART-AUDIT-001, AUDIO-AUDIT-001, DIRECTOR-001,
GAME-CONTENT-012, NPC-CONTENT-012, ART-PROD-002, AUDIO-CONTENT-002, DIRECTOR-CONTENT-002,
**UI-CONTENT-008, NPC-CONTENT-015, QA-CONTENT-015** are DONE at repository/source/report level. Runtime/render/playback evidence remains separate where stated below.

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
- Owner: gameplay
- Branch: `agent/game-content-012-daily-economy-hooks`
- Status: DONE
- Accepted exact tip: `14ca63ac569680008f9f4b20cb01514672d75caa`.
- Runtime boundary: livelihood verifier/reachability/day-rollover/save-load/Godot evidence belongs to QA-002.

### GAME-CONTENT-013 — First-day onboarding gate & objective state
- Owner: gameplay
- Branch: `agent/game-content-013-first-day-onboarding-gate`
- Status: IN_PROGRESS
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Base: accepted GAME-CONTENT-012 exact tip `14ca63ac569680008f9f4b20cb01514672d75caa`.
- Latest observed task tip this heartbeat: `29082502a61793e14d672695d4b5c14b3aeac933`.
- Branch now contains task-specific changes in the authorized `scripts/Game.gd`, `scripts/systems/CafeActivities.gd` and `tools/verify_first30_flow.gd`, but `agent-reports/gameplay.md` still describes the already-accepted GAME-CONTENT-012 predecessor. Therefore GAME-CONTENT-013 is active but **not yet review-submitted**.
- Writable:
  - `scripts/Game.gd` only for narrow onboarding state/objective/event/quest/encounter suppression, meal-before-leave gate and first-night completion;
  - `scripts/systems/CafeActivities.gd` only for onboarding/Day-1 visibility of `side_gig`;
  - `tools/verify_first30_flow.gd`;
  - `agent-reports/gameplay.md`.
- Required Day-1 spine: home meal -> subway -> office -> Old Zhang before ordinary work -> work -> optional overtime -> store -> home first night.
- Suppress ordinary EventSystem/legacy annual takeover, Pack A, encounters/dark takeover and q1-q3 foreground evaluation/notify/reward during onboarding without deleting those systems.
- Successful full-night first sleep sets `flags["onboarding_complete"] = true`; accidental midnight rollover is not completion.
- Expose exactly one current onboarding objective state for later UI consumption.
- Cafe side gig hidden during onboarding/Day 1, available Day 2+.
- Preserve GAME-FIX-001..009 terminal ordering and GAME-CONTENT-012 values.
- No new save schema, HUD redesign, event/quest data edit, NPC copy edit, LocationManager edit, unrelated refactor or `main` edit.
- Prepare verifier only; no Godot PASS without QA-002.

### GAME-CONTENT-014 — Ordinary city-event minute-scale path
- Owner: gameplay
- Status: BACKLOG / NEXT AFTER GAME-CONTENT-013 REVIEW
- Priority: HIGH.
- Blocker solved by this future task: ordinary EventSystem event close currently still reaches `_year_pass()`. Accepted Pack A must remain runtime-suppressed until a validated non-year-advancing ordinary-city-event completion path exists while legacy annual progression remains intact.

### GAME-AUDIT-011
- Owner: gameplay
- Status: BACKLOG
- Reason: non-blocking audit during CONTENT-WAVE-01.

## Lane 02 — Scene/UI
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: BLOCKED
- Repository-accepted exact tip: `fe2e527616e18868df0900c3b6b8b1f2db9599d4`.
- Blocked only by exact-SHA Godot/headless + rendered 1280x720 and 960x540 evidence in QA-002.

### UI-CONTENT-008 — Pack A event-choice readability pass
- Owner: scene-ui
- Branch: `agent/ui-content-008-event-choice-readability`
- Status: DONE
- Accepted exact tip: `f4684143a314e6d9c14e02b6d77cbe7cd665c113`.
- Review: final branch delta is limited to the authorized `scripts/ui/EventUI.gd`, `tools/verify_event_choice_readability.gd` and Scene/UI report. Event title stays outside the bounded scroll region; long body + 2–3 choices share vertical overflow; long choices wrap and left-align while preserving supplied indices and enabled state; result Continue stays outside the scroll region; stale choice layout is removed immediately; scroll resets on choice/result rebuild. Public EventUI signals/methods/busy semantics remain unchanged.
- Runtime boundary: verifier is prepared but **NOT RUN**. Final Godot typography/scrollbar/render acceptance at 1280x720 and 960x540 belongs to QA-002. This does not make Pack A runtime-triggerable before GAME-CONTENT-014.

### Lane 02 scheduling hold
- No new web READY is created this heartbeat.
- Reason: the next first-day HUD/objective presentation task depends on GAME-CONTENT-013 exposing the accepted single-current-objective state. Starting it now would guess an API and create rework. UI-FIX-007 remains separately runtime-blocked.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: DONE
- Accepted worker tip: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`.
- Accepted append delta: `fe1625c7a302ac6fc0c902f55145772fa5521580`.
- Integration rule: preserve cumulative accepted pre-Pack-A content through NPC-CONTENT-010 and append exactly the 20 accepted `e_cw01_*` objects; never whole-file replace from the stale worker snapshot.
- Runtime Pack A remains suppressed until GAME-CONTENT-014 + QA evidence.

### NPC-CONTENT-015 — First-day NPC recognition micro-pass
- Owner: npc-content
- Branch: `agent/npc-content-015-first-day-recognition`
- Status: DONE
- Accepted exact worker tip: `6f529a127601510fdabae13f8928bd7b980d1df6`.
- Accepted production commit: `6941e0a2f66e5eabf9ad6b18563158170e67312a`.
- Review: production commit changes exactly six authorized `scripts/Data.gd` strings: three `chenjie.lines.young` and three `laozhang.lines.young`; all mid/old/dark dialogue, relationship mechanics, schedules, events, quests, Xiaoyu canon and schema remain untouched.
- Chenjie now reads clearly as the nearby life/supply anchor; Old Zhang reads clearly as the practical pre-work office guide.
- No runtime/parser/render PASS is inferred.

### Lane 03 scheduling hold
- No new READY is created this heartbeat.
- Reason: `NPC-CONTENT-013 — Relationship Episode Pack A` is intentionally deferred behind accepted first-day mainline implementation and a corrected DIRECTOR-CONTENT-003 handoff. Creating new narrative production now would outrun 01/07 and risk content churn.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG / deferred behind first-day mainline implementation and DIRECTOR-CONTENT-003 review.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG / after relationship pack review.

### NPC-AUDIT-011
- Owner: npc-content
- Status: BACKLOG.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Branch: `agent/qa-content-014-content-pack-acceptance`
- Status: DONE
- Latest accepted report tip: `7391aac43a602bb04490e20144a4354a76b45b3a`.

### QA-CONTENT-015 — Accepted producer consolidation manifest
- Owner: qa-build
- Branch: `agent/qa-content-015-producer-consolidation`
- Status: DONE
- Accepted exact tip: `470e8abee0f250b7f2b8105613679de73db8db7e`.
- Review: delta against task baseline is report-only, exactly as authorized. The report records accepted GAME-CONTENT-012, UI-FIX-007, NPC-CONTENT-012 semantic-append inputs and DIRECTOR-CONTENT-002 control requirements; excludes moving/unaccepted successor tips; records stale-SHA stop rules and deterministic local/Codex execution order; claims no parser/Godot/render/Web/browser/audio PASS.
- The manifest is a snapshot, not a frozen candidate. NPC-CONTENT-015 and UI-CONTENT-008 were accepted after that snapshot, so final integration inputs must explicitly include their accepted exact tips rather than silently absorbing moving branch heads.

### Lane 04 scheduling hold
- No new web READY is created this heartbeat.
- Reason: current source/design producers 01/05/07 are still active and QA-002 cannot freeze yet. Another report-only audit would be duplicate busywork.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review semantic integration SHA plus real Godot 4.7.2/browser/audio execution context.
- Eventual CONTENT-WAVE-01 package must include:
  - UI-FIX-007 verifier + rendered 1280x720 / 960x540;
  - accepted UI-CONTENT-008 verifier + rendered long-title/body/choice/result checks;
  - livelihood overtime/side-gig once/day/day-rollover/save-load/reachability;
  - Pack A baseline-preservation/count/schema gate;
  - after GAME-CONTENT-014, prove ordinary Pack A completion does not advance a year and trigger one accepted Pack A event per target location;
  - `verify_first30_flow.gd` after GAME-CONTENT-013;
  - earlier terminal/UI regressions;
  - NPC-CONTENT-015 dialogue/parser presence in the frozen semantic candidate;
  - art contact/loop/render only after explicit repository asset ingestion;
  - audio acquisition/provenance/edit/audition before runtime integration, then actual playback/Web evidence on the same frozen SHA;
  - Web export + real browser smoke on the same exact SHA.
- Any candidate SHA movement invalidates affected evidence.

### QA-013
- Owner: qa-build
- Status: BACKLOG / superseded for now.

## Lane 05 — Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Status: DONE
- Accepted exact tip: `727c81b7afaf3d46f03a5048fcfda37715bfb11c`.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: DONE
- Accepted exact tip: `9fbeb0628eda40f93a72f96150508113e2c8fbcc`.
- Acceptance remains candidate-only: not canonical protagonist pixels, not repository/Godot integration, not rendered loop PASS.

### ART-PROD-003 — First-day action cleanup candidates: cooking + typing
- Owner: art-animation
- Branch: `agent/art-prod-003-first-day-action-cleanup`
- Status: READY
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Writable repository scope: `agent-reports/art-animation.md` only; actual generated images remain chat deliverables until a later explicit ingestion task.
- Prioritize home cooking/stirring, then office typing; study deferred.
- Produce cleaner transparent enter/contact-loopA/loopB/exit key poses with stable root/scale, separated fixture reference, locked utensil/pan and hand/keyboard planes, and exact logical 256x256 crop/anchor plan.
- Do not claim canonical identity or integration without direct identity lock and later Godot evidence.
- Current observed branch tip remains accepted ART-PROD-002 baseline `9fbeb0628eda40f93a72f96150508113e2c8fbcc`; no ART-PROD-003 report/new candidate handoff is reviewable yet.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: DONE
- Accepted exact tip: `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.
- Accepted source manifest provides home music candidate, office/subway/indoor-rain ambience, ten frequent SFX candidates and optional subway-arrival layer with provenance/license/preparation metadata; no binaries or playback are claimed.

### AUDIO-CONTENT-003 — Approved-source acquisition + first playback pack
- Owner: audio-music / Codex-local
- Status: BLOCKED
- Input: accepted AUDIO-CONTENT-002 exact tip `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.
- Blocked by real binary download/edit/listening context and explicit local asset-ingestion execution.
- Local requirements: re-open exact source page at download time, preserve dated license/source snapshot and upstream filename/creator, derive only approved game-ready files under authorized `assets/audio/**`, record trims/loops/gain/EQ/conversion, audition for intelligible speech/real-city announcements/copyrighted background audio/clipping/tone mismatch, reject bad sources rather than forcing them into the build.
- Runtime AudioStreamPlayer/bus hook work requires a separate explicit code grant. Actual Godot/Web playback evidence belongs QA-002.
- **No speculative web-audio READY task is created merely to hide this legitimate local blocker.** Dispatcher should treat current BLOCKED work as intentionally occupied, not as a missing-work error.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Branch: `agent/director-content-002-first-30m-map`
- Status: DONE
- Accepted final exact tip: `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.
- Accepted deterministic spine: home meal -> subway -> Old Zhang pre-work contact -> ordinary work -> optional overtime -> store/optional Chenjie -> home first night -> Day 2.

### DIRECTOR-CONTENT-003 — Day 2-7 retention loop implementation map
- Owner: game-director
- Branch: `agent/director-content-003-day2-7-retention`
- Status: IN_PROGRESS
- Priority: MEDIUM
- Player-visible/direct-unblock: YES.
- Latest reviewed worker tip: `dc6bb2f2419cb501ddb18c4a3a0d17a8b1ee55fd`.
- Review disposition: **minimal correction required; not DONE yet**.
- Scope compliance passed: compared from accepted DIRECTOR-CONTENT-002 baseline `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`, task delta is limited to `docs/design/DAY_2_7_RETENTION_LOOP.md` and `agent-reports/game-director.md`.
- Product direction passed: Week-1 motivation derives from existing relation state (`laozhang >= 20 OR chenjie >= 20`), uses existing +4/day anti-spam relation semantics, keeps Pack A behind GAME-CONTENT-014, avoids new save systems/canon decisions, and keeps HUD hierarchy centered on `当前行动 + 本周目标`.
- **Correction blocker:** the final report narrows Pack A Week-1 eligibility after schedule/time continuity review, but the design document still contains broader recommendations that conflict with that final rule. Examples: the design doc presents `park_free_class` / `park_lost_wallet` as ordinary early candidates without requiring Lao Zhou's actual presence, and describes `hospital_kiosk` as a usable hospital event even though its prose physically places Chenjie in hospital while her accepted schedule keeps her at the store. A handoff where the report “overrides” contradictory design text is not a single implementation source of truth.
- Minimal correction, same branch/files only:
  1. synchronize `DAY_2_7_RETENTION_LOOP.md` Pack A sections to the final A/B/C eligibility from the report;
  2. explicitly require schedule-aware presence for Lao-Zhou park events or keep them suppressed;
  3. suppress cafe-interview / hospital-kiosk / hospital-late-queue in Week 1 until their spatial/time continuity is corrected;
  4. retain age gates, cross-day remembered-choice pacing, max-one ordinary event/day recommendation and GAME-CONTENT-014 blocker;
  5. remove/replace any broader examples elsewhere in the document that contradict those rules;
  6. refresh the report and return `NEEDS_REVIEW` with one authoritative Week-1 event eligibility table.
- No production source/data/UI/art/audio edits. No Godot/runtime claim.

## Active ratio after this heartbeat
Active web lanes: 01 IN_PROGRESS, 05 READY, 07 IN_PROGRESS = 3. All three are player-visible/direct-unblock work = **100%**. Lanes 02, 03 and 04 are intentionally held pending upstream producer/director movement; Lane 06 is intentionally BLOCKED / LOCAL. CONTENT-WAVE-01 remains above the 60% minimum without duplicate audits or speculative work.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic-life first or supernatural dark line first.
- Whether V1.0 formally narrows to the first month or keeps long-life mode visible.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime/local blocker; `BACKLOG` = intentionally non-active work the Dispatcher must not dispatch.
