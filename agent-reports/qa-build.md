# QA/Build Agent Report

## Task
- ID: QA-004 — Repair-wave acceptance matrix
- Agent: qa-build
- Branch/worktree: `agent/qa-004-repair-wave-acceptance-matrix`
- Status: NEEDS_REVIEW

## Scope
Report-only QA planning for the current repair wave. Writable scope is this report only. No source, scene, asset, workflow, task-board, project/export configuration, or worker branch files were modified.

## Summary
Prepared an exact acceptance matrix for GAME-FIX-001, UI-FIX-001, and NPC-CONTENT-002. The matrix is branch/SHA-specific, separates repository checks from headless runtime checks and rendered/manual checks, includes the new narrow regressions where present, and defines stop conditions before integration.

No Godot process, Web export, browser, or rendered capture was run in this QA-004 execution. The commands below are prepared execution instructions, not claimed results.

## Coordination state inspected
- `orchestrator/multi-agent-bootstrap` task board: GAME-FIX-001 is repository-accepted/DONE; UI-FIX-001 remains NEEDS_REVIEW pending rendered evidence; NPC-CONTENT-002 is IN_PROGRESS on the board but its worker report has returned to NEEDS_REVIEW after correcting the `老周` collision.
- Ownership policy: QA may inspect the full repository but this task authorizes only `agent-reports/qa-build.md` for writes.
- QA-003 headless-gate specification: minimum reusable headless gate is `verify_locations.gd`, `verify_navigation.gd`, `verify_day_cycle.gd`, `verify_day_flow.gd`, `verify_npc.gd`, `verify_quests.gd`; `verify_home_input.gd` is windowed-only; legacy `verify.gd` and the five old `Verify*.tscn` diagnostics must not be treated as required modern gates.

## Exact acceptance matrix

### 1. GAME-FIX-001 — Separate daily event closure from annual progression

**Candidate branch / exact current tip**
- Branch: `agent/game-fix-001-daily-event-separation`
- Branch tip inspected: `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7`
- Source implementation commit recorded by worker: `d7b0cae0741a08a64c2ee68c050a8913a3bc6f89`
- Current branch diff vs coordination is limited to:
  - `scripts/Game.gd`
  - `tools/verify_event_year_separation.gd`
  - `agent-reports/gameplay.md`

**Repository checks — required before runtime**
1. Confirm `_close_event()` does not call `_year_pass()` on ordinary event closure.
2. Confirm ordinary no-event paths in `_enter_place()` and `_interior_boss()` do not advance a year.
3. Confirm explicit annual progression remains callable through `_year_pass()` and still reaches `rules_sys.year_tick(st)`.
4. Confirm the existing explicit dark-story `pass_year` path remains intact.
5. Confirm no balance values, save schema, or unrelated gameplay semantics changed.

**Task-specific headless regression — required**
```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
```
Expected evidence:
- exit code `0`;
- stdout contains `GAME-FIX-001 PASS: regular event/no-event closure is separated from explicit annual progression`.

