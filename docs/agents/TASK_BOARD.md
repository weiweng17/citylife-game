# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` at exact planning tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- User pause is lifted by the explicit 2026-09-14 instruction to switch to CONTENT-WAVE-01 and dispatch the first content batch.
- `main` remains untouched by the multi-agent control plane.

## CONTENT-WAVE-01 scheduling rule
At least **60% of active work must produce player-visible content or directly unblock player-visible content**.

Current active split:
- 01 Gameplay — player-visible livelihood actions.
- 02 Scene/UI — dialogue readability infrastructure required by longer content.
- 03 NPC/Content — 20-event City Event Pack A.
- 04 QA/Build — content acceptance/integration gate.

Repository-only speculative audits are BACKLOG unless they block integration or a known HIGH/CRITICAL defect. Do not create another audit chain before the first playable Pack A slice exists.

## CONTENT-WAVE-01 player-visible exit target
- 20 new ordinary-life events across park / cafe / hospital / alley / rooftop: 4 each.
- 8 relationship-stage NPC episodes across 陈姐 / 老张 / 小雨 / 阿哲: 2 each, after Event Pack A.
- Extend serial quest chain from q1–q3 to q1–q8 after the event/relationship slice.
- At least 2 new repeatable livelihood actions with meaningful money/time/health/mood tradeoffs.
- First-pass visible economic pressure without silently deciding unresolved family/romance canon.
- No unresolved spouse/child/roommate/Xiaoyu romance canon is decided in this wave.

## Completed
ORCH-001, GAME-001, UI-001, NPC-001, QA-001,
GAME-FIX-001..007, GAME-AUDIT-008, GAME-FIX-009, GAME-AUDIT-010,
UI-AUDIT-004..007,
NPC-CONTENT-002..008, NPC-AUDIT-009, NPC-CONTENT-010,
QA-003..012,
ART-AUDIT-001 are DONE.

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
- Owner: gameplay
- Branch: `agent/game-content-012-daily-economy-hooks`
- Status: READY
- Priority: HIGH
- Player-visible: YES.
- Writable:
  - `scripts/systems/OfficeActivities.gd`
  - `scripts/systems/CafeActivities.gd`
  - `scripts/Game.gd` **only for the narrow livelihood action handlers/context feeds described below**
  - `tools/verify_livelihood_actions.gd`
  - `agent-reports/gameplay.md`
- Explicit high-conflict grant: `scripts/Game.gd` may be edited only around Office/Cafe activity context/handlers and the new livelihood settlement helpers. Do not refactor unrelated Game code.
- Objective: add two normal-play livelihood choices using existing activity architecture:
  1. **Office overtime** — visible at the office after ordinary work has been completed that day; once per in-game day; meaningful extra pay; about 2 hours; clear health/mood cost.
  2. **Cafe temporary side gig** — visible at the existing cafe; once per in-game day; lower pay than an ordinary work shift; meaningful time + health/mood cost.
- Recommended first-pass balance (may only be adjusted narrowly with report justification): overtime pay scales from current wage at roughly 50–70% of a normal shift, 120 minutes, health −4, mood −8; cafe side gig about 45–60 money, 90–120 minutes, health −2/−3, mood −3/−4.
- Daily anti-spam should reuse existing persisted generic state/flags or another already-saved mechanism; **no new save schema**.
- Acceptance:
  - both actions are visible/reachable without debug jumps;
  - labels/tooltips state time and major tradeoff;
  - both are repeatable across days but not spammed infinitely in one day;
  - each trades money + time + at least one survival/emotional stat;
  - cafe gig pays less than ordinary work;
  - no opaque random success chance;
  - preserve GAME-FIX-001..009 terminal/death ordering and current save compatibility;
  - prepare `verify_livelihood_actions.gd`; do not claim Godot PASS without real QA-002 execution.
- Forbidden: unrelated `Game.gd`, quest data, event data, NPC relationships, UI redesign, LocationManager, `main`, coordination files.

### GAME-AUDIT-011 — Cross-midnight daily-boundary audit
- Owner: gameplay
- Branch: `agent/game-audit-011-cross-midnight-daily-boundaries`
- Status: BACKLOG
- Reason: non-blocking repository audit; CONTENT-WAVE-01 planning explicitly deprioritizes it unless a concrete release blocker appears.
- Preserve the cross-midnight scenario as a QA stress case; do not dispatch during Pack A production.

