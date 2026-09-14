# Game Director Agent Report

## Task
- ID: `DIRECTOR-CONTENT-003`
- Agent: `07-Game-Director`
- Branch/worktree: `agent/director-content-003-day2-7-retention`
- Status: `NEEDS_REVIEW`
- Priority: MEDIUM
- Baseline: accepted `DIRECTOR-CONTENT-002` tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`

## Summary
Completed and self-reviewed the implementation-ready Day 2–7 retention-loop map for CONTENT-WAVE-01.

The accepted Day-1 spine remains unchanged. Day 2–7 now answers a different product question:

> **“这座城市有没有开始认得我？”**

The week is deliberately not another six-day tutorial. It uses one authored anchor per day while the rest of each day remains ordinary-life play:

`Day 2 work/recovery → park gets a reason`  
`Day 3 cafe gets a reason → optional side gig/recovery`  
`Day 4 deliberately revisit Lao Zhang or Chenjie`  
`Day 5 choose money vs recovery vs relationship time`  
`Day 6 map suggestions respond to real needs`  
`Day 7 show that the week changed something`

### Weekly-scale motivation
The single visible week goal is:

> **本周：让一个熟面孔真正记住你。**

Completion is derived entirely from the existing relation system:

`laozhang >= 20 OR chenjie >= 20`.

This requires no new WeeklySystem or save field. Existing `NpcRelations` already gives +4 only on the first completed conversation with an NPC each day, relation 20 is the existing `认识` tier, and the current milestone says the NPC remembers the player's face. The player therefore needs five meaningful conversations across multiple days, not same-day grinding. Day 7 has no failure state.

Lao Zhang / Chenjie are intentionally the Week-1 goal pair because they are the two accepted Day-1 human anchors with deterministic, high-frequency return locations. Azhe and Lao Zhou remain valuable optional city texture, but the week goal does not depend on catching narrower schedules. Xiaoyu and Daoshi remain outside this goal because their canon/dark-line role is explicitly deferred.

### Day 2
After an ordinary work shift, park becomes the first new authored life reason:

- office overtime = more money / more health-mood cost;
- park = no money / recovery.

Lao Zhou is optional because his current 11:30–15:00 schedule gap makes him unsuitable as a deterministic Day-2 gate.

### Day 3
Cafe becomes an authored opportunity only after the player has first used park as a real life location. Recommended derived reveal rule:

`onboarding_complete && day >= 3 && park visited`.

The accepted cafe side gig is an optional route, not a mandatory task. Coffee / idle / side gig make the same map support different priorities. Azhe remains an optional schedule reward around 12:00–14:00, never a gate.

### Day 4–5
Day 4 asks the player to deliberately revisit either Lao Zhang or Chenjie. The week goal gives those returns a reason beyond `+4`.

Day 5 puts only already-accepted choices side by side:

- overtime for higher money and heavier health/mood cost;
- cafe side gig for lower money / lighter cost;
- park/cafe/home for recovery;
- Lao Zhang/Chenjie for relationship time.

No best-answer branch is authored.

### Day 6
Maps become need-driven:

- hospital is suggested only when health actually creates a reason;
- park/cafe remain recovery alternatives;
- money pressure points back to existing overtime/side-gig choices;
- alley/rooftop/Daoshi are not actively routed during Week 1.

No fixed-rent mechanic or artificial health damage is introduced to force map use.

### Day 7
The week closes without a fail state.

If Lao Zhang or Chenjie has reached the existing `认识` tier, the summary says the city is still large but somebody recognizes the player. If not, the player is told the route is familiar now and there is still time next week to build a connection.

The second-week hook is work value rather than map completion: skill growth, deeper Lao Zhang relationship, and eventual salary negotiation.

## Final Pack A positioning after continuity self-review
Accepted `NPC-CONTENT-012` is treated as accepted source/content only, **not** current runtime eligibility.

All Pack A remains suppressed until `GAME-CONTENT-014` separates ordinary city-event minute-scale completion from legacy `_year_pass()` and that path is later frozen/validated.

A late director self-review cross-checked the event prose against the actual NPC schedules and narrowed the first-week list. This final report is the integration boundary for Week-1 event eligibility; the design document's broader candidate examples must not be interpreted as unconditional runtime approval.

### A — safe early candidates after GAME-CONTENT-014

- `e_cw01_cafe_charger` — age 22, no physical scheduled NPC required, natural cafe vignette.
- `e_cw01_cafe_gossip` — age 22, generic coworker, natural after several work days.
- `e_cw01_hospital_medicine` — age 22; Chenjie is only a message reference, so her store schedule is not contradicted; only use when the player already has a real health reason to visit hospital.

### B — conditional candidates, otherwise keep suppressed

- `e_cw01_park_free_class`
- `e_cw01_park_lost_wallet`

Both place Lao Zhou physically in the scene prose. They are only safe if the event eligibility layer can confirm Lao Zhou is currently present at park under his existing schedule/weather rules. If GAME-CONTENT-014 does not provide schedule-aware eligibility, keep both suppressed rather than showing a character who is absent from the actual scene.

- `e_cw01_cafe_unpaid_trial` — good remembered-choice follow-up after `cw01_lent_cafe_charger`, but it should not fire in the same in-game day as the charger event. If there is no safe cross-day gate, defer it.
- `e_cw01_park_rain_aunties` — good remembered-choice follow-up after `cw01_joined_park_class`, but only after the parent event was itself safely triggered and not as a same-session chain dump.

### C — suppress in Week 1 unless separately corrected

- `e_cw01_cafe_interview_prep` — prose puts Lao Zhang physically in cafe, but his accepted schedule has no cafe slot. Being “already known” does not solve the spatial contradiction.
- `e_cw01_hospital_kiosk` — prose puts Chenjie physically in hospital while her accepted 07:00–23:00 schedule keeps her at the convenience store.
- `e_cw01_hospital_late_queue` — depends on kiosk and explicitly says it is 01:00; current ordinary EventSystem has no time-of-day condition in event data, so it is not a safe first-week random candidate.
- `e_cw01_park_recruiter_call` — age min 23; default first week is age 22.
- `e_cw01_hospital_report` — age min 25.
- all alley/rooftop Pack A — deferred because those maps still lack a stronger Week-1 life reason and should not be opened just to consume content quota.

Recommended pacing after GAME-CONTENT-014: at most one Pack A ordinary-city event per in-game day during Week 1. If the eventual narrow implementation cannot guarantee this without scope growth, open fewer events instead of adding another broad event subsystem.

## HUD transition
After onboarding, the first-week hierarchy becomes:

1. **当前行动** — immediate reason to act;
2. **本周目标** — one relationship-scale motivation;
3. DailyRoutine — weak daily progress/status;
4. q1–q3 — backend/task-detail progression, not another persistent high-priority HUD command;
5. the 22–60-year stage/dark-line objective wall remains outside the Week-1 primary HUD.

q1 is not repurposed as the universal Week-1 goal because its fixed skill>=55 / money>=3000 conditions have sharply different difficulty by origin and its closing copy is month-scale. q2 may arise naturally for fast progress but salary negotiation is not forced by Day 7. q3 is not used as a Week-1 director goal because it still encodes unresolved Xiaoyu roommate/home semantics.

UI should prefer relationship labels (`陌生人 / 认识`) rather than exposing the whole numeric ladder. Do not turn the week goal into “还差 N 次聊天”的 permanent grind counter unless usability testing proves the qualitative labels are too opaque.

## Files changed
- `docs/design/DAY_2_7_RETENTION_LOOP.md`
- `agent-reports/game-director.md`

Task-specific work is limited to these two authorized paths. The inherited `FIRST_30_MIN_MAINLINE_IMPLEMENTATION.md` belongs to the accepted DIRECTOR-CONTENT-002 baseline and is not a DIRECTOR-CONTENT-003 production edit.

No Game/data/UI/art/audio production files, `main`, `TASK_BOARD.md`, or other coordination files were modified by DIRECTOR-CONTENT-003.

## Repository/static validation performed
- Read latest `orchestrator/multi-agent-bootstrap` TASK_BOARD, FILE_OWNERSHIP and WEB_AGENT_LAUNCHPAD.
- Confirmed this task's writable scope is only `docs/design/DAY_2_7_RETENTION_LOOP.md` and `agent-reports/game-director.md`.
- Confirmed the task branch started from accepted DIRECTOR-CONTENT-002 final tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.
- Re-read current q1–q3 data and QuestSystem semantics.
- Re-read `NpcRelations`: +4/day first valid talk, tiers 0/20/45/70, same-day anti-spam and existing `认识` milestone.
- Re-read NPC schedules for Lao Zhang, Chenjie, Lao Zhou, Azhe, Xiaoyu and Daoshi.
- Re-read DailyRoutine, HUD thresholds, LocationManager `unlocked/visited` persistence, and current visit-unlock behavior.
- Re-read accepted Pack A source IDs/conditions and cross-checked named physical NPCs against `npc_schedules.json`.
- Preserved accepted GAME-CONTENT-012 livelihood values rather than redesigning economy.
- Kept `GAME-CONTENT-014` as an explicit runtime blocker instead of claiming Pack A is playable after onboarding.
- Reconciled concurrent same-branch work rather than overwriting it; the final self-review narrows Pack A eligibility where prose/schedule/time semantics would otherwise contradict the living world.

## Godot / Web / browser / rendered validation
- Godot: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Rendered UI: **NOT RUN**.
- Animation/audio playback: **NOT RUN**.
- No runtime/build/render/browser/audio PASS is claimed.

DIRECTOR-CONTENT-003 is not authorized to add `tools/**`, so the design provides a future validation contract rather than an executable verifier.

## Prepared future validation package
Suggested future `verify_day2_7_retention.gd` / exact-SHA QA coverage:

1. Week-1 retention state only starts after `onboarding_complete`;
2. week goal derives from existing Lao Zhang/Chenjie relations, no new save schema;
3. first valid conversation per NPC/day remains +4; same-day repeats cannot grind the goal;
4. relation 20 still uses the existing `认识` tier/milestone;
5. Day-2 park hint is advisory, not a blocking gate;
6. cafe side-gig authored visibility does not occur during onboarding, Day 2, or before park was visited;
7. after `day>=3 + park visited`, cafe opportunity becomes available without changing accepted livelihood settlement values;
8. Day-7 unmet week goal is not failure/terminal state;
9. q1/q2 backend progression cannot replace the Week-1 current-action/week-goal hierarchy;
10. q3 cannot automatically become the Week-1 director objective;
11. no authored Week-1 alley/rooftop/Daoshi requirement;
12. save/load preserves all existing state from which Week-1 UI is derived.

After `GAME-CONTENT-014` only, additionally verify:

- `e_cw01_*` completion never advances age/year;
- legacy annual event year semantics remain intact;
- early candidate pool obeys the final A/B/C eligibility rules above;
- park events that physically use Lao Zhou do not fire while he is absent/hidden;
- cafe-interview/hospital-kiosk/late-queue do not enter Week-1 runtime until their spatial/time continuity is corrected;
- remembered-choice follow-ups do not dump immediately in the same day if cross-day pacing is part of the accepted implementation;
- event prerequisite flags survive save/load.

Manual frozen-SHA play paths should include one balanced route and one money-first overtime/side-gig route and compare whether the latter earns more at a visible time/health/mood cost.

## Known issues / risks
- `TASK_BOARD.md` remains status authority; this report only requests `NEEDS_REVIEW`.
- Day-1 production implementation (`GAME-CONTENT-013`, first-day UI/content tasks) is still a prerequisite for this map to become a coherent runtime sequence.
- `GAME-CONTENT-014` remains a hard blocker for Pack A runtime use even after onboarding.
- The design document contains broad content-placement examples written before the final schedule-continuity self-review; **the narrowed A/B/C eligibility in this report overrides any broader interpretation for implementation/review.** No production data was changed in this task.
- The current technical visit-unlock chain may expose destinations earlier than the authored week wants to emphasize. Week-1 implementation should prefer UI focus/derived hints over a broad LocationManager rewrite; any high-conflict edit requires explicit 00 authorization.
- q1 remains origin-asymmetric and month-worded; this task intentionally does not edit quest data.
- Xiaoyu roommate/romance/housing canon remains unresolved and untouched.
- There is no true weekday/weekend calendar mechanic. “Day 2–7 / first week” means the first seven game days, not Monday–Sunday; no weekend work rule is invented.

## Handoff to 00
After Day-1 implementation is reviewed, dispatch small independent tasks rather than one Week-1 rewrite:

### 01 Gameplay — `WEEK1-GAME-001`
- expose Week-1 derived goal state from existing Lao Zhang/Chenjie relations/day/visited;
- cafe authored reveal uses onboarding + day>=3 + park visited;
- Day-2 park / Day-3 cafe are hints, not hard travel locks;
- Day-7 summary state has no fail path;
- do not change GAME-CONTENT-012 settlement values or add save schema;
- keep q1/q2 in background hierarchy and prevent q3 from replacing the Week-1 director objective;
- keep Pack A runtime work separate behind `GAME-CONTENT-014` and use the final A/B/C eligibility above after that blocker clears.

### 02 Scene/UI — `WEEK1-UI-001`
- transition HUD to `本周目标 + 当前行动` after onboarding;
- DailyRoutine stays secondary;
- q1/stage/dark copy does not reclaim the primary objective area;
- prefer qualitative relationship labels over permanent numeric/chat-count grind UI;
- route emphasis: park Day2, cafe Day3+, hospital only from real health need, no Week-1 alley/rooftop emphasis;
- light Day-7 summary using current state only.

### 03 NPC/Content — `WEEK1-CONTENT-001`
- minimal repeat-contact continuity for Lao Zhang and Chenjie after the first-day recognition micro-pass;
- preserve relation mechanics and avoid numeric-threshold exposition;
- Lao Zhou/Azhe remain optional life texture, not mandatory Week-1 quests;
- no Xiaoyu canon decision;
- perform a narrow continuity repair/curation pass before any schedule-conflicting Pack A item is allowed into Week-1 runtime; do not add another event quota before the loop is played.

## Handoff status
`DIRECTOR-CONTENT-003` is complete within its two-file authorization and requests **NEEDS_REVIEW**.

Director recommendation: implement and play this Week-1 loop only after the Day-1 spine is stable. The product metric is not “how many maps were opened by Day 7”; it is whether the player can name at least one place they use for a reason, one economic tradeoff they deliberately chose, and one person in the city who now recognizes them.
