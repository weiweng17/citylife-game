# QA/Build Agent Report

## Task
- ID: QA-012
- Agent: qa-build
- Branch/worktree: `agent/qa-012-post-review-integration-manifest`
- Status: NEEDS_REVIEW

## Scope
Report-only post-review integration manifest for the repository-reviewed 009/006/009 wave, refreshed after the next worker lanes produced new outputs while the orchestrator task board still records those follow-ups as `READY`.

Per `docs/agents/TASK_BOARD.md`, the only writable path for QA-012 is this report.

No merge, cherry-pick, rebase, source/data/UI/workflow edit, task-board edit, parser execution, Godot launch, verifier execution, Web export, browser run, screenshot capture, or rendered validation was performed or claimed.

This continuation does not repeat or replace the already completed manifest logic. It refreshes only facts that changed after the previous QA-012 report commit.

## Current control-plane state
Latest coordination state inspected:
- coordination branch: `orchestrator/multi-agent-bootstrap`
- coordination tip: `96a202796d5b454f730bf84c566367e8564db7f4`
- task board still lists QA-012 as `READY`
- this QA-012 report was already `NEEDS_REVIEW` before the present refresh
- `main`: `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b`

The unchanged task-board state means the orchestrator has not yet mirrored/reviewed this QA-012 result. QA does not edit `TASK_BOARD.md` and does not self-promote to DONE.

Neither coordination SHA nor `main` is the runtime acceptance candidate. QA-002 still requires one separately assembled and explicitly frozen integration SHA.

## Repository-reviewed 009/006/009 identities — unchanged
These remain the only accepted inputs from the wave named by QA-012:

| Task | Accepted exact tip | Repository disposition | Runtime-candidate effect |
| --- | --- | --- | --- |
| GAME-FIX-009 | `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d` | DONE | Source + verifier input. Its `Game.gd` is the deterministic cumulative Gameplay semantic state through 009. |
| UI-FIX-006 | `d328f227b8473297d4b74c058dfd1a7101a68074` | BLOCKED only on real exact-SHA runtime/rendered evidence | Source + verifier input. Include ShopUI overflow containment, but do not call it runtime/rendered PASS. |
| NPC-AUDIT-009 | `a16920be7462436c1070e79e833cbadb7bdd0bd1` | DONE | No source/runtime input. Report-only triage defining follow-up boundaries. |

File-level identities for the two implementation inputs:

### GAME-FIX-009
- `scripts/Game.gd`
  - blob `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`
- `tools/verify_terminal_mutation_order.gd`
  - blob `79d07a38ac0ea07a8e17530028c776606f24070c`

### UI-FIX-006
- `scripts/ui/ShopUI.gd`
  - blob `200d60bc34200dda3b6c2a1ff51c25c3bd8788d7`
- `tools/verify_shop_panel_overflow.gd`
  - blob `1924219242ba146e40106cdd03bbda3374af712a`

Integration must use these accepted exact identities, not a later moving branch head.

## What changed after the previous QA-012 capture
The previous QA-012 report correctly recorded that GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 had no worker deltas at that time. That statement is now stale.

All three worker branches have since moved, but the current task board still records every one of those tasks as `READY`, not DONE/accepted. Therefore their current outputs are **unreviewed worker results** from the control-plane perspective.

### GAME-AUDIT-010 — worker output exists, not orchestrator-accepted yet
Branch:
- `agent/game-audit-010-terminal-mutation-surface`

Current worker tip:
- `fee1ee8072aeea821fd78881fbb4b0a06404526b`

Comparison against its coordination start `96a202796d5b454f730bf84c566367e8564db7f4`:
- ahead 1 / behind 0
- changed path: `agent-reports/gameplay.md` only

Worker report status:
- `NEEDS_REVIEW`

Repository-only worker conclusion:
- no new deterministic/repository-proven terminal revival or masking bypass found after accepted GAME-FIX-009;
- no new Gameplay source task proposed;
- one runtime-only event-loop stress candidate is identified: pending travel-time need settlement followed by an immediate recovery activity (strongest example: travel to cafe and attempt coffee activation before the next settled `Game._process()` pass).

