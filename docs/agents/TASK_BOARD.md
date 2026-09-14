# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` exact tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- `main` remains untouched by the multi-agent control plane.

## Scheduling rule
At least **60% of active work must create player-visible content or directly unblock player-visible content**. Non-blocking speculative audits remain BACKLOG. Every execution lane has at most one active `READY/IN_PROGRESS` task. A blocked historical/runtime task may coexist with one non-overlapping active task. Real Godot/render/browser/Web/audio-playback evidence stays centralized in QA-002 on one frozen SHA.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012, QA-CONTENT-014,
ART-AUDIT-001, AUDIO-AUDIT-001, DIRECTOR-001,
**GAME-CONTENT-012, NPC-CONTENT-012, ART-PROD-002, AUDIO-CONTENT-002, DIRECTOR-CONTENT-002** are DONE at repository/source level. Runtime/render/playback evidence remains separate where stated below.

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
- Owner: gameplay
- Branch: `agent/game-content-012-daily-economy-hooks`
- Status: **DONE**
- Accepted exact tip: `14ca63ac569680008f9f4b20cb01514672d75caa`.
- Review: scope is limited to the authorized Office/Cafe livelihood surface, `scripts/Game.gd` narrow livelihood sections, verifier and report. Office overtime is available only after ordinary work, once/day, 120 minutes, health −4, mood −8, pay = 60% of current ordinary shift wage. Cafe side gig is once/day, 90 minutes, +55 money, health −2, mood −4. Existing `GameState.flags` persists daily markers; no save schema was added. Terminal ordering remains elapsed-time -> needs settlement -> authoritative terminal evaluation -> ordinary completion feedback.
- Runtime boundary: `tools/verify_livelihood_actions.gd` is prepared but **NOT RUN** by web workers. Godot/day-rollover/save-load/reachability evidence belongs to QA-002.

### GAME-CONTENT-013 — First-day onboarding gate & objective state
- Owner: gameplay
- Branch: `agent/game-content-013-first-day-onboarding-gate`
- Status: **READY**
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Base requirement: start from accepted GAME-CONTENT-012 exact tip `14ca63ac569680008f9f4b20cb01514672d75caa`; do not reimplement its settlement values.
- Writable:
  - `scripts/Game.gd` only for narrow onboarding state/objective/event/quest/encounter suppression and first-night completion;
  - `scripts/systems/CafeActivities.gd` only for onboarding/Day-1 visibility of `side_gig`;
  - `tools/verify_first30_flow.gd`;
  - `agent-reports/gameplay.md`.
- Objective from accepted DIRECTOR-CONTENT-002:
  1. one deterministic Day-1 onboarding state using existing `game_state.flags`/day/visited/daily state, with no new save schema;
  2. first 30 minutes suppress ordinary EventSystem annual/random takeover, encounters/dark takeover and q1–q3 foreground progression/reward noise without deleting those systems;
  3. first-night completion sets `flags["onboarding_complete"] = true` (or an equivalent existing-state implementation only if clearly justified);
  4. expose a single current onboarding objective state for later UI consumption, but do not redesign HUD here;
  5. office overtime remains optional after ordinary work and taken/skipped both rejoin the store objective;
  6. cafe side gig hidden during onboarding/Day 1, available after onboarding/Day 2+;
  7. preserve GAME-FIX-001..009 terminal ordering and GAME-CONTENT-012 values.
- Forbidden: HUD/EventUI/DialogUI redesign, events/quests data edits, NPC copy, LocationManager, new save schema, unrelated Game refactor, `main`, coordination files.
- Prepare `verify_first30_flow.gd`; do not claim Godot PASS without QA-002 execution.

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

