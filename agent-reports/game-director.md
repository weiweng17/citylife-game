# Game Director Agent Report

## Task
- ID: `DIRECTOR-CONTENT-002`
- Agent: `07-Game-Director`
- Branch/worktree: `agent/director-content-002-first-30m-map`
- Status: `NEEDS_REVIEW`
- Priority: HIGH

## Summary
Completed and self-reviewed the implementation-ready first-30-minute mainline map for CONTENT-WAVE-01.

The final deterministic onboarding spine is:

`home 做饭 → subway 通勤 → office 先找老张 → 第一班工作 → 可选 overtime → store 补给/可选陈姐 → home 第一晚 → Day 2`

The important final correction is **Old Zhang before the first work shift**. Existing timing gives new game 07:30 → meal ~08:00 → subway ~08:20 → office ~08:55. Old Zhang is already scheduled in office 08:00–12:00, and dialogue pauses city time. This is deterministic. Putting him after a four-hour shift lands at roughly 12:55 inside his 12:00–13:00 schedule gap and would make onboarding depend on waiting; the implementation map now removes that brittleness without changing NPC schedules.

Required experience windows are explicitly mapped:

- **0–1 min:** cook one meal; learn movement/interaction/resource cost; establish “today I have work to reach”.
- **1–5 min:** home → subway → office, one commuting objective at a time.
- **5–15 min:** first meaningful Old Zhang contact → first work shift → visible pay/cost/skill feedback.
- **15–30 min:** optional overtime tradeoff → store purchase / optional Chenjie contact → home → first-night close.

Key director decisions:

- Exactly one foreground `现在：...` objective at a time. DailyRoutine is supporting progress, not a competing command list.
- First-night completion writes existing `flags["onboarding_complete"] = true`; this is preferred over `day >= 2` because accidental cross-midnight actions must not silently complete onboarding. No new save schema is needed.
- q1–q3 evaluation/notify/reward/front-end copy is gated until onboarding completes, so origin-dependent skill/money thresholds cannot chain-jump Day 1.
- City Event Pack A, legacy annual events and encounters are all suppressed during the first 30 minutes (`Pack A eligible 0/20`).
- Office overtime is the first optional economic tradeoff, visible only after the normal shift if the producer task is accepted/integrated; taking or skipping it rejoins the same store objective.
- Cafe side gig is not a Day-1 action; it becomes eligible only after onboarding and after cafe has an authored reason to matter.
- Old Zhang is the work-anchor NPC; Chenjie is the life-support NPC; Azhe is ambient/optional. Xiaoyu is deliberately not made a first-30-minute dependency while roommate/romance/housing canon remains unresolved.
- Technical location unlock state may remain for compatibility, but onboarding travel presentation uses a phase allowlist so park/cafe/hospital/alley/rooftop do not compete with the authored route.
- No recurring rent, new job tree, spouse/child decision, new currency, new save schema or supernatural-first premise is introduced.

## Parallel producer snapshots inspected read-only

### GAME-CONTENT-012
- Latest observed branch tip during final self-review: `14ca63ac569680008f9f4b20cb01514672d75caa`.
- Worker report requests `NEEDS_REVIEW`.
- Candidate behavior used only for placement: office overtime 2h / ~60% current shift pay / health−4 / mood−8 / once per day; cafe side gig 90m / +55 / health−2 / mood−4 / once per day.
- No producer acceptance or runtime PASS is inferred.

