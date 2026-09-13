# QA/Build Agent Report

## Task
- ID: QA-009
- Agent: qa-build
- Branch/worktree: `agent/qa-009-next-wave-acceptance-delta`
- Status: NEEDS_REVIEW

## Scope
Report-only acceptance delta for GAME-FIX-007, UI-FIX-005, and NPC-CONTENT-007, plus a freshness refresh for the UI-FIX-001..004 hold set.

Per `docs/agents/TASK_BOARD.md`, the only writable path for QA-009 is this report. No worker source/data/UI file, workflow, coordination file, `main`, integration branch, or task board was modified. No Godot, Web export, browser, screenshot, JSON parser, or verifier execution was performed or claimed.

## Coordination baseline
Current orchestration task definition inspected from `orchestrator/multi-agent-bootstrap` records:
- GAME-FIX-007: READY, `agent/game-fix-007-sleep-terminal-guard`
- UI-FIX-005: READY, `agent/ui-fix-005-start-screen-overflow`
- NPC-CONTENT-007: READY, `agent/npc-content-007-remaining-neutral-copy-audit`
- QA-009: READY, `agent/qa-009-next-wave-acceptance-delta`
- QA-002 remains BLOCKED on real Godot 4.7.2 + browser execution context.

The orchestration branch still functions as coordination metadata rather than the final integrated runtime candidate. Runtime evidence must therefore be collected only after one explicit integration SHA is frozen.

## Exact branch tips captured

### New QA-009 wave
| Task | Branch | Exact tip | Worker state / QA disposition |
| --- | --- | --- | --- |
| GAME-FIX-007 | `agent/game-fix-007-sleep-terminal-guard` | `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344` | Worker report `NEEDS_REVIEW`. Repository delta includes cumulative accepted GAME-FIX-001..003 gameplay semantics plus the sleep-terminal guard and `verify_sleep_terminal_guard.gd`; requires source review plus real Godot regression before runtime acceptance. |
| UI-FIX-005 | `agent/ui-fix-005-start-screen-overflow` | `a0402610cef12455dfc970641e4273c8b246d6d1` | Worker report `NEEDS_REVIEW`. StartUI overflow owner + narrow verifier prepared; final visual acceptance requires exact-SHA rendered 1280×720 and 960×540 evidence. |
| NPC-CONTENT-007 | `agent/npc-content-007-remaining-neutral-copy-audit` | `ff06b547751715a354c60d255713208f63e8c656` | Worker report `NEEDS_REVIEW`. Strict report-only audit; no runtime/parser acceptance is needed for the report itself. It identifies two possible future string-only fixes but applies none. |

### Existing UI hold set — refreshed exact tips
| Task | Branch | Exact tip | Hold reason |
| --- | --- | --- | --- |
| UI-FIX-001 | `agent/ui-fix-001-active-npc-integration` | `07a4d159e073e9f810cf1c3007ba907a49299ae3` | Repository-reviewed previously; exact-SHA rendered grounding/click/occlusion evidence still required. |
| UI-FIX-002 | `agent/ui-fix-002-home-bed-seam` | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | Repository-reviewed previously; exact-SHA rendered bed/seam/layering evidence still required. |
| UI-FIX-003 | `agent/ui-fix-003-hud-header-decoupling` | `51124e758877750d01f8b72429ead0075a73c596` | Repository-reviewed previously; exact-SHA logical-viewport render evidence still required. Older `ff36fe63...` evidence remains stale. |
| UI-FIX-004 | `agent/ui-fix-004-event-panel-overflow` | `4a2ce2473dd05691fc2e1368b381497a5768d3e6` | Repository scope accepted; exact-SHA verifier + rendered 1280×720 / 960×540 evidence still required. |

No current UI hold tip changed from the latest QA-008 handoff. Any future branch movement invalidates worker-tip-specific captures and requires this matrix to be refreshed before promotion.

## GAME-FIX-007 repository acceptance contract
GAME-FIX-007 closes the bypass identified by GAME-FIX-006: overnight `_sync_needs_to_time()` settlement can cross a terminal health/mood threshold while the activity lock prevents the normal process-loop evaluator from observing it; same-flow sleep recovery must not revive the player before the authoritative evaluator runs.

Repository review requirements before integration:
1. `_sleep_through_night()` ordering must be time advance -> `_sync_needs_to_time()` -> existing `_evaluate_terminal_state()` -> only then non-terminal sleep recovery.
2. Terminal sleep must return before `health +12`, `mood +8`, or `energy = 100` recovery.
3. The home-activity caller must release/finish activity state safely and skip normal wake/completion feedback if `game_over` was set.
4. `_evaluate_terminal_state()` remains the authoritative terminal path; no sleep-specific threshold/death/ending path is acceptable.
5. Existing GAME-FIX-001 event/year separation, GAME-FIX-002 completed-hour cadence, GAME-FIX-003 idempotent evaluator, and GAME-FIX-004 save/load re-entry contract must remain intact.
6. No save schema, annual progression, LocationManager, UI semantics, or balance values may change.