### UI-CONTENT-008 — Pack A event-choice readability pass
- Owner: scene-ui
- Branch: `agent/ui-content-008-event-choice-readability`
- Status: **READY**
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Current task branch has no task-specific production/report delta yet; inherited report remains stale.
- Writable: `scripts/ui/EventUI.gd`, `tools/verify_event_choice_readability.gd`, `agent-reports/scene-ui.md` only.
- Objective: keep Pack A 2–3 choice events readable and operable at 1280×720 and 960×540 when title/body/result/choice copy is longer than legacy content. Event content must remain bounded; wrapped choice text must not overlap/disappear; all choices and continue flow remain reachable.
- Preserve EventUI public signals/lifecycle and exactly-once option/continue behavior. Do not touch `DialogUI.gd`, HUD, Game, event data, LocationManager, or coordination files.
- Prepare a narrow static verifier; rendered PASS remains QA-002 exact-SHA work.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: **DONE**
- Accepted exact worker tip: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`.
- Accepted content commit/delta: `fe1625c7a302ac6fc0c902f55145772fa5521580`.
- Review: exactly 20 new `e_cw01_*` ordinary-life events, 4 each for park/cafe/hospital/alley/rooftop, 3 choices each, five remembered-choice chains, more than six natural existing-NPC references, supported existing condition/effect keys only, and deferred family/roommate/Xiaoyu-romance canon untouched.
- **Critical integration rule:** accept the **20-event append delta**, not the worker branch's whole stale `data/events.json` snapshot. The final integration must start from the accepted pre-Pack-A content baseline through NPC-CONTENT-010, preserve every existing accepted event object, then append these 20 objects. Blind whole-file replacement is forbidden.
- Parser/Godot/runtime acceptance remains QA-002/frozen integration work.

### NPC-CONTENT-015 — First-day NPC recognition micro-pass
- Owner: npc-content
- Branch: `agent/npc-content-015-first-day-recognition`
- Status: **READY**
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Writable:
  - `scripts/Data.gd` **only inside `const NPCS` young-dialogue lines for `laozhang` and `chenjie`**;
  - `agent-reports/npc-content.md`.
- Objective from accepted DIRECTOR-CONTENT-002:
  - 老张 first-day young dialogue must clearly communicate “工作上的事以后可以来问我 / 他知道怎么在这里混”；
  - 陈姐 first-day young dialogue must clearly communicate “她知道附近怎么生活 / 这里是补给锚点”；
  - preserve relationship mechanics and all dark/mid/old lines;
  - do not surface relationship threshold numbers;
  - no Xiaoyu romance/housing decision, no new NPC, no events/quest/schedule edits.
- This task intentionally does **not** touch `data/events.json`, avoiding the stale whole-file integration risk described above.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG / deferred behind first-day mainline implementation.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG / after first-day mainline and relationship review.

### NPC-AUDIT-011
- Owner: npc-content
- Status: BACKLOG.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Branch: `agent/qa-content-014-content-pack-acceptance`
- Status: **DONE**
- Latest accepted report tip: `7391aac43a602bb04490e20144a4354a76b45b3a`.
- The post-`de16911e...` delta is report-only. Accepted gate now explicitly records final producer review tips, the Pack A stale-baseline hazard, the deterministic “all baseline events unchanged + exactly 20 appended” rule, livelihood static/runtime checks and the single frozen QA-002 package. No parser/Godot/render/Web/browser PASS is inferred.

### QA-CONTENT-015 — Accepted producer consolidation manifest
- Owner: qa-build
- Branch: `agent/qa-content-015-producer-consolidation`
- Status: **READY**
- Priority: MEDIUM
- Writable: `agent-reports/qa-build.md` only.
- Inputs now accepted by 00:
  - GAME-CONTENT-012 tip `14ca63ac569680008f9f4b20cb01514672d75caa`;
  - NPC-CONTENT-012 worker tip `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`, but integration must consume content delta `fe1625c7...` semantically on top of accepted NPC-CONTENT-010;
  - UI-FIX-007 repository tip `fe2e527616e18868df0900c3b6b8b1f2db9599d4`;
  - ART/AUDIO/DIRECTOR outputs are specifications/source candidates only unless a later integration task ingests assets/source.
- Objective: produce the deterministic exact-input integration manifest, stale-SHA stop rules and minimum local/Codex execution order. Do not merge/cherry-pick production source in the web task and do not claim runtime PASS.
- If UI-CONTENT-008 or GAME-CONTENT-013 moves before freeze, record it as pending rather than silently changing frozen inputs.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review semantic integration SHA plus real Godot 4.7.2/browser/audio execution context.
- CONTENT-WAVE-01 package must eventually include:
  - `verify_dialog_panel_overflow.gd` + rendered 1280×720 / 960×540 for UI-FIX-007;
  - UI-CONTENT-008 verifier/render checks if accepted before freeze;
  - livelihood verifier + overtime/side-gig once/day/day-rollover/save-load/reachability;
  - Pack A deterministic baseline-preservation/count/schema gate + one accepted Pack A event triggered from each target location;
  - `verify_first30_flow.gd` once GAME-CONTENT-013 is accepted;
  - all earlier terminal/UI exact-SHA regressions;
  - art contact/loop checks only after a task explicitly ingests chat assets into repository/Godot;
  - audio source acquisition/license snapshot/trim/mix/playback/Web checks only after the accepted AUDIO-CONTENT-002 manifest is consumed by an authorized local asset task;
  - Web export + real browser smoke/runtime evidence on the same frozen SHA.
- Any candidate SHA movement invalidates affected runtime/render/browser/audio evidence.

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
- Status: **DONE**
- Accepted exact tip: `9fbeb0628eda40f93a72f96150508113e2c8fbcc`.
- Review: repository delta is report-only as authorized; actual chat image-generation candidates for office typing, home study and home cooking were produced. Report records 256×256 target cells, enter/contact/loop/exit needs, home/office contact anchors, alpha/root drift and hand/prop/furniture consistency defects, and exact 02/Codex integration requirements.
- Acceptance boundary: this is a **candidate art pack**, not canonical final protagonist pixels and not a GitHub/Godot integration. Canonical identity match and rendered loop/contact acceptance remain later work.

### ART-PROD-003 — First-day action cleanup candidates: cooking + typing
- Owner: art-animation
- Branch: `agent/art-prod-003-first-day-action-cleanup`
- Status: **READY**
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Writable repository scope: `agent-reports/art-animation.md` only; actual image-generation outputs remain chat deliverables until a later explicit ingestion task.
- Objective: consume ART-PROD-002 instead of starting another audit. Prioritize accepted director order:
  1. home cooking/stirring;
  2. office typing;
  3. study is deferred for this task.
- Produce cleaner transparent actor/contact candidates with a stable root/scale and four readable key poses per action (`enter`, `contact/loop A`, `loop B`, `exit`). Remove/break out baked full furniture; keep only minimal contact references. Lock utensil/pan and hand/keyboard planes across loop poses. Record exact logical 256×256 crop/anchor plan and remaining identity defects.
- Do not claim canonical identity or integration if direct canonical sprite conditioning remains unavailable. No scene/script/gameplay edits.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: **DONE**
- Accepted exact tip: `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.
- Review: authorized delta is only `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md` + Audio report. It supplies home music, office/subway/indoor-rain ambience, 10 high-frequency SFX candidates and an optional subway-arrival layer, with source/creator/license/preparation/loop/hook metadata and explicit NOT DOWNLOADED/NOT INTEGRATED/NOT PLAYBACK-VERIFIED boundaries.
- External spot-check this heartbeat confirmed CC0 on the OpenGameArt music page and multiple Freesound candidates including office, rain-window, dialogue click, footsteps, keyboard, page, cooking, purchase, success and subway-arrival sources. **Every actual download must still re-open the exact source page and capture a license snapshot; inaccessible/cache-missed pages are not exempt.**

