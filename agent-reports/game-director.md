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

The accepted Day-1 spine remains unchanged. Day 2–7 answers:

> **“这座城市有没有开始出现一点属于我的规律？”**

The single weekly motivation is:

> **本周：把“新来的”过成“能留下的人”。**

It is expressed through three derived, non-failing anchors rather than a new WeeklySystem:

1. **work** — repeat an ordinary post-onboarding work day;
2. **person** — any ordinary-life NPC reaches the existing `认识` tier (`relation >= 20`);
3. **place** — after onboarding, actually use `park` or `cafe` as a non-work destination.

All three use existing quest/day/relations/visited state. No new save schema is proposed. Missing anchors on Day 7 only change the summary/recommendation; they do not fail or lock the player.

## Day 2–7 authored rhythm
- **Day 2:** complete an ordinary day without tutorial hand-holding; park gains its first authored purpose as free recovery. Old Zhou is not a gate because his 11:30–15:00 schedule gap and storm hiding make a post-work encounter non-deterministic.
- **Day 3:** cafe becomes the first spotlight for a different money/time choice once it is reachable through the existing `park -> cafe` chain. The accepted cafe side gig does **not** gain a new Day-3 unlock; an exploring player may discover it earlier after onboarding. Day 3 is only the first proactive hint.
- **Day 4:** deliberately revisit a person rather than collect NPCs. Lao Zhang / Chenjie are the main repeat anchors; Lao Zhou / Azhe remain optional city texture.
- **Day 5:** surface existing JobGrowth meaning and give home study a strategic reason: spend an hour becoming more valuable instead of earning or recovering.
- **Day 6:** reserve part of the day outside the company; park/cafe/home/store/work remain legal choices.
- **Day 7:** translate the three anchors into a short non-failing week summary and a second-week hook around work value / eventual salary negotiation.

## HUD transition
After first-night `onboarding_complete`, the hierarchy becomes:

1. **当前：...** — exactly one immediate action;
2. **本周：把“新来的”过成“能留下的人”。** — weak persistent direction, optionally showing the three derived anchors;
3. DailyRoutine — weak daily recap, not four simultaneous commands;
4. money/health/mood/fullness/energy/time/weather/skill — instruments;
5. 22–60-year stages and dark-line targets remain outside the Week-1 primary HUD.

## q1 / q2 / q3 — final contract correction
A concurrent draft had proposed keeping q1–q3 suppressed through Day 7. That would silently contradict accepted DIRECTOR-CONTENT-002 / `GAME-CONTENT-013`, whose suppression applies **during onboarding** and whose first successful full-night sleep releases onboarding.

Final contract:

- **q1 resumes normally on Day 2** using existing QuestSystem behavior, but stays secondary to `本周 + 当前`; Day 7 does not require q1 completion.
- q1 closing currently says “这个月”; fast origins may finish during the first week, so the follow-up content task should make that copy week-neutral without changing mechanics/reward.
- **q2 may arise naturally** for fast progress, but salary negotiation is not a Week-1 hard goal. Relation 20 is useful as a human milestone; real negotiation still depends on skill/network and Lao Zhang only gives mechanical help at relation 45.
- **q3 is not a Week-1 director objective.** If an extreme path activates it early, it must not replace the Week-1 HUD or be used to decide new Xiaoyu roommate/romance/housing canon.

## Map-purpose decisions
- `home`: food / sleep / study and daily grounding.
- `subway`: commute; Azhe can recur as ambient life.
- `office`: income, skill growth, Lao Zhang, optional overtime.
- `store`: food/backpack, Chenjie.
- `park`: first non-work destination; free recovery; Old Zhou only when schedule/weather permits.
- `cafe`: coffee/idle/accepted side gig; Azhe may appear 12:00–14:00.
- `hospital`: only spotlight from a real health reason; recommended when health enters warning (`<=55`).
- `alley` / `rooftop`: **not Week-1 destinations**; existing story unlocks remain intact and are not broken to consume Pack A inventory.

## Cafe side-gig placement
Accepted GAME-CONTENT-012 values remain unchanged.

