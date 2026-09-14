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

The accepted Day-1 spine remains unchanged. Day 2–7 now answers:

> **“明天为什么还值得再过一天？”**

Week 1 is deliberately not another six-day tutorial. It rotates three already-supported retention sources instead of adding a WeekSystem:

1. work becomes visibly more valuable through existing skill / JobGrowth progress;
2. people begin to remember the player through existing once-per-day relations and the `认识` milestone;
3. after-work time becomes a real tradeoff between recovery, ordinary work, overtime, store/home life and the accepted cafe side gig.

The authored beats are:

- **Day 2:** complete the ordinary loop without tutorial hand-holding; park gains its first explicit purpose as free recovery;
- **Day 3:** compare “sell more time / recover / see someone”; cafe side gig may already be discovered Day 2+ inside cafe, while Day 3 is only the first proactive hint;
- **Day 4:** deliberately revisit a person rather than collect NPCs;
- **Day 5:** surface skill/job-growth meaning and give home study a clear reason;
- **Day 6:** leave part of the day outside the company and let existing life maps carry choice;
- **Day 7:** summarize current life state without a pass/fail exam or new reward currency.

### Weekly-scale motivation
The single visible week framing is:

> **本周：把“新来的”过成“能留下的人”。**

This is not a hard checklist and has no failure state. The most visible existing proof is relation continuity: one meaningful talk per NPC/day gives +4 and `20 = 认识`. A player who keeps returning to Lao Zhang after the Day-1 contact can naturally see the existing “he remembers your face” milestone around midweek. Work progress, useful-place knowledge and state management are equally part of “留下来”; they are not converted into a new persisted week score.

## Final self-review corrections

### q1–q3 remain suppressed through Day 7
The concurrent draft briefly allowed q1–q3 to resume backend evaluation on Day 2. Final review rejected that.

Current q1 is origin-asymmetric and month-worded: `work_shift -> skill>=55 -> meal -> money>=3000`, then closes with “这个月”. A high-skill/high-money origin can cross several steps almost immediately after onboarding. Therefore the final Week-1 contract keeps q1–q3 `evaluate / notify / reward / closing` suppressed through Day 7 so the old month-scale chain cannot hijack the first-week pacing.

This task intentionally does **not** decide how Day 8+ should reintroduce or rewrite q1–q3; that belongs to a later quest-pacing/content task.

### Cafe side gig remains Day-2+ cafe-local eligibility
The concurrent draft also proposed a new hard `day>=3 && park visited` reveal gate. Final review aligns with the already-dispatched Day-1 Gameplay contract instead:

- runtime eligibility stays `onboarding_complete + Day 2+ + cafe reachable`;
- a curious player may discover the side gig inside cafe on Day 2;
- no Day-2 global banner advertises it;
- Day 3 is only the first proactive generic spotlight that the city has more than one way to sell time.

No GAME-CONTENT-012 settlement value is changed.

## HUD transition
After onboarding the first-week hierarchy is:

1. **当前行动** — one immediate reason to act;
2. **本周目标** — stable “把新来的过成能留下的人” framing;
3. DailyRoutine — weak daily recap/status;
4. money/health/mood/fullness/energy/time/skill — instrumentation;
5. q1–q3, 22–60-year stage goals and dark-line counters remain outside the Week-1 primary HUD.

UI should prefer qualitative relationship feedback (`陌生人 / 认识`, existing milestone copy) over turning Week 1 into a permanent “还差 N 次聊天” grind counter.

## Map-purpose decisions
- `home`: food / sleep / recovery; study gets its first explicit growth purpose around Day 5;
- `subway`: ordinary commute and optional Azhe continuity;
- `office`: normal income / skill / Lao Zhang / optional overtime;
- `store`: concrete life spending and Chenjie continuity;
- `park`: first new Week-1 map purpose, free recovery after work;
- `cafe`: rest/social/side-gig map; discoverable Day 2+ once reachable, first proactively explained on Day 3;
- `hospital`: only gets a prompt when health reaches the existing HUD warning region (`<=55`) or another concrete reason exists;
- `alley` / `rooftop`: not actively opened merely to consume Week-1 content.

## Pack A positioning
Accepted `NPC-CONTENT-012` remains accepted source/content only, **not current runtime eligibility**.

