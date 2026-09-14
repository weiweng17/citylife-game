# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-012
- Agent: npc-content
- Branch/worktree: `agent/npc-content-012-city-event-pack-a`
- Status: NEEDS_REVIEW

## Scope
Player-visible City Event Pack A only.

Writable scope:
- `data/events.json`
- `agent-reports/npc-content.md`

No scripts, scenes, schema, coordination files or `main` changes are authorized or made.

Explicitly untouched by this task:
- `e_parent_gone`
- `e_roommate`
- `e_kid_school`
- `e_second_child`
- `e_downsize`
- `e_empty_nest`
- Xiaoyu romance / housing canon

## Baseline / coordination note
- Worker branch initially matched `orchestrator/multi-agent-bootstrap` exactly at `d415ecf165fc6c90d5abf42e5929745d1739acf4` (`ahead 0 / behind 0`).
- During implementation the control-plane branch advanced through metadata/report heartbeats, but its `data/events.json` blob remained unchanged at `7d2460d089668f27058d91c2ceb48517c56afcf9`.
- Therefore the Pack A source delta remains a clean append against the same event-data baseline; no coordination event-data conflict was introduced.

## Implementation
Content commit:
- `fe1625c7a302ac6fc0c902f55145772fa5521580` — `NPC-CONTENT-012 add city event pack A`

The commit appends exactly 20 new `e_cw01_*` event objects to `data/events.json` and does not modify or delete existing event objects.

### Park — 4
1. `e_cw01_park_free_class` — free community exercise class; naturally uses 老周.
2. `e_cw01_park_lost_wallet` — lost wallet / honesty vs money/time tradeoff; naturally uses 老周.
3. `e_cw01_park_rain_aunties` — later acknowledgement of joining the exercise class.
4. `e_cw01_park_recruiter_call` — recruiter call on a park bench; naturally references 老周.

### Cafe — 4
1. `e_cw01_cafe_charger` — charger request; neutral 小雨 message reference.
2. `e_cw01_cafe_interview_prep` — mock interview with 老张.
3. `e_cw01_cafe_unpaid_trial` — later acknowledgement of the charger interaction; unpaid trial-work boundary.
4. `e_cw01_cafe_gossip` — coworker gossip vs restraint / information tradeoff.

### Hospital — 4
1. `e_cw01_hospital_kiosk` — help 陈姐 with the self-service registration kiosk.
2. `e_cw01_hospital_report` — physical-report follow-up; naturally references 老张.
3. `e_cw01_hospital_late_queue` — later acknowledgement of the kiosk-help encounter.
4. `e_cw01_hospital_medicine` — generic vs familiar branded medicine; neutral 陈姐 message reference.

### Alley — 4
1. `e_cw01_alley_rider_shelter` — share rain shelter with a delivery rider; 阿哲 is audible nearby.
2. `e_cw01_alley_secondhand` — second-hand furniture listing shared by 小雨, without romance/housing-state progression.
3. `e_cw01_alley_rain_stall` — later acknowledgement of sharing shelter with the rider.
4. `e_cw01_alley_landlord_repair` — landlord/repair-cost dispute using only existing money/mood/network/skill/health effects.

### Rooftop — 4
1. `e_cw01_rooftop_bedding` — help a neighbor save drying bedding from the wind.
2. `e_cw01_rooftop_bad_review` — after-hours bad-review/customer call.
3. `e_cw01_rooftop_fireworks` — later acknowledgement of helping the bedding neighbor.
4. `e_cw01_rooftop_afterhours` — late-night work-group message; naturally references 老张.

## Deterministic count
- Total Pack A IDs: **20**.
- `park`: **4**.
- `cafe`: **4**.
- `hospital`: **4**.
- `alley`: **4**.
- `rooftop`: **4**.
- All new IDs use prefix `e_cw01_` and are distinct from the pre-existing event ID set.
- Every new event has **3 usable choices**.

## Remembered-choice chains
Five producer events persist an existing-schema flag and five later Pack A events require and acknowledge that flag:

1. `e_cw01_park_free_class`
   - writes `cw01_joined_park_class = true`
   - acknowledged by `e_cw01_park_rain_aunties`
2. `e_cw01_cafe_charger`
   - writes `cw01_lent_cafe_charger = true`
   - acknowledged by `e_cw01_cafe_unpaid_trial`
3. `e_cw01_hospital_kiosk`
   - writes `cw01_helped_hospital_kiosk = true`
   - acknowledged by `e_cw01_hospital_late_queue`