## Lane 02 — Scene/UI
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: READY
- Priority: HIGH for CONTENT-WAVE-01 support.
- Player-visible: YES / directly unblocks longer content.
- Writable: `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: keep the bottom dialog bounded while only the wrapped body scrolls/contains overflow; speaker and `继续` / `结束` stay outside and reachable at 1280×720 and 960×540.
- Preserve: `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression, button copy, exactly-once final emission and Game-facing busy semantics.
- Required repository behavior: long-line scroll path; scroll reset on next line and reopen; normal text still reads naturally; no gameplay/content changes.
- Final rendered PASS remains QA-002 exact-SHA work.

### UI-CONTENT-008 — Content readability pass
- Owner: scene-ui
- Status: BACKLOG / NEXT AFTER UI-FIX-007 REVIEW
- Player-visible: YES.
- Objective after UI-FIX-007: verify long event/dialogue copy, quest objectives/completion feedback and visible choice costs remain scannable at 1280×720 and 960×540 using existing UI vocabulary. Keep intentionally small if UI-FIX-007 already solves most of the problem.
- Do not dispatch simultaneously with UI-FIX-007.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: READY
- Priority: HIGH
- Player-visible: YES.
- Writable: `data/events.json`, `agent-reports/npc-content.md` only.
- Objective: add exactly **20 ordinary-life events**, using the existing supported event schema:
  - park: 4
  - cafe: 4
  - hospital: 4
  - alley: 4
  - rooftop: 4
- Prefer a recognizable ID prefix such as `e_cw01_...` so QA can count the wave deterministically; all IDs must remain unique.
- Content quality rules:
  - every event has 2–3 usable choices;
  - at least one choice per event has a real downside/cost;
  - avoid pseudo-decisions where every option is merely a positive mood reward;
  - choices should trade at least two among money / health / mood / skill / network / flags where supported;
  - at least 5 events create a remembered choice through the existing flag mechanism and a later Pack A event acknowledges it;
  - at least 6 events naturally reference existing NPCs;
  - ordinary city life is primary; supernatural/dark-line content stays optional/secondary;
  - no new unsupported effect/condition keys and no script/schema edits.
- Suggested subjects from the accepted wave plan: free exercise class, lost wallet, rain-shelter aunties, recruiter call; interview prep, charger request, coworker gossip, unpaid trial work; physical report, kiosk help, generic vs branded medicine, late-night queue; second-hand furniture, landlord repair dispute, rain-night stall, delivery rider shelter; bad review call, drying bedding, distant fireworks, after-hours work message.
- Explicitly untouched: `e_parent_gone`, `e_roommate`, `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`, Xiaoyu romance/housing canon.
- Validation claim boundary: report exact event IDs/counts and data-only diff; parser/Godot/runtime PASS belongs to QA.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG / NEXT AFTER NPC-CONTENT-012 REVIEW
- Target: 8 relationship-stage episodes, 2 each for 陈姐 / 老张 / 小雨 / 阿哲; one 认识→熟络 and one 熟络→朋友 episode each, with at least one consequence beyond relation points.
- Xiaoyu remains relationship-neutral; no romance/housing canon.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG / AFTER RELATIONSHIP PACK REVIEW
- Target: extend `data/quests.json` from q1–q3 to q1–q8 using only already supported step types unless Gameplay first adds a validated new hook.
- No deadlines/failure cycles/missable dead ends; rewards exactly once.

### NPC-AUDIT-011 — Post-genericization pronoun consistency audit
- Owner: npc-content
- Branch: `agent/npc-audit-011-post-genericization-pronouns`
- Status: BACKLOG
- Reason: non-blocking copy audit; explicitly deprioritized for CONTENT-WAVE-01 Pack A.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Branch: `agent/qa-content-014-content-pack-acceptance`
- Status: READY
- Priority: MEDIUM
- Player-visible support: integration gate, not an audit chain.
- Writable: `agent-reports/qa-build.md` only for the web-agent phase. Any executable verifier addition requires a later explicit 00 grant.
- Objective: prepare and maintain the Pack A acceptance manifest, then inspect current exact tips as GAME-CONTENT-012 / UI-FIX-007 / NPC-CONTENT-012 move.
- Repository gate:
  - JSON shape/parser command specified and later executed only in real QA context;
  - exactly 20 new Pack A events and 4 per target location;
  - event IDs unique; every event has usable options; condition/effect keys are already supported;
  - at least 5 remembered-choice acknowledgements and at least 6 natural existing-NPC references are traceable;
  - no accidental edits to deferred-policy events;
  - livelihood actions have visible cost/reward, anti-spam/day behavior and no save-schema change;
  - capture exact branch tips and stop on stale SHA.