### NPC-CONTENT-012
- Latest observed branch tip during final self-review: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`.
- Content commit: `fe1625c7a302ac6fc0c902f55145772fa5521580`.
- Worker report requests `NEEDS_REVIEW` and contains exactly 20 `e_cw01_*` Pack A candidates.
- The design now records all 20 as suppressed during onboarding and nominates only low-risk Day 2–7 candidates after producer acceptance.
- No integration/parser/runtime PASS is inferred.

## Files changed
- `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`
- `agent-reports/game-director.md`

No production source/data/UI/art/audio files, `main`, `TASK_BOARD.md`, or other coordination files were modified by DIRECTOR-CONTENT-002.

## Validation

### Repository/static checks performed
- Read latest available `docs/agents/TASK_BOARD.md`, `docs/agents/FILE_OWNERSHIP.md`, `docs/agents/WEB_AGENT_LAUNCHPAD.md`, and the 07 report from `orchestrator/multi-agent-bootstrap`.
- Confirmed task authorization is limited to the two files above.
- Rechecked `LocationManager.VISIT_UNLOCKS`, home activity timing, NPC schedules, q1–q3 data, inventory/store catalog, HUD hierarchy, and Game opening/work/event/sleep/quest flow.
- Reconciled concurrent work already present on this task branch rather than restarting DIRECTOR-001 or modifying unrelated files.
- Read-only inspected the current GAME-CONTENT-012 and NPC-CONTENT-012 producer branches to keep this implementation map current.
- Corrected the earlier non-deterministic work-before-Old-Zhang order and stale Pack-A status wording.

### Godot / Web / browser
- Godot: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Rendered UI: **NOT RUN**.
- Animation/audio playback: **NOT RUN**.
- No runtime/render/build/browser PASS is claimed.

### Prepared validation package
The design document specifies the future `tools/verify_first30_flow.gd` / exact-SHA QA contract. DIRECTOR-CONTENT-002 is not authorized to create `tools/**`, so no verifier file was added.

The future frozen-SHA verification must cover at least:

1. meal gate before leaving home;
2. home → subway → office arrival and Old Zhang availability around 08:55 without waiting for the 13:00 schedule window;
3. Old Zhang → ordinary work order;
4. no Pack A / legacy annual event / encounter takeover during onboarding;
5. no `_year_pass()` anywhere on the authored Day-1 path;
6. no q1–q3 first-day chain-jump, toast or reward noise;
7. exactly one L1 current objective at every onboarding phase;
8. overtime taken/skipped both rejoin store;
9. cafe side gig hidden during onboarding;
10. first successful full-night sleep writes/releases `onboarding_complete`;
11. save/load preserves onboarding state;
12. 1280×720 and 960×540 objective/status/location readability;
13. animation/audio evidence only on the same frozen integration SHA after those assets are actually integrated.

## Known issues / risks
- `TASK_BOARD.md` remains status authority; this report only requests `NEEDS_REVIEW`.
- Producer branches are independent and may move before 00 review. Their SHAs above are snapshot evidence, not acceptance inputs; 00/04 must re-read reviewed exact tips at freeze time.
- Existing ordinary `EventSystem` events close into `_year_pass()`. Therefore even accepted Pack A content cannot safely become normal minute-scale Day 2+ content until Gameplay gives ordinary city events a non-year-advancing path or keeps them suppressed. The design explicitly records this dependency instead of silently enabling Pack A.
- Existing `VISIT_UNLOCKS` fans office into park/store and later cafe/hospital. A narrow onboarding travel-button allowlist is required if the first day is to remain deterministic. Any `LocationManager` edit needs an explicit high-conflict grant from 00.
- Current q1 thresholds differ sharply by origin and its closing copy is month-scale. Day-1 gating avoids this without changing quest data in this task.
- Xiaoyu housing/romance/roommate semantics remain unresolved and untouched.

## Handoff
If 00 accepts the map, dispatch the smallest independent tasks described in `docs/design/FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md`:

- **01 Gameplay — FIRST30-GAME-001:** onboarding state/gates; meal-before-leave; q1/event/encounter suppression; first-night `onboarding_complete`; no new save schema.
- **02 Scene/UI — FIRST30-UI-001:** one dominant `现在：...` objective; DailyRoutine secondary; hide long-horizon copy; onboarding navigation allowlist/focus. Any LocationManager edit requires explicit narrow authorization.
- **03 NPC/Content — FIRST30-CONTENT-001:** minimal first-day Old Zhang/Chenjie recognition copy; no Xiaoyu canon decision; no new Day-1 random-event batch.
- **05 Art/Animation — FIRST30-ART-001:** home cooking first, office typing second; study can wait until Day 2; integration remains separately authorized.
- **06 Audio/Music — FIRST30-AUDIO-001:** home rain → footsteps/cooking/door → subway → office/keyboard → dialog/purchase/completion cues.
- **04 QA — later explicit grant:** run Golden Path and overtime alternate path on one frozen integration SHA; rendered/Web/audio/animation evidence remains centralized exact-SHA QA/Codex work.

## Handoff status
`DIRECTOR-CONTENT-002` is complete within its two-file authorization and requests **NEEDS_REVIEW**.

Director recommendation: integrate this Day-1 spine before adding more first-hour content. The next product question is whether a new player who has cooked, commuted, met Old Zhang, worked, spent money and returned home actually wants to wake up for Day 2.