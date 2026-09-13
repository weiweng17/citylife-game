# QA/Build Agent Report

## Task
- ID: QA-008
- Agent: qa-build
- Branch/worktree: `agent/qa-008-runtime-handoff-refresh`
- Status: NEEDS_REVIEW

## Scope
Report-only exact-SHA runtime handoff refresh. Per `TASK_BOARD.md`, the only writable file for QA-008 is `agent-reports/qa-build.md`.

No worker source, workflow, task board, orchestration file, `main`, scene, asset, data, or integration branch was modified. No Godot, Web export, browser, screenshot, parser, or headless verifier execution was performed or claimed.

## Coordination baseline inspected
- `orchestrator/multi-agent-bootstrap`: `4249687c2c20a5680ed5914c01f4f55665d397d9`
- QA-008 branch started at the same SHA before this report-only commit.
- `main` was observed only as a branch ref and was not modified.

## Exact branch tips captured

### UI hold candidates — runtime/render evidence still required
| Task | Branch | Current exact tip | QA disposition |
| --- | --- | --- | --- |
| UI-FIX-001 | `agent/ui-fix-001-active-npc-integration` | `07a4d159e073e9f810cf1c3007ba907a49299ae3` | Repository-reviewed previously; final visual acceptance still requires exact-SHA Godot evidence. |
| UI-FIX-002 | `agent/ui-fix-002-home-bed-seam` | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | Repository-reviewed previously; final bed/seam visual acceptance still requires exact-SHA Godot evidence. |
| UI-FIX-003 | `agent/ui-fix-003-hud-header-decoupling` | `51124e758877750d01f8b72429ead0075a73c596` | Repository-reviewed previously; final HUD/header viewport acceptance still requires exact-SHA Godot evidence. |
| UI-FIX-004 | `agent/ui-fix-004-event-panel-overflow` | `4a2ce2473dd05691fc2e1368b381497a5768d3e6` | Repository scope remains reviewable; this tip is newer than QA-007 and requires fresh headless + rendered evidence. |

### Orchestrator-accepted gameplay candidates
| Task | Branch | Current exact tip | Notes |
| --- | --- | --- | --- |
| GAME-FIX-001 | `agent/game-fix-001-daily-event-separation` | `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7` | Accepted repository delta; retain annual/event-separation regression in integration gate. |
| GAME-FIX-002 | `agent/game-fix-002-need-zero-cadence` | `ef88708a3ab120da4129fea7e0efad125fb7b0a6` | Accepted repository delta; retain hourly cadence regression. |
| GAME-FIX-003 | `agent/game-fix-003-terminal-state-evaluation` | `9ae0e807a59cba366a6013f61f22ab8d76000c82` | Accepted repository delta; authoritative terminal evaluator contract. |
| GAME-FIX-004 | `agent/game-fix-004-save-terminal-reentry` | `20d80444487074be89a7cf80cf078f6f36a98a32` | Accepted regression coverage for save/load terminal re-entry. |
| GAME-FIX-005 | `agent/game-fix-005-integration-contract-audit` | `707ba7e595c808c6cdf118c3e0faba37fa5c9830` | Accepted report-only integration contract audit; branch tip has advanced from older handoff references. |

### Accepted content candidates
| Task | Branch | Current exact tip | Notes |
| --- | --- | --- | --- |
| NPC-CONTENT-002 | `agent/npc-content-002-narrative-alignment` | `fcc70368e60a2ea8d247aa1a304d2c0a9049c89e` | Accepted content delta. |
| NPC-CONTENT-003 | `agent/npc-content-003-naming-consistency` | `def4f9ab5df04562d43380f533a4cb07cf259459` | Accepted content delta. |
| NPC-CONTENT-004 | `agent/npc-content-004-relationship-neutral-copy` | `2244d21272a08c2c6b0079917e17c5228c3f9b3d` | Accepted content delta; distinguish full branch tip from earlier effective source commit notes. |
| NPC-CONTENT-005 | `agent/npc-content-005-family-state-ambiguity-audit` | `52c814394f5fbeff484de87f6325ed6e4d85e515` | Accepted report-only audit; no data/runtime delta. |

### Latest worker continuations not yet promoted by the coordination board
These are captured for freshness only and must **not** be silently treated as accepted integration inputs until the orchestrator reviews them.

