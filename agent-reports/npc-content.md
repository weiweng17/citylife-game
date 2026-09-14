# NPC/Content Agent Report

## Task
- ID: NPC-AUDIT-009
- Agent: npc-content
- Branch/worktree: `agent/npc-audit-009-speaker-premise-triage`
- Status: NEEDS_REVIEW

## Scope
Report-only triage of remaining non-family-policy speaker/premise assumptions. The only writable path for this task is `agent-reports/npc-content.md`.

No event/quest/NPC data, speakers, conditions, IDs, flags, rewards/effects, counters, schema, scripts, schedules, flow, coordination files, or `main` changes are authorized or made.

Explicitly outside this task:
- the four deferred spouse/child policy cases: `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`;
- already accepted NPC-CONTENT-002..008 work, including the two NPC-CONTENT-008 mother-specific copy fixes.

## Baseline
- Latest coordination branch at audit start: `86ea90c9742b31c8d562199f873ea0d0a6ca5a95`.
- Before this report update, `agent/npc-audit-009-speaker-premise-triage` matched `orchestrator/multi-agent-bootstrap` exactly (`ahead 0 / behind 0`).
- NPC-CONTENT-008 is already marked DONE/accepted by the current task board; stale pre-integration strings still visible in the metadata-oriented coordination data are not re-counted here.

Inspected repository blobs include:
- `data/events.json`: `7d2460d089668f27058d91c2ceb48517c56afcf9`
- `data/quests.json`: `3e2a6d460faeb8893e27279f8c3cbb825ab24627`
- `scripts/Data.gd`: `16fa43074421ed7e6553a37af5a8cec1368f9c74`
- `scripts/systems/EventSystem.gd`: `628e18a0a1cbb0f67e63d0f25486713dd1a451d8`
- `scripts/GameState.gd`: `7fd26e69889753ac39197b42dcc018f2ecd7925f`
- `scripts/systems/NPCScheduleSystem.gd`: `88cc5ee8b073000352c3bd8dcae63e5372992638`
- `data/npc_schedules.json`: `1f9ff6441548fd60ef99852f1e40eacaab72f63e`

## Triage definitions
For this audit:

- **SAFE COPY-ONLY**: the unsupported specificity can be removed by changing string values only, while all eligibility, effects, flags, counters, jobs and flow remain semantically correct.
- **CONDITION / STATE-SCHEMA DEPENDENT**: a relationship premise is also encoded by a mechanic/flag, or correctness requires state the repository does not currently establish before the event.
- **PRODUCT-POLICY DEPENDENT**: more than one internally coherent world-model is possible and the repository does not define which one is intended; choosing code/data changes before that decision risks encoding the wrong canon.

`EventSystem.cond_ok()` can gate on numeric values, job, arbitrary `flags` / `flags_not`, and origin flags. `GameState.reset_from_origin()` currently seeds only the selected origin flag; there is no seeded parent/sibling/shared-rent lifecycle state. NPC relationship scores exist for named core NPCs, but family speakers in these events are not represented as named NPC relation entries.

## Findings

### 1. `e_parents_call` — SAFE COPY-ONLY
Current evidence:
- `scene = rent`
- `speaker = 母亲`
- title `家里的电话`
- age `23–40`
- `cond = null`
- applies across all origins
- body: `「吃饭了吗？工作累不累？」\n「你张叔家的儿子，今年在县城买了房。」\n你听着，筷子戳着外卖盒里的最后几粒米饭。`

Why this is copy-only:
- no option, effect, flag, job or result depends on the caller being specifically the player's mother;
- the title and body already work as a generic call from home;
- previous accepted NPC audits treat broad `家人` / family-of-origin wording as materially different from spouse/child-state assertions, so a generic home/family caller is compatible with the current content baseline.

Smallest neutral boundary:
- change only `speaker: 母亲` to a generic source such as `家里来电`.

No eligibility/state/mechanic change is required.

### 2. `e_parent_sick` — SAFE COPY-ONLY
Current evidence:
- `scene = hospital`
- `speaker = 父亲`
- title `电话`
- age `34–52`
- `cond = null`
- applies across all origins
- body: `「没事，就是个小手术，你别回来了，耽误工作。」\n你听出他声音不对。护士在旁边喊：「三床家属来一下。」`
- first option result: `你在病房陪了十一天。这十一天，是你成年后跟父亲说话最多的一段时间。`
- options only change money/mood/network/health; no family flag or relationship mechanic is written.

Why this is copy-only:
- unlike `e_parent_gone`, this event does not set or consume any parent-specific state;
- the hospital/caregiving beat survives if the caller is generalized to family rather than specifically father;
- the second option (`打钱，请个护工`) and all effects remain semantically valid under the generic family premise.

Smallest neutral boundary:
- `speaker: 父亲` -> generic source such as `家里来电`;
- first option result -> generic family wording, e.g. `你在病房陪了十一天。这十一天，是你成年后陪家里人最久的一段时间。`

No condition/effect/flag/schema change is required.

### 3. `e_parent_gone` — CONDITION / STATE-SCHEMA DEPENDENT
Current evidence:
- `scene = home`
- `speaker = 弟弟`
- age `42–60`
- `cond = null`
- body begins `「哥，爸走了。」`
- both options write `flags: {"parentGone": true}`.

Why this is not safely copy-only:
- the relationship premise is not just presentation: the event's state mutation explicitly records a parent death;
- changing `弟弟` / `爸` into a non-parent premise while leaving `parentGone` would make the copy disagree with the mechanic;
- merely changing the sibling speaker to `家里来电` would still leave the unconditional father-death premise unresolved;
- the current state model does not establish `parentAlive`, `hasFather`, `hasSibling`, or equivalent eligibility before this event.

