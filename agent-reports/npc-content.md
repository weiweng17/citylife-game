# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-008
- Agent: npc-content
- Branch/worktree: `agent/npc-content-008-neutral-parent-copy`
- Status: NEEDS_REVIEW

## Scope
Neutralize only the two incidental mother-specific relationship assumptions accepted from NPC-CONTENT-007. Writable scope is limited to `data/events.json` and this report. No speaker, condition, ID, flag, reward/effect, age/origin eligibility, job, counter, schema, flow, script, coordination-file, or `main` changes are authorized or made.

The four policy-dependent family-state events remain explicitly untouched:
- `e_kid_school`
- `e_second_child`
- `e_downsize`
- `e_empty_nest`

## Baseline
- Latest task contract read from `orchestrator/multi-agent-bootstrap`.
- Before this task's source edit, `agent/npc-content-008-neutral-parent-copy` matched coordination commit `46d1ab5ce72331ef20c2260c29dccdd0a4b250f2` exactly (`ahead 0 / behind 0`).
- NPC-CONTENT-007 is marked DONE and accepted with exactly two safe copy-only candidates: `e_first_salary` and `e_sidejob`.

## Applied corrections
Content commit: `2c724e6bbaf1a791f7596c0621b79031f27482f1` — `NPC-CONTENT-008 neutralize incidental mother copy`.

### 1. `e_first_salary`
Existing eligibility/mechanics remain:
- age `22–26`
- `cond = null`
- speaker `银行短信`
- all options/effects unchanged

Changed only the event body string:
- Old: `「您尾号 8821 的账户到账 8,420.00 元。」\n你盯着短信看了三遍，然后给妈妈转了两千。`
- New: `「您尾号 8821 的账户到账 8,420.00 元。」\n你盯着短信看了三遍，然后把两千块转了出去。`

Reason:
- Preserves the first-salary transfer action and tone.
- Removes the unsupported mother-specific recipient assumption.
- Does not introduce a new origin, household, spouse, parent, or hometown assumption.

### 2. `e_sidejob`
Existing eligibility/mechanics remain:
- age `24–34`
- `cond = null`
- speaker `大学同学`
- first option effects remain `money +8000`, `health -8`, `mood -4`, `skill +3`

Changed only the first option result string:
- Old: `你做完了。那八千块后来变成了你妈的一台洗衣机。`
- New: `你做完了。那八千块后来变成了一台洗衣机。`

Reason:
- Preserves the original image that the side-job income becomes a concrete household purchase.
- Removes only the unsupported mother-specific ownership claim.
- Does not add another relationship or origin assumption.

## Explicitly unchanged
- all event IDs, scenes, speakers and titles;
- all ages and origin eligibility;
- all `cond` values;
- all option text other than the two target string values above;
- all effects, flags, jobs, counters and flow;
- JSON structure/schema;
- all other events, including the four deferred family-policy cases;
- previously accepted NPC-CONTENT-002..007 work was not re-applied or altered in this narrow task.

## Repository validation
- GitHub commit diff for `2c724e6bbaf1a791f7596c0621b79031f27482f1` contains exactly two removed string lines and two added string lines in `data/events.json`.
- Immediately after the content commit, comparison against `orchestrator/multi-agent-bootstrap` showed:
  - `ahead 1 / behind 0`
  - `data/events.json`: `+2 / -2`
  - no other changed file.
- The diff contains no speaker, condition, ID, flag, reward/effect, age/origin eligibility, job, counter, schema, or flow line changes.

## Runtime / parser evidence
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Terminal JSON parser: **NOT RUN** in this web-worker context.
- No runtime, build, browser, or parser PASS is claimed.

No verification script was added because the task authorizes only `data/events.json` plus this report and the acceptance condition is strictly two string-value edits.

## Known risks / integration note
- The coordination branch is still metadata-oriented and may not yet contain all earlier accepted NPC worker source deltas. This task intentionally carries only its own two-string delta and must not be used to overwrite or revert separately accepted NPC-CONTENT-003/004/006 changes during integration.
- The four hard family-state cases remain deferred pending explicit product policy and are not affected by this task.

## Handoff
NPC-CONTENT-008 requests `NEEDS_REVIEW`.

The task is complete within its two authorized paths: exactly two relationship-neutral string substitutions in `data/events.json` plus this report. No family-state policy or gameplay mechanics were changed.