| Task | Branch | Current exact tip | Current worker finding |
| --- | --- | --- | --- |
| GAME-FIX-006 | `agent/game-fix-006-integration-callsite-guard-audit` | `a1acff1e6bb42cf04f53fb1133684ba32a363281` | Worker report is `NEEDS_REVIEW`; identifies a concrete sleep-settlement terminal-crossing gap and recommends GAME-FIX-007. |
| NPC-CONTENT-006 | `agent/npc-content-006-house-copy-neutralization` | `8fd1b880f1e6c5aa85ca7971ca482268df92b9a4` | Worker report/content change is awaiting orchestrator acceptance; do not include in accepted content set yet. |
| UI-AUDIT-005 | `agent/ui-audit-005-next-responsive-hotspot` | `58f5534d733a26e17042094c016157e7ab0bad16` | Report-only UI audit continuation; does not itself require runtime acceptance. |

## Stale-SHA hazards refreshed
1. **UI-FIX-004 changed after QA-007.** QA-007 named `3f3d39068d3e633d763d1d5181d7b9df2ccef6a3`; the current branch tip is `4a2ce2473dd05691fc2e1368b381497a5768d3e6`. Any verifier output, screenshot, or visual approval tied only to `3f3d3906...` is stale for the current review tip.
2. **UI-FIX-003 older `ff36fe63...` evidence remains invalid.** The current tip remains `51124e758877750d01f8b72429ead0075a73c596`.
3. **GAME-FIX-005 branch tip is now `707ba7e5...`.** Older notes that identify an earlier report commit should be treated as historical, not current branch-tip evidence.
4. **GAME-FIX-006 is not yet an accepted source/input task.** Its finding is important for integration planning, but its report status cannot be converted into a PASS or an authorized source repair by QA.
5. **NPC-CONTENT-006 is not yet accepted on the current coordination board.** Do not fold its `e_house` copy delta into an “accepted content” integration candidate until orchestrator review records that state.
6. Evidence is valid only for the exact integration SHA actually executed. Isolated worker-tip evidence must be regenerated if integration changes the relevant files or behavior.

## Newly material integration blocker from GAME-FIX-006
The current GAME-FIX-006 report identifies a concrete gameplay guard gap not covered by Contracts A-D:

`_sleep_through_night()` advances time and calls `_sync_needs_to_time()`, then applies sleep recovery before the authoritative `_evaluate_terminal_state()` can observe a health/mood terminal threshold crossed during overnight settlement. Because sleep occurs under the activity lock and the normal `_process()` evaluator is gated while UI/activity is busy, a temporary terminal state can be recovered above zero before shared evaluation.

QA disposition:
- This is a **repository-visible semantic risk**, not a runtime PASS/FAIL claim.
- QA must not patch `Game.gd`.
- A future integration candidate that includes GAME-FIX-001..004 but does not address this guard should be treated as having a known gameplay acceptance risk.
- If the orchestrator authorizes GAME-FIX-007 and adds `tools/verify_sleep_terminal_guard.gd`, that regression must be inserted into the gameplay gate before final runtime acceptance.

Prepared future command only if that authorized verifier exists on the candidate:

```bash
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

No execution is claimed.

## Ordered runtime handoff for one future integration candidate

### Step 0 — freeze one candidate SHA
Before running anything, record:

```bash
git rev-parse HEAD
git status --short
```

Required evidence:
- exact 40-character SHA;
- clean worktree or explicitly documented QA-only evidence artifacts;
- list of integrated task deltas represented by that SHA.

Stop if the SHA changes during the run. Restart evidence collection from the new SHA.

### Step 1 — content/data parse before Godot runtime
For an integration candidate containing accepted NPC-CONTENT-002/003/004 deltas, parse the modified JSON files with a real parser. One acceptable Python command is:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence:
- command and exit code 0;
- `JSON_PARSE_OK` output;
- diff review confirming content tasks changed only authorized string/data values and did not alter IDs/conditions/rewards/effects/flow beyond their accepted scopes.

Do not claim this step passed from repository inspection alone.

### Step 2 — task-specific gameplay regressions on the same integration SHA
Run in this order:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
```

If GAME-FIX-007 has been authorized, integrated, and its verifier exists, insert:

```bash
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

Required evidence for every command:
- exact candidate SHA;
- full command;
- process exit code;
- verifier summary/output;
- no parser/runtime error hidden behind a zero exit status.

Stop on the first failed gameplay contract. Do not continue to visual promotion as though the candidate were acceptable.

### Step 3 — UI task-specific prepared regressions on the same integration SHA
Run only when the corresponding UI delta is actually present in the integration candidate:

```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
```

UI-FIX-004's current verifier at branch tip `4a2ce247...` is intended to cover:
- logical 1280×720 and 960×540 containment;
- explicit vertical overflow ownership;
- bottom-most enabled choice reachability;
- long-result Continue reachability;
- `option_selected` and `continue_requested` signal forwarding.

These are prepared assertions only. QA-008 did not execute them.

### Step 4 — shared headless gate
Retain the six-script shared gate specified by the earlier QA headless manifest, after task-specific regressions pass. The exact scripts/ordering from that accepted QA specification should be executed on this same candidate SHA; do not substitute historical output from worker branches.

If the integration candidate changes after any gate, rerun the affected task-specific checks and the shared gate on the new SHA.

### Step 5 — rendered UI evidence on the same integration SHA
Headless PASS is insufficient for UI-FIX-001..004.

Required real Godot rendered evidence:

**UI-FIX-001 — active NPC integration**
- NPC feet visually grounded;
- scale/depth/shadow/tint coherent in scene;
- foreground occlusion correct;
- tooltip/click target aligns with visible NPC;
- dialog/talk routing remains usable.

**UI-FIX-002 — home bed seam**
- sleep composition rendered with no obvious lower-body/duvet/foreground seam regression;
- foreground layering remains coherent through the sleep presentation.

**UI-FIX-003 — HUD/header decoupling**
- declared logical viewport contracts render without header/HUD overlap or unreachable controls;
- evidence must be from current tip `51124e75...` or the exact integrated successor SHA, never the stale `ff36fe63...` reference.

**UI-FIX-004 — EventUI overflow containment**
Capture both 1280×720 and 960×540 logical viewport cases with intentionally long body/result content and many choices. Confirm:
- EventPanel remains inside the logical viewport;
- header remains visible;
- vertical scrolling owns body/choice overflow;
- long choice text wraps without horizontal escape;
- last enabled choice is fully reachable at bottom scroll extent;
- long result keeps Continue visible/clickable;
- selecting a choice and continuing preserve normal signal flow;
- background/shade composition remains correct.

Required evidence:
- exact candidate SHA visible in the run record;
- screenshots/captures for each declared viewport/scenario;
- concise inspection notes tied to those captures.

### Step 6 — Web export/browser acceptance
QA-002 remains the owner of final runtime/Web acceptance when a real Godot 4.7.2 + browser environment is available. On the exact candidate SHA:
- perform the configured Web export using the repository's existing preset;
- record command, exit code, generated artifact location, and export stderr/stdout;
- serve/open the exported build in a real browser;
- record load/console/network/runtime errors and basic interaction evidence;
- rerun any visually sensitive check that differs materially in browser rendering.

No Web/browser PASS exists from QA-008.

## Stop conditions
Stop promotion and open/route the smallest follow-up task when any of these occurs:
1. runtime evidence was collected on a SHA other than the declared integration SHA;
2. any UI evidence belongs to an older worker tip after the relevant branch advanced;
3. GAME-FIX-001..004 integration loses event/year separation, hourly need cadence, authoritative terminal evaluation, or save/load idempotency;
4. the GAME-FIX-006 sleep-settlement terminal gap remains unaddressed in a candidate that is otherwise being treated as gameplay-final;
5. a content integration changes IDs, conditions, speakers, flags, rewards, effects, counters, or flow outside the accepted task scope;
6. JSON parsing fails;
7. any task-specific or shared verifier exits nonzero or emits a failure/assertion/runtime error;
8. UI-FIX-001 NPC grounding/click/occlusion fails visually;
9. UI-FIX-002 bed seam/layering still fails visually;
10. UI-FIX-003 HUD/header overlaps or controls become unreachable;
11. UI-FIX-004 clips or hides the last enabled choice/Continue action at 960×540;
12. Web export or browser startup produces a blocking parse/runtime/resource error;
13. an unexecuted command is described as PASS.

## Validation actually performed in QA-008
Performed:
- read current orchestrator `TASK_BOARD.md` and `FILE_OWNERSHIP.md`;
- read the QA-008 branch report state;
- captured current repository branch tips from GitHub;
- reviewed QA-007's prior exact-SHA manifest to identify stale references;
- reviewed the latest GAME-FIX-006 report and current UI-FIX-004 report;
- refreshed the ordered runtime/evidence handoff without modifying worker code.

Not performed:
- Godot 4.7.2 launch;
- any `verify_*.gd` execution;
- Python/JSON parser execution against a local checkout;
- merge/cherry-pick/rebase operations;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow edits or runs.

## Handoff
QA-008 repository-only runtime handoff refresh is complete and requests `NEEDS_REVIEW`.

The immediate orchestrator review points are:
1. accept/reject the refreshed exact-SHA manifest;
2. separately review GAME-FIX-006's newly identified sleep-settlement terminal guard gap and, if accepted, authorize the minimal GAME-FIX-007 source task before treating gameplay integration as runtime-final;
3. separately review NPC-CONTENT-006 and UI-AUDIT-005 rather than silently adding them to the accepted integration set;
4. when a real Godot 4.7.2 + browser context becomes available, freeze one exact integration SHA and execute the ordered matrix above on that same SHA.