QA-012 disposition:
- this branch contributes **no runtime source** because its task is report-only;
- its conclusion is not promoted to accepted project truth until 00-Orchestrator reviews it;
- the cafe immediate-reentry scenario may be retained as a **provisional QA-002 stress idea**, but it is not a new mandatory acceptance gate and not a repository-proven bug at this time.

### UI-AUDIT-007 — worker output exists, not orchestrator-accepted yet
Branch:
- `agent/ui-audit-007-next-presentation-hotspot`

Current worker tip:
- `d4559faa17dd089fae82fcd0fd8b8cf605f77f37`

Comparison against coordination start:
- ahead 1 / behind 0
- changed path: `agent-reports/scene-ui.md` only

Worker report status:
- `NEEDS_REVIEW`

Worker recommendation:
- next smallest independent presentation repair: DialogUI body overflow containment;
- suggested future boundary: `scripts/ui/DialogUI.gd` + one narrow `tools/verify_dialog_panel_overflow.gd` + Scene/UI report;
- keep speaker and continue/end action outside the body overflow region;
- preserve `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, line progression and Game queue/content semantics.

QA-012 disposition:
- UI-AUDIT-007 contributes **no source/runtime input** to the current frozen candidate;
- no UI-FIX-007 implementation exists or is accepted through the current task board;
- do not add a DialogUI verifier or rendered requirement to QA-002 unless the orchestrator first accepts the audit and separately reviews a future implementation.

### NPC-CONTENT-010 — implementation output exists, not orchestrator-accepted yet
Branch:
- `agent/npc-content-010-generic-family-callers`

Current worker tip:
- `923e43541303a4f66a643bddef3a993a1ed234b5`

Source commit recorded by the worker:
- `46264de61d72c6b8a51bbe54003f665c36226f4a`

`data/events.json` blob at that source commit:
- `6cbc94e49413b1017dcbe41a1f1a13fe24316924`

Comparison against coordination start:
- ahead 2 / behind 0
- `data/events.json`: `+3 / -3`
- `agent-reports/npc-content.md`: report update

Worker report status:
- `NEEDS_REVIEW`

Worker-declared three-string delta:
1. `e_parents_call.speaker`
   - `母亲` -> `家里来电`
2. `e_parent_sick.speaker`
   - `父亲` -> `家里来电`
3. `e_parent_sick` first-option result
   - `你在病房陪了十一天。这十一天，是你成年后跟父亲说话最多的一段时间。`
   - -> `你在病房陪了十一天。这十一天，是你成年后陪家里人最久的一段时间。`

The branch comparison is consistent with the task's exact three-string boundary. However QA-012 does **not** convert that observation into orchestrator acceptance.

QA-012 disposition:
- **exclude NPC-CONTENT-010 from the current frozen candidate while TASK_BOARD remains READY**;
- if 00-Orchestrator later reviews it and records an accepted exact tip, the integration candidate content changes and must be re-frozen;
- then rerun JSON parse/semantic-diff evidence and any evidence affected by the new integration SHA;
- do not overwrite the cumulative `data/events.json` with this worker branch snapshot because the coordination branch is metadata-oriented and earlier accepted NPC content deltas must be preserved semantically.

## Current frozen-candidate membership
Until the task board records additional accepted exact tips, the next candidate membership remains:

### Gameplay
Use accepted GAME-FIX-009 cumulative semantic source:
- `scripts/Game.gd` from accepted identity `85d1ce4e...`
- carry the existing accepted Gameplay verifier set, including newly mandatory `verify_terminal_mutation_order.gd`

Preserve:
1. settled-frame needs/time -> terminal evaluation -> quest evaluation ordering;
2. synchronous shop-use time settlement and terminal evaluation before another item use;
3. shop-use rejection after `game_over`;
4. prior accepted GAME-FIX-001..007 semantics;
5. `_evaluate_terminal_state()` as the single authoritative terminal/death consumer path.

Do not include GAME-AUDIT-010 as source; it is report-only.

### Scene/UI
Carry all six repository-reviewed held implementations and their task verifiers:
- UI-FIX-001 `07a4d159e073e9f810cf1c3007ba907a49299ae3`
- UI-FIX-002 `b480befaedc3a3b0cbdaca1916e31dbba7283121`
- UI-FIX-003 `51124e758877750d01f8b72429ead0075a73c596`
- UI-FIX-004 `4a2ce2473dd05691fc2e1368b381497a5768d3e6`
- UI-FIX-005 `a0402610cef12455dfc970641e4273c8b246d6d1`
- UI-FIX-006 `d328f227b8473297d4b74c058dfd1a7101a68074`

Do not include UI-AUDIT-007 as source and do not invent UI-FIX-007 before orchestrator assignment/review.

### NPC/content
Carry the previously accepted cumulative NPC content semantics through NPC-CONTENT-008.

NPC-AUDIT-009 adds no runtime source.
NPC-CONTENT-010 is currently a worker `NEEDS_REVIEW` result while the task board remains `READY`; therefore its three strings are excluded until orchestrator acceptance.

## Deterministic integration rules
QA-012 is a manifest, not the integration lane.

1. Start from the previously accepted semantic integration baseline; do not use the metadata-oriented coordination source snapshot as a replacement for accepted cumulative Gameplay/content semantics.
2. Use accepted GAME-FIX-009 `Game.gd` exact identity and its verifier.
3. Carry repository-reviewed UI-FIX-001..006 source/assets/verifiers.
4. Carry accepted NPC-CONTENT-002..008 semantics only unless a later orchestrator heartbeat accepts NPC-CONTENT-010 before freeze.
5. Exclude report-only audits from runtime source.
6. Inspect the assembled diff for accidental worker-report/control-plane contamination and whole-file overwrites that revert accepted cumulative changes.
7. Create one explicit integration commit and record its exact 40-character SHA.
8. Create/select the QA-002 local/Codex worktree from exactly that SHA.
9. Do not modify candidate source during evidence collection.

## One-frozen-SHA rule
Every parser/Godot/headless/rendered/Web/browser artifact used for acceptance must identify the same integration SHA.

If the candidate changes after any evidence is captured:
- stop promotion;
- record the new SHA;
- determine which evidence is affected;
- rerun all affected task-specific and shared gates;
- never splice PASS output from different integration SHAs into one acceptance decision.

A worker branch moving does not automatically replace an already accepted exact tip. An accepted input changes only when 00-Orchestrator explicitly records a new accepted identity or when the assembled integration candidate itself changes.

## QA-002 frozen-SHA package
All commands below are prepared only. They were **not run** by QA-012.

### Step 0 — freeze identity
```bash
git rev-parse HEAD
git status --short
```

Record the exact SHA and worktree state before any execution.

### Step 1 — JSON parse + semantic diff gate
Because accepted NPC content already touches JSON:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence:
- exit code 0;
- literal `JSON_PARSE_OK`;
- semantic diff confirms only orchestrator-accepted content changes;
- no accidental condition/ID/flag/effect/reward/schema/flow changes.

If NPC-CONTENT-010 is accepted before candidate freeze, this gate must explicitly confirm its three accepted strings in the cumulative file. If it remains unaccepted, those strings must not be silently treated as QA-012 accepted input.

### Step 2 — Gameplay task-specific regressions
```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
godot --headless --path . --script res://tools/verify_terminal_mutation_order.gd
```

Because GAME-FIX-009 changes cumulative `Game.gd`, pre-009 Gameplay PASS output is stale.

Provisional extra stress from unreviewed GAME-AUDIT-010, if QA-002 has a suitable real-input harness:
- place needs/time near a terminal settlement boundary;
- travel to cafe;
- attempt recovery activation before the next settled Game process pass;
- record actual Godot input/process ordering and whether terminal state can be revived.

Do not report this theoretical sequence as a bug unless real runtime reproduction proves it.

### Step 3 — UI task-specific headless regressions
```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd
```

Headless success is necessary but is not rendered visual PASS.

No DialogUI overflow verifier belongs here yet; UI-AUDIT-007 is unreviewed/report-only and no UI-FIX-007 exists in the accepted task board.

### Step 4 — shared headless regression gate
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```

