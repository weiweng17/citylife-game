# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-007
- Agent: npc-content
- Branch/worktree: `agent/npc-content-007-remaining-neutral-copy-audit`
- Status: NEEDS_REVIEW

## Scope
Report-only audit of remaining event/quest strings for unconditional relationship or household claims that are not supported by current eligibility. The only writable path for this task is `agent-reports/npc-content.md`; no event/quest data, speakers, conditions, IDs, flags, rewards/effects, counters, schema, flow, scripts, coordination files, or `main` changes are authorized or made.

Explicit exclusions from the task contract:
- policy-dependent family-state events: `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`;
- all already accepted NPC-CONTENT-002..006 fixes.

## Baseline / source-of-truth note
- Before this report update, `agent/npc-content-007-remaining-neutral-copy-audit` matched `orchestrator/multi-agent-bootstrap` exactly at coordination commit `e60060cd559c46ff73af81354fafa50e3a8a7245` (`ahead 0 / behind 0`).
- Current inspected blobs:
  - `data/events.json`: `7d2460d089668f27058d91c2ceb48517c56afcf9`
  - `data/quests.json`: `3e2a6d460faeb8893e27279f8c3cbb825ab24627`
  - `scripts/Data.gd`: `16fa43074421ed7e6553a37af5a8cec1368f9c74`
- The coordination data still contains some pre-integration strings already accepted by NPC-CONTENT-003/004/006. Those accepted deltas are treated semantically as resolved and are not counted again here.

## Audit rule used
This task is looking for incidental copy that asserts a relationship/household state beyond what the event or quest eligibility proves, where the assertion can be removed by changing only a string value.

I did **not** classify an event-local speaker premise by itself (`母亲`, `父亲`, `弟弟`, `合租室友`, `发小`, `老同学`, etc.) as a safe copy-only candidate when neutralizing the relationship would require changing the speaker or redesigning the whole event premise. I also did not treat generic social pronouns such as `你们` as relationship-state claims when they clearly refer to people already established inside that same event.

## New safe copy-only candidates

### 1. `e_first_salary` — SAFE COPY-ONLY
Current eligibility:
- age `22–26`
- `cond = null`
- applies across origins
- speaker is `银行短信`

Current relationship-loaded string in the event body:
- `你盯着短信看了三遍，然后给妈妈转了两千。`

Why it is unsupported:
- the event has no parent/mother eligibility;
- unlike a parent-speaker event, the mother reference is incidental to an otherwise generic first-salary event;
- `scripts/Data.gd` explicitly gives family premises to some origins (`origin_town` / `origin_local`) but not to every origin (`origin_returnee` / `origin_switcher`), while this event is unconditional.

Why a future fix is safe copy-only:
- no speaker/condition/state/mechanic depends on the mother reference;
- the emotional/action beat can stay intact with a neutral transfer phrase.

Example future neutral boundary (not applied here):
- `你盯着短信看了三遍，然后转了两千回去。`

No other `e_first_salary` string or mechanic needs to change.

### 2. `e_sidejob` — SAFE COPY-ONLY
Current eligibility:
- age `24–34`
- `cond = null`
- applies across origins
- speaker is `大学同学`

Current relationship-loaded result:
- `你做完了。那八千块后来变成了你妈的一台洗衣机。`

Why it is unsupported:
- no mother/parent condition exists;
- the side-job choice itself only establishes that the player accepted and completed paid work;
- the specific recipient relationship is incidental and is not required by the outcome/effects.

Why a future fix is safe copy-only:
- the result can retain the same “钱最终变成一件生活用品” beat without naming a mother;
- no speaker, condition, reward/effect, flag, job or flow needs to change.

Example future neutral boundary (not applied here):
- `你做完了。那八千块后来变成了一台洗衣机，送回了老家。`

## Checked relationship/household strings that are NOT new safe copy-only candidates

### Origin-supported family copy
- `e_town_kaoyan`: event requires `origins: [origin_town]`; its `家里人希望你再考一次` / `家里扛不住` wording is consistent with `Data.gd`'s `origin_town` description `家境普通，背着全家的期望`.
- `e_local_family`: event requires `origins: [origin_local]`; `Data.gd` explicitly defines that origin as `家里有房，父母在身边` and its opening text already contains `爸妈`. The event's `爸妈` / `舅舅` family premise is therefore origin-backed rather than unconditional cross-origin copy.