4. `e_cw01_alley_rider_shelter`
   - writes `cw01_shared_rider_shelter = true`
   - acknowledged by `e_cw01_alley_rain_stall`
5. `e_cw01_rooftop_bedding`
   - writes `cw01_helped_rooftop_bedding = true`
   - acknowledged by `e_cw01_rooftop_fireworks`

No new condition key is used: acknowledgement events use the already-supported `cond.flags` mechanism.

## Existing NPC references
Pack A naturally references existing named NPCs in more than the required six events. Examples:
- 老周: `e_cw01_park_free_class`, `e_cw01_park_lost_wallet`, `e_cw01_park_recruiter_call`
- 小雨: `e_cw01_cafe_charger`, `e_cw01_alley_secondhand`
- 陈姐: `e_cw01_hospital_kiosk`, `e_cw01_hospital_medicine`
- 阿哲: `e_cw01_alley_rider_shelter`
- 老张: `e_cw01_cafe_interview_prep`, `e_cw01_hospital_report`, `e_cw01_rooftop_afterhours`

These are ordinary-life references only. In particular, the Xiaoyu references do not establish romance, exclusivity, cohabitation progression or a new roommate canon.

## Choice / cost quality
- Every Pack A event has at least one materially negative cost/downside.
- Choices use only existing supported mutations among `money`, `health`, `mood`, `skill`, `network`, plus optional `flags`.
- No new unsupported effect key, condition key, job value or schema member was introduced.
- Choices intentionally include tradeoffs rather than three positive mood rewards: examples include money vs health, skill vs mood, network vs time/health proxies, and short-term money vs emotional/social cost.
- Ordinary city life remains primary; no new supernatural/dark-line event was added in this pack.

## Repository evidence
- `EventSystem.cond_ok()` currently supports the condition mechanisms used by this pack, including `flags` / `flags_not` and the existing numeric gates.
- `EventSystem._apply_option()` already supports every effect key used by Pack A: `money`, `health`, `mood`, `skill`, `network`, `flags`, and `job` (Pack A does not add new job semantics).
- Content commit diff is append-only in `data/events.json`: GitHub shows the event pack added at the end of the array with no old event deletions or edits.
- Immediately after the content commit, branch comparison showed `data/events.json` as `+720 / -0`; later coordination movement is outside this worker branch and does not change the coordination event-data blob.

## Deferred-policy safety
The content commit does not touch any pre-existing event object, so the explicitly deferred cases remain byte-for-byte outside the Pack A delta:
- `e_parent_gone`
- `e_roommate`
- `e_kid_school`
- `e_second_child`
- `e_downsize`
- `e_empty_nest`

Pack A also does not add a romance or housing-state condition around Xiaoyu.

## Known content risk for review
`e_cw01_alley_landlord_repair` intentionally follows the accepted wave-plan subject “landlord repair dispute” and assumes a rented-space context inside that one event. It does **not** alter `e_roommate`, Xiaoyu housing canon, or any housing schema/flag. If playtest/QA requires strict homeowner/local-home exclusion, the smallest follow-up would be an event-local existing `flags_not` eligibility gate; that policy tightening is not silently added here because the current task explicitly forbids deciding unresolved housing canon.

## Files changed
- `data/events.json`
- `agent-reports/npc-content.md`

No other source/data/script/schema file is intentionally changed by NPC-CONTENT-012.

## Validation / execution boundary
Repository-level inspection performed:
- task/ownership/launchpad contract read from the latest control branch;
- worker branch was checked against coordination before writing;
- event schema and supported condition/effect keys were inspected from current `EventSystem.gd`;
- existing NPC names were cross-checked against `Data.gd`;
- content commit diff inspected to confirm append-only event-data scope;
- Pack A IDs, location grouping, remembered-choice pairs and NPC-reference coverage manually audited from repository text.

Not run in this web-worker task:
- Godot 4.7.2: **NOT RUN**
- terminal JSON parser: **NOT RUN**
- Web export/browser: **NOT RUN**
- rendered/UI runtime: **NOT RUN**

No parser, Godot, runtime, render, build or browser PASS is claimed. Exact parser/runtime acceptance belongs to QA-CONTENT-014 / QA-002 on the frozen integration SHA.

## Handoff
NPC-CONTENT-012 requests **NEEDS_REVIEW**.

Pack A is repository-complete within the authorized two-file boundary: exactly 20 new ordinary-life events, 4 per target location, five remembered-choice acknowledgement chains, and more than six natural existing-NPC references, with no script/schema or deferred-policy event edits.