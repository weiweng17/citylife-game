# QA/Build Agent Report

## Task
- ID: QA-005
- Agent: qa-build
- Branch/worktree: `agent/qa-005-next-wave-manifest`
- Status: NEEDS_REVIEW

## Scope
Repository-only acceptance manifest for the next repair wave. Writable scope for QA-005 is this report only. No workflow, source, scene, asset, data, project/export configuration, task-board, or worker-owned file was modified.

No Godot, Web export, browser, rendered capture, or local integration run was executed in this task. All runtime commands below are prepared instructions, not claimed evidence.

## Summary
QA-005 captured exact current branch tips for GAME-FIX-002/003, UI-FIX-002/003 and NPC-CONTENT-003 and prepared one ordered evidence checklist for each task plus the shared six-script headless gate inherited from QA-003.

The key integration rule is: task-branch repository evidence is useful for ownership/scope review, but final runtime acceptance must be rerun on one exact integration candidate SHA after the reviewed task commits are combined. Isolated branch results must not be treated as proof of cross-task compatibility.

## Exact branch-tip manifest

| Task | Branch | Captured tip SHA | Worker status | Runtime-sensitive? |
| --- | --- | --- | --- | --- |
| GAME-FIX-002 | `agent/game-fix-002-need-zero-cadence` | `ef88708a3ab120da4129fea7e0efad125fb7b0a6` | `NEEDS_REVIEW` | Yes — gameplay/time cadence |
| GAME-FIX-003 | `agent/game-fix-003-terminal-state-evaluation` | `9ae0e807a59cba366a6013f61f22ab8d76000c82` | `NEEDS_REVIEW` | Yes — ending transition/idempotence |
| UI-FIX-002 | `agent/ui-fix-002-home-bed-seam` | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | `NEEDS_REVIEW` | Yes — headless contract + rendered visual |
| UI-FIX-003 | `agent/ui-fix-003-hud-header-decoupling` | `ff36fe6368d4f0b8088c266dab6331fce71e6454` | `NEEDS_REVIEW` | Yes — layout contract + rendered visual |
| NPC-CONTENT-003 | `agent/npc-content-003-naming-consistency` | `def4f9ab5df04562d43380f533a4cb07cf259459` | `NEEDS_REVIEW` | Data/parser + quest/event loading |

If any branch tip changes before execution, this manifest is stale for that task and its task-specific review must be refreshed against the new SHA.

## Task-specific acceptance matrix

### GAME-FIX-002 — Need-zero penalty cadence
Repository checklist:
1. Diff remains limited to authorized `scripts/Game.gd`, `tools/verify_need_zero_cadence.gd`, and `agent-reports/gameplay.md`.
2. Zero-fullness health and zero-energy mood penalties are applied only inside the completed-hour loop in `_sync_needs_to_time()`.
3. Existing values remain unchanged: fullness -4/hour, energy -3/hour, zero-fullness health -2, zero-energy mood -2.
4. Save schema, warning semantics, replenishment behavior and unrelated progression stay unchanged.

Focused runtime commands on the exact integration SHA:
```bash
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
```
Required evidence:
- first command exits 0 and ends with `GAME-FIX-002 PASS: zero-need penalties are tied to the hourly need-drain cadence`;
- `verify_needs.gd` completes successfully;
- no duplicate penalty occurs on zero-time refresh/re-entry;
- sub-hour time does not apply a penalty; multi-hour time settles once per completed hour.

Stop conditions:
- any non-zero exit;
- any observed penalty outside completed-hour cadence;
- any save/replenishment/warning regression.

### GAME-FIX-003 — Centralized terminal-state evaluation
Repository checklist:
1. Diff remains limited to authorized `scripts/Game.gd`, `tools/verify_terminal_state_evaluation.gd`, and `agent-reports/gameplay.md`.
2. `Game.gd` has one direct `rules_sys.death_reason(...)` consumer owned by `_evaluate_terminal_state()`.
3. Annual and settled normal-gameplay paths route through the shared evaluator.
4. Existing threshold ordering/results in Rules and ending presentation remain unchanged.
5. `game_over` makes repeated evaluation idempotent.

Focused runtime command on the exact integration SHA:
```bash
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
```
Required evidence:
- exit 0;
- final output contains `GAME-FIX-003 PASS: terminal-state evaluation is centralized and idempotent`;
- non-terminal state remains playable;
- health/mood terminal state reaches existing ending path;
- repeated evaluation does not replace/reopen the ending.

Stop conditions:
- more than one direct death-reason evaluation path appears after integration;
- duplicate ending transition/re-entry;
- changed thresholds/results not explicitly authorized.

### UI-FIX-002 — Home bed seam cleanup
Repository checklist:
1. Diff remains limited to the task-owned bed foreground asset, `tools/verify_home_bed_seam.gd`, and scene-ui report.
2. Default `HomeInteractionVisual` path still selects the repaired legacy-path foreground; A/B switches remain off by default.
3. Sleep pose < duvet foreground < programmatic Z/z layering contract remains intact.
4. No sleep gameplay, navigation, shared-manager, input-routing or unrelated scene semantics change.

Headless contract commands on the exact integration SHA:
```bash
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_home_presentation.gd
godot --headless --path . --script res://tools/verify_home_activities.gd
```

Rendered evidence is mandatory before visual PASS. Run the existing activity-prop capture/default home sleep path in a real Godot rendered environment and retain screenshots/capture output showing:
- no duplicated/second bed or whole-bed foreground overlay;
- lower body and duvet read as one composition without a hard crop seam;
- head/pillow anchor remains coherent;
- foreground only covers the waist/leg region;
- only the intended Z/z effect remains above the duvet;
- enter-sleep/breathing/wake transitions remain visually coherent.

