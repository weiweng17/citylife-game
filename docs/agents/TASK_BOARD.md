# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` exact tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- Dispatch mode: **ORCHESTRATOR-GATED**.
- Parallel dispatch: **YES — GAME-CONTENT-013 + ART-INGEST-004 binary asset lane**.
- Selected execution lanes: **01-Gameplay / GAME-CONTENT-013** and **05-Art-Animation / ART-INGEST-004**.
- Parallel rationale: ART-INGEST-004 is restricted to isolated `assets/art/production/**` binary ingestion and does not overlap GAME-CONTENT-013 writable scripts.
- `main` remains untouched by the multi-agent control plane.

## Scheduling rule
- `READY` means queued only. Dispatcher must not wake a READY worker.
- `IN_PROGRESS` means 00 explicitly selected that worker to execute now.
- Default global limit: **one ordinary web task IN_PROGRESS at a time**.
- Multiple IN_PROGRESS web tasks are allowed only when this board explicitly says `Parallel dispatch: YES` and records why the work is independent and worth the extra coordination cost.
- ART-INGEST-004 is an explicitly user-authorized binary-ingestion exception and may run alongside GAME-CONTENT-013 because their writable paths do not overlap.
- `NEEDS_REVIEW` stops worker continuation and wakes 00 for review.
- `BLOCKED` / `BACKLOG` are never execution commands.
- Progress is measured by GitHub branch/report deltas and accepted outputs, not chat-message count.
- Real Godot/render/browser/Web/audio-playback evidence remains centralized in QA-002 on one frozen exact SHA.
- Machine-readable active status lines use plain tokens (`Status: READY` / `Status: IN_PROGRESS`) with no Markdown emphasis around the token.

## Completed summary
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012, QA-CONTENT-014,
ART-AUDIT-001, AUDIO-AUDIT-001, DIRECTOR-001,
GAME-CONTENT-012, NPC-CONTENT-012, ART-PROD-002, AUDIO-CONTENT-002, DIRECTOR-CONTENT-002,
UI-CONTENT-008, NPC-CONTENT-015, QA-CONTENT-015,
**ART-PROD-003, DIRECTOR-CONTENT-003** are DONE at repository/source/report or candidate-handoff level. Runtime/render/playback evidence remains separate where stated below.

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
- Selected by 00 as the current ordinary web execution task because it is the critical dependency for first-day HUD/UI, GAME-CONTENT-014, Week-1 implementation and the next useful QA freeze.
- Base: accepted GAME-CONTENT-012 exact tip `14ca63ac569680008f9f4b20cb01514672d75caa`.
- Latest observed branch tip: `60e8c5e68f0a12ae4d77ab88754ae0ea766da13d`.
- Current branch has task-specific changes in authorized `scripts/Game.gd`, `scripts/systems/CafeActivities.gd`, and `tools/verify_first30_flow.gd`.
- Current `agent-reports/gameplay.md` still describes already-accepted GAME-CONTENT-012, so GAME-CONTENT-013 is **not review-submitted yet**.
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
- Status: BACKLOG
- Priority: HIGH / next critical Gameplay task after GAME-CONTENT-013 review.
- Blocker: ordinary EventSystem completion still reaches legacy `_year_pass()` semantics. Accepted Pack A must remain runtime-suppressed until a validated non-year-advancing ordinary-city-event path exists while legacy annual progression remains intact.

### WEEK1-GAME-001 — Day 2–7 retention state implementation
- Owner: gameplay
- Status: BACKLOG
- Dependency: accepted GAME-CONTENT-013; Pack A portion also depends on GAME-CONTENT-014.
- Source: accepted DIRECTOR-CONTENT-003 exact tip `03da70f7443bef7292b60fd1078681f399dcf178`.

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
- Runtime boundary: verifier exists but is not a rendered PASS; final 1280x720 / 960x540 evidence belongs to QA-002.