Prepared task-specific command on the exact integrated candidate SHA:

```bash
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

Expected success marker only if genuinely produced by a real run:

```text
GAME-FIX-007 PASS: overnight settlement observes terminal thresholds before sleep recovery
```

Because the GAME-FIX-007 branch reconstructs accepted GAME-FIX-001..003 semantics on top of the coordination baseline, do not merge historical gameplay branches wholesale and then also merge the full 007 branch blindly. The orchestrator must form one deterministic integrated `Game.gd` candidate and QA must test that exact final SHA.

## UI-FIX-005 repository and visual acceptance contract
UI-FIX-005 adds an explicit bounded vertical overflow owner to StartUI while preserving the existing pre-tree `setup()` lifecycle and post-ready load availability updates.

Prepared task-specific headless command on the exact integrated candidate SHA:

```bash
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
```

The prepared verifier is expected to exercise:
- `setup(origins, money_formatter)` before `add_child()`;
- logical 1280×720 and 960×540 viewport contracts;
- four stress-shaped origin cards;
- vertical scroll reachability to the fourth card and optional load button;
- no required horizontal scrolling;
- exact origin dictionary forwarding through `origin_selected(origin)`;
- `load_requested` signal routing;
- post-ready `set_load_available(value)` behavior;
- close/reopen reset to top rather than retaining stale bottom scroll.

Headless PASS is necessary but not sufficient. Final UI-FIX-005 visual acceptance requires real rendered captures on the **same exact SHA** at:
- 1280×720 logical viewport;
- 960×540 logical viewport.

Required rendered evidence:
1. StartUI panel remains correctly contained in the logical viewport.
2. Title/subtitle/cards remain horizontally contained without horizontal-scroll dependency.
3. At 960×540, vertical scrolling is usable and all four origin cards are reachable.
4. When enabled, `读取上次存档` is reachable and clickable at the bottom.
5. Wrapped description/stat text does not escape card width.
6. Full-card click targets match visible cards and emit the intended supplied origin dictionary.
7. Post-ready load visibility toggling does not leave broken spacing or scroll state.
8. Close/reopen/restart returns the StartUI scroll position to the top.
9. Selecting an origin and loading a save preserve the current Game flow.

Do not mark UI-FIX-005 DONE from source inspection or a headless verifier alone if the task's rendered acceptance has not been collected.

## NPC-CONTENT-007 acceptance contract
NPC-CONTENT-007 is report-only. Repository acceptance should confirm that its branch delta is limited to `agent-reports/npc-content.md` and that no content/data/mechanics files were changed.

The report identifies exactly two future safe copy-only candidates:
- `e_first_salary`: incidental `给妈妈转了两千` relation assumption;
- `e_sidejob`: incidental `你妈的一台洗衣机` relation assumption.

It explicitly does **not** modify these strings, and it keeps speaker/premise-level cases plus the four family-policy cases outside its safe-copy scope. Therefore QA-009 does not add a parser/runtime gate for accepting the 007 audit itself.

If a later NPC task actually edits those JSON strings, that later source task must re-enter the JSON parse/diff gate on its own exact integrated SHA.

## Single-integration-SHA runtime handoff
All executable validation below must target one frozen integrated commit. Never combine PASS evidence from isolated worker tips and call the combined repository accepted.

### Step 0 — freeze candidate identity
```bash
git rev-parse HEAD
git status --short
```

Record:
- exact 40-character integration SHA;
- clean worktree, or explicitly documented QA-only evidence files;
- exact task deltas represented by the candidate.

**Stale-SHA stop condition:** if `HEAD` changes at any point, stop and restart affected evidence collection on the new SHA.

### Step 1 — parse source data if the integration candidate contains content JSON changes
```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence:
- command;
- exit code 0;
- literal `JSON_PARSE_OK` output;
- diff review showing no unauthorized ID/condition/speaker/flag/effect/counter/schema/flow changes.

NPC-CONTENT-007 by itself is report-only and does not make this step pass or fail; run it when the final integration candidate contains actual accepted content deltas.

### Step 2 — complete Gameplay task-specific regressions
On the exact same candidate SHA:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

For each command capture:
- exact SHA;
- complete command;
- exit code;
- verifier summary;
- stderr/stdout sufficient to prove no hidden parse/runtime/assertion failure.

Stop on the first failed Gameplay contract. Do not continue promotion while treating later output as compensating for an earlier failure.

### Step 3 — UI task-specific headless regressions
Run only when the corresponding UI delta exists on the integration candidate:

```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
```

Do not infer visual correctness from these scripts. They are regression gates for prepared contracts, not substitutes for rendered acceptance.