### Quest relationship copy is mechanically/contextually supported
- `q2_laozhang`: the quest explicitly uses `relation_at_least` with `npc = laozhang`; 老张 relationship copy is supported.
- `q3_someone_waits`: `Data.gd` defines `xiaoyu` as `合租室友`, and the quest explicitly checks relation thresholds for `xiaoyu` at 20 and 45. The q3 relationship arc is therefore supported by its NPC/relation context.
- The old q3 `store_buy` gift-handoff implication still visible on this coordination baseline is an already accepted NPC-CONTENT-003 fix and is intentionally excluded from this task.

### Generic/broad family wording already checked
- `e_will` / `写下来，跟家人交代`: NPC-CONTENT-005 already checked this phrase and did not classify it as a spouse/child-state defect. `家人` is generic and the wider narrative contains family-of-origin relationships. It is not promoted to a new 007 candidate.
- `e_house` / `你们家能凑多少`: NPC-CONTENT-005 already judged this wording broad enough to include family of origin. The narrower `六个钱包` spouse-loaded idiom was separately fixed and accepted by NPC-CONTENT-006, so neither is a new 007 finding.

### Relationship is embedded in the event speaker/premise, so not copy-only under 007
These may be world-premise assumptions, but they cannot be fully neutralized while preserving the current speaker, which this task forbids changing:
- `e_parents_call` — `speaker = 母亲`, `cond = null`.
- `e_parent_sick` — `speaker = 父亲`, `cond = null`.
- `e_parent_gone` — `speaker = 弟弟`, body also says `爸走了`, with no sibling/parent existence condition.
- `e_roommate` — `speaker = 合租室友`; eligibility only excludes `localHome` and `hasHouse`, so the roommate is an event-local household premise rather than a stored relationship state.

These are **not** recommended as a follow-up copy-only batch because changing only body/result strings would leave the relationship-bearing speaker/premise intact. If the product later wants origin-agnostic or relationship-state-driven versions of these events, that requires explicit speaker/event-premise ownership, not this audit's neutral-copy scope.

## Previously accepted fixes intentionally excluded
The current coordination data can still show old strings from accepted worker branches; they are not new findings:
- NPC-CONTENT-003: q3 store-buy handoff implication; `e_final_health` accidental core-NPC `老张` reuse.
- NPC-CONTENT-004: `e_boss_talk` / `老婆`; unsupported child-custody clause in `e_divorce`; plural household wording in `e_mortgage_pressure`; `e_old_colleague` / `带家属一起`.
- NPC-CONTENT-006: `e_house` / `掏空六个钱包，买` → neutral purchase wording.

The four NPC-CONTENT-005 hard family-state cases remain explicitly deferred and are outside NPC-CONTENT-007.

## Inventory summary
- New safe copy-only candidates: **2**
  1. `e_first_salary` — `给妈妈转了两千`
  2. `e_sidejob` — `你妈的一台洗衣机`
- New quest copy-only candidates: **0**
- Speaker/premise-level family/household cases that are not safe under current task constraints: **4** (`e_parents_call`, `e_parent_sick`, `e_parent_gone`, `e_roommate`)
- Policy-dependent spouse/child events excluded by contract: **4**
- Already accepted fixes: excluded from new count.

## Smallest follow-up task boundary
If the orchestrator wants to remove the two remaining incidental parent-specific assumptions, the smallest safe follow-up is a two-string content task:
- writable: `data/events.json`, `agent-reports/npc-content.md`
- exact IDs: `e_first_salary`, `e_sidejob`
- string values only
- no speaker, conditions, IDs, flags, rewards/effects, jobs, schema or flow changes
- preserve each event's existing action/tone while removing only the unguaranteed mother-specific relationship reference.

No family-state policy decision is required for that two-string task.

## Files inspected
Read-only:
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `data/events.json`
- `data/quests.json`
- `scripts/Data.gd`
- accepted NPC-CONTENT-003 report
- accepted NPC-CONTENT-004 report
- accepted NPC-CONTENT-005 report

Writable:
- `agent-reports/npc-content.md` only

## Validation / execution evidence
Repository inspection performed:
- branch freshness checked against the latest coordination branch before this report update;
- event IDs, age ranges and eligibility were read from the current task branch;
- quest relation checks and origin-gated family wording were cross-checked against current repository data;
- no source/data file was edited.

Not run:
- Godot 4.7.2: **NOT RUN**
- Web export/browser: **NOT RUN**
- terminal scripts / JSON parser: **NOT RUN**
- no runtime/build/parser PASS is claimed.

## Handoff
NPC-CONTENT-007 requests `NEEDS_REVIEW`.

The task is complete as a report-only audit. Two additional string-only neutralization candidates were identified, and all speaker/policy/mechanics-dependent cases remain untouched.