All Pack A stays suppressed until `GAME-CONTENT-014` supplies and validates a minute-scale ordinary-city-event path that does not use legacy `_year_pass()`.

A continuity self-review also cross-checked Pack A prose against accepted NPC schedules/time semantics. After GAME-CONTENT-014, the safe Week-1 pool should be deliberately narrower than “all age-22 events”:

### A — safe early candidates after GAME-CONTENT-014
- `e_cw01_cafe_charger` — age 22, no physically scheduled named NPC required;
- `e_cw01_cafe_gossip` — age 22, generic coworker, appropriate after several work days;
- `e_cw01_hospital_medicine` — age 22; Chenjie is a message reference only; use only when the player already has a real hospital reason.

### B — conditional candidates
- `e_cw01_park_free_class` and `e_cw01_park_lost_wallet` physically place Lao Zhou in the event prose. They are eligible only if the eventual ordinary-event path can confirm Lao Zhou is actually present under his schedule/weather rules; otherwise keep them suppressed.
- `e_cw01_cafe_unpaid_trial` is a useful remembered-choice follow-up only after `cw01_lent_cafe_charger` and should not dump in the same in-game day as its seed.
- `e_cw01_park_rain_aunties` is useful only after a safely triggered `cw01_joined_park_class` seed and should not become an immediate same-day chain dump.

### C — suppress in Week 1 unless separately corrected
- `e_cw01_cafe_interview_prep`: prose physically places Lao Zhang in cafe, but his accepted schedule has no cafe slot;
- `e_cw01_hospital_kiosk`: prose physically places Chenjie in hospital while her accepted schedule keeps her at the convenience store;
- `e_cw01_hospital_late_queue`: depends on kiosk and explicitly says 01:00 while current event data has no time-of-day condition;
- `e_cw01_park_recruiter_call`: age min 23;
- `e_cw01_hospital_report`: age min 25;
- all alley/rooftop Pack A: deferred because those maps still lack a stronger Week-1 life reason.

Recommended pacing after GAME-CONTENT-014 is at most one ordinary Pack A spotlight per in-game day during Week 1. If a narrow implementation cannot guarantee that without scope growth, expose fewer events rather than adding another broad event director.

## Files changed
- `docs/design/DAY_2_7_RETENTION_LOOP.md`
- `agent-reports/game-director.md`

Task-specific changes are limited to these two authorized paths. No production Game/data/UI/art/audio files, `main`, `TASK_BOARD.md`, or other coordination files were modified.

