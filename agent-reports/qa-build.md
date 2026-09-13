# QA/Build Agent Report

## Task
- ID: QA-010
- Agent: qa-build
- Branch/worktree: `agent/qa-010-post-review-integration-delta`
- Status: NEEDS_REVIEW

## Scope
Report-only post-review integration/freshness delta after repository acceptance of GAME-FIX-007, NPC-CONTENT-007, and QA-009 while UI-FIX-005 remains in exact-SHA rendered hold.

Per `docs/agents/TASK_BOARD.md`, the only writable path for QA-010 is this report. No worker source/data/UI file, workflow, coordination file, task board, integration branch, or `main` was modified. No merge/cherry-pick/rebase, parser, Godot, Web export, browser, screenshot, or verifier execution was performed or claimed.

## Coordination baseline
Current coordination branch state inspected from `orchestrator/multi-agent-bootstrap`:
- GAME-FIX-007 — DONE, accepted at `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344`.
- GAME-AUDIT-008 — READY on `agent/game-audit-008-terminal-time-callsite-audit`.
- UI-FIX-005 — NEEDS_REVIEW; source/scope accepted but final rendered acceptance still held.
- UI-AUDIT-006 — READY on `agent/ui-audit-006-next-responsive-hotspot`.
- NPC-CONTENT-007 — DONE.
- NPC-CONTENT-008 — READY on `agent/npc-content-008-neutral-parent-copy`.
- QA-009 — DONE.
- QA-010 — READY on this branch.
- QA-002 — BLOCKED only by a real Godot 4.7.2 + browser execution context.

The coordination branch remains metadata-oriented rather than an assembled runtime candidate. All executable acceptance must still target one explicitly frozen integration SHA.

## QA-010 branch freshness
Before this report update, `agent/qa-010-post-review-integration-delta` still pointed exactly at coordination commit:
- `46d1ab5ce72331ef20c2260c29dccdd0a4b250f2`
- report contents were the old QA-001 bootstrap template.

This confirms QA-010 had not previously produced task-specific QA output. This update intentionally changes only `agent-reports/qa-build.md`.

## Exact branch tips captured

| Task | Branch | Exact tip | Current QA disposition |
| --- | --- | --- | --- |
| GAME-FIX-007 | `agent/game-fix-007-sleep-terminal-guard` | `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344` | Repository-accepted Gameplay semantic source for the sleep guard; runtime PASS still requires the frozen integration SHA matrix. |
| GAME-AUDIT-008 | `agent/game-audit-008-terminal-time-callsite-audit` | `54edcdd2b3dbaf98ce1511d4acd7a9657c920903` | Worker report `NEEDS_REVIEW`; report-only audit. Identifies two concrete remaining terminal-observation gaps and proposes one narrow GAME-FIX-009. |
| UI-FIX-005 | `agent/ui-fix-005-start-screen-overflow` | `a0402610cef12455dfc970641e4273c8b246d6d1` | Still in rendered hold. Source inspection/headless preparation is not enough for DONE. |
| UI-AUDIT-006 | `agent/ui-audit-006-next-responsive-hotspot` | `9fac5a93af60cbeb00ef390bc5b3d877d319b619` | Worker report `NEEDS_REVIEW`; report-only audit. Recommends isolated ShopUI vertical overflow repair. |
| NPC-CONTENT-008 | `agent/npc-content-008-neutral-parent-copy` | `a787d4ab237af9db2d85eac47b9c9db504786951` | Worker report `NEEDS_REVIEW`; implementation contains the authorized two-string content delta plus report. Parser/runtime PASS not inferred. |
| QA-009 | `agent/qa-009-next-wave-acceptance-delta` | `f08abc1f037962616efca82dff70015790e96671` | Repository-accepted report-only predecessor. Its single-integration-SHA and stale-evidence rules remain authoritative unless superseded by an accepted later QA report. |

### Freshness note
UI-AUDIT-006 has advanced to `9fac5a93...`; any earlier record of a different UI-AUDIT-006 tip is stale. GAME-AUDIT-008, UI-FIX-005, NPC-CONTENT-008, GAME-FIX-007, and QA-009 exact tips above are the identities captured for this QA-010 handoff.

**Stale-SHA stop rule:** if any worker branch participating in the final candidate moves after evidence is collected, affected evidence is invalid. Refresh the exact tip, re-form/freeze the integration candidate, and rerun all affected task-specific plus shared gates on the new integration SHA.

## New acceptance delta — GAME-AUDIT-008
GAME-AUDIT-008 is report-only and should not itself be merged as gameplay source. It identifies two repository-visible HIGH-severity ordering gaps after accepted GAME-FIX-007:

1. `_process()` runs reward-bearing `_evaluate_quests()` before pending need settlement and before the authoritative `_evaluate_terminal_state()`. A quest reward can therefore restore mood/money before an already-terminal or pending-terminal state is observed.
2. While the backpack/ShopUI remains open, `_sync_needs_to_time()` can settle health to zero while `ui_busy` suppresses `_evaluate_terminal_state()`. `_on_shop_use()` can then permit another health-restoring item before the evaluator runs.

