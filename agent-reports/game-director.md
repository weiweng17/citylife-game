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

The Day-1 spine remains unchanged. Day 2–7 now has a separate retention question:

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

`laozhang >= 20 OR chenj ie >= 20` (implementation key: `chenjie`).

This does not require a new WeeklySystem or save field. Existing `NpcRelations` already gives +4 only on the first completed conversation with an NPC each day, relation 20 is the existing `认识` tier, and the current milestone text says the NPC remembers the player's face. A player therefore needs five meaningful conversations across the week, not same-day grinding. The goal has no failure state at Day 7.

### Day 2
After an ordinary work shift, park is the first new authored reason:

- office overtime = more money / more status cost;
- park = no money / recovery.

Old Zhou is optional because his current 11:30–15:00 schedule gap makes him unsuitable as a deterministic Day-2 gate.

### Day 3
Cafe becomes an authored opportunity only after the player has first used park as a real life location. The recommended derived reveal rule is:

`onboarding_complete && day >= 3 && park visited`.

The accepted cafe side gig then becomes an optional route, not a mandatory task. Coffee / idle / side gig make the same map support three different priorities. Azhe remains an optional schedule reward around 12:00–14:00, never a gate.

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

No fixed-rent mechanic or artificial health damage was introduced to force map use.

### Day 7
The week closes without a fail state.

If Lao Zhang or Chenjie has reached the existing `认识` tier, the player gets the emotional summary: the city is still large, but somebody recognizes them. If not, the summary explicitly says the player knows the route now but still has time next week to build a real connection.

The second-week hook is work value rather than map completion: skill growth, a deeper Lao Zhang relationship, and eventual salary negotiation.

## Pack A positioning
Accepted `NPC-CONTENT-012` is treated as accepted source/content only, not current runtime eligibility.

The design keeps **all Pack A suppressed until `GAME-CONTENT-014` separates ordinary city-event minute-scale completion from legacy `_year_pass()`**.

Once that blocker is accepted/integrated/validated, first-week priority candidates are:

- Park: `e_cw01_park_free_class`, `e_cw01_park_lost_wallet`, then `e_cw01_park_rain_aunties` after its real prerequisite.
- Cafe: `e_cw01_cafe_charger`, `e_cw01_cafe_gossip`, `e_cw01_cafe_interview_prep`, then `e_cw01_cafe_unpaid_trial` after its remembered-choice prerequisite.
- Hospital only when the player has a real reason to be there: `e_cw01_hospital_kiosk`, `e_cw01_hospital_medicine`, then `e_cw01_hospital_late_queue` after its prerequisite.

Explicit first-week deferrals:

- `e_cw01_park_recruiter_call` has age min 23;
- `e_cw01_hospital_report` has age min 25;
- alley/rooftop Pack A remains deferred because the maps do not yet have a stronger first-week life reason than park/cafe/hospital.

This map never treats “recommended on Day N” as a forced calendar event. Location purpose comes first; Pack A is a variation layer only after its runtime time semantics are safe.

## HUD transition
After onboarding, the first-week hierarchy becomes:

1. **当前行动** — immediate reason to act;
2. **本周目标** — one relationship-scale motivation;
3. DailyRoutine — weak daily progress/status;
4. q1–q3 — backend/task-detail progression, not another persistent high-priority HUD command;
5. 22–60-year stage/dark-line objective wall remains out of the Week-1 primary HUD.

q1 is not repurposed as the universal Week-1 goal because its fixed skill>=55 / money>=3000 conditions have sharply different difficulty by origin and its closing copy is month-scale. q2 may arise naturally for fast progress but salary negotiation is not forced by Day 7. q3 is not used as a Week-1 director goal because it still encodes unresolved Xiaoyu roommate/home semantics.

## Files changed
- `docs/design/DAY_2_7_RETENTION_LOOP.md`
- `agent-reports/game-director.md`

No Game/data/UI/art/audio production files, `main`, `TASK_BOARD.md`, or other coordination files were modified by DIRECTOR-CONTENT-003.

