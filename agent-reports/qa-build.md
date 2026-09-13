# QA/Build Agent Report

## Task
- ID: QA-007
- Agent: qa-build
- Branch/worktree: `agent/qa-007-next-wave-delta`
- Status: NEEDS_REVIEW

## Scope
Repository-only branch freshness and acceptance-delta audit. Writable scope is `agent-reports/qa-build.md` only.

No worker code, task board, workflow, `main`, integration branch, data, scene, or asset file was modified. No Godot/Web/browser/runtime execution was performed or claimed.

## Coordination baseline
- `orchestrator/multi-agent-bootstrap`: `ecb3b9331ef1b94095529a083c12636e47983176`
- QA-007 task branch was created from that coordination baseline.

## Exact candidate tips captured
| Task | Branch | Exact current tip | Repository-only disposition |
| --- | --- | --- | --- |
| GAME-FIX-004 | `agent/game-fix-004-save-terminal-reentry` | `20d80444487074be89a7cf80cf078f6f36a98a32` | Already orchestrator-accepted; freshness captured for integration/runtime evidence. |
| UI-AUDIT-004 | `agent/ui-audit-004-responsive-hotspots` | `1094294932a7f73f5d8c34a96ec0725423eaab98` | Report-only and already accepted. No render claim required for the audit itself. |
| UI-FIX-004 | `agent/ui-fix-004-event-panel-overflow` | `3f3d39068d3e633d763d1d5181d7b9df2ccef6a3` | Repository/layout contract reviewable; rendered acceptance still outstanding. |
| NPC-CONTENT-004 | `agent/npc-content-004-relationship-neutral-copy` | `2244d21272a08c2c6b0079917e17c5228c3f9b3d` | Already orchestrator-accepted; current branch tip differs from the earlier effective source commit recorded in worker notes, so evidence must name this full tip when referring to the branch. |
| NPC-CONTENT-005 | `agent/npc-content-005-family-state-ambiguity-audit` | `52c814394f5fbeff484de87f6325ed6e4d85e515` | Report-only; repository-reviewable with no runtime claim. |
| UI-FIX-001 | `agent/ui-fix-001-active-npc-integration` | `07a4d159e073e9f810cf1c3007ba907a49299ae3` | Repository implementation is reviewable; final visual acceptance still requires exact-SHA Godot evidence. |
| UI-FIX-002 | `agent/ui-fix-002-home-bed-seam` | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | Repository/presentation implementation is reviewable; final visual acceptance still requires exact-SHA Godot evidence. |
| UI-FIX-003 | `agent/ui-fix-003-hud-header-decoupling` | `51124e758877750d01f8b72429ead0075a73c596` | Repository/layout implementation is reviewable; final visual acceptance still requires exact-SHA Godot evidence. |

## Freshness and stale-SHA hazards
1. **UI-FIX-003 stale evidence hazard is confirmed.** Any QA note or screenshot tied to the older `ff36fe63...` value is stale. The current branch tip is `51124e758877750d01f8b72429ead0075a73c596`; rendered or regression evidence must be regenerated on that SHA (or on a later explicitly recorded integration SHA).
2. **UI-FIX-004 has continued after its production change.** Its current review tip is `3f3d3906...`; the worker report records later verifier/review hardening after the initial EventUI implementation. Do not reuse evidence captured on an earlier UI-FIX-004 commit as proof of the current review tip.
3. **NPC-CONTENT-004 has two useful identifiers with different meanings.** Worker audit notes reference `fb0b932c...` as the accepted effective copy delta, while the branch itself now ends at `2244d212...` after report completion. QA must distinguish “effective source commit” from “current branch tip” rather than treating them as interchangeable.
4. **GAME-FIX-004 current branch tip is `20d80444...`.** Older handoff values from earlier review iterations must not be reused as exact-SHA runtime evidence.
5. **UI hold branches are not fresh descendants of the current orchestrator baseline.** Repository comparison against `ecb3b933...` shows:
   - UI-FIX-001: diverged, ahead 6 / behind 7;
   - UI-FIX-002: diverged, ahead 7 / behind 5;
   - UI-FIX-003: diverged, ahead 8 / behind 3.
   Therefore none of these should be whole-branch merged or treated as if their branch history equals the current integration state. Apply/reconcile their task deltas deliberately, then rerun acceptance on the resulting exact integration SHA.
