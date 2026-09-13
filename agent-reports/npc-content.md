# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-006
- Agent: npc-content
- Branch/worktree: `agent/npc-content-006-house-copy-neutralization`
- Status: NEEDS_REVIEW

## Scope
Neutralize only the relationship-loaded `e_house` purchase option phrase identified by NPC-CONTENT-005. Writable scope is limited to `data/events.json` and this report. No conditions, speakers, IDs, flags, rewards, effects, jobs, schema, flow, scripts, coordination files, or `main` changes are authorized or made.

## Baseline
- Latest task contract read from `orchestrator/multi-agent-bootstrap`.
- Task branch initially matched coordination commit `4249687c2c20a5680ed5914c01f4f55665d397d9` exactly (`ahead 0 / behind 0`).
- `NPC-CONTENT-005` is marked DONE and explicitly classified `e_house` / `掏空六个钱包，买` as the remaining low-risk copy-only relationship assumption.

## Applied correction
Content commit: `2289578f6814e1ec29c02d4ca97d02f062054320` — `NPC-CONTENT-006 neutralize e_house purchase copy`.

Event: `e_house`

Changed only the first purchase option string:
- `掏空六个钱包，买`
- → `凑够首付，买`

Reason:
- “六个钱包” commonly implies the buyer couple plus both sets of parents and therefore carries an unnecessary partner/spouse assumption.
- `凑够首付，买` preserves the same purchase intent without asserting any relationship state.
- The event's broader family wording, eligibility, purchase mechanics and outcome are otherwise unchanged because the task authorizes exactly this one copy-only neutralization.

## Explicitly unchanged
- `e_house` event eligibility and age range.
- option `money_min = 600000`.
- effects: `money`, `mood`, `health`, `network`.
- flags: `hasHouse`, `mortgage`.
- result text and the other two options.
- the four policy-dependent family-state events from NPC-CONTENT-005: `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`.
- all speakers, conditions, IDs, flags, rewards/effects, jobs, schemas and flow.

## Repository validation
- GitHub commit diff for `2289578f6814e1ec29c02d4ca97d02f062054320` contains exactly one removed string line and one added string line in `data/events.json`.
- The surrounding diff confirms `money_min = 600000` and the option structure remain unchanged.
- No other file is present in the content commit.
- No verification script was added because the task permits only `data/events.json` plus this report and the change is one string value.

## Runtime / parser evidence
- Godot 4.7.2: **NOT RUN**.
- Web export/browser: **NOT RUN**.
- Terminal JSON parser: **NOT RUN** in this web-worker context.
- No runtime, build, browser, or parser PASS is claimed.

## Known risks / integration note
- This task intentionally does not solve the four hard family-state policy ambiguities identified by NPC-CONTENT-005.
- The coordination branch may still require separate integration of earlier accepted NPC content worker deltas; this task's own source delta is only the single `e_house` option-string substitution above.

## Handoff
NPC-CONTENT-006 requests `NEEDS_REVIEW`.

The task is complete within its two authorized paths: one relationship-neutral option-string substitution in `data/events.json` plus this report. No family-state policy or mechanics were invented.