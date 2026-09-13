# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-003
- Agent: npc-content
- Branch/worktree: `agent/npc-content-003-naming-consistency`
- Status: NEEDS_REVIEW

## Scope
Audit quest/event copy for accidental reuse of established core-NPC names, relationship claims not supported by existing mechanics, and contradictory identity wording. Writable scope was limited to `data/quests.json`, `data/events.json`, and this report. No schema, condition, flag, counter, reward, effect, flow, script, coordination file, or `main` change was allowed or made.

## Baseline
- Latest task contract was read from `orchestrator/multi-agent-bootstrap`.
- This worker branch initially matched coordination commit `6215005b34e860a5d346fa38ee339537a819cd66` exactly.
- Core NPC identities were checked against `scripts/Data.gd`: 陈姐 (`chenjie`), 老张 (`laozhang`), 老周 (`laozhou`), 疯道士 (`daoshi`), 小雨 (`xiaoyu`), 阿哲 (`azhe`). `scripts/Data.gd` was read-only.

## Applied copy-only corrections
### 1. `data/quests.json` / `q3_someone_waits`
Mechanic remains exactly:
- `type = counter`
- `key = store_buy`
- `count = 1`

Changed only these string values:
- step: `路过便利店，给她带一样东西` → `路过便利店，顺手买一样东西`
- done: `一样不贵的东西，装在塑料袋里，拎回去的时候有点分量。` → `你拎着一个普通的塑料袋走出便利店，忽然觉得今晚回去可以多说两句话。`

Reason: the counter proves a store purchase only; it does not prove that an item was selected for 小雨 or handed to her. The surrounding relation steps for `xiaoyu` at 20 and 45 remain unchanged and are supported by explicit relation checks.

Commit: `b012c0a5842c2d80f7da993e78f36af49d2992df`.

### 2. `data/events.json` / `e_final_health`
Changed only the successful-hospital result string:
- `病房里你认识了老张。你们约好出院后一起去钓鱼。`
- → `病房里你认识了隔壁床的病友。你们约好出院后一起去钓鱼。`

Reason: `老张` is already the established core NPC `laozhang` / 公司老同事. The hospital event has no NPC identity condition or relationship mechanic tying this acquaintance to that core NPC, so the reused name falsely aliases two identities.

Final branch-tip content commit: `bb8a9bf4047fd2efcaa226b29fdd38c87e2872ec`.

## Audit findings — no source edit made
The following relationship-copy cases were found during the audit but were intentionally not rewritten in this task because their consistency depends on family-state flow/conditions rather than a single unambiguous identity string. Changing `cond`, flags, or event eligibility is outside this task; aggressively genericizing the copy would also alter the intended family narrative for valid married runs.

1. `e_kid_school` — speaker is `妻子`, while eligibility checks `hasChild` rather than `married`. After a divorce, `hasChild` can remain true, so this can describe an ex-spouse as a current wife.
2. `e_second_child` — speaker is `妻子`, while eligibility is `hasChild` + not `noChild`; no current-marriage condition is required.
3. `e_downsize` — speaker is `妻子`, while eligibility requires only `hasChild`.
4. `e_empty_nest` — speaker is `妻子` and the option/result describe a two-person household, while eligibility requires only `hasChild`.
5. `e_boss_talk` — one result says `给老婆发了条微信`, but the event has only `network_min` and no marriage condition.
6. `e_mortgage_pressure` — one result says `你们搬进了更小的房子`, but `mortgage` can exist without a marriage flag.
7. `e_divorce` — event correctly requires `married`, but the divorce result says `孩子跟她` without requiring `hasChild`.
8. `e_old_colleague` — result says `约好下次带家属一起` without any partner/family-state condition.

These are documented for orchestrator/gameplay follow-up because a fully correct repair requires deciding intended event eligibility/state semantics. No new relationship threshold or hidden assumption was invented here.

## Identity audit notes
- `q2_laozhang` intentionally names core NPC 老张 and uses `relation_at_least` with `npc = laozhang`; this is consistent and was not changed.
- `q3_someone_waits` intentionally names core NPC 小雨 and uses `relation_at_least` with `npc = xiaoyu`; this is consistent. Only the unrelated `store_buy` handoff implication was removed.
- Generic event labels such as `老同事`, `前同事`, `合租室友`, `张总`, and `张叔` were not automatically treated as the exact core NPCs because the data does not explicitly bind those strings to a core NPC ID. They are noted as potential presentation ambiguity, not proven identity collisions.
- No accidental exact event-copy reuse of core names 陈姐、老周、疯道士、阿哲 was found in the reviewed event content.

## Repository validation
- Final branch comparison against `orchestrator/multi-agent-bootstrap` before this report update showed only the three authorized paths:
  - `data/quests.json`
  - `data/events.json`
  - `agent-reports/npc-content.md`
- Data diff remained narrow:
  - `data/quests.json`: 2 additions / 2 deletions.
  - `data/events.json`: 1 addition / 1 deletion.
- IDs, counters, relation thresholds, conditions, flags, rewards, effects, jobs, event/quest flow, and JSON structure were not intentionally altered.
- Current q3 branch-tip text and hospital branch-tip text were re-read after commit.

## Runtime / parser evidence
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Terminal JSON parser: **NOT RUN** in this web-worker context.
- No runtime, build, browser, or parser PASS is claimed.

## Known risks / handoff
- The family-state findings above remain repository-visible design/flow risks. They should be handled only by a task that explicitly owns event-condition/state semantics, or by an orchestrator-approved copy policy for divorced/single-parent paths.
- Earlier dangling Git objects were created while assembling the hospital correction, but the branch tip was ultimately advanced by normal fast-forward to `bb8a9bf4047fd2efcaa226b29fdd38c87e2872ec`; review the branch diff/tip, not unattached intermediate objects.

## Handoff
NPC-CONTENT-003 requests `NEEDS_REVIEW`.

The completed source edits are copy-only and individually documented. No mechanics or relationship thresholds were invented. The remaining relationship-state inconsistencies are explicitly surfaced rather than silently changing mechanics outside ownership.