# Game Director Agent Report

## Task
- ID: `DIRECTOR-CONTENT-003`
- Agent: `07-Game-Director`
- Branch/worktree: `agent/director-content-003-day2-7-retention`
- Status: `NEEDS_REVIEW`
- Priority: MEDIUM
- Baseline: accepted `DIRECTOR-CONTENT-002` tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`
- Review responded to: 00 latest reviewed worker tip `dc6bb2f2419cb501ddb18c4a3a0d17a8b1ee55fd`, disposition `minimal correction required`.

## Current coordination freshness check
- Latest coordination TASK_BOARD read for this resubmission: blob `a7e35324fb5e81ce03b75c797caa10408517d4cb`.
- That board still shows `DIRECTOR-CONTENT-003` as `IN_PROGRESS` and still cites the older reviewed worker tip `dc6bb2f...`; it has not yet consumed the later correction submission.
- Re-read latest `FILE_OWNERSHIP` and `WEB_AGENT_LAUNCHPAD`; writable scope remains exactly `docs/design/DAY_2_7_RETENTION_LOOP.md` plus `agent-reports/game-director.md`.
- Recompared the task branch from accepted DIRECTOR-CONTENT-002 baseline: the complete task delta is still limited to those two authorized paths.
- Re-scanned the current design document for the correction examples named by 00. `e_cw01_hospital_kiosk` now appears only in the Week-1 suppress class; `e_cw01_park_free_class` / `e_cw01_park_lost_wallet` are only conditionally eligible with actual Lao-Zhou schedule/weather presence; the broader contradictory recommendations are gone.
- No new product-direction change was introduced in this freshness pass. This resubmission exists so 00 can review the corrected current branch tip rather than the stale `dc6bb2f...` snapshot.

## Review-blocker closure
00's blocker was that the report had narrowed Week-1 Pack A eligibility after schedule/time continuity review while the design document still contained broader examples. That ambiguity is now removed.

`docs/design/DAY_2_7_RETENTION_LOOP.md` is synchronized to the same A/B/C rules below:
- Lao-Zhou park events require **actual Lao Zhou presence under existing schedule/weather** or remain suppressed;
- `e_cw01_cafe_interview_prep`, `e_cw01_hospital_kiosk`, and `e_cw01_hospital_late_queue` are **Week-1 suppressed until their spatial/time continuity is corrected**;
- age gates remain authoritative;
- remembered-choice follow-ups require later-day pacing, not same-day chain dumping;
- recommended density remains at most one ordinary Pack A spotlight per in-game day;
- before `GAME-CONTENT-014`, Week-1 Pack A runtime eligibility remains **0/20**.

There is no longer a “report overrides contradictory design” rule. The design document and this report now state one implementation contract.

## Authoritative Week-1 Pack A eligibility table

This table is the single review/handoff summary. The detailed rationale is in design section `# 8. Pack A：首周候选，但当前仍全部 BLOCKED`.

| Event / group | Week-1 eligibility after GAME-CONTENT-014 | Required context | Reason / rule |
| --- | --- | --- | --- |
| `e_cw01_cafe_charger` | **A — default candidate** | cafe reachable | age 22; no physically scheduled named NPC required; small ordinary-life seed |
| `e_cw01_cafe_gossip` | **A — default candidate** | cafe reachable; preferably after several work days | age 22; generic coworker; no spatial schedule contradiction |
| `e_cw01_park_free_class` | **B — conditional** | Lao Zhou must be physically present in park and not weather-hidden | prose places Lao Zhou on scene; current event schema alone cannot prove presence |
| `e_cw01_park_lost_wallet` | **B — conditional** | Lao Zhou must be physically present in park and not weather-hidden | same spatial continuity rule as free class |
| `e_cw01_park_rain_aunties` | **B — conditional follow-up** | parent flag exists **and event occurs on a later day** | remembered-choice continuation; no same-day chain dump |
| `e_cw01_cafe_unpaid_trial` | **B — conditional follow-up** | `cw01_lent_cafe_charger` exists **and event occurs on a later day** | remembered-choice continuation; no same-day chain dump |
| `e_cw01_park_recruiter_call` | **C — suppress Week 1** | — | age min 23; default first week remains age 22 |
| `e_cw01_cafe_interview_prep` | **C — suppress Week 1** | needs separate continuity correction | physically places Lao Zhang in cafe; accepted schedule has no cafe slot; also premature next-job framing |
| `e_cw01_hospital_kiosk` | **C — suppress Week 1** | needs separate continuity correction | physically places Chenjie in hospital while accepted schedule keeps her in store |
| `e_cw01_hospital_report` | **C — suppress Week 1** | — | age min 25 |
| `e_cw01_hospital_late_queue` | **C — suppress Week 1** | needs separate time/parent correction | depends on kiosk and says 01:00; ordinary event data has no hour gate |
| `e_cw01_hospital_medicine` | **C — suppress Week 1** | needs a real persisted prescription/clinic qualification | message reference is spatially safe, but current clinic activity does not persist “has prescription” |
| all 4 alley Pack A | **C — suppress Week 1** | existing story/night/clue route only | do not break map story lock to consume event inventory |
| all 4 rooftop Pack A | **C — suppress Week 1** | existing age/dark route only | do not break map story lock to consume event inventory |

