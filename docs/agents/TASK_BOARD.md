# Multi-Agent Task Board

Only 00-Orchestrator edits this file. Workers update only their own reports.

## Control state
- Development execution: **ACTIVE — CONTENT-WAVE-01**.
- Wave source: `planning/content-expansion-wave-01` at exact planning tip `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`.
- Wave title: **城市开始活起来**.
- `main` remains untouched by the multi-agent control plane.

## CONTENT-WAVE-01 scheduling rule
At least **60% of active work must produce player-visible content or directly unblock player-visible content**.

Current active split after this heartbeat:
- 01 Gameplay — player-visible livelihood actions.
- 02 Scene/UI — dialogue readability infrastructure required by longer content.
- 03 NPC/Content — 20-event City Event Pack A.
- 04 QA/Build — content acceptance/integration gate.
- 05 Art/Animation — first-hour embodied action art candidates.
- 06 Audio/Music — first-hour legally usable sound-source pack.
- 07 Game Director — first-30-minute mainline implementation map.

Player-visible / direct-unblock lanes = 6/7 = **85.7%**; QA/integration = 1/7 = **14.3%**.
Repository-only speculative audits remain BACKLOG unless they block integration or a known HIGH/CRITICAL defect.

## CONTENT-WAVE-01 player-visible exit target
- 20 new ordinary-life events across park / cafe / hospital / alley / rooftop: 4 each.
- 8 relationship-stage NPC episodes across 陈姐 / 老张 / 小雨 / 阿哲: 2 each, after Event Pack A.
- Extend serial quest chain from q1–q3 to q1–q8 after the event/relationship slice.
- At least 2 new repeatable livelihood actions with meaningful money/time/health/mood tradeoffs.
- First-pass visible economic pressure without silently deciding unresolved family/romance canon.
- First-hour art/audio/director vertical-slice inputs are now active so Pack A does not remain a text-and-number-only expansion.
- No unresolved spouse/child/roommate/Xiaoyu romance canon is decided in this wave.

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
- Status: IN_PROGRESS
- Priority: HIGH
- Player-visible: YES.
- Latest observed branch tip at this heartbeat: `437618ad4a1950257204a7e4d792b76ec924a683` (`GAME-CONTENT-012 restore accepted gameplay baseline`). Worker report has not yet been updated to this task, so this is **not accepted output** and there is no runtime claim.
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

