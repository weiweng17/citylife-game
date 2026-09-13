# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-004
- Agent: npc-content
- Branch/worktree: `agent/npc-content-004-relationship-neutral-copy`
- Status: NEEDS_REVIEW

## Scope
Apply only unambiguous string-level neutralizations for event copy that asserts a spouse/family relationship without an eligibility condition supporting that relationship. Writable scope was limited to `data/events.json` and this report. No speaker, condition, flag, schema, ID, reward, effect, job, flow, script, coordination file, or `main` change was allowed or made.

## Baseline
- Latest task contract was read from `orchestrator/multi-agent-bootstrap`.
- Before this task's edit, `agent/npc-content-004-relationship-neutral-copy` matched coordination commit `26919477e86fabda1094f3955b0a570028c63a86` exactly (`ahead 0 / behind 0`).
- NPC-CONTENT-003 was already marked DONE on the task board, but this task intentionally does not reapply or duplicate prior task edits; its branch diff is limited to the NPC-CONTENT-004 relationship-neutral strings below.

## Applied string-only corrections
Commit: `fb0b932c63542a61bc6a00d7c8e67cebf1e09cde` — `NPC-CONTENT-004 neutralize unsupported relationship copy`.

### 1. `e_boss_talk`
Existing eligibility: `network_min = 50`; no marriage/partner condition.

Changed only the result string:
- `你签了字。走出办公楼时，你给老婆发了条微信：「晚上我做饭。」`
- → `你签了字。走出办公楼时，你发了条微信：「晚上我做饭。」`

Reason: the event can occur without any spouse state, so `老婆` was an unsupported relationship assertion. The action and tone remain intact.

### 2. `e_divorce`
Existing eligibility: `mood_max = 51` + `married`; there is no `hasChild` requirement.

Changed only the first option result string:
- `你们分了财产，孩子跟她。你搬进了一间一居室，重新学会了做饭。`
- → `你们分了财产。你搬进了一间一居室，重新学会了做饭。`

Reason: divorce is mechanically supported, but existence/custody of a child is not guaranteed by this event's eligibility. The unsupported child claim was removed without changing the divorce outcome.

### 3. `e_mortgage_pressure`
Existing eligibility: `mortgage`; no marriage/partner condition.

Changed only the second option result string:
- `你们搬进了更小的房子，用差价覆盖月供。你自嘲是专业房东。`
- → `你搬进了更小的房子，用差价覆盖月供。你自嘲是专业房东。`

Reason: a mortgage does not prove a spouse/partner or shared household. Singular wording preserves the exact event outcome without inventing a relationship.

### 4. `e_old_colleague`
Existing eligibility: none (`cond = null`).

Changed only the first option result string:
- `你们加了微信，约好下次带家属一起。走出咖啡馆时，你觉得心里很暖。`
- → `你们加了微信，约好下次再聚。走出咖啡馆时，你觉得心里很暖。`

Reason: the event does not establish that the player or former colleague currently has a spouse/partner/family member to bring. `下次再聚` preserves the social follow-up without a family-state assumption.

## Ambiguous relationship-state cases intentionally not edited
These remain documented because their correctness depends on family-state/event eligibility semantics rather than one safely neutralizable string. The task explicitly forbids changing speakers/conditions/flags and says not to guess ambiguous wife/child-state cases.

1. `e_kid_school` — `speaker = 妻子`, but eligibility checks only `hasChild`. A divorced player can still have a child; changing only dialogue strings would not resolve the speaker identity contradiction.
2. `e_second_child` — `speaker = 妻子`, eligibility is `hasChild` plus not `noChild`; no current-marriage condition is required.
3. `e_downsize` — `speaker = 妻子`, eligibility requires only `hasChild`; the shared-household copy depends on unresolved family-state semantics.
4. `e_empty_nest` — `speaker = 妻子`, eligibility requires only `hasChild`; both the speaker and two-person-household copy depend on whether the player is still married.

These should be handled only by a later task with explicit event-condition/family-state ownership, or by an orchestrator-approved policy that can also address speaker identity.

## Consistent relationship cases checked and left unchanged
- `e_child` uses `speaker = 妻子` and explicitly requires `married`; spouse wording is supported.
- `e_marry_life` uses `speaker = 妻子` and explicitly requires `married`; spouse wording is supported.
- `e_divorce` itself explicitly requires `married`; only the unsupported child-custody clause was removed.
- `e_marry` / `e_longdistance` use `恋人` with explicit `dating` conditions; those relationship labels are supported.

## Repository validation
- The content commit patch contains exactly four result-string substitutions in `data/events.json`.
- Comparison against `orchestrator/multi-agent-bootstrap` immediately after the content commit showed:
  - `data/events.json`: 4 additions / 4 deletions.
  - no other source/data file changed.
- The patch was re-read from commit `fb0b932c63542a61bc6a00d7c8e67cebf1e09cde`; no speaker, condition, flag, ID, reward, effect, job, or flow line appears in the diff.
- No verification script was added because this is a copy-only task and writable scope contains only `data/events.json` plus this report.

## Runtime / parser evidence
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Terminal JSON parser: **NOT RUN** in this web-worker context.
- No runtime, build, browser, or parser PASS is claimed.

## Known risks / integration note
- The four ambiguous wife/child-state cases listed above remain intentionally unresolved and require explicit family-state/condition ownership.
- This task branch was cut from the coordination baseline rather than from the NPC-CONTENT-003 worker branch. Therefore review/integration should evaluate this branch by its four-line content patch and should integrate previously accepted NPC-CONTENT-003 source edits independently; this task does not intentionally revert or duplicate them.

## Handoff
NPC-CONTENT-004 requests `NEEDS_REVIEW`.

All completed edits are string-only, individually justified against existing event eligibility, and limited to the two authorized paths. No relationship mechanics or thresholds were invented.