Capture command, exact candidate SHA, exit code and sufficient stdout/stderr for each run.

### Step 5 — rendered UI acceptance
On the exact candidate SHA, retain all held UI visual checks.

At minimum:
- UI-FIX-001: active NPC grounding, scale, idle frame, shadow, foreground occlusion, hover/click/dialog alignment;
- UI-FIX-002: home sleep/duvet seam and transition coherence;
- UI-FIX-003: HUD/header separation and reachability at its declared logical viewports;
- UI-FIX-004: EventUI at 1280x720 and 960x540, including final-option/continue reachability;
- UI-FIX-005: StartUI at 1280x720 and 960x540, including all origins/load/reopen behavior;
- UI-FIX-006: ShopUI at 1280x720 and 960x540, including six-row buy/full-bag reachability, fixed status/footer/close, reset behavior and no horizontal-scroll dependency.

Any affected UI source/asset change after capture makes the corresponding rendered evidence stale.

### Step 6 — Web export/browser acceptance
On the same frozen candidate SHA:
- perform the configured Godot 4.7.2 Web export;
- record command, exit code, stdout/stderr and artifact path;
- serve/open the export in a real browser;
- inspect console/network for blocking JS/WASM/Godot/resource errors;
- exercise start/origin/load, representative normal progression, terminal-state flows, ShopUI and the held visual paths represented in the candidate.