The audit explicitly classifies overnight sleep, year settlement, ordinary travel, no-event location time, event close, and standard locked activities as safe from the same-flow recovery pattern, aside from the global quest-before-terminal ordering.

### QA consequence
Do **not** expand GAME-FIX-007. If the orchestrator accepts the audit, create a separate minimal Gameplay repair, recommended as `GAME-FIX-009 — Pre-terminal mutation ordering guard`, using the existing `_evaluate_terminal_state()` as the only terminal authority.

A future narrow regression should cover at minimum:
- quest completion cannot revive `mood == 0` before terminal observation;
- pending zero-need damage is observed before quest rewards;
- item time can make health terminal while the bag is open and a second healing item cannot revive it before evaluation;
- normal non-terminal quest rewards and item-use behavior remain unchanged;
- no direct new `death_reason()` consumer is introduced outside `_evaluate_terminal_state()`.

If GAME-FIX-009 is later accepted into the candidate, its verifier must be added to the Gameplay regression sequence and all Gameplay checks rerun on the same final integration SHA.

## New acceptance delta — UI-AUDIT-006
UI-AUDIT-006 is report-only and recommends the next independent UI repair:

### `UI-FIX-006 — Shop list vertical overflow containment`
Recommended source boundary:
- `scripts/ui/ShopUI.gd`
- one narrow `tools/verify_shop_panel_overflow.gd` if explicitly authorized
- `agent-reports/scene-ui.md`

The repository-visible defect is structural: title/subtitle, dynamic `ShopList`, status, footer, and close action share one vertical container; the six-row list has no bounded vertical overflow owner, so shorter logical heights can allow row growth to push status/footer/close out of reach.

The audit deliberately keeps the repair narrow:
- scroll only the item-list region;
- keep title/status/footer/close outside the scroll owner;
- preserve buy/bag modes, signals, `open_buy`, `open_bag`, `refresh`, `set_status`, `close`, and `is_open`;
- do not edit `Game.gd`, inventory data/effects/prices, settlement semantics, or UI-FIX-001..005 held files;
- leave sub-660px horizontal redesign for a separate task.

### Future QA requirements if UI-FIX-006 is queued
- task-specific headless verifier on the frozen candidate SHA;
- real rendered 1280×720 and 960×540 evidence;
- six-row buy and six-owned-item bag paths;
- last-row vertical reachability;
- fixed status/footer/close reachability;
- buy ↔ bag transitions and same-mode `refresh()` reset invalid scroll offsets/stale height;
- correct buy/use/closed signals exactly once;
- no horizontal-scroll dependency at 960px logical width.

UI-AUDIT-006 itself requires no runtime PASS because it changes only its report.

## New acceptance delta — NPC-CONTENT-008
NPC-CONTENT-008 implements exactly the two safe copy-only changes discovered by NPC-CONTENT-007:

1. `e_first_salary`
   - old: `然后给妈妈转了两千。`
   - new: `然后把两千块转了出去。`
2. `e_sidejob`
   - old: `那八千块后来变成了你妈的一台洗衣机。`
   - new: `那八千块后来变成了一台洗衣机。`

Worker evidence states the source commit is `2c724e6bbaf1a791f7596c0621b79031f27482f1` and changes `data/events.json` by exactly two removed/two added string lines; branch tip `a787d4ab...` adds the completion report afterward.

### Integration requirement
Integrate only the two authorized string substitutions plus any separately accepted NPC deltas. Do not use NPC-CONTENT-008 as a replacement snapshot for the entire event file if doing so would overwrite earlier accepted NPC-CONTENT-003/004/006 work.

On the final integration SHA containing this content delta, run a real parser check:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence:
- exact candidate SHA;
- exit code 0;
- literal `JSON_PARSE_OK`;
- diff inspection confirming no speaker, condition, ID, flag, reward/effect, age/origin eligibility, job, counter, schema, or flow changes from NPC-CONTENT-008.

The four product-policy events `e_kid_school`, `e_second_child`, `e_downsize`, and `e_empty_nest` must remain untouched.

## Deterministic integration-order / conflict hazards

### 1. `scripts/Game.gd` is cumulative, not branch-stack-safe
GAME-FIX-007 reconstructs earlier accepted Gameplay semantics because the coordination branch is metadata-only. GAME-AUDIT-008 adds no source, but its proposed GAME-FIX-009 would necessarily modify the same high-conflict `scripts/Game.gd`.

Therefore:
- do not blindly merge GAME-FIX-001..007 historical branches in sequence and then overlay a future GAME-FIX-009 branch snapshot;
- form one deterministic `Game.gd` candidate from the accepted semantic state;
- if GAME-FIX-009 exists, base its implementation on the accepted GAME-FIX-007 semantic source and review the final combined diff/function ordering before runtime validation.

### 2. Content file integration must be semantic, not whole-file overwrite
NPC-CONTENT-008 touches `data/events.json`, while prior NPC tasks also altered event content. Its intended delta is only two strings. Apply/review those two substitutions without reverting earlier accepted content work.