**Shared headless regression — required on the same exact SHA**
Run at minimum, in order:
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```
Record command, exit code, stdout/stderr, and the tested SHA for every command.

**Rendered/browser evidence**
- Not intrinsically required for this logic-only fix.
- Web/browser acceptance remains part of QA-002 integration acceptance if this candidate is included in a deployable integration SHA.

**Stop conditions**
- Any non-zero task-specific regression result.
- Any shared regression failure.
- Any evidence that ordinary event/no-event closure changes age/year or applies annual income/cost/recovery.
- Any branch movement after test start: if `git rev-parse HEAD` is no longer `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7`, discard the evidence and rerun on the new exact candidate.

**Integration decision**
- Repository-level acceptance is already recorded by orchestrator.
- Fresh runtime acceptance remains pending until the commands above are actually executed on an integration candidate containing this change.

---

### 2. UI-FIX-001 — Active NPC grounding and animation integration

**Candidate branch / exact current tip**
- Branch: `agent/ui-fix-001-active-npc-integration`
- Branch tip inspected: `07a4d159e073e9f810cf1c3007ba907a49299ae3`
- Current branch diff vs coordination is limited to:
  - `scripts/systems/LocationManager.gd`
  - `scripts/world/ActiveNpcVisual.gd`
  - `tools/verify_active_npc_visual.gd`
  - `agent-reports/scene-ui.md`

**Repository checks — required before runtime**
1. Confirm the active NPC path creates the grounded visual helper while preserving the separate transparent `Npc_<id>` click/talk layer.
2. Confirm Xiaoyu/Chenjie use walk-capable 4-direction sprite-sheet presentation where available.
3. Confirm static fallback remains available for legacy NPC artwork.
4. Confirm feet/visual origin, contact shadow, depth ordering, scale normalization, and lighting contract are implemented from the NPC foot coordinate.
5. Confirm `_clear_npcs()` removes both visual and click layers.
6. Confirm no NPC dialogue/content semantics, gameplay settlement, navigation, task board, or unrelated scene-root changes are present.

**Task-specific headless regression — required**
```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
```
Expected evidence:
- exit code `0`;
- regression confirms 4-direction/4-frame walk-sheet construction for Xiaoyu, idle reset, static fallback, grounding/shadow contract, `LocationManager` visual creation, tooltip preservation, `npc_requested("xiaoyu")` routing, and `_clear_npcs()` cleanup.

**Shared headless regression — required on the same exact SHA**
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_npc.gd
```
Also run the remaining QA-003 minimum gate before final integration:
```bash
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_quests.gd
```

**Rendered/windowed evidence — mandatory before visual PASS**
Run Godot with rendering enabled on this exact SHA. Use the existing capture path noted by the worker (`tools/capture_npc.gd`) and record screenshots/captures that prove at minimum:
1. Xiaoyu at home: feet contact, scale, idle frame, tint, contact shadow.
2. Chenjie at store: same grounding checks.
3. One static fallback NPC such as Lao Zhang: source-size normalization and contact shadow.
4. Foreground occlusion near furniture/scene foreground: NPC must sort visually without appearing pasted on top of everything.
5. Relationship hover label and tooltip/click target alignment.
6. Clicking the NPC opens the expected dialog through the existing route.

Prepared rendered command form:
```bash
godot --path . --rendering-method gl_compatibility --script res://tools/capture_npc.gd
```
If the capture script expects a scene or arguments in the local environment, record the exact invocation actually used; do not substitute a claimed result without a real rendered run.

**Stop conditions**
- `verify_active_npc_visual.gd` exits non-zero.
- Any minimum/shared headless regression fails.
- Rendered capture shows floating feet, wrong scale, obvious foreground/depth break, missing/misaligned click target, incorrect tooltip/hover label, or dialogue routing failure.
- Capture/test SHA differs from `07a4d159e073e9f810cf1c3007ba907a49299ae3` or a later explicitly recorded candidate SHA.
- Rendered evidence is absent: repository acceptance may proceed, but visual task must not be marked fully accepted/integrated as visually complete.

**Integration decision**
- Repository implementation is structurally reviewable.
- Final UI-FIX-001 acceptance must remain blocked on real rendered evidence from the exact candidate SHA.

---

### 3. NPC-CONTENT-002 — Narrative/mechanic alignment cleanup

**Candidate branch / exact current tip**
- Branch: `agent/npc-content-002-narrative-alignment`
- Branch tip inspected: `fcc70368e60a2ea8d247aa1a304d2c0a9049c89e`
- Final hospital correction commit recorded by worker: `e78ad96b72374033c89f4bc5ac9bfc7743b43f5d`
- Original q3 content commit recorded by worker: `46eba39101b2e7bddbe27c3c49513462b2af6e87`
- Current branch diff vs coordination is limited to:
  - `data/quests.json`
  - `data/events.json`
  - `agent-reports/npc-content.md`

**Repository/content checks — required**
1. `q3_someone_waits` remains `type=counter`, `key=store_buy`, `count=1`.
2. q3 step/done copy describes only buying something at the store and does not claim a completed gift handoff to 小雨.
3. `e_final_health` result copy uses a generic non-core identity: `隔壁床的病友`.
4. No quest/event IDs, counters, conditions, rewards, effects, age ranges, flags, `next` flow, or schema structure changed.
5. Diff remains copy/content-only inside the two authorized JSON files plus the report.