Current CI curl/static smoke is not a substitute for real browser runtime acceptance.

## Stop / stale-evidence conditions
Stop promotion and refresh/review the candidate if any of the following occurs:
1. runtime/parser/render/browser evidence references a SHA other than the declared integration SHA;
2. assembled candidate source changes after evidence begins;
3. 00-Orchestrator accepts a new source/content task after freeze and the team chooses to include it;
4. a supposedly accepted exact tip is replaced by a newer orchestrator-recorded accepted identity;
5. cumulative `Game.gd` loses prior accepted GAME-FIX semantics;
6. another direct terminal/death authority is introduced outside `_evaluate_terminal_state()`;
7. JSON parse fails or semantic diff contains unaccepted content/schema/effect changes;
8. UI task verifiers fail or rendered evidence does not satisfy their exact-SHA contracts;
9. Web export/browser has blocking parse/runtime/resource failures;
10. any unexecuted command is described as PASS;
11. unreviewed GAME-AUDIT-010, UI-AUDIT-007 or NPC-CONTENT-010 worker output is silently treated as accepted source/project policy while TASK_BOARD still records READY.

## Validation actually performed in this continuation
Performed:
- re-read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and this QA-012 report from GitHub;
- confirmed coordination branch remains `96a202796d5b454f730bf84c566367e8564db7f4` and task board still records QA-012 plus the three follow-ups as READY;
- detected that all three follow-up worker branches moved after the previous QA-012 capture;
- captured current worker tips for GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010;
- compared each against its coordination start;
- confirmed GAME-AUDIT-010 and UI-AUDIT-007 changed only their authorized reports;
- confirmed NPC-CONTENT-010 comparison is limited to `data/events.json +3/-3` plus its report;
- inspected all three worker reports and their current `NEEDS_REVIEW` status;
- captured NPC-CONTENT-010 provisional source commit and `data/events.json` blob identity;
- repository-only manifest/freshness analysis.

Not performed:
- orchestrator acceptance decision for those worker results;
- merge/cherry-pick/rebase;
- JSON parser execution;
- Godot/verifier execution;
- local/Codex terminal execution;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow edits/runs;
- any production source/data/UI edit by QA-012.

## Handoff
QA-012 remains complete and requests `NEEDS_REVIEW`.

Important delta for 00-Orchestrator:
1. the original 009/006/009 accepted manifest remains valid and unchanged;
2. GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 now each have worker `NEEDS_REVIEW` outputs even though TASK_BOARD still says READY;
3. review those worker results independently before deciding whether to create/accept any new source input;
4. until such review occurs, only the already accepted inputs belong in the next frozen runtime candidate;
5. when one final candidate SHA is formed, QA-002 must execute all parser/Godot/render/Web/browser evidence on that exact SHA only.