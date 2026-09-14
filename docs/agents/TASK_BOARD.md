# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` exact tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- `main` remains untouched by the multi-agent control plane.

## Scheduling rule
At least **60% of active work must create player-visible content or directly unblock player-visible content**. Non-blocking speculative audits remain BACKLOG. Every execution lane has at most one active `READY/IN_PROGRESS` task. Real Godot/render/browser/Web/audio-playback evidence stays centralized in QA-002 on one frozen SHA.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012,
ART-AUDIT-001, AUDIO-AUDIT-001, DIRECTOR-001 are DONE.

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
- Owner: gameplay
- Branch: `agent/game-content-012-daily-economy-hooks`
- Status: **IN_PROGRESS**
- Priority: HIGH
- Player-visible: YES.
- Latest observed tip: `8e3192744026f7ffcaa11195b099f3170d25de1d`.
- Writable: `scripts/systems/OfficeActivities.gd`, `scripts/systems/CafeActivities.gd`, narrow Office/Cafe livelihood sections of `scripts/Game.gd`, `tools/verify_livelihood_actions.gd`, `agent-reports/gameplay.md`.
- Objective: office overtime + cafe temporary side-gig, once/day, repeatable across days, clear money/time/health/mood tradeoffs, no save-schema change, preserve GAME-FIX-001..009 terminal ordering.
- Current worker report is still stale GAME-001 template, so no acceptance yet.
- Scope warning: current in-progress branch contains `tools/.content_wave_012_marker`, which is not an authorized deliverable. It must be removed before `NEEDS_REVIEW`; the required verifier and current-task report must be present before review.

### GAME-AUDIT-011
- Owner: gameplay
- Status: BACKLOG
- Reason: non-blocking audit during CONTENT-WAVE-01.

## Lane 02 — Scene/UI
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: **BLOCKED — repository accepted; exact-SHA runtime/render evidence outstanding**
- Repository-reviewed exact tip: `fc94583b9e490638ef176a4f08f00c6b2f552e55`.
- Review: authorized three-file scope only: `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Accepted repository contract: only body text scrolls; speaker and continue/end action remain outside; scroll resets on next line and reopen; `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression and exactly-once final emission are preserved.
- Blocked by: actual Godot run of `verify_dialog_panel_overflow.gd` plus rendered 1280×720 and 960×540 evidence on the frozen integration SHA. No runtime/render PASS inferred from source review.
- Lane 02 is intentionally held here; do not start UI-CONTENT-008 until this DialogUI delta is included in the frozen QA candidate.

### UI-CONTENT-008
- Owner: scene-ui
- Status: BACKLOG / NEXT AFTER UI-FIX-007 candidate inclusion.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: READY
- Priority: HIGH
- Player-visible: YES.
- Current branch tip remains `d415ecf165fc6c90d5abf42e5929745d1739acf4`; worker report is still the inherited template.
- Writable: `data/events.json`, `agent-reports/npc-content.md` only.
- Objective: exactly 20 ordinary-life events, 4 each for park/cafe/hospital/alley/rooftop; 2–3 choices each; real downside/cost; at least 5 remembered-choice acknowledgements; at least 6 natural existing-NPC references; supported schema/effects/conditions only.
- Deferred family/roommate/Xiaoyu-romance events remain untouched.

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
- Status: READY
- Priority: MEDIUM
- Current branch tip remains `d415ecf165fc6c90d5abf42e5929745d1739acf4`; worker report is still the inherited template.
- Writable: `agent-reports/qa-build.md` only in web phase.
- Objective: Pack A-specific acceptance manifest for GAME-CONTENT-012 / UI-FIX-007 / NPC-CONTENT-012; counts/IDs/supported keys/deferred-policy safety/livelihood anti-spam/no save-schema change/exact tips/stale-SHA stop rules.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- CONTENT-WAVE-01 package must include:
  - `verify_dialog_panel_overflow.gd` plus rendered 1280×720 / 960×540 evidence for UI-FIX-007;
  - after acceptance, livelihood verifier + both new actions incl. once/day/day-rollover + save/load;
  - after acceptance, at least one Pack A event from each of five locations + JSON/schema/count/diff gates;
  - all earlier terminal/UI exact-SHA regressions;
  - integrated art animation checks only after an explicit binary ingestion/integration task;
  - audio playback/mix/Web unlock checks only after licensed assets and runtime audio integration exist;
  - Web export + real browser smoke/runtime evidence.