6. UI-FIX-004 is a clean descendant of the current coordination baseline (ahead 6 / behind 0). GAME-FIX-005 and NPC-CONTENT-005 likewise started from the same current coordination baseline, but QA-007 does not promote their worker status; it only records freshness/acceptance deltas.

## Acceptance delta by task

### GAME-FIX-004 — save/load terminal re-entry
Repository state:
- Orchestrator already accepted the task at repository level.
- GAME-FIX-004 is a descendant of the accepted GAME-FIX-003 line and adds the save/load re-entry regression/report rather than a second terminal-state implementation.

Required narrow runtime check on the exact integration candidate SHA:
```bash
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
```
Because this contract depends on the centralized evaluator from GAME-FIX-003, isolated branch PASS is not sufficient for final combined acceptance. On the final gameplay integration SHA also retain the terminal-state and earlier gameplay regressions specified by QA-006/GAME-FIX-005.

Runtime status here: **NOT RUN**.

### UI-AUDIT-004 — responsive hotspot inventory
- Report-only task; branch tip `1094294932a7f73f5d8c34a96ec0725423eaab98`.
- No source/runtime delta exists to re-test for the audit itself.
- Its actionable output was the EventUI overflow hotspot, now implemented as UI-FIX-004.

Repository review: sufficient for the audit task itself.
Runtime/render requirement: none for UI-AUDIT-004 itself.

### UI-FIX-004 — EventUI overflow containment
Current exact review tip: `3f3d39068d3e633d763d1d5181d7b9df2ccef6a3`.

Current branch diff versus coordination baseline is limited to the declared task scope:
- `scripts/ui/EventUI.gd`
- `tools/verify_event_panel_overflow.gd`
- `agent-reports/scene-ui.md`

Prepared narrow check:
```bash
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
```
Expected runtime evidence must be recorded, not inferred. The verifier is prepared to exercise 1280×720 and 960×540 logical viewports, long narrative/result copy, multiple long enabled choices, explicit vertical scroll range, bottom-most choice reachability, and visible result continuation.

Required rendered evidence on the same exact candidate SHA:
- 1280×720 logical viewport;
- 960×540 logical viewport;
- long narrative plus multi-choice case;
- last enabled choice reachable at bottom scroll extent;
- long result keeps Continue reachable/clickable;
- signal/event flow unchanged.

Repository/layout review can proceed now. Final visual PASS cannot.

### NPC-CONTENT-004 — relationship-neutral copy cleanup
Current branch tip: `2244d21272a08c2c6b0079917e17c5228c3f9b3d`.

Repository/content acceptance already exists. For any future integrated candidate that absorbs this delta:
- parse `data/events.json` successfully;
- verify only the accepted string-level substitutions are introduced for this task;
- ensure IDs, conditions, speakers, flags, rewards, effects and flow are unchanged;
- then include normal event/data loading in the shared runtime gate.

No parser or Godot execution was performed in QA-007.

### NPC-CONTENT-005 — family-state ambiguity inventory
Current exact tip: `52c814394f5fbeff484de87f6325ed6e4d85e515`.

The branch is exactly one report commit ahead of the current orchestrator baseline and changes only `agent-reports/npc-content.md`. It identifies four hard policy-dependent cases (`e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`) plus one low-priority copy-only risk (`e_house`).

Repository review is sufficient for NPC-CONTENT-005 itself. No JSON/parser/runtime test is required because the task does not modify data. A future implementation task must not invent married-household versus co-parent-inclusive policy without explicit ownership/decision.

### UI-FIX-001 — active NPC grounding/animation
Current exact tip: `07a4d159e073e9f810cf1c3007ba907a49299ae3`.