### Step 4 — shared headless gate
After task-specific regressions pass, execute the accepted shared QA headless gate from the current QA manifest on this same integration SHA. Do not reuse historical worker-branch output.

Any candidate change after a gate invalidates at least the affected task-specific checks and the shared gate; rerun them on the new SHA.

### Step 5 — real rendered UI acceptance
Collect real Godot evidence on this same SHA for UI-FIX-001..005.

Hold requirements retained from prior QA:
- UI-FIX-001: grounded NPC feet, coherent scale/depth/shadow/tint, correct foreground occlusion, aligned click/tooltip target, usable talk/dialog routing.
- UI-FIX-002: sleep pose/bed/duvet/foreground composition without visible seam/layering regression.
- UI-FIX-003: declared logical viewports without HUD/header overlap or unreachable controls.
- UI-FIX-004: 1280×720 + 960×540, long body/result, many choices, last enabled choice reachable, Continue reachable, no horizontal escape, signal flow preserved.
- UI-FIX-005: 1280×720 + 960×540 StartUI evidence exactly as specified above.

Every capture must be tied to the exact integrated SHA. If the UI branch/source changes after capture, that evidence is stale.

### Step 6 — Web export/browser acceptance
QA-002 remains blocked until a real Godot 4.7.2 + browser environment is available. When available, on the same candidate SHA:
- run the repository's configured Web export;
- capture command, exit code, stdout/stderr, and artifact location;
- serve/open the exported build in a real browser;
- capture console/network/runtime errors;
- exercise start/origin/load, core gameplay progression, terminal state, and visually sensitive UI flows represented by the integrated wave.

No Web/browser PASS exists from QA-009.

## Stop / escalation conditions
Stop promotion and route the smallest owning-domain follow-up when any of these occurs:
1. runtime evidence references a SHA other than the declared integrated candidate;
2. a Worker branch advances after evidence was captured for its old tip;
3. GAME-FIX-007 introduces a second terminal/death path instead of the existing authoritative evaluator;
4. overnight terminal settlement can still receive sleep recovery before `game_over` is observed;
5. any GAME-FIX-001..004 contract regresses while integrating 007;
6. GAME-FIX-007 changes sleep duration, recovery values, annual progression, save schema, UI semantics, or LocationManager behavior outside its assignment;
7. StartUI `setup()` is no longer safe before `add_child()`, or `set_load_available()` is unsafe post-ready;
8. UI-FIX-005 requires horizontal scrolling, loses any origin card/load action, forwards the wrong origin payload, or reopens at stale bottom scroll;
9. UI-FIX-005 lacks actual 1280×720 and 960×540 rendered evidence;
10. UI-FIX-001..004 rendered evidence is absent, stale, or tied to an obsolete tip;
11. NPC-CONTENT-007 is found to change any file other than its own report;
12. a future content implementation derived from NPC-CONTENT-007 changes speakers/conditions/IDs/flags/effects/schema/flow instead of only authorized strings;
13. JSON parsing fails on an integration candidate containing JSON changes;
14. any verifier/shared gate exits nonzero or emits an assertion/parse/runtime failure;
15. Web export/browser startup produces a blocking parse/runtime/resource error;
16. an unexecuted command is described as PASS.

## Validation actually performed in QA-009
Performed:
- read current orchestrator `TASK_BOARD.md`;
- read `FILE_OWNERSHIP.md`;
- read the current QA-009 branch report state;
- captured exact branch tips for GAME-FIX-007, UI-FIX-005, NPC-CONTENT-007, and UI-FIX-001..004;
- inspected GAME-FIX-007 Worker report and its prepared regression contract;
- inspected UI-FIX-005 Worker report and rendered/headless acceptance requirements;
- inspected NPC-CONTENT-007 report-only findings;
- reviewed QA-008's prior single-SHA handoff so this delta extends rather than replaces the existing gate.

Not performed:
- Godot 4.7.2 launch;
- any `verify_*.gd` execution;
- JSON parser execution against a local checkout;
- merge/cherry-pick/rebase operations;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow edits/runs;
- worker-source edits.

## Handoff
QA-009 repository-only acceptance delta is complete and requests `NEEDS_REVIEW`.

Immediate orchestrator review points:
1. review GAME-FIX-007 as an integration-ready gameplay candidate, with special attention to the cumulative `Game.gd` composition and the requirement to preserve the one authoritative terminal evaluator;
2. keep UI-FIX-005 in rendered-evidence hold until both exact-SHA headless regression and real 1280×720 + 960×540 captures exist;
3. accept NPC-CONTENT-007 only as a report-only audit; any two-string neutralization should be a separate future NPC task;
4. preserve UI-FIX-001..004 visual holds and their refreshed exact tips;
5. when a real Godot 4.7.2 + browser context exists, freeze one exact integration SHA and execute the ordered matrix above without mixing evidence from isolated branches.