Global rule: **the entire table is dormant until `GAME-CONTENT-014` is accepted and QA later proves ordinary-city event completion no longer advances age/year while legacy annual semantics remain intact.**

## Day 2–7 retained product contract
The accepted Day-1 spine remains unchanged. Day 2–7 asks:

> **“这座城市有没有开始出现一点属于我的规律？”**

The single weekly framing remains:

> **本周：把“新来的”过成“能留下的人”。**

It uses three existing-state anchors, with no WeeklySystem or new save field:
1. **work** — repeat a real post-onboarding ordinary work day;
2. **person** — any ordinary-life NPC reaches existing `认识` (`relation >= 20`);
3. **place** — after onboarding, actually use park or cafe as a non-work destination.

Missing anchors on Day 7 change the summary only; they never fail, terminate, or lock the player.

### Authored rhythm
- **Day 2:** run the ordinary loop without tutorial hand-holding; park gains an authored purpose as free recovery.
- **Day 3:** explain that money/time can be traded in more than one way; cafe side gig may already be discovered after onboarding once cafe is reachable, while Day 3 is only the first proactive hint.
- **Day 4:** deliberately revisit a person rather than collect NPCs.
- **Day 5:** surface existing JobGrowth meaning and give home study a strategic reason.
- **Day 6:** reserve part of the day outside the company; existing life maps remain legal choices.
- **Day 7:** translate current state into a non-failing week summary and a second-week hook around work value / eventual salary negotiation.

## HUD / quest hierarchy
After first-night `onboarding_complete`:
1. **当前：...** — exactly one immediate action;
2. **本周：把“新来的”过成“能留下的人”。** — weak persistent direction;
3. DailyRoutine — weak recap;
4. resources / skill — instrumentation;
5. 22–60-year stage/dark targets stay outside Week-1 primary HUD.

Final q1/q2/q3 contract:
- **q1 resumes normally on Day 2**; it stays secondary to `本周 + 当前` and is not a Day-7 requirement;
- q1's month-worded closing is a follow-up NPC/Content copy issue only, not a reason to re-suppress q1;
- **q2 may arise naturally**, but successful salary negotiation is not a Week-1 hard goal;
- **q3 is not a Week-1 director objective** and cannot be used to decide Xiaoyu roommate/romance/housing canon.

## Map-purpose rules
- home: food / sleep / study / grounding;
- subway: commute / optional Azhe continuity;
- office: income / skill / Lao Zhang / optional overtime;
- store: life spending / Chenjie;
- park: first non-work map reason; useful even when Lao Zhou is absent;
- cafe: coffee / idle / accepted side gig; no new Day-3 unlock gate;
- hospital: spotlight only from a real health reason, recommended at existing health warning `<=55`;
- alley / rooftop: not opened for Week-1 content inventory.

## Files changed
Authorized task delta only:
- `docs/design/DAY_2_7_RETENTION_LOOP.md`
- `agent-reports/game-director.md`

No Game/data/UI/art/audio production file, `main`, `TASK_BOARD.md`, or other coordination file was modified.