Technical implication:
- `EventSystem` is capable of gating on flags, so a future design could use a family-state flag without changing the condition parser;
- however a reliable parent-existence/alive flag needs a defined producer/lifecycle/save meaning. Origin gating alone is not equivalent: `origin_local` establishes parents near the player at age 22, not a guaranteed living father/sibling state at age 42–60.

Therefore this case needs a state/eligibility contract before content changes. No follow-up is proposed inside this audit.

### 4. `e_roommate` — PRODUCT-POLICY DEPENDENT
Current event evidence:
- `scene = rent`
- `speaker = 合租室友`
- age `22–32`
- eligibility is only `flags_not: [localHome, hasHouse]`;
- body assumes a shared kitchen and another resident's room;
- one option is `加钱换个独居`;
- first result says `你们后来成了朋友，虽然只维持到各自搬家。`

Cross-repository evidence:
- core NPC `xiaoyu` is explicitly defined in `Data.gd` as `小雨 / 合租室友`;
- her normal lines include `隔壁那间又涨租了，咱们是不是也得搬？`;
- `npc_schedules.json` places `xiaoyu` at `home` in morning/evening/night windows, with no origin/housing predicate in the schedule system;
- quest `q3_someone_waits` explicitly calls Xiaoyu `室友`, checks her named relation at 20 and 45, and describes the transition from roommate to a trusted person.

Why policy is required first:
There are at least three coherent product interpretations, and they imply different fixes:
1. **小雨 is the canonical roommate.** Then the anonymous event should probably align to Xiaoyu, but merely renaming the speaker is insufficient because the event says the two become friends while its effects modify global `network`, not `xiaoyu` relation.
2. **The anonymous roommate is a separate temporary roommate.** Then the game intentionally allows another shared-house resident in addition to Xiaoyu; that should be stated as world canon before changing copy.
3. **Roommate content should exist only on a shared-rent path.** Then the project needs a `sharedRent`/equivalent housing-state lifecycle and consistent gating for the event and potentially Xiaoyu's home presentation/quest premise.

Because the repository does not choose among these models, `e_roommate` should not receive a copy-only patch yet. If product chooses Xiaoyu-as-canonical or strict shared-rent gating, the implementation may also cross into named-NPC relation or housing-state mechanics.

## Other speaker/premise checks
No additional follow-up is recommended for ordinary event-local social roles such as:
- `e_sidejob` / `大学同学`
- `e_friend_borrow` / `发小`
- `e_backhome` / `老同学`
- `e_old_colleague` / `前同事`
- `e_classmate` / `班长`

These speakers introduce one-off social contacts inside their own events and do not currently write a contradictory persistent family/household state or collide with a named relation mechanic in the way `e_parent_gone` / `e_roommate` do.

Origin-backed family premises also remain consistent:
- `e_town_kaoyan` is gated to `origin_town`, whose origin description explicitly carries family expectation;
- `e_local_family` is gated to `origin_local`, whose origin description/opening explicitly establishes parents and a family home.

The four spouse/child policy events remain excluded by task contract.

## Inventory summary
- SAFE COPY-ONLY: **2**
  - `e_parents_call`
  - `e_parent_sick`
- CONDITION / STATE-SCHEMA DEPENDENT: **1**
  - `e_parent_gone`
- PRODUCT-POLICY DEPENDENT: **1**
  - `e_roommate`
- New source/data changes in NPC-AUDIT-009: **0**

## Smallest safe follow-up
At most one follow-up is recommended:

### Proposed narrow content task — genericize the two parent-specific caller labels
Writable boundary:
- `data/events.json`
- `agent-reports/npc-content.md`

Exact IDs:
- `e_parents_call`
- `e_parent_sick`

Maximum intended data delta: **3 string-value edits only**:
1. `e_parents_call.speaker`: `母亲` -> generic home/family caller, e.g. `家里来电`.
2. `e_parent_sick.speaker`: `父亲` -> generic home/family caller, e.g. `家里来电`.
3. `e_parent_sick` first option result: replace only `跟父亲说话最多` with generic family caregiving wording.

Forbidden in that follow-up:
- conditions, age/origin eligibility, effects, flags, jobs, counters, IDs, schema or flow;
- `e_parent_gone` and `e_roommate` until their state/policy questions are resolved;
- the four deferred spouse/child policy events.

This is the smallest follow-up that resolves every currently identified **safe copy-only** speaker case without pre-empting family-state or roommate canon decisions.

## Files inspected
Read-only:
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `data/events.json`
- `data/quests.json`
- `data/npc_schedules.json`
- `scripts/Data.gd`
- `scripts/GameState.gd`
- `scripts/Game.gd` (origin/start-state and NPC build context only)
- `scripts/systems/EventSystem.gd`
- `scripts/systems/NPCScheduleSystem.gd`
- accepted NPC-CONTENT-007 report

Writable:
- `agent-reports/npc-content.md` only

## Validation / execution evidence
Repository-only inspection performed:
- task/ownership/launchpad contract read from latest coordination branch;
- branch freshness checked before report write;
- exact event IDs, speakers, conditions, effects/flags and relevant result strings inspected;
- origin definitions, core Xiaoyu identity, Xiaoyu quest relation usage and home schedule cross-checked;
- event condition/state capabilities inspected;
- no source/data file edited.

Not run:
- Godot 4.7.2: **NOT RUN**
- Web export/browser: **NOT RUN**
- terminal scripts / JSON parser: **NOT RUN**
- no runtime/build/parser/render PASS is claimed.

## Handoff
NPC-AUDIT-009 requests `NEEDS_REVIEW`.

The triage is complete: two cases are safely copy-only, one is state/condition dependent, and one requires a roommate-canon product decision before implementation.