Stop conditions:
- headless contract failure;
- any sleep gameplay/navigation behavior changes;
- rendered evidence unavailable: repository acceptance may proceed, but final visual PASS must remain pending.

### UI-FIX-003 — HUD/header layout decoupling
Repository checklist:
1. Diff remains limited to authorized `scripts/ui/HUD.gd`, `tools/verify_hud_header_layout.gd`, and scene-ui report.
2. `Game.gd` and `LocationManager.gd` remain untouched by this task.
3. HUD keeps a stable 112px reserved-height contract and long dynamic labels cannot vertically grow into the independently placed location header.
4. Existing HUD refresh APIs and save/load/quit/backpack signals remain unchanged.
5. Primary/status rows and all action buttons stay inside the HUD envelope at default and 1024x720 test viewports.

Headless contract commands on the exact integration SHA:
```bash
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_locations.gd
```

Rendered evidence is mandatory before visual PASS. Inspect a real running build at 1280x720 and 1024x720 and retain screenshots/capture evidence showing:
- HUD and location header do not overlap;
- long goal/daily/time/weather/skill text stays inside the HUD;
- clipped long text remains available through tooltip where designed;
- Backpack/Save/Load/Quit remain visible, clickable and aligned;
- health/mood/fullness/energy bars and skill text do not collide;
- location title/subtitle and location controls retain existing behavior.

Stop conditions:
- any headless layout/location failure;
- controls become unreachable/clipped at the declared viewport contract;
- rendered evidence unavailable: do not claim final visual acceptance.

### NPC-CONTENT-003 — Naming/relationship-copy consistency
Repository checklist:
1. Diff remains limited to `data/quests.json`, `data/events.json`, and `agent-reports/npc-content.md`.
2. q3 remains `type=counter`, `key=store_buy`, `count=1`; only copy changes remove the unsupported gift-handoff implication.
3. Hospital acquaintance remains generic (`隔壁床的病友`) rather than aliasing core NPC 老张.
4. No IDs, counters, conditions, relation thresholds, flags, rewards, effects, flow, schema or scripts change.
5. Documented family-state findings remain findings only; they must not be silently fixed under this copy-only task.

Parser/data commands on the exact integration SHA:
```bash
python -m json.tool data/quests.json > /dev/null
python -m json.tool data/events.json > /dev/null
godot --headless --path . --script res://tools/verify_quests.gd
godot --headless --path . --script res://tools/verify_hospital.gd
```
On Windows PowerShell, omit `/dev/null` or redirect to `$null`.

Required evidence:
- both JSON documents parse successfully;
- `verify_quests.gd` exits 0 with zero quest failures;
- `verify_hospital.gd` exits 0;
- no content-load/schema regression appears.

Stop conditions:
- JSON parse failure;
- quest/hospital regression;
- integration introduces mechanics/state-condition edits under this task.

## Shared minimum headless integration gate
After task-specific narrow checks pass on one exact integration SHA, run the QA-003 six-script minimum gate in this order and stop on first non-zero exit:

```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```

Expected success signals inherited from QA-003:
- `verify_locations`: final success summary and exit 0;
- `verify_navigation`: `failures: 0` and exit 0;
- `verify_day_cycle`: all assertions complete and exit 0;
- `verify_day_flow`: reaches final day-flow money summary and exit 0;
- `verify_npc`: `NPC relation failures: 0` and exit 0;
- `verify_quests`: `quest failures: 0` and exit 0.

Important gate caveat retained from QA-003: `verify_day_cycle.gd` and `verify_day_flow.gd` are assert-heavy. Before treating them as required CI gates, QA-002/local execution must confirm a deliberately forced assertion failure produces a non-zero process exit in the exact Godot 4.7.2/CI environment. A green historical run does not prove that negative-path exit-code contract.

## Recommended integration execution order
1. Record exact integration SHA: `git rev-parse HEAD`.
2. Record engine: `godot --version` and require Godot 4.7.2 for parity with the existing QA baseline.
3. Run task-specific narrow checks for every included task.
4. Run the shared six-script headless gate.
5. Run UI rendered acceptance for UI-FIX-002 and UI-FIX-003 on that same SHA.
6. If Web/deployment is part of the candidate, perform QA-002 export/browser checks separately on the same SHA.
7. Archive command lines, exit codes, stdout/stderr, screenshots/captures and the exact SHA together.

## Integration stop rules
Do not promote an integration candidate when any of the following is true:
- branch tip used for review differs from the captured manifest and was not re-reviewed;
- task diff crosses its declared ownership boundary without an orchestrator exception;
- a task-specific regression fails;
- the shared minimum headless gate fails;
- UI task is called visually complete without rendered evidence;
- browser/Web success is claimed without actual execution;
- the tested working tree SHA cannot be identified;
- a failure is hidden by rerunning on a different SHA without documenting the change.

## What this task did not prove
QA-005 did not execute Godot, Web export, browser, screenshots, capture scripts, JSON parser commands, or an integrated multi-branch candidate. Therefore this report is a prepared acceptance manifest only. Final runtime/rendered acceptance remains QA-002/local/Codex work.

## Handoff
QA-005 repository work is complete and requests `NEEDS_REVIEW`.

For the next execution pass, construct one exact integration candidate SHA from orchestrator-approved task commits, run the task-specific commands first, then the six-script shared headless gate, and finally the two UI rendered checks. Keep Web/browser acceptance separate and do not infer it from headless success.