## Repository/static validation performed
- Re-read latest coordination `TASK_BOARD`, `FILE_OWNERSHIP`, and `WEB_AGENT_LAUNCHPAD`.
- Confirmed 00's current correction blocker and exact two-file writable scope.
- Re-read current branch design/report rather than repeating DIRECTOR-CONTENT-002.
- Searched the current design for the previously conflicting Pack A examples: `hospital_kiosk` now appears only in the suppress class; `park_free_class / park_lost_wallet` appear only under schedule/weather-aware conditional eligibility.
- Confirmed design still retains the GAME-CONTENT-014 blocker, age gates, later-day remembered-choice pacing, map-lock rules and one-event/day pacing recommendation.
- Reconfirmed q1 Day-2 release and cafe side-gig no-new-gate rules remain aligned with the accepted Day-1 contract.
- Recompared current branch against `cebc2c868...`: only the authorized design/report files differ.

## Runtime / build boundary
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Rendered UI: **NOT RUN**.
- Animation/audio playback: **NOT RUN**.
- No runtime/build/render/browser/audio PASS is claimed.

003 has no `tools/**` write authorization, so it only defines the future verifier contract.

## Prepared future validation package
Suggested future `tools/verify_day2_7_retention.gd` / frozen-SHA QA coverage:
1. Week-1 begins only after successful first-night `onboarding_complete`;
2. week anchors derive from existing state/save; no new save key;
3. q1 resumes Day 2 but cannot replace Week-1 `本周/当前` hierarchy;
4. q2 remains optional; q3 cannot become Week-1 director objective;
5. one valid NPC conversation/day remains +4 and same-day repeat cannot grind relation;
6. park remains useful without Lao Zhou;
7. cafe uses existing `park -> cafe` unlock; side gig gains no new Day-3 eligibility gate;
8. health warning can recommend hospital but healthy players are not sent there as tourists;
9. alley/rooftop remain under existing story locks;
10. before GAME-CONTENT-014, Pack A Week-1 eligibility is 0/20;
11. after 014, A candidates never advance age/year and legacy annual semantics remain intact;
12. B Lao-Zhou events never fire while Lao Zhou is absent/weather-hidden;
13. remembered-choice follow-ups cannot fire in the same in-game day as their seed;
14. C candidates remain suppressed until their stated continuity/premise blocker is explicitly corrected;
15. at most one ordinary Pack A spotlight/day during Week 1, or expose fewer events if that cap would cause scope growth;
16. Day-7 0/1/2/3-anchor states all summarize without failure/terminal behavior;
17. 1280×720 / 960×540 and Web/browser evidence are accepted only on one frozen integration SHA.

## Handoff to 00
If this correction is accepted, the next implementation split remains narrow:

### 01 Gameplay — `WEEK1-GAME-001`
- derive work/person/place anchors + one current action from existing state; no new WeekSystem/save schema;
- q1 resumes Day 2 but remains secondary; q2 optional; q3 cannot replace Week-1 objective;
- no new side-gig Day-3 gate;
- Day-7 non-failing summary;
- keep Pack A behind GAME-CONTENT-014, then enforce the authoritative A/B/C table above.

### 02 Scene/UI — `WEEK1-UI-001`
- transition after onboarding to `本周 + 当前`;
- DailyRoutine secondary; q1 weak detail only;
- map hints communicate reasons without changing unlock semantics;
- light Day-7 summary; frozen-SHA rendered verification later.

### 03 NPC/Content — `WEEK1-CONTENT-001`
- neutralize q1 closing's premature “这个月” wording without changing mechanics/reward;
- make q2 relation copy life-like rather than numeric-grind copy;
- repeat-contact continuity for Lao Zhang / Chenjie after Day-1 recognition pass;
- no Xiaoyu canon decision;
- do not add another event quota; continuity repairs to C events require separate narrow work.

## Handoff status
`DIRECTOR-CONTENT-003` has closed the current 00 correction blocker within its two-file authorization and requests **NEEDS_REVIEW**.

Director recommendation: Week-1 success is not “how many maps opened”. It is whether the player can name one place they use for a reason, one economic tradeoff they deliberately chose, one way work is making them more valuable, and one person who is beginning to recognize them.