- Runtime gate on one frozen QA-002 candidate:
  - trigger at least one new event from each of five locations;
  - complete both new livelihood actions at least once, including anti-spam/day rollover behavior;
  - after later packs, progress at least two q4–q8 steps and trigger one relationship-stage episode;
  - save/load during new content slice;
  - preserve exact-SHA Web/browser validation.
- If source branches have not moved yet, prepare the gate and remain waiting; do not invent another speculative audit task.

### QA-013 — Next-wave candidate / Codex preflight
- Owner: qa-build
- Branch: `agent/qa-013-next-wave-candidate-preflight`
- Status: BACKLOG / SUPERSEDED FOR NOW
- Reason: CONTENT-WAVE-01 has a more specific QA-CONTENT-014 gate. Reuse useful frozen-SHA rules; do not spend the wave producing another generic preflight report.

### QA-002 — Single frozen Codex/Local runtime package
- Owner: qa-build (Codex/local)
- Branch: `codex/qa-002-runtime-acceptance`
- Status: BLOCKED
- Blocked by: one frozen post-review integration SHA plus real Godot 4.7.2/browser execution context.
- Remains the single final runtime/render/Web evidence package; any candidate SHA movement invalidates affected evidence.

## Lane 05 — Art / Animation
### ART-AUDIT-001 — V1.0 visual-production & animation gap audit
- Owner: art-animation
- Branch: `agent/art-audit-001-production-gap`
- Status: DONE
- Accepted exact tip: `727c81b7afaf3d46f03a5048fcfda37715bfb11c`.
- Review: report-only scope respected. Accepted conclusion: active game has 9 structurally playable but still background-heavy B-tier maps, no fully mature A-tier map, and most non-sleep activities remain standing-sprite/timer/number settlements. The audit identifies work/study/cook/commute/NPC talk and office/subway/home as the highest-impact first-30-minute art gaps. No rendered PASS or production asset integration is inferred.
- CONTENT-WAVE-01 Pack A requires no new external art asset, so no new 05 task is dispatched in the first batch.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: BACKLOG
- Reason: important for V1.0 but does not block CONTENT-WAVE-01 Pack A; the accepted wave explicitly says Pack A requires no new external art/audio.
- Preserve for the post-Pack-A vertical-slice wave; do not lose the user's requirement for a complete BGM/ambience/SFX layer before V1.0.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: BACKLOG
- Reason: the user explicitly selected `planning/CONTENT_EXPANSION_WAVE_01.md` as the current scheduling plan. DIRECTOR-001 remains required before V1.0/mainline freeze but is not allowed to displace the first Pack A player-visible batch.

## Second batch — do not activate until first playable Pack A is integrated and played
- Economy pressure v1 (recurring rent/fixed expenses only if playtest still shows weak money pressure; requires explicit save/migration design).
- Event Pack B selected from observed repetition gaps, not quota alone.
- NPC Episode Pack B (老周 / 疯道士 + midlife continuations; dark line secondary).
- Quest Pack C only after q1–q8 pacing is played.
- Alpha freeze: stop new features, form one exact integration SHA, run full Godot/Web QA, publish test build.

## User playtest checkpoint after first integrated Pack A build
Ask only:
1. Which location still feels empty?
2. Which NPC do you actually want to see again?
3. Did money/time/health ever force a decision, or were you simply clicking the best-looking reward?

Use those answers to choose Pack B.

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only. Default for this wave: relationship-neutral close friend.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Existing `e_parent_gone` / `e_roommate` policy remains untouched.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime blocker; `BACKLOG` = intentionally non-active work that the Dispatcher must not dispatch.