### WEEK1-UI-001 — First-day/Week-1 objective presentation
- Owner: scene-ui
- Status: BACKLOG
- Dependency: wait for accepted GAME-CONTENT-013 objective-state API; do not guess the API early.
- Product direction from DIRECTOR-CONTENT-003: after onboarding show `当前行动 + 本周目标`, keep DailyRoutine/quests secondary.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: DONE
- Accepted worker tip: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`.
- Accepted append delta: `fe1625c7a302ac6fc0c902f55145772fa5521580`.
- Integration rule: preserve cumulative accepted pre-Pack-A content through NPC-CONTENT-010 and append exactly the 20 accepted `e_cw01_*` objects; never whole-file replace the stale worker snapshot.
- Runtime Pack A remains suppressed until GAME-CONTENT-014 + QA evidence.

### NPC-CONTENT-015 — First-day NPC recognition micro-pass
- Owner: npc-content
- Branch: `agent/npc-content-015-first-day-recognition`
- Status: DONE
- Accepted exact worker tip: `6f529a127601510fdabae13f8928bd7b980d1df6`.
- Accepted production commit: `6941e0a2f66e5eabf9ad6b18563158170e67312a`.

### WEEK1-CONTENT-001 — Week-1 continuity copy pass
- Owner: npc-content
- Status: BACKLOG
- Dependency: accepted GAME-CONTENT-013. DIRECTOR-CONTENT-003 is now accepted.
- Narrow future scope: q1 closing copy, q2 life-like relation copy, Lao Zhang/Chenjie repeat-contact continuity; no Xiaoyu canon decision and no new event quota.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG
- Reason: defer until first-day and Week-1 continuity implementation are stable.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG

### NPC-AUDIT-011
- Owner: npc-content
- Status: BACKLOG

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Status: DONE
- Latest accepted report tip: `7391aac43a602bb04490e20144a4354a76b45b3a`.

### QA-CONTENT-015 — Accepted producer consolidation manifest
- Owner: qa-build
- Status: DONE
- Accepted exact tip: `470e8abee0f250b7f2b8105613679de73db8db7e`.
- Snapshot only, not a frozen candidate. Later accepted UI/NPC/Art/Director inputs must be explicitly added before freeze.

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
  - after GAME-CONTENT-014, prove ordinary Pack A completion does not advance a year and exercise only continuity-safe event eligibility;
  - `verify_first30_flow.gd` after GAME-CONTENT-013;
  - earlier terminal/UI regressions;
  - NPC-CONTENT-015 dialogue/parser presence;
  - art contact/loop/render only after explicit repository asset ingestion;
  - audio acquisition/provenance/edit/audition before runtime integration, then actual playback/Web evidence on the same frozen SHA;
  - Web export + real browser smoke on the same exact SHA.
- Any candidate SHA movement invalidates affected evidence.

### QA-013
- Owner: qa-build
- Status: BACKLOG

## Lane 05 — Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Status: DONE
- Accepted exact tip: `727c81b7afaf3d46f03a5048fcfda37715bfb11c`.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Status: DONE
- Accepted exact tip: `9fbeb0628eda40f93a72f96150508113e2c8fbcc`.

### ART-PROD-003 — First-day action cleanup candidates: cooking + typing
- Owner: art-animation
- Branch: `agent/art-prod-003-first-day-action-cleanup`
- Status: DONE
- Accepted exact tip: `31d46675afc3b65f9af535995ca474e3e9262211`.
- Review: repository delta is report-only as authorized. The 05 chat/workspace produced deterministic exact-256 cooking + typing candidate handoff packages with enter/contact/loopA/loopB/exit poses, fixture references, common scale/root plans and hashes.
- Acceptance boundary: candidate handoff only. Canonical protagonist identity, actor/fixture separation, repository asset ingestion, SpriteFrames/Godot integration and rendered loop/contact acceptance are **not** claimed.

### ART-INGEST-004 — Today’s generated production-art ingestion
- Owner: art-animation / Codex-local; later Scene/UI integration requires a separate grant
- Branch: `agent/art-ingest-004-production-assets`
- Status: IN_PROGRESS
- Priority: HIGH / USER-AUTHORIZED.
- User authorization date: 2026-09-15.
- Mission: ingest and organize today’s generated `《都市浮生》` art assets from the shared 05 chat/workspace/library into repository production paths, preserving usable source sheets and normalized game-ready exports where available.
- Writable — exact grant only:
  - `assets/art/production/player/actions/**`
  - `assets/art/production/npc/**`
  - `assets/art/production/foreground/**`
  - `assets/art/production/fx/**`
  - `agent-reports/art-animation.md`
- Required ingestion behavior:
  - player action/sprite/pose sheets -> `player/actions/**`;
  - NPC-specific character/action sheets -> `npc/**`;
  - occlusion, cutout and foreground layers -> `foreground/**`;
  - VFX/weather/interaction feedback frames -> `fx/**`;
  - keep deterministic filenames; replace generic `image-gen-*` names with descriptive production names during ingestion;
  - record an asset manifest in the authorized production tree or agent report with source filename, destination path, intended use, dimensions/hash when available, and whether it is source-only or integration-ready;
  - do not silently discard today’s generated candidates: if an asset is not yet integration-ready, store it as a clearly named source/candidate under the appropriate authorized subtree rather than losing it;
  - no edit to `scenes/**`, `scripts/**`, `data/**`, `project.godot`, UI integration or `main` under this task.
- Parallel safety: this task is asset-only and may run simultaneously with GAME-CONTENT-013.
- Acceptance boundary: repository ingestion + organization + manifest only. Godot SpriteFrames hookup, scene composition, runtime loop/contact calibration and rendered acceptance remain separate Scene/UI + QA work.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Status: DONE
- Accepted exact tip: `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.

### AUDIO-CONTENT-003 — Approved-source acquisition + first playback pack
- Owner: audio-music / Codex-local
- Status: BLOCKED
- Input: accepted AUDIO-CONTENT-002 exact tip `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.
- Blocked by real binary download/edit/listening context and explicit local asset-ingestion execution.
- Local requirements: re-open exact source page at download time, preserve dated license/source snapshot and upstream filename/creator, derive only approved game-ready files under authorized `assets/audio/**`, record trims/loops/gain/EQ/conversion, audition for intelligible speech/real-city announcements/copyrighted background audio/clipping/tone mismatch, reject bad sources rather than forcing them into the build.
- Runtime AudioStreamPlayer/bus hook work requires a separate explicit code grant. Actual Godot/Web playback evidence belongs QA-002.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Status: DONE
- Accepted final exact tip: `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.

### DIRECTOR-CONTENT-003 — Day 2–7 retention loop implementation map
- Owner: game-director
- Branch: `agent/director-content-003-day2-7-retention`
- Status: DONE
- Accepted exact tip: `03da70f7443bef7292b60fd1078681f399dcf178`.
- Review: correction is satisfied. `DAY_2_7_RETENTION_LOOP.md` and report now agree on one authoritative Week-1 Pack-A A/B/C eligibility contract.
- Accepted continuity rules:
  - before GAME-CONTENT-014, Pack A Week-1 eligibility remains 0/20;
  - cafe charger/gossip are default post-014 candidates;
  - Lao-Zhou physical park events require actual schedule/weather-aware presence or stay suppressed;
  - remembered-choice follow-ups require later-day pacing;
  - cafe-interview, hospital-kiosk and hospital-late-queue remain Week-1 suppressed until spatial/time continuity is corrected;
  - alley/rooftop stay under existing story locks;
  - recommended density remains at most one ordinary Pack-A spotlight per in-game day;
  - no new WeekSystem/save schema/canon decision.
- Day 2–7 product contract: `当前行动 + 本周目标`, Week-1 motivation from existing work/relation/place state, non-failing Day-7 summary, q1 resumes Day 2 as secondary progress.
- No production-source/runtime PASS is inferred.

### Director scheduling hold
- No new Director web task is queued now. Product direction is sufficiently specified; implementation should proceed through 01/02/03 rather than more design documents.

## Current execution gate
- Parallel dispatch: **YES**.
- Ordinary web `IN_PROGRESS` count: **1** (`GAME-CONTENT-013`).
- Parallel binary-ingest `IN_PROGRESS` count: **1** (`ART-INGEST-004`).
- Current selected tasks: **GAME-CONTENT-013 / 01-Gameplay** + **ART-INGEST-004 / 05-Art-Animation**.
- ART-INGEST-004 is limited to the four authorized production-art directory trees and may not expand into scenes/scripts.
- Queued/held work stays READY/BACKLOG/BLOCKED and will not wake workers until 00 explicitly promotes the next task.
- Player-visible/direct-unblock share of active execution: **100%**.
