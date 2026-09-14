# Game Director Agent Report

## Task
- ID: `DIRECTOR-CONTENT-002`
- Agent: `07-Game-Director`
- Branch/worktree: `agent/director-content-002-first-30m-map`
- Status: `NEEDS_REVIEW`
- Priority: HIGH

## Summary
Completed and self-reviewed the implementation-ready first-30-minute mainline map for CONTENT-WAVE-01.

The accepted DIRECTOR-001 direction is reduced to one deterministic onboarding spine:

`home 做饭 → subway 通勤 → office 第一班工作 → 找老张 → 可选 overtime → store 补给/陈姐 → home 第一晚 → Day 2`

The implementation map defines the four required experience windows:

- 0–1 min: make one meal; learn movement/interaction/resource cost and establish that today has a job to reach.
- 1–5 min: home → subway → office, with one commuting objective at a time.
- 5–15 min: first work shift → first meaningful Old Zhang contact.
- 15–30 min: optional overtime tradeoff → store purchase / optional Chenjie contact → home → first-night close.

Existing timing is intentionally reused rather than inventing a new clock rule: new game 07:30 → meal ~08:00 → subway ~08:20 → office ~08:55 → four-hour work ~12:55. Old Zhang's current office schedule resumes at 13:00; the remaining five game minutes are about 2.5 real seconds at the current time rate, so the design does not authorize a broad NPC-schedule rewrite.

Key director decisions:

- Exactly one foreground `现在：...` objective at a time. DailyRoutine becomes supporting progress, not a second competing command list.
- Existing long-horizon stage/dark/q1–q3 objective copy is deferred during onboarding.
- City Event Pack A, legacy annual events and random encounters are suppressed for the first-30-minute onboarding window.
- Office overtime is the first optional economic tradeoff: visible after the normal shift, never mandatory, with taken/skipped paths both rejoining the store objective.
- Cafe temporary side gig does not appear on Day 1/onboarding; recommended first visibility is Day 2+ once cafe has a narrative reason to matter.
- Old Zhang is the first work-anchor NPC because he has a real later system consequence; Chenjie is the first life-support NPC. Azhe remains ambient/optional. Xiaoyu is deliberately not made a first-30-minute dependency while roommate/romance/housing canon remains deferred.
- Technical map unlock data does not itself define player motivation: onboarding presentation exposes only destinations for which the current life problem has created a reason.
- No recurring rent, new save schema, new job tree, spouse/child decision or supernatural-first premise is introduced.

## Files changed
- `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`
- `agent-reports/game-director.md`

No production source/data/UI/art/audio files, `main`, `TASK_BOARD.md`, or other coordination files were modified.

## Validation
### Repository/static checks performed
- Read the latest available `docs/agents/TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and own report from `orchestrator/multi-agent-bootstrap`; task authorization remains limited to the two files above.
- Rechecked current LocationManager visit-unlock behavior, NPC schedules, q1–q3, HUD hierarchy and Game opening/work/sleep flow used by the implementation map.
- Continued the task-specific work already present on the assigned isolation branch instead of recreating DIRECTOR-001 or overwriting concurrent work.
- Read-only inspected the moving `GAME-CONTENT-012` branch. Latest observed producer tip during final self-review: `14ca63ac569680008f9f4b20cb01514672d75caa` (`GAME-CONTENT-012 wait for interaction layers in verifier`). The director contract depends only on its already-defined overtime/side-gig behavior, not on accepting this SHA. No runtime/PASS claim is inferred.
- Read-only inspected the moving `NPC-CONTENT-012` branch. Latest observed producer tip during final self-review: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2` (`NPC-CONTENT-012 complete city event pack A`), whose parent contains the 20 `e_cw01_*` Pack A candidates. This is a producer snapshot, not an integration acceptance claim.
- Producer SHA references inside the design document are therefore snapshot evidence only. 00/04 must re-read the final reviewed producer tips before integration; the onboarding rule remains unchanged regardless: Pack A eligibility during the first 30 minutes is `0/20`.

### Godot / Web / browser
- Not run in this web-agent task.
- No Godot, runtime, render, Web export, browser, animation or audio-playback PASS is claimed.