## Lane 02 — Scene/UI
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- Status: IN_PROGRESS
- Priority: HIGH for CONTENT-WAVE-01 support.
- Player-visible: YES / directly unblocks longer content.
- Latest observed branch tip at this heartbeat: `5f1e4d3831007a131fbbd20d2342447a4f6575f7` (`test: add DialogUI overflow verifier`). Worker report is still the inherited template, so this branch movement is **not yet reviewable/accepted** and no Godot/rendered PASS is inferred.
- Writable: `scripts/ui/DialogUI.gd`, `tools/verify_dialog_panel_overflow.gd`, `agent-reports/scene-ui.md`.
- Objective: keep the bottom dialog bounded while only the wrapped body scrolls/contains overflow; speaker and `继续` / `结束` stay outside and reachable at 1280×720 and 960×540.
- Preserve: `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression, button copy, exactly-once final emission and Game-facing busy semantics.
- Required repository behavior: long-line scroll path; scroll reset on next line and reopen; normal text still reads naturally; no gameplay/content changes.
- Final rendered PASS remains QA-002 exact-SHA work.

### UI-CONTENT-008 — Content readability pass
- Owner: scene-ui
- Status: BACKLOG / NEXT AFTER UI-FIX-007 REVIEW
- Player-visible: YES.
- Objective after UI-FIX-007: verify long event/dialogue copy, quest objectives/completion feedback and visible choice costs remain scannable at 1280×720 and 960×540 using existing UI vocabulary.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
- Owner: npc-content
- Branch: `agent/npc-content-012-city-event-pack-a`
- Status: READY
- Priority: HIGH
- Player-visible: YES.
- Current branch tip at this heartbeat is still coordination baseline `d415ecf165fc6c90d5abf42e5929745d1739acf4`; worker report remains the inherited template.
- Writable: `data/events.json`, `agent-reports/npc-content.md` only.
- Objective: add exactly **20 ordinary-life events**, using the existing supported event schema:
  - park: 4
  - cafe: 4
  - hospital: 4
  - alley: 4
  - rooftop: 4
- Prefer ID prefix `e_cw01_...`; all IDs unique.
- Every event has 2–3 usable choices; at least one real downside/cost; choices trade at least two supported dimensions where natural; at least 5 remembered-choice acknowledgements; at least 6 natural existing-NPC references; ordinary city life primary; no unsupported schema/effect/condition keys.
- Explicitly untouched: `e_parent_gone`, `e_roommate`, `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`, Xiaoyu romance/housing canon.
- Parser/Godot/runtime PASS belongs to QA.

### NPC-CONTENT-013 — Relationship Episode Pack A
- Owner: npc-content
- Status: BACKLOG / NEXT AFTER NPC-CONTENT-012 REVIEW
- Target: 8 relationship-stage episodes, 2 each for 陈姐 / 老张 / 小雨 / 阿哲; Xiaoyu remains relationship-neutral.

### NPC-CONTENT-014 — Serial Quest Pack B
- Owner: npc-content
- Status: BACKLOG / AFTER RELATIONSHIP PACK REVIEW
- Target: extend q1–q3 to q1–q8 using only supported step types unless Gameplay first adds a validated hook.

### NPC-AUDIT-011 — Post-genericization pronoun consistency audit
- Owner: npc-content
- Branch: `agent/npc-audit-011-post-genericization-pronouns`
- Status: BACKLOG
- Reason: non-blocking copy audit.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content Pack acceptance gate
- Owner: qa-build
- Branch: `agent/qa-content-014-content-pack-acceptance`
- Status: READY
- Priority: MEDIUM
- Current branch tip at this heartbeat is still coordination baseline `d415ecf165fc6c90d5abf42e5929745d1739acf4`; worker report remains the inherited template.
- Player-visible support: integration gate, not an audit chain.
- Writable: `agent-reports/qa-build.md` only for the web-agent phase. Any executable verifier addition requires a later explicit 00 grant.
- Objective: maintain Pack A acceptance manifest and inspect exact tips as GAME-CONTENT-012 / UI-FIX-007 / NPC-CONTENT-012 move.
- Repository gate: exact 20-event count and 4/location; unique IDs; usable options; supported keys; remembered-choice/NPC-reference traceability; deferred-policy safety; livelihood visible tradeoffs/anti-spam/no save-schema change; exact tips/stale-SHA stop.
- Runtime gate remains QA-002 on one frozen candidate: trigger at least one event from each location; complete both livelihood actions incl. day rollover; save/load; later q4–q8 and relationship episode; exact-SHA Web/browser evidence.
- If source branches have not moved, prepare the gate and wait; do not create speculative audits.

### QA-013 — Next-wave candidate / Codex preflight
- Owner: qa-build
- Branch: `agent/qa-013-next-wave-candidate-preflight`
- Status: BACKLOG / SUPERSEDED FOR NOW

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
- Accepted conclusion: 9 active maps are structurally playable but background-heavy B-tier; no A-tier map; work/study/cook/commute/NPC talk are the highest-impact action gaps. The worker report still says NEEDS_REVIEW because workers do not rewrite accepted status after 00 consumes it; TASK_BOARD is authoritative.

### ART-PROD-002 — First-hour embodied action candidate pack
- Owner: art-animation
- Branch: `agent/art-prod-002-first-hour-actions`
- Status: READY
- Priority: HIGH
- Player-visible: YES / direct visual production.
- Writable repository scope: `agent-reports/art-animation.md` only in this production pass. **Chat image-generation outputs are allowed and expected deliverables but are not treated as repository-integrated assets.**
- Objective: produce the first coherent player action candidate pack for the three most visible missing actions:
  1. office workstation typing;
  2. home desk study/reading;
  3. home kitchen cooking/stirring.
- Production contract:
  - preserve the current player visual identity, 2.5D camera angle, body proportions, transparent-background sprite convention and fixed foot anchor;
  - target reusable `256×256` RGBA action cells unless a documented reason requires otherwise;
  - each action must define enter/contact/loop/exit needs; prioritize a visually coherent loop over excessive frame count;
  - props (laptop/book/pot) must meet the hands/furniture contact rather than float separately;
  - generate actual candidate visual output in the 05 chat, not only prose/prompt text;
  - do not pretend the generated image is already in GitHub or Godot.
- Report handoff must record: generated candidate names, frame/layout specification, intended anchor/contact geometry, which existing home/office background contact it targets, any consistency defects, and the exact integration work needed from 02/Codex.
- Forbidden: scene/script/gameplay edits, unrelated character redesign, promotional-poster art, changing the player's canonical identity, `main`, coordination files.
- Rendered/animation-loop acceptance requires later exact-SHA Godot/Codex integration; this task only produces candidate art + integration manifest.

## Lane 06 — Audio / Music
### AUDIO-AUDIT-001 — V1.0 sound-system & asset audit
- Owner: audio-music
- Branch: `agent/audio-audit-001-sound-system`
- Status: DONE
- Accepted exact tip: `cb17301c2dd9e4f4502e5279f27024dc84b503b1`.
- Review: report-only scope respected; branch delta is only `agent-reports/audio-music.md`. Accepted conclusion: the active project has essentially no BGM/ambience/SFX assets, no AudioStreamPlayer/Bus/mix/fade framework, but existing location/time/weather/activity/dialogue/shop/quest hooks are sufficient for a clean first audio layer. No playback/integration PASS is inferred.

### AUDIO-CONTENT-002 — First-hour legally usable sound-source pack
- Owner: audio-music
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: READY
- Priority: HIGH
- Player-visible: YES / directly unblocks audible vertical slice.
- Writable:
  - `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`
  - `agent-reports/audio-music.md`
- Objective: curate a **small, legally usable first-hour sound pack** rather than another architecture audit.
- Required source set:
  - 1 home/rain-night music or musical-bed candidate;
  - 1 office ambience loop;
  - 1 subway ambience/arrival loop;
  - 1 indoor rain/window ambience;
  - at least 8 high-frequency SFX candidates covering UI click/dialog advance, footsteps, door, keyboard/work, study/page, cooking, purchase/confirm and task-complete/warning.
- Rights rule: use only clearly reusable sources whose license permits the intended game distribution; prefer CC0/Public Domain or similarly unambiguous royalty-free use. Record exact source page, creator, license, attribution requirement, modification rule and download filename. Reject unclear/YouTube-ripped/commercial-game assets.
- Do not claim an item has been downloaded, mixed or integrated unless that actually happens. The immediate deliverable is a legally traceable source pack + prioritized integration manifest.
- Report must specify recommended trim/loop/fade/use point and map each item to an existing hook from AUDIO-AUDIT-001.
- No `project.godot`, Game, LocationManager, AudioManager or playback integration edits in this task; those become a later narrow integration task after source review.

## Lane 07 — Game Director
### DIRECTOR-001 — V1.0 mainline & first-hour experience plan
- Owner: game-director
- Branch: `agent/director-001-v1-mainline-plan`
- Status: DONE
- Accepted exact tip: `cea3443980458e0fb930289c6c487a0cc96be01a`.
- Review: report-only scope respected; branch delta is only `agent-reports/game-director.md`. Accepted as the strategic V1.0 direction: foreground minutes/days/weeks/month for the first-month experience, reduce simultaneous objective noise, give every map/NPC an authored reason to matter, and keep old annual/midlife content as preserved later-life assets rather than letting it dominate the first hour. Major implementation changes still require separate task-level review; no gameplay rewrite is implied by accepting the plan.

### DIRECTOR-CONTENT-002 — First-30-minute mainline implementation map
- Owner: game-director
- Branch: `agent/director-content-002-first-30m-map`
- Status: READY
- Priority: HIGH
- Player-visible: YES / direct implementation unblock.
- Writable:
  - `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`
  - `agent-reports/game-director.md`
- Objective: turn DIRECTOR-001 into one implementation-ready **0–30 minute sequence** that current CONTENT-WAVE-01 work can actually build without a giant rewrite.
- Required sequence specification:
  - exact player objective shown at 0–1, 1–5, 5–15 and 15–30 minutes;
  - which existing location unlock/reason is used at each step;
  - which NPC appears and why the player wants to find them again;
  - where GAME-CONTENT-012 overtime/cafe side-gig should first become visible, if at all in first 30 minutes;
  - which subset of Pack A events should be eligible vs suppressed during onboarding so random content does not drown the mainline;
  - exact HUD/tutorial copy hierarchy: one current objective, supporting daily needs, deferred long-horizon systems;
  - handoff list of the smallest tasks for 01/02/03/05/06 after this spec is accepted.
- Do not change Game/data/UI/art/audio source. Do not silently decide Xiaoyu romance/housing, spouse/child semantics, recurring-rent canon or supernatural marketing emphasis.
- Acceptance: one deterministic flow, no contradictory simultaneous objectives, no unsupported mechanics, and a concrete task decomposition small enough for 00 to dispatch independently.

## Second batch — do not activate until first playable Pack A is integrated and played
- Economy pressure v1 only if playtest still shows weak money pressure; recurring rent/fixed expenses require explicit design/migration review.
- Event Pack B selected from observed repetition gaps, not quota alone.
- NPC Episode Pack B (老周 / 疯道士 + midlife continuations; dark line secondary).
- Quest Pack C only after q1–q8 pacing is played.
- Alpha freeze: stop new features, form one exact integration SHA, run full Godot/Web QA, publish test build.

## User playtest checkpoint after first integrated Pack A build
Ask only:
1. Which location still feels empty?
2. Which NPC do you actually want to see again?
3. Did money/time/health ever force a decision, or were you simply clicking the best-looking reward?

## Deferred product decisions
- Xiaoyu canon: roommate / romance possibility / close friend only. Default for this wave: relationship-neutral close friend.
- Family semantics: married-household-only vs co-parent-inclusive.
- Whether recurring rent/fixed expenses becomes a core survival mechanic.
- Whether first public Alpha markets realistic daily life first or supernatural dark line first.
- Existing `e_parent_gone` / `e_roommate` policy remains untouched.

## Status values
`READY` -> `IN_PROGRESS` -> `NEEDS_REVIEW` -> `DONE`; `BLOCKED` = real dependency/runtime blocker; `BACKLOG` = intentionally non-active work that the Dispatcher must not dispatch.