## Repository/static validation performed
- Read latest `orchestrator/multi-agent-bootstrap` TASK_BOARD, FILE_OWNERSHIP and WEB_AGENT_LAUNCHPAD.
- Confirmed the branch started exactly from accepted DIRECTOR-CONTENT-002 final tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.
- Confirmed task authorization is only the two files above.
- Re-read current q1–q3 data and QuestSystem semantics.
- Re-read current `NpcRelations`: +4/day first valid talk, tiers 0/20/45/70, same-day anti-spam and existing `认识` milestone.
- Re-read current NPC schedules: Chenjie 07:00–23:00 store; Lao Zhang office 08:00–12:00 and 13:00–19:30 plus evening subway; Lao Zhou park time windows; Azhe subway/cafe schedule; Xiaoyu home schedule; Daoshi alley nights.
- Re-read DailyRoutine and current HUD hierarchy.
- Re-read accepted Pack A source objects on the accepted NPC-CONTENT-012 branch, including age gates and remembered-choice chains.
- Preserved accepted GAME-CONTENT-012 livelihood values rather than redesigning economy.
- Kept `GAME-CONTENT-014` as an explicit runtime blocker instead of claiming Pack A is playable after onboarding.

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
9. q1–q3 backend progression cannot replace the Week-1 current-action/week-goal hierarchy;
10. no authored Week-1 alley/rooftop/Daoshi requirement;
11. save/load preserves all existing state from which Week-1 UI is derived.

After `GAME-CONTENT-014` only, additionally verify:

- `e_cw01_*` completion never advances age/year;
- legacy annual event year semantics remain intact;
- recommended park/cafe/conditional-hospital events trigger safely;
- remembered-choice prerequisite flags survive save/load.

Manual frozen-SHA play paths should include one balanced route and one money-first overtime/side-gig route and compare whether the latter earns more at a visible time/health/mood cost.

## Known issues / risks
- TASK_BOARD remains status authority; this report only requests `NEEDS_REVIEW`.
- Day-1 production implementation (`GAME-CONTENT-013`, first-day UI/content tasks) is still a prerequisite for this map to become a coherent runtime sequence.
- `GAME-CONTENT-014` remains a hard blocker for Pack A runtime use even after onboarding.
- The current technical visit-unlock chain may expose destinations earlier than the authored week wants to emphasize. Week-1 implementation should prefer UI focus/derived hints over a broad LocationManager rewrite; any high-conflict edit requires explicit 00 authorization.
- q1 remains origin-asymmetric and month-worded; this task intentionally does not edit quest data.
- Xiaoyu roommate/romance/housing canon remains unresolved and untouched.
- There is no true weekday/weekend calendar mechanic. “Day 2–7 / first week” here means the first seven game days, not Monday–Sunday; no weekend work rule is invented.

## Handoff to 00
After Day-1 implementation is reviewed, dispatch small independent tasks rather than one Week-1 rewrite:

### 01 Gameplay — `WEEK1-GAME-001`
- expose Week-1 derived goal state from existing relations/day/visited;
- cafe authored reveal uses onboarding + day>=3 + park visited;
- Day-2 park / Day-3 cafe are hints, not hard travel locks;
- Day-7 summary state has no fail path;
- do not change GAME-CONTENT-012 settlement values or add save schema.

Keep `GAME-CONTENT-014` separate and complete it before allowing Pack A runtime events.

### 02 Scene/UI — `WEEK1-UI-001`
- transition HUD to `本周目标 + 当前行动` after onboarding;
- DailyRoutine stays secondary;
- q1/stage/dark copy does not reclaim the primary objective area;
- route emphasis: park Day2, cafe Day3+, hospital only from real health need, no Week-1 alley/rooftop emphasis;
- light Day-7 summary using current state only.

### 03 NPC/Content — `WEEK1-CONTENT-001`
- minimal repeat-contact continuity for Lao Zhang and Chenjie after the first-day recognition micro-pass;
- preserve relation mechanics and avoid numeric-threshold exposition;
- Lao Zhou/Azhe remain optional life texture, not mandatory Week-1 quests;
- no Xiaoyu canon decision;
- consume accepted Pack A rather than adding another event quota before the loop is played.

## Handoff status
`DIRECTOR-CONTENT-003` is complete within its two-file authorization and requests **NEEDS_REVIEW**.

Design document commit: `dfcd8d75223faa8ff56dc36f04589496e29bc221`.

Director recommendation: implement and play this Week-1 loop only after the Day-1 spine is stable. The product metric is not “how many maps were opened by Day 7”; it is whether the player can name at least one place they use for a reason, one economic tradeoff they deliberately chose, and one person in the city who now recognizes them.