### Prepared validation package
`docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md` specifies the future `tools/verify_first30_flow.gd` contract plus exact-SHA manual/rendered checks covering:

1. no annual event / encounter / Pack A takeover during onboarding;
2. no `_year_pass()` during the authored first-day path;
3. no q1–q3 first-day chain-jump/reward noise;
4. exactly one L1 current objective per onboarding state;
5. home → subway → office → work → Old Zhang → store → home reachability;
6. overtime taken/skipped both rejoin the same mainline;
7. cafe side gig hidden on Day 1 and only exposed after the onboarding gate is released;
8. first-night gate release;
9. save/load preserving onboarding state;
10. 1280×720 and 960×540 rendered readability after UI integration.

The verifier is a handoff specification only. DIRECTOR-CONTENT-002 is not authorized to create `tools/**`, so no verifier file was added here.

## Known issues / risks
- `TASK_BOARD.md` remains the status authority. This worker report requests `NEEDS_REVIEW`; it does not edit the task board.
- Gameplay and Pack A producer branches are still moving independently. Exact producer SHAs must be re-read at freeze time; no stale SHA should be treated as accepted merely because it appears in this design/report.
- Existing q1 can advance very differently across origins because skill/money thresholds vary and its closing language is month-scale. The spec therefore suppresses q1–q3 front-end progress during onboarding instead of repairing quest data in this task.
- Current technical visit unlocks expose park/store after office, then cafe/hospital through visit chains. The spec asks UI/gameplay presentation to stop non-core destinations competing with the current mainline rather than requiring a broad LocationManager rewrite.
- Old Zhang has a 12:00–13:00 schedule gap. Existing timing places a zero-idle Golden Path at roughly 12:55 after work; normal reading/movement normally crosses 13:00. If real runtime evidence proves this brittle, 00 may authorize one narrow onboarding fallback rather than changing the whole schedule.
- The current cafe side-gig candidate is available whenever cafe is reachable; the later onboarding-visibility task must hide it on Day 1 rather than duplicating its settlement logic.
- `onboarding_complete` in existing `flags` is the preferred gate because flags already persist inside GameState; `day >= 2` remains an acceptable smaller fallback if 00 chooses it. Neither requires a new save schema.

## Handoff
00 should review `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md` and, if accepted, dispatch the independent work described there rather than one large rewrite:

- 01 Gameplay A: onboarding gate/current-objective state, first-day q1/event/encounter suppression, first-night release, no new save schema.
- 01 Gameplay B after GAME-CONTENT-012 acceptance: retain overtime after work; hide cafe side gig during Day 1/onboarding; do not reimplement livelihood settlement.
- 02 Scene/UI: one dominant `现在：...` objective; DailyRoutine secondary; hide long-horizon stage/dark/q1 copy during onboarding; visually prioritize only the current destination.
- 03 NPC/Content: minimal first-day Old Zhang / Chenjie recognition copy; Pack A remains Day 2+; do not decide Xiaoyu canon.
- 05 Art/Animation: office typing first, home cooking second; study can wait until Day 2. Asset integration remains separately authorized work.
- 06 Audio/Music: home rain → footsteps/cooking/door → subway → office/keyboard → dialogue/purchase/completion cues. No repeated architecture audit.
- 04 QA after 00 grants executable scope: Golden Path + overtime alternate path on one frozen integration SHA; rendered/Web/audio/animation evidence remains exact-SHA QA/Codex work.

## Commit evidence
- Initial task handoff: `395c61b7a3e6f5a67d61278c77dd30c476b5673a`.
- Refreshed implementation map: `d9c49ddb326bc5517779a7055119a577e916d1bc`.
- Prior NEEDS_REVIEW handoff: `87f9742ff28ee60236c9a35625316791aab333c4`.
- This commit performs final producer-freshness reconciliation only; it does not alter the accepted implementation spine.

Director recommendation: accept and integrate this spine before adding more first-hour content. The next product question is whether Day 1 makes a new player want to return for Day 2, not how many systems can be shown before the first shift ends.