**JSON parser check — required**
Run a real JSON parser against both files on the exact candidate SHA. Example:
```bash
python -m json.tool data/quests.json > /dev/null
python -m json.tool data/events.json > /dev/null
```
Expected evidence: both commands exit `0` with no parse errors.

**Headless gameplay/content regressions — required**
```bash
godot --headless --path . --script res://tools/verify_quests.gd
godot --headless --path . --script res://tools/verify_hospital.gd
```
Then run the full QA-003 six-script minimum gate before integration:
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```
`verify_quests.gd` need not be executed twice in one run if already included and recorded once on the exact same SHA.

**Rendered/browser evidence**
- No rendered visual proof is intrinsically required for these copy-only edits.
- If the final integration candidate is Web-exported under QA-002, browser smoke should confirm the affected quest/event screens load without runtime parse/data errors, but this is integration acceptance rather than a content-edit-specific visual criterion.

**Stop conditions**
- JSON parser failure.
- Any change to IDs/counters/conditions/effects/flow/schema beyond string copy.
- q3 copy again implies a gift was handed to a recipient despite only `store_buy` being checked.
- Hospital copy contains a core NPC name such as `老张` or `老周` as the newly met patient.
- `verify_quests.gd`, `verify_hospital.gd`, or any minimum gate command fails.
- Test SHA differs from `fcc70368e60a2ea8d247aa1a304d2c0a9049c89e` or a later explicitly recorded candidate SHA.

**Integration decision**
- Current branch-tip content satisfies the prior narrative review finding at repository level.
- Runtime/data-load acceptance is still pending fresh parser/Godot execution; no such execution is claimed here.

## Cross-task ordered acceptance sequence
For a final integration candidate, do not combine evidence from different SHAs. First create/identify one exact integration SHA containing the accepted worker changes, then record:

1. `git rev-parse HEAD` and Godot version (`godot --version`).
2. Repository diff/ownership review against the intended integration base.
3. JSON parser checks for `data/quests.json` and `data/events.json` when NPC-CONTENT-002 is included.
4. Task-specific narrow regressions:
   - `verify_event_year_separation.gd`
   - `verify_active_npc_visual.gd`
5. Content/system targeted regressions:
   - `verify_hospital.gd`
6. QA-003 minimum six-script headless gate:
   - `verify_locations.gd`
   - `verify_navigation.gd`
   - `verify_day_cycle.gd`
   - `verify_day_flow.gd`
   - `verify_npc.gd`
   - `verify_quests.gd`
7. Windowed/rendered UI-FIX-001 capture and click/dialog checks.
8. If the candidate is intended for Web delivery, QA-002 then performs export, artifact, deployed HTTP, browser startup/console/runtime acceptance on that same SHA.

Stop the sequence on the first unexplained non-zero exit or visual/runtime defect. Do not merge evidence from an older branch tip after the candidate SHA changes.

## Evidence produced in QA-004
Repository-only evidence gathered in this run:
- GAME-FIX-001 current tip: `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7`; diff paths are the authorized `Game.gd`, narrow regression, and gameplay report.
- UI-FIX-001 current tip: `07a4d159e073e9f810cf1c3007ba907a49299ae3`; diff paths are the authorized manager/helper/regression/report set.
- NPC-CONTENT-002 current tip: `fcc70368e60a2ea8d247aa1a304d2c0a9049c89e`; diff paths are exactly the two authorized JSON files plus the NPC report.
- Worker reports explicitly state that fresh Godot/Web/rendered evidence was not run for these fixes.

## Validation performed by QA-004
- GitHub task-board/ownership/report inspection: performed.
- Branch-tip inspection: performed.
- Branch diff-path inspection: performed.
- Godot headless execution: not performed.
- JSON parser execution: not performed.
- Rendered Godot capture: not performed.
- Web export/browser execution: not performed.

## Handoff
QA-004 is complete as a report-only acceptance-planning task and requests `NEEDS_REVIEW`.

The next execution step is QA-002/local/Codex runtime acceptance on one exact integration SHA. UI-FIX-001 must not receive final visual PASS without real rendered evidence. GAME-FIX-001 and NPC-CONTENT-002 should likewise receive fresh runtime/data-load evidence before deployment acceptance, even though their repository-level changes are already reviewable.