### AUDIO-CONTENT-003 — Approved-source acquisition + first playback pack
- Owner: audio-music / Codex-local
- Status: **BLOCKED**
- Blocked by: binary download/edit/listening context and an explicit local asset-ingestion execution package.
- Input: accepted AUDIO-CONTENT-002 tip `67033f8c0bf8323d5600c7bccf47f42a0baa1042`.
- Local package requirements: re-verify CC0 source page at download time, preserve source/license snapshots and upstream filenames, create only approved derived game-ready files under exact future `assets/audio/**` paths, record trims/loops/gain/EQ/conversion, and audition for intelligible speech/real-city announcements/copyrighted background music/clipping. Runtime AudioStreamPlayer/bus integration requires a separate explicit code grant; playback/Web evidence belongs QA-002.
- No separate speculative web-audio task is dispatched while this local blocker remains.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Branch: `agent/director-content-002-first-30m-map`
- Status: **DONE**
- Accepted exact tip: `d9c49ddb326bc5517779a7055119a577e916d1bc`.
- Review: scope-clean design/report delta. Accepted spine is `home 做饭 → subway 通勤 → office 第一班工作 → 老张 → 可选 overtime → store/陈姐 → home 第一晚 → Day 2`; one L1 objective at a time; Pack A/legacy annual/random encounters/q1–q3 foreground noise suppressed during onboarding; overtime optional, cafe side gig Day 2+; no Xiaoyu/family/rent/supernatural canon decision.
- A stale producer-status sentence in the worker report is treated as snapshot text only; the implementation contract itself is accepted and current task board state is authoritative.

### DIRECTOR-CONTENT-003 — Day 2–7 retention loop implementation map
- Owner: game-director
- Branch: `agent/director-content-003-day2-7-retention`
- Status: **READY**
- Priority: MEDIUM
- Player-visible/direct-unblock: YES.
- Writable: `docs/design/DAY_2_7_RETENTION_LOOP.md`, `agent-reports/game-director.md` only.
- Objective: extend the accepted first-day spine into a deterministic but non-railroaded Day 2–7 loop using already accepted systems/content only:
  - when cafe side gig first becomes visible and why;
  - which accepted Pack A events may become eligible on Day 2–7 by location, without forcing all 20;
  - first repeat reasons to revisit 老张/陈姐 and when other NPCs/maps gain purpose;
  - one weekly-scale motivation that does not revive the old 22–60-year objective wall;
  - HUD hierarchy transition from onboarding L1 to a small “本周目标 + 当前行动” pair;
  - exact handoff tasks for 01/02/03 after Day-1 implementation.
- Do not add new gameplay systems, decide Xiaoyu/family/rent canon, or modify production source/data/UI/art/audio.

## Active ratio after this heartbeat
Active web lanes with READY tasks: 01, 02, 03, 04, 05, 07 = 6. Player-visible/direct-unblock lanes: 01, 02, 03, 05, 07 = 5/6 = **83.3%**. Lane 04 is the integration gate. Lane 06 is intentionally blocked on local binary/audio execution. This remains above the CONTENT-WAVE-01 minimum.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Whether V1.0 formally narrows to the first month or keeps long-life mode visible.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime/local blocker; `BACKLOG` = intentionally non-active work the Dispatcher must not dispatch.
