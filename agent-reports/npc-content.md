# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-010
- Agent: npc-content
- Branch/worktree: `agent/npc-content-010-generic-family-callers`
- Status: NEEDS_REVIEW

## Scope
Apply only the three safe string-value edits accepted from NPC-AUDIT-009 in `e_parents_call` and `e_parent_sick`.

Writable scope:
- `data/events.json`
- `agent-reports/npc-content.md`

No conditions, age/origin eligibility, effects, flags, jobs, counters, IDs, schema, flow, scripts, coordination files, or `main` changes are authorized or made.

Explicitly untouched:
- `e_parent_gone`
- `e_roommate`
- `e_kid_school`
- `e_second_child`
- `e_downsize`
- `e_empty_nest`

## Baseline
- Latest coordination branch at task start: `96a202796d5b454f730bf84c566367e8564db7f4`.
- Before the source edit, `agent/npc-content-010-generic-family-callers` matched `orchestrator/multi-agent-bootstrap` exactly (`ahead 0 / behind 0`).
- NPC-AUDIT-009 is DONE and accepted at `a16920be7462436c1070e79e833cbadb7bdd0bd1`, classifying `e_parents_call` and `e_parent_sick` as safe copy-only.

## Applied corrections
Content commit: `46264de61d72c6b8a51bbe54003f665c36226f4a` — `NPC-CONTENT-010 genericize safe family callers`.

### 1. `e_parents_call.speaker`
- Old: `母亲`
- New: `家里来电`

Preserved:
- event body
- age `23–40`
- `cond = null`
- all options/effects/flags/jobs/results

### 2. `e_parent_sick.speaker`
- Old: `父亲`
- New: `家里来电`

Preserved:
- event body
- age `34–52`
- `cond = null`
- all option texts/effects/flags/jobs

### 3. `e_parent_sick` first-option result
- Old: `你在病房陪了十一天。这十一天，是你成年后跟父亲说话最多的一段时间。`
- New: `你在病房陪了十一天。这十一天，是你成年后陪家里人最久的一段时间。`

The caregiving beat and duration remain unchanged; only the unsupported father-specific relationship wording is generalized.

## Explicitly unchanged
- all event IDs, scenes and titles;
- all ages and origin eligibility;
- all `cond` values;
- all event body strings;
- all option texts other than the one authorized result string above;
- all effects, flags, jobs, counters and flow;
- JSON schema/structure;
- `e_parent_gone` remains parent-state/schema dependent and untouched;
- `e_roommate` remains product-policy dependent and untouched;
- all four deferred spouse/child-policy events remain untouched.

## Repository validation
- GitHub commit diff for `46264de61d72c6b8a51bbe54003f665c36226f4a` contains exactly three removed string lines and three added string lines in `data/events.json`.
- Comparison against `orchestrator/multi-agent-bootstrap` immediately after the content commit showed:
  - `ahead 1 / behind 0`
  - `data/events.json`: `+3 / -3`
  - no other changed file before this report update.
- The source diff contains no condition, age/origin eligibility, effect, flag, job, counter, ID, schema or flow change.

## Source-of-truth / integration note
The coordination branch remains metadata-oriented and can still contain stale strings from earlier accepted NPC content tasks. NPC-CONTENT-010 intentionally carries only its own three-string delta and must not be used to overwrite or revert separately accepted NPC-CONTENT-003/004/006/008 source deltas during deterministic integration.

## Runtime / parser evidence
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Terminal JSON parser: **NOT RUN** in this web-worker context.
- No runtime, parser, build, render or browser PASS is claimed.

No verification script was added because this task authorizes only `data/events.json` plus this report and its acceptance condition is exactly three string-value edits.

## Handoff
NPC-CONTENT-010 requests `NEEDS_REVIEW`.

The task is complete within the two authorized paths: exactly three safe parent-caller string substitutions in `data/events.json` plus this report.