### 3. UI fixes are mostly file-isolated but evidence is SHA-coupled
UI-FIX-005 owns `StartUI.gd`; the proposed UI-FIX-006 would own `ShopUI.gd`, so direct source conflict should be low. However all visual/headless evidence must reference the final integrated SHA, not isolated branch tips. Any later UI source movement invalidates old rendered evidence.

### 4. QA reports are metadata only
QA-009 and QA-010 should not be treated as runtime source inputs. Their value is the manifest, stop conditions, exact-tip capture, and execution order.

## Frozen-candidate execution order
The final QA-002 candidate must be one explicit integration commit. Suggested order:

### Step 0 — freeze candidate identity
```bash
git rev-parse HEAD
git status --short
```
Record exact 40-character SHA and clean/known worktree state. If HEAD changes later, stop and refresh affected evidence.

### Step 1 — JSON parse/diff gate
Run when the candidate contains NPC-CONTENT-008 or any other accepted JSON content delta:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

### Step 2 — Gameplay task-specific regressions
At minimum, retain the accepted QA-009 sequence on the same candidate SHA:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

If GAME-FIX-009 is accepted later, append its authorized verifier after source integration and rerun the entire Gameplay set; do not reuse pre-009 PASS output.

### Step 3 — UI task-specific headless regressions
Retain UI-FIX-001..005 checks when those deltas are present, including:

```bash
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
```

If UI-FIX-006 is accepted later, add:

```bash
godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd
```

Do not infer rendered correctness from headless output.

### Step 4 — shared QA headless gate
Run the accepted shared gate on the same candidate SHA only after task-specific regressions pass.

### Step 5 — real rendered UI acceptance
UI-FIX-001..005 remain in exact-SHA visual acceptance. UI-FIX-005 specifically still requires real 1280×720 and 960×540 StartUI evidence. If UI-FIX-006 is later integrated, collect the same declared viewport sizes for ShopUI and verify its list/control reachability contract.

### Step 6 — Web export/browser acceptance
QA-002 remains BLOCKED only on availability of a real Godot 4.7.2 + browser context. When available, use the same frozen candidate SHA for Web export and browser validation; capture command, exit code, artifact location, browser console/network/runtime output, and representative gameplay/UI flows.

## Stop / escalation conditions
Stop promotion and route the smallest owning-domain follow-up if:
1. evidence references a SHA different from the declared integration SHA;
2. a participating Worker branch moves after its evidence was captured;
3. the final Gameplay candidate adds another terminal/death threshold path instead of using `_evaluate_terminal_state()`;
4. quest rewards can still mutate a terminal/pending-terminal state before observation after a future ordering fix;
5. the open backpack can still allow a post-settlement healing revival after a future ordering fix;
6. GAME-FIX-001..007 contracts regress while integrating later Gameplay changes;
7. NPC-CONTENT-008 changes anything beyond the two authorized string values;
8. JSON parsing fails;
9. UI-FIX-005 lacks real 1280×720 and 960×540 rendered evidence;
10. a future UI-FIX-006 moves status/footer/close into the scrolling list, changes gameplay/item semantics, or depends on horizontal scrolling at 960px;
11. any verifier/shared gate exits nonzero or emits a parse/assertion/runtime failure;
12. Web export/browser startup has blocking parse/runtime/resource errors;
13. any unexecuted command is described as PASS.

## Validation actually performed in QA-010
Performed:
- read current `orchestrator/multi-agent-bootstrap` task board;
- read `docs/agents/FILE_OWNERSHIP.md`;
- inspected current QA-010 branch/report state;
- captured exact tips for GAME-FIX-007, GAME-AUDIT-008, UI-FIX-005, UI-AUDIT-006, NPC-CONTENT-008, and QA-009;
- inspected GAME-AUDIT-008 report and its exact callsite/ordering findings;
- inspected UI-AUDIT-006 report and ShopUI repair boundary;
- inspected NPC-CONTENT-008 report and exact old/new content strings;
- reviewed QA-009 predecessor matrix so this report extends rather than discards its single-SHA acceptance rules;
- repository-only integration/freshness analysis.

Not performed:
- Godot 4.7.2 launch;
- any `verify_*.gd` execution;
- JSON parser execution against a local checkout;
- merge/cherry-pick/rebase;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow edits/runs;
- worker-source edits.

## Handoff
QA-010 repository-only integration/freshness delta is complete and requests `NEEDS_REVIEW`.

Immediate orchestrator review points:
1. accept GAME-AUDIT-008 only as report-only evidence and, if approved, queue the smallest separate GAME-FIX-009 for the two terminal-observation ordering gaps;
2. accept UI-AUDIT-006 only as report-only evidence and, if approved, queue isolated UI-FIX-006 for ShopUI vertical list containment;
3. review NPC-CONTENT-008 as exactly two string substitutions and require JSON parse/diff validation on the eventual frozen integration SHA;
4. keep UI-FIX-005 in rendered hold until real exact-SHA 1280×720 and 960×540 evidence exists;
5. keep QA-002 blocked solely on real Godot/browser execution context and run the complete ordered matrix only after one deterministic integration SHA is frozen.
