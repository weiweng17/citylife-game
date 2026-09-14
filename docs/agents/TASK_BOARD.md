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
- Writable: `scripts/systems/OfficeActivities.gd`, `scripts/systems/CafeActivities.gd`, narrow Office/Cafe livelihood sections of `scripts/Game.gd`, `tools/verify_livelihood_actions.gd`, `agent-reports/gameplay.md`.
- Objective: office overtime + cafe temporary side-gig, once/day, repeatable across days, clear money/time/health/mood tradeoffs, no save-schema change, preserve GAME-FIX-001..009 terminal ordering.
- Current branch diff is now limited to the four authorized production/verifier paths; the earlier unauthorized marker is no longer present.
- Worker report is still the inherited GAME-001 template, therefore the current source tip is **not accepted yet**. Continue the same task and update `agent-reports/gameplay.md` to GAME-CONTENT-012 / `NEEDS_REVIEW` when complete.
- No Godot/runtime PASS may be claimed by this web lane.

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
- Repository review: exact six-commit delta from the CONTENT-WAVE-01 baseline changes only `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, and `agent-reports/scene-ui.md`, matching authorized scope.
- Accepted source contract: only body text scrolls; speaker and continue/end action stay outside; scroll resets on next line and reopen; `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression and exactly-once final emission remain intact.
- No runtime/render PASS inferred.

### UI-CONTENT-008 — Content readability pass
- Owner: scene-ui
- Status: BACKLOG / INTENTIONALLY HELD
- Reason: do not create speculative UI work before actual Pack A copy / Director 0–30 minute implementation map exists. Lane 02 is intentionally idle while UI-FIX-007 waits for the shared QA-002 candidate.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: READY
- Priority: HIGH
- Player-visible: YES.
- Current exact tip remains the task baseline `d415ecf165fc6c90d5abf42e5929745d1739acf4`; report is still the inherited NPC-001 template.
- Writable: `data/events.json`, `agent-reports/npc-content.md` only.
- Objective: exactly 20 ordinary-life events, 4 each for park/cafe/hospital/alley/rooftop; 2–3 choices each; at least one real downside/cost; at least 5 remembered-choice acknowledgements; at least 6 natural existing-NPC references; supported schema/effects/conditions only.
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
- Status: DONE
- Accepted exact tip: `8c61bf5549eb7017fb9a9b5f8dcf52eddd851c5a`.
- Review: one report-only commit changing `agent-reports/qa-build.md` only, exactly within authorized web scope.
- Accepted deliverable: deterministic Pack A JSON/schema/count/deferred-policy gate, livelihood anti-spam/save compatibility checklist, UI-FIX-007 verifier/render requirements, one-frozen-SHA stale-evidence rule, and QA-002 runtime/Web/browser package.
- This acceptance is a **gate specification**, not producer/runtime acceptance. The report explicitly claims no parser/Godot/render/Web/browser PASS.

### QA-CONTENT-015 — Pack A producer acceptance consolidation
- Owner: qa-build
- Status: BLOCKED
- Blocked by: final orchestrator-reviewed GAME-CONTENT-012 and NPC-CONTENT-012 `NEEDS_REVIEW` exact tips.
- Objective after unblock: apply the accepted QA-CONTENT-014 repository gate to the exact accepted producer tips, record deterministic integration inputs, then hand one frozen candidate to QA-002. Do not poll or create speculative audit churn while producer branches are still moving.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- CONTENT-WAVE-01 package must eventually include:
  - `verify_dialog_panel_overflow.gd` plus rendered 1280×720 / 960×540 evidence for UI-FIX-007;
  - livelihood verifier + both actions incl. once/day/day-rollover + save/load after Gameplay acceptance;
  - at least one accepted Pack A event from each of five locations + JSON/schema/count/diff gates after NPC acceptance;
  - all earlier terminal/UI exact-SHA regressions;
  - integrated art animation checks only after an explicit asset-ingestion/integration task;
  - audio playback/mix/Web checks only after licensed assets and runtime audio integration exist;
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
- Accepted finding: all 9 active maps remain background-heavy B-tier; work/study/cook/commute/NPC talk are the highest-impact first-hour action gaps.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: READY
- Priority: HIGH
- Player-visible/direct-unblock: YES.
- Current branch tip is still its creation baseline `eead05e847fade67a5fe69f8c86280fc625ae735`; current report is inherited ART-AUDIT-001 template, so work has not been submitted yet.
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
- Status: READY
- Priority: HIGH
- Player-visible direct-unblock: YES.
- Direct GitHub retrieval during this heartbeat succeeds; Dispatcher `report fetch failed` is therefore treated as a transient local fetch warning, not a missing branch/report blocker.
- Current exact branch tip is still the creation baseline `eead05e847fade67a5fe69f8c86280fc625ae735`; report is inherited AUDIO-AUDIT-001 template and no current-task worker delta exists yet.
- Writable: `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`, `agent-reports/audio-music.md`.
- Objective: curate a legally usable first-hour pack: home/rain musical bed, office ambience, subway ambience/arrival, indoor rain, and at least 8 frequent SFX covering UI/dialog, footsteps, door, keyboard/work, study/page, cooking, purchase and task-complete/warning.
- Record source page, creator, license, attribution/modification requirements, intended filename and trim/loop/fade/use point. Reject unclear/YouTube-ripped/commercial-game sources.
- No binary import/playback claim in this web task.

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
- Direct GitHub retrieval during this heartbeat succeeds; Dispatcher `report fetch failed` is therefore treated as a transient local fetch warning, not a missing branch/report blocker.
- Current exact branch tip is still the creation baseline `eead05e847fade67a5fe69f8c86280fc625ae735`; report is inherited DIRECTOR-001 template and no current-task worker delta exists yet.
- Writable: `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`, `agent-reports/game-director.md`.
- Objective: one deterministic 0–30 minute implementation-ready sequence: exact objectives at 0–1 / 1–5 / 5–15 / 15–30, location reasons, NPC return motivation, livelihood-action timing, Pack A onboarding eligibility/suppression, HUD/tutorial hierarchy and smallest-task handoff to 01/02/03/05/06.
- No Game/data/UI/art/audio source changes and no silent decision on Xiaoyu/family/rent/supernatural-marketing canon.

## Active ratio after this heartbeat
Active non-runtime producer lanes: 01,03,05,06,07 = 5. All five are player-visible/direct-unblock = **100%**. Lane 02 is intentionally blocked on the shared exact-SHA render gate; lane 04 has finished the gate spec and is intentionally blocked until producer acceptance. This remains above the CONTENT-WAVE-01 minimum.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Whether V1.0 formally narrows to the first month or keeps long-life mode visible; DIRECTOR-001 does not by itself authorize an irreversible scope change.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime blocker; `BACKLOG` = intentionally non-active work the Dispatcher must not dispatch.