## Repository/static validation performed
- Read latest `orchestrator/multi-agent-bootstrap` TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, MASTER_PLAN and AGENT_RULES plus HANDOFF context.
- Confirmed the task branch initially matched accepted DIRECTOR-CONTENT-002 tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f` exactly (`ahead 0 / behind 0`).
- Re-read current q1–q3 data and QuestSystem semantics.
- Re-read `NpcRelations`: +4/day first valid talk, tiers 0/20/45/70, same-day anti-spam and existing `认识` milestone.
- Re-read JobGrowth skill tiers / negotiation coupling.
- Re-read DailyRoutine and current HUD hierarchy/health warning threshold.
- Re-read NPC schedules for Lao Zhang, Chenjie, Lao Zhou, Azhe, Xiaoyu and Daoshi.
- Re-read accepted Pack A producer report/source objects, including age gates, remembered-choice chains and physical named-NPC references.
- Preserved accepted GAME-CONTENT-012 livelihood values.
- Kept GAME-CONTENT-014 as an explicit runtime blocker.
- Reconciled concurrent same-branch work instead of blindly overwriting it and corrected the q1/side-gig inconsistencies before handoff.

## Godot / Web / browser / rendered validation
- Godot: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Rendered UI: **NOT RUN**.
- Animation/audio playback: **NOT RUN**.
- No runtime/build/render/browser/audio PASS is claimed.

DIRECTOR-CONTENT-003 has no `tools/**` write authorization, so it defines a future validation package but does not create or execute the verifier.

## Prepared future validation package
Suggested future `tools/verify_week1_retention.gd` / frozen-SHA QA coverage:

1. Week-1 mode starts only after `onboarding_complete`;
2. Day 2–7 has one current action plus one stable week framing, not stage/q1/dark competing commands;
3. q1–q3 do not evaluate/notify/reward/close during Day 2–7;
4. same-NPC second talk on the same day cannot grind relations;
5. Day 1 plus Day 2–5 meaningful Lao Zhang talks can naturally reach relation 20;
6. park/home/store/office form a complete fallback week even with Pack A disabled;
7. side gig is hidden Day 1, discoverable Day 2+ inside reachable cafe, once/day, while Day 3 is only a spotlight rather than unlock;
8. at least one later-day route may choose not to work/overtime and still continue normally;
9. Day 7 -> Day 8 summary has no fail state and no duplicate reward system;
10. save/load does not return Week-1 state to onboarding;
11. before GAME-CONTENT-014, Pack A remains ineligible;
12. after GAME-CONTENT-014, accepted ordinary events do not `_year_pass()` and remembered-choice flags survive save/load;
13. schedule-dependent Pack A does not fire with the named NPC absent/hidden;
14. spatial/time-conflicting Pack A remains suppressed until repaired;
15. 1280×720 / 960×540 week/current/daily/resources layout is verified only on one frozen integration SHA.

## Known issues / risks
- `TASK_BOARD.md` remains status authority; this report only requests `NEEDS_REVIEW`.
- Day-1 implementation tasks are still prerequisites for coherent Week-1 runtime behavior.
- `GAME-CONTENT-014` remains a hard blocker for Pack A runtime use after onboarding.
- Technical `VISIT_UNLOCKS` may expose destinations earlier than the authored week wants to emphasize. Prefer UI focus/derived hints over a broad LocationManager rewrite; any high-conflict edit requires explicit 00 authorization.
- q1 remains origin-asymmetric and month-worded; final Week-1 design suppresses it rather than editing quest data in this task.
- There is no true weekday/weekend calendar. “Day 2–7” means first seven game days, not Monday–Sunday.
- Xiaoyu roommate/romance/housing canon remains unresolved and untouched.

## Exact handoff to 00
After Day-1 implementation is reviewed, dispatch small independent tasks rather than one Week-1 rewrite:

### 01 Gameplay — `WEEK1-GAME-001`
- derive `week_goal + current_action` from existing day/flags/relations/visited/daily/skill/state; no WeekSystem/save schema;
- keep q1–q3 suppressed through Day 7;
- side gig keeps accepted Day-2+ cafe-local eligibility; Day 3 is only the first authored spotlight;
- Day-2 park / Day-3 choice prompts are advisory, never travel locks;
- Day-7 summary has no fail path/reward currency;
- do not change GAME-CONTENT-012 settlement values;
- keep Pack A runtime work separate behind GAME-CONTENT-014 and use the narrowed A/B/C eligibility after that blocker clears.

### 02 Scene/UI — `WEEK1-UI-001`
- transition from Day-1 L1 to `本周目标 + 当前行动`;
- DailyRoutine stays secondary;
- q1/stage/dark copy cannot reclaim the primary objective area during Week 1;
- route emphasis: park Day 2, cafe discoverable Day 2+ / lightly explained Day 3, hospital only from real health need, no Week-1 alley/rooftop emphasis;
- use a light Day-7 summary from current state rather than inventing new score panels.

### 03 NPC/Content — `WEEK1-CONTENT-001`
- follow `NPC-CONTENT-015` so the same Data.gd lines are not edited concurrently;
- add minimal repeat-contact continuity for Lao Zhang and Chenjie;
- give Lao Zhou a “slowing down is valid” ordinary-life line and Azhe an alternate-life perspective without making either a mandatory quest;
- preserve relation mechanics and avoid numeric-threshold exposition;
- no Xiaoyu canon decision;
- curate/repair schedule-conflicting Pack A before Week-1 runtime rather than adding another event quota.

## Handoff status
`DIRECTOR-CONTENT-003` is complete within its two-file authorization and requests **NEEDS_REVIEW**.

Design correction commit: `dc6bb2f2419cb501ddb18c4a3a0d17a8b1ee55fd`.

Director recommendation: Week-1 success is not “how many maps were opened”. It is whether the player can name one place they use for a reason, one economic tradeoff they deliberately chose, one way work is making them more valuable, and one person who is beginning to recognize them.