### QA-013
- Owner: qa-build
- Status: BACKLOG / superseded for now by QA-CONTENT-014.

## Lane 05 — Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Branch: `agent/art-audit-001-production-gap`
- Status: DONE
- Accepted exact tip: `727c81b7afaf3d46f03a5048fcfda37715bfb11c`.
- Accepted finding: all 9 active maps remain background-heavy B-tier; work/study/cook/commute/NPC talk are the highest-impact first-hour action gaps.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: READY
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Branch created from control-plane tip `eead05e847fade67a5fe69f8c86280fc625ae735`.
- Writable repository scope: `agent-reports/art-animation.md` only in this pass. Image-generation outputs are expected art-lane deliverables but are not treated as integrated assets.
- Objective: produce actual candidate visuals for office typing, home study/reading, and home cooking/stirring, preserving current player identity, 2.5D view, body proportions and fixed foot anchor; target 256×256 RGBA action cells unless documented otherwise.
- Report must record candidate names, frame/layout needs, enter/contact/loop/exit, furniture/prop contact geometry, known consistency defects and exact later repo/integration filenames.
- No scene/script/gameplay edits; no promotional-poster art; no false integration claim.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.
- Review: report-only scope respected. Accepted conclusion: no real BGM/ambience/SFX/Bus/mix/fade layer exists yet; current lifecycle signals provide sufficient hooks. No playback/runtime claim inferred.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: READY
- Priority: HIGH
- Player-visible direct-unblock: YES.
- Branch created from control-plane tip `eead05e847fade67a5fe69f8c86280fc625ae735`.
- Writable: `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`, `agent-reports/audio-music.md`.
- Objective: curate a small legally usable first-hour pack: home/rain musical bed, office ambience, subway ambience/arrival, indoor rain, and at least 8 frequent SFX covering UI/dialog, footsteps, door, keyboard/work, study/page, cooking, purchase and task-complete/warning.
- Every candidate must record source page, creator, license, attribution/modification requirements, intended filename and trim/loop/fade/use point. Prefer CC0/Public Domain or equivalently clear commercial-use licensing; reject unclear/YouTube-ripped/commercial-game sources.
- No binary import/playback claim in this web task. After review, 00 packages a narrow local/Codex acquisition + playback/integration task.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.
- Accepted strategic direction: first hour must have one foreground life objective hierarchy; maps/NPCs need authored reasons; minutes/days/weeks/month should dominate onboarding rather than competing daily/quest/stage/annual goal systems.
- Acceptance does not automatically authorize large mechanics/time-scale/terminal/canon rewrites.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Branch: `agent/director-content-002-first-30m-map`
- Status: READY
- Priority: HIGH
- Player-visible direct-unblock: YES.
- Branch created from control-plane tip `eead05e847fade67a5fe69f8c86280fc625ae735`.
- Writable: `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`, `agent-reports/game-director.md`.
- Objective: translate DIRECTOR-001 into one deterministic 0–30 minute implementation-ready sequence for CONTENT-WAVE-01: exact objectives at 0–1 / 1–5 / 5–15 / 15–30, location reasons, NPC return motivation, livelihood-action timing, Pack A onboarding eligibility/suppression, HUD/tutorial hierarchy and a smallest-task handoff to 01/02/03/05/06.
- No Game/data/UI/art/audio source changes and no silent decision on Xiaoyu/family/rent/supernatural marketing canon.

## Active ratio after this heartbeat
Active non-runtime lanes: 01,03,04,05,06,07 = 6. Player-visible/direct-unblock lanes: 01,03,05,06,07 = **5/6 = 83%**. Lane 02 is repository-complete but intentionally held on the shared frozen-SHA runtime/render gate.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Whether V1.0 formally narrows to the first month or keeps long-life mode visible; DIRECTOR-001 alone does not decide this irreversible scope change.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime blocker; `BACKLOG` = intentionally non-active work the Dispatcher must not dispatch.