Prepared narrow regression:
```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
```
Required rendered follow-up on the same exact SHA/integration candidate includes `tools/capture_npc.gd` plus inspection of NPC foot grounding, scale, tint/shadow, foreground occlusion, tooltip/click alignment, and dialog routing.

Repository review remains acceptable; visual PASS remains blocked on real Godot evidence.

### UI-FIX-002 — home bed seam
Current exact tip: `b480befaedc3a3b0cbdaca1916e31dbba7283121`.

Current task diff includes:
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png`
- `tools/verify_home_bed_seam.gd`
- `agent-reports/scene-ui.md`

Prepared narrow regression:
```bash
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
```
The image/layering change remains visually sensitive, so repository evidence cannot replace a real rendered sleep/bed capture on the exact candidate SHA.

### UI-FIX-003 — HUD/header decoupling
Current exact tip: `51124e758877750d01f8b72429ead0075a73c596`.

Current task diff includes:
- `scripts/ui/HUD.gd`
- `tools/verify_hud_header_layout.gd`
- `agent-reports/scene-ui.md`

Prepared narrow regression:
```bash
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
```
Repository layout review remains acceptable. Real Godot rendering at the task's declared logical viewport contracts is still required before final visual PASS, and any evidence tied to the older `ff36fe63...` SHA is invalid for this current tip.

## Repository-reviewable vs runtime/render-blocked
Repository-reviewable without new execution:
- GAME-FIX-004 repository delta/status freshness (already accepted by orchestrator; runtime integration still pending)
- UI-AUDIT-004
- NPC-CONTENT-004 repository/content delta/status freshness (already accepted)
- NPC-CONTENT-005
- repository ownership/diff checks for UI-FIX-001/002/003/004

Still requires real Godot/browser/render evidence before final promotion:
- GAME-FIX-004 combined runtime acceptance on the final gameplay integration SHA;
- UI-FIX-001 rendered NPC grounding/click/occlusion evidence;
- UI-FIX-002 rendered bed/sleep seam evidence;
- UI-FIX-003 rendered HUD/header viewport evidence;
- UI-FIX-004 headless verifier plus rendered 1280×720 and 960×540 EventUI evidence;
- QA-002 as a whole remains blocked until a real Godot 4.7.2 + browser execution context is available.

## Stop conditions for later integration QA
Stop promotion and open a minimal follow-up issue/task rather than silently accepting if any of the following occurs:
1. the candidate SHA differs from the SHA on which evidence was captured;
2. a UI task is tested only on its isolated worker tip but integrated source differs afterward;
3. any UI hold branch is merged wholesale despite its divergence from the current coordination baseline;
4. EventUI bottom-most enabled choice cannot be reached at 960×540;
5. HUD/bed/NPC rendered evidence shows clipping, grounding, scale, occlusion or click-target regressions;
6. GAME-FIX-004 reintroduces a save-specific terminal path or fails idempotent re-entry on the combined candidate;
7. NPC-CONTENT-004 integration changes structure/mechanics rather than strings only;
8. any unexecuted command is recorded as PASS.

## Validation performed in QA-007
Performed:
- read current orchestrator task board and file-ownership policy;
- captured exact current branch tips listed above;
- compared UI-FIX-001/002/003 and UI-FIX-004 against the current coordination baseline;
- reviewed current GAME-FIX-005, UI-FIX-004 and NPC-CONTENT-005 worker reports for their latest acceptance contracts;
- confirmed QA-007 writable scope is report-only.

Not performed:
- Godot 4.7.2 execution;
- any `verify_*.gd` execution;
- Web export;
- browser execution;
- screenshots/render inspection;
- JSON parser execution;
- merge/cherry-pick/integration operations.

## Handoff
QA-007 repository-only freshness and acceptance-delta audit is complete and requests `NEEDS_REVIEW`.

For the next runtime-capable QA step, first assemble or identify one exact integration candidate SHA, then run each task-specific narrow regression on that same candidate, followed by the broader shared headless gate. UI-FIX-001/002/003/004 must retain separate real rendered evidence; do not promote them from repository inspection alone.