Final director rule:
- hidden during onboarding / Day 1 per Day-1 implementation;
- after `onboarding_complete`, if cafe is reachable through existing map logic, the interaction may be discovered normally;
- **no new `day >= 3` eligibility gate**;
- Day 3 is the first authored global hint because the player now understands ordinary work/overtime and can interpret side gig as an alternative rather than a second tutorial job button.

## Pack A — final Week-1 eligibility curation
Accepted `NPC-CONTENT-012` remains accepted source/content only. **All 20 Pack A events remain runtime-suppressed until `GAME-CONTENT-014` separates ordinary city-event minute-scale completion from legacy `_year_pass()` and the path is later QA-validated.**

After that blocker clears:

### A — safe default Week-1 candidates
- `e_cw01_cafe_charger` — age 22, small ordinary-life scale, no physically scheduled named NPC required.
- `e_cw01_cafe_gossip` — age 22, generic coworker, appropriate after several work days.

### B — good candidates only if existing context can be proven
- `e_cw01_park_free_class`
- `e_cw01_park_lost_wallet`

Both physically place Lao Zhou in the prose. They are safe only if the routing layer can confirm Lao Zhou is currently present at park under existing schedule/weather state. Otherwise keep them suppressed.

- `e_cw01_park_rain_aunties` — only after its parent flag and on a later day; without safe cross-day pacing, defer.
- `e_cw01_cafe_unpaid_trial` — only after `cw01_lent_cafe_charger` and on a later day; without safe cross-day pacing, defer.

### C — suppress in Week 1
- `e_cw01_park_recruiter_call` — age min 23; default first week remains age 22.
- `e_cw01_cafe_interview_prep` — puts Lao Zhang physically in cafe although his accepted schedule has no cafe slot; also premature next-job framing.
- `e_cw01_hospital_kiosk` — puts Chenjie physically in hospital while her accepted 07:00–23:00 schedule keeps her in store.
- `e_cw01_hospital_report` — age min 25.
- `e_cw01_hospital_late_queue` — depends on kiosk and explicitly assumes 01:00 while ordinary event data has no hour gate.
- `e_cw01_hospital_medicine` — Chenjie is only a message reference, but the event assumes an existing prescription and current clinic activity persists no such qualification; do not random-trigger it in Week 1.
- all alley Pack A — map remains story/night/clue gated.
- all rooftop Pack A — map remains age/dark gated.

The curation intentionally prefers fewer coherent events over opening more accepted content at the cost of spatial/time continuity.

## Files changed
- `docs/design/DAY_2_7_RETENTION_LOOP.md`
- `agent-reports/game-director.md`

No Game/data/UI/art/audio production file, `main`, `TASK_BOARD.md`, or other coordination file was modified by DIRECTOR-CONTENT-003.

## Repository/static validation performed
- Read latest `orchestrator/multi-agent-bootstrap` TASK_BOARD, FILE_OWNERSHIP and WEB_AGENT_LAUNCHPAD.
- Confirmed authorization is exactly the two files above.
- Confirmed task branch baseline is accepted DIRECTOR-CONTENT-002 exact tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.
- Re-read current `DailyRoutine`, q1–q3 data, QuestSystem contract, `NpcRelations`, `JobGrowth`, NPC schedules, LocationManager visit/story unlocks, Game ordinary-event closure, and existing park/cafe/hospital activities.
- Re-read accepted Pack A source events and cross-checked age, physical named-NPC premises, schedule/time continuity and remembered-choice dependencies.
- Reconciled concurrent same-branch draft work instead of discarding it, then corrected q1 release, cafe side-gig eligibility and Pack-A continuity inconsistencies before handoff.

## Godot / Web / browser / rendered validation
- Godot: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Rendered UI: **NOT RUN**.
- Animation/audio playback: **NOT RUN**.
- No runtime/build/render/browser/audio PASS is claimed.

003 has no `tools/**` authorization, so no executable verifier was added.

## Prepared future validation package
Suggested future `tools/verify_day2_7_retention.gd` / frozen-SHA QA coverage:

1. Week-1 mode begins only after successful first-night `onboarding_complete`;
2. week anchors derive from existing state and survive save/load; no new save key;
3. q1 resumes Day 2, but Day-1 onboarding work/meal do not chain-jump q1;
4. q1/q2 backend progression cannot replace the Week-1 `本周/现在` hierarchy; q3 cannot become the Week-1 director objective;
5. one valid NPC conversation/day remains +4; same-day repeats cannot grind; relation 20 still uses existing `认识` milestone;
6. Day-2 park suggestion is advisory; park remains useful even when Lao Zhou is absent/storm-hidden;
7. cafe unlock remains existing `park -> cafe`; side gig is discoverable after onboarding whenever cafe is reachable, with Day 3 only a spotlight;
8. ordinary work/overtime/side-gig accepted values and once/day behavior remain unchanged;
9. health warning can recommend hospital, but healthy players are not routed there as tourists;
10. alley/rooftop are not opened for Week-1 content;
11. before GAME-CONTENT-014, Pack A Week-1 runtime eligibility remains 0/20;
12. after 014, A candidates complete without age/year advance and legacy annual semantics remain intact;
13. B park candidates never fire while Lao Zhou is absent/hidden;
14. remembered-choice follow-ups do not dump on the same day if later-day pacing is accepted;
15. Day-7 0/1/2/3 anchor states all summarize without fail/terminal behavior;
16. 1280×720 and 960×540 `本周 + 当前` hierarchy is readable;
17. Web/browser/render evidence remains tied to one frozen integration SHA.

## Known issues / risks
- `TASK_BOARD.md` remains status authority; this report requests `NEEDS_REVIEW` only.
- Day-1 production implementation (`GAME-CONTENT-013` and corresponding UI/content work) is a prerequisite for a coherent runtime transition.
- `GAME-CONTENT-014` remains a hard blocker for any Pack A runtime use.
- Current technical map unlocks may expose destinations earlier than the authored week emphasizes; prefer UI/current-action focus over a broad LocationManager rewrite.
- q1 is origin-asymmetric and its closing copy is month-worded; this task intentionally does not edit quest data.
- There is no weekday/weekend calendar; “Day 2–7” means the first seven game days, not Monday–Sunday.
- Xiaoyu / family / rent / supernatural marketing decisions remain deferred and untouched.

## Handoff to 00
After Day-1 implementation is accepted, dispatch three small tasks:

### 01 Gameplay — `WEEK1-GAME-001`
- derive work/person/place anchor state and exactly one `current_action` from existing state; no WeekSystem/save schema;
- resume q1 on Day 2; keep q1/q2 secondary to Week-1 HUD and prevent q3 from replacing the director objective;
- side gig adds no Day-3 eligibility gate; spotlight only;
- health-warning hospital override;
- Day-7 non-failing anchor summary;
- keep Pack A fully suppressed behind GAME-CONTENT-014, then route only curated A/B candidates under their continuity rules;
- preserve livelihood values, story map locks and terminal ordering.

### 02 Scene/UI — `WEEK1-UI-001`
- transition after onboarding to `本周目标 + 当前行动`;
- show three anchors as small state only, DailyRoutine as secondary recap;
- q1 may be weak detail but not primary; stage/dark objective wall remains hidden;
- highlight map reasons without changing unlock semantics;
- light Day-7 summary; no new large weekly UI;
- verify 1280×720 and 960×540 later on frozen SHA.

### 03 NPC/Content — `WEEK1-CONTENT-001`
- change q1 closing “这个月” to first-week-neutral wording only; do not change mechanics/reward;
- make q2 relation copy life-like instead of exposing “好感20” as grind instruction;
- minimal repeat-contact continuity for Lao Zhang/Chenjie after the first-day recognition micro-pass;
- Lao Zhou/Azhe stay optional; no Xiaoyu canon decision;
- do not add another event quota or rewrite accepted Pack A in this task.

## Handoff status
`DIRECTOR-CONTENT-003` is complete within its two-file authorization and requests **NEEDS_REVIEW**.

Director recommendation: implement this loop only after the Day-1 spine is stable. The product metric is not “how many maps opened by Day 7”; it is whether the player can name one place they use for a reason, one economic tradeoff they deliberately chose, and one person who now recognizes them.
