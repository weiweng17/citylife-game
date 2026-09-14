# QA/Build Agent Report

## Task
- ID: QA-012
- Agent: qa-build
- Branch/worktree: `agent/qa-012-post-review-integration-manifest`
- Status: NEEDS_REVIEW

## Scope
Report-only post-review integration manifest after repository review of:
- GAME-FIX-009
- UI-FIX-006
- NPC-AUDIT-009

Per the current task contract, the only writable path is `agent-reports/qa-build.md`.

No merge, cherry-pick, rebase, source/data/UI/workflow edit, task-board edit, parser execution, Godot launch, verifier execution, Web export, browser run, screenshot capture, or rendered validation was performed or claimed in QA-012.

This report refreshes and supersedes the conditional 009/006/009 portion of QA-011 while retaining the accepted one-frozen-SHA and stale-evidence rules from QA-010/QA-011.

## Current coordination baseline
Latest coordination state inspected:
- coordination branch: `orchestrator/multi-agent-bootstrap`
- coordination tip: `96a202796d5b454f730bf84c566367e8564db7f4`
- QA-012 branch before this report edit: same `96a202796d5b454f730bf84c566367e8564db7f4`
- `main`: `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b`

Neither coordination SHA nor `main` is the runtime acceptance candidate. The coordination branch is the control-plane/source-of-truth for task metadata; QA-002 still requires a separately assembled and explicitly frozen integration SHA.

## Post-review exact-tip manifest
The task board now records these immutable repository-review identities:

| Task | Accepted exact tip | Repository disposition | Runtime-candidate effect |
| --- | --- | --- | --- |
| GAME-FIX-009 | `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d` | DONE | **Source + verifier input.** Its `Game.gd` is the deterministic cumulative Gameplay semantic state through 009. |
| UI-FIX-006 | `d328f227b8473297d4b74c058dfd1a7101a68074` | BLOCKED only on real exact-SHA runtime/rendered evidence | **Source + verifier input.** Include ShopUI overflow containment, but do not call it runtime/rendered PASS. |
| NPC-AUDIT-009 | `a16920be7462436c1070e79e833cbadb7bdd0bd1` | DONE | **No source/runtime input.** Report-only triage; it only defines follow-up boundaries. |

### File-level identities for the two new implementation inputs
Use the accepted commit identities above, not a later branch HEAD.

GAME-FIX-009:
- `scripts/Game.gd`
  - blob: `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`
- `tools/verify_terminal_mutation_order.gd`
  - blob: `79d07a38ac0ea07a8e17530028c776606f24070c`

UI-FIX-006:
- `scripts/ui/ShopUI.gd`
  - blob: `200d60bc34200dda3b6c2a1ff51c25c3bd8788d7`
- `tools/verify_shop_panel_overflow.gd`
  - blob: `1924219242ba146e40106cdd03bbda3374af712a`

Repository comparisons against the common pre-worker coordination baseline `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` confirm:
- GAME-FIX-009 changes only `scripts/Game.gd`, `tools/verify_terminal_mutation_order.gd`, and its Gameplay report.
- UI-FIX-006 changes only `scripts/ui/ShopUI.gd`, `tools/verify_shop_panel_overflow.gd`, and its Scene/UI report.
- NPC-AUDIT-009 changes only `agent-reports/npc-content.md`.

## What belongs in the next frozen runtime candidate
QA-012 is a manifest only. The orchestrator/integration lane must assemble the candidate; this worker does not perform that integration.

### A. Gameplay — authoritative cumulative source through GAME-FIX-009
For `scripts/Game.gd`, use the accepted GAME-FIX-009 semantic file identity above as the authoritative cumulative Gameplay state.

Reason:
- the 009 worker explicitly rebuilt from the accepted GAME-FIX-007 `Game.gd` semantic state before applying the narrow 009 mutation-order repair;
- therefore `8ff9a36...:scripts/Game.gd` already represents the intended combined Gameplay semantics through GAME-FIX-009;
- do **not** blindly stack historical GAME-FIX-001..007 branch snapshots and then overlay 009;
- do **not** take `Game.gd` from the metadata-oriented coordination branch.

Also carry the accepted Gameplay task-specific verifier set already required by QA-011, adding the reviewed 009 verifier:
- `tools/verify_event_year_separation.gd`
- `tools/verify_need_zero_cadence.gd`
- `tools/verify_needs.gd`
- `tools/verify_terminal_state_evaluation.gd`
- `tools/verify_save_terminal_reentry.gd`
- `tools/verify_sleep_terminal_guard.gd`
- `tools/verify_terminal_mutation_order.gd` **newly mandatory after 009 integration**

GAME-FIX-009 repository semantics to preserve in the candidate:
1. settled-frame need/time mutation is observed by `_evaluate_terminal_state()` before reward-bearing quest evaluation;
2. shop-use elapsed time is synchronously settled and terminal-evaluated before another item can revive a terminal state;
3. item use is rejected after `game_over`;
4. existing terminal thresholds, item effects/time costs, quest rewards, save schema and previous GAME-FIX semantics remain unchanged;
5. `_evaluate_terminal_state()` remains the single authoritative terminal/death consumer path.

### B. Scene/UI — carry all repository-reviewed held deltas, now including UI-FIX-006
The next frozen candidate should carry forward the already repository-reviewed UI-FIX-001..005 inputs and add UI-FIX-006.

Accepted exact tips currently recorded by the task board:
- UI-FIX-001 — `07a4d159e073e9f810cf1c3007ba907a49299ae3`
- UI-FIX-002 — `b480befaedc3a3b0cbdaca1916e31dbba7283121`
- UI-FIX-003 — `51124e758877750d01f8b72429ead0075a73c596`
- UI-FIX-004 — `4a2ce2473dd05691fc2e1368b381497a5768d3e6`
- UI-FIX-005 — `a0402610cef12455dfc970641e4273c8b246d6d1`
- UI-FIX-006 — `d328f227b8473297d4b74c058dfd1a7101a68074`

Expected semantic/file inputs from those reviewed tasks:
- UI-FIX-001: grounded active-NPC presentation integration (`LocationManager` + `ActiveNpcVisual`) and `verify_active_npc_visual.gd`.
- UI-FIX-002: localized home-bed foreground asset repair and `verify_home_bed_seam.gd`.
- UI-FIX-003: bounded HUD/reserved-header presentation contract and `verify_hud_header_layout.gd`.
- UI-FIX-004: bounded EventUI vertical-overflow/signal contract and `verify_event_panel_overflow.gd`.
- UI-FIX-005: bounded StartUI vertical-overflow/reopen contract and `verify_start_screen_overflow.gd`.
- UI-FIX-006: list-only ShopUI vertical overflow containment and `verify_shop_panel_overflow.gd`.

Integration rule:
- integrate reviewed source/assets/verifiers, not worker reports as runtime inputs;
- preserve each task's exact public-signal/API contract;
- no visual task is accepted as rendered PASS until QA-002 runs on the final frozen candidate.

### C. NPC/content — carry accepted source through NPC-CONTENT-008; NPC-AUDIT-009 adds no source
NPC-AUDIT-009 must **not** add a data/source file to the runtime candidate.

Carry forward the separately accepted NPC-CONTENT-002..008 semantic content state from the previous integration manifest.

The latest accepted safe copy delta before the audit is NPC-CONTENT-008:
- accepted branch tip: `a787d4ab237af9db2d85eac47b9c9db504786951`
- its source commit recorded by QA-010: `2c724e6bbaf1a791f7596c0621b79031f27482f1`
- its authorized semantic contribution is exactly two string substitutions in `data/events.json`:
  1. `e_first_salary`: `然后给妈妈转了两千。` -> `然后把两千块转了出去。`
  2. `e_sidejob`: `那八千块后来变成了你妈的一台洗衣机。` -> `那八千块后来变成了一台洗衣机。`

Important content integration rule:
- do **not** replace the entire `data/events.json` with the NPC-CONTENT-008 branch snapshot if that would revert earlier accepted NPC-CONTENT-003/004/006 or other accepted semantic edits;
- integrate the accepted NPC content set semantically;
- NPC-AUDIT-009 itself contributes no parser/Godot/runtime command.

## What does NOT belong in the current frozen candidate
The following new branches are READY boundaries only and currently have **no worker delta**. At QA-012 capture, all three still point exactly to coordination SHA `96a202796d5b454f730bf84c566367e8564db7f4`.

### GAME-AUDIT-010
Branch:
- `agent/game-audit-010-terminal-mutation-surface`

Contract:
- report-only `agent-reports/gameplay.md`;
- audit the accepted GAME-FIX-009 semantic state for any remaining concrete pre-terminal mutation bypass;
- may propose at most one smallest follow-up;
- no source edit and no runtime PASS.

Candidate rule:
- GAME-AUDIT-010 can never directly add runtime source because its contract is report-only;
- only a later separately assigned and repository-reviewed Gameplay fix may alter a future candidate.

### UI-AUDIT-007
Branch:
- `agent/ui-audit-007-next-presentation-hotspot`

Contract:
- report-only `agent-reports/scene-ui.md`;
- inspect an independent presentation hotspot outside held UI-FIX-001..006 files;
- no source edit and no rendered/runtime PASS.

Candidate rule:
- exclude from current candidate;
- any recommended UI implementation must be a separate reviewed task and would require a new candidate freeze if later included.

### NPC-CONTENT-010
Branch:
- `agent/npc-content-010-generic-family-callers`

Current state:
- READY, no worker delta yet at QA-012 capture.

Authorized future delta if/when completed and separately reviewed:
- exactly three string-value edits in `data/events.json`:
  1. genericize `e_parents_call.speaker`;
  2. genericize `e_parent_sick.speaker`;
  3. neutralize the father-specific phrase in the first `e_parent_sick` option result while preserving the caregiving beat.

Explicitly forbidden by that task:
- conditions;
- age/origin eligibility;
- effects/rewards;
- flags;
- jobs;
- counters;
- IDs;
- schema/flow;
- `e_parent_gone`;
- `e_roommate`;
- the four deferred spouse/child-policy events.

Candidate rule:
- **exclude NPC-CONTENT-010 now**;
- if it completes before runtime freeze, do not include it until the orchestrator reviews and records an accepted exact tip;
- if the orchestrator decides to include it after this QA-012 manifest, that changes the candidate content, so freeze a new SHA and rerun the JSON/diff gate plus any affected shared/runtime evidence.

## Deterministic integration order
This is the recommended orchestrator/integration sequence, not work performed by QA-012.

1. Start from the previously accepted semantic integration baseline described by QA-010/QA-011; do not use coordination `Game.gd`/content snapshots as replacements for accepted cumulative semantics.
2. Replace/compose `scripts/Game.gd` to the exact accepted GAME-FIX-009 semantic identity (`85d1ce4...`) and include `verify_terminal_mutation_order.gd` (`79d07a3...`).
3. Carry forward reviewed UI-FIX-001..005 source/assets/verifiers, then apply the reviewed UI-FIX-006 `ShopUI.gd` (`200d60b...`) and verifier (`1924219...`).
4. Carry forward accepted NPC-CONTENT-002..008 semantic content. NPC-AUDIT-009 adds no source.
5. Exclude GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 from this candidate unless their status later changes through orchestrator review. Report-only audits never become runtime source inputs.
6. Inspect the assembled diff for accidental worker-report/control-plane/source-snapshot contamination and for semantic overwrite of cumulative Gameplay/content state.
7. Create one explicit integration commit and record its exact 40-character SHA.
8. From that exact SHA, create/select the QA-002 local/Codex worktree and run the complete acceptance package below.
9. Do not modify candidate source during evidence collection. Any source/asset/verifier change requires a new freeze and rerun of affected evidence.

## QA-002 frozen-SHA acceptance package
Everything below must run against one and the same final integration SHA.

### Step 0 — identity / clean state
```bash
git rev-parse HEAD
git status --short
```

Required evidence:
- exact 40-character SHA;
- worktree state;
- confirmation that every later command/capture references that same SHA.

### Step 1 — JSON parse + semantic diff gate
Because accepted NPC content changes touch JSON:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence:
- exit code 0;
- literal `JSON_PARSE_OK`;
- diff review proving accepted content edits only;
- no accidental condition/ID/flag/effect/reward/schema/flow changes.

If NPC-CONTENT-010 is not orchestrator-accepted into the candidate, its three future strings must not appear as an unreviewed QA-012 input.

### Step 2 — complete Gameplay task-specific regression set
```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
godot --headless --path . --script res://tools/verify_terminal_mutation_order.gd
```

Because GAME-FIX-009 changes cumulative `Game.gd`, all prior Gameplay PASS output from a pre-009 SHA is stale. The whole Gameplay task-specific sequence must rerun on the new frozen SHA.

Minimum 009 proof:
- terminal/pending-terminal state is observed before quest rewards can revive it;
- shop-use elapsed time is settled/evaluated before another healing item mutation;
- post-`game_over` shop use is rejected;
- healthy/non-terminal quest reward and item use still behave normally;
- no new terminal/death authority bypasses `_evaluate_terminal_state()`.

### Step 3 — complete UI task-specific headless-prepared regression set
```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd
```

Headless success is necessary repository/runtime evidence but is **not** rendered visual PASS.

### Step 4 — shared headless regression gate
Run on the same frozen SHA after task-specific checks:

```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```

Capture for every command:
- candidate SHA;
- command;
- exit code;
- stdout/stderr sufficient to prove no hidden parse/assertion/runtime failure.

### Step 5 — real rendered UI acceptance on the same SHA
UI-FIX-001..006 remain runtime/render blocked until this evidence exists.

UI-FIX-001 — active NPC:
- Xiaoyu at home and Chenjie at store;
- one static fallback NPC;
- foot grounding/contact shadow;
- depth/scale/tint/foreground occlusion;
- hover label/tooltip/click target alignment;
- clicking still opens expected dialog.

UI-FIX-002 — home bed:
- no duplicate/second bed or whole-bed overlay;
- local duvet seam visually blends;
- head/pillow relationship remains correct;
- waist/leg occlusion only;
- sleep enter/breathe/wake transition remains coherent.

UI-FIX-003 — HUD/header:
- declared logical viewports from the reviewed task, including 1280x720 and the narrower logical viewport used by its verifier;
- HUD/header separation;
- long copy containment;
- all action buttons reachable.

UI-FIX-004 — EventUI:
- 1280x720 and 960x540 logical viewports;
- long narrative/options;
- final enabled option reachable;
- continue action reachable;
- no horizontal overflow dependency;
- option/continue signals preserve normal flow.

UI-FIX-005 — StartUI:
- 1280x720 and 960x540 logical viewports;
- all origin cards reachable;
- load action reachable when present;
- wrapped content remains horizontally contained;
- reopen starts at top;
- origin/load flow unchanged.

UI-FIX-006 — ShopUI:
- 1280x720 and 960x540 logical viewports;
- six-row buy list and six-owned-item bag path remain usable;
- final row reachable vertically;
- title/subtitle/status/footer/close stay fixed outside list scroll owner;
- full-list -> empty-bag and buy <-> bag rebuilds do not retain stale range/offset/height;
- same-mode refresh resets rebuilt list correctly;
- buy/use/close flows remain correct;
- no horizontal-scroll dependency at 960px.

Any affected UI source/asset change after capture invalidates its rendered evidence.

### Step 6 — Web export + real browser
Still requires QA-002 local/Codex/browser context.

On the same frozen SHA:
- use Godot 4.7.2-compatible environment;
- perform the configured Web export;
- capture command, exit code, stdout/stderr and artifact location;
- serve/open the exported build in a real browser;
- inspect blocking console/network/runtime/resource failures;
- exercise start/origin/load, ordinary progression, terminal-state flows, ShopUI, and all held visual paths represented by the candidate.

No Web/browser PASS is claimed by QA-012.

## Exact stale-evidence / stop rules after repository review
QA-012 sharpens the older READY-branch rule now that 009/006/009 have been reviewed.

### Accepted worker tips are immutable inputs
The accepted task-board SHAs are commit identities. A worker branch later moving does **not** automatically replace an accepted input.

For GAME-FIX-009 / UI-FIX-006 / NPC-AUDIT-009:
- keep using the accepted exact tips recorded in the task board;
- do not chase a later branch HEAD;
- only change the manifest if the orchestrator explicitly supersedes/reopens the task and records a new accepted exact tip.

### Runtime evidence becomes stale when the frozen integration identity changes
Stop promotion and refresh/rerun affected evidence if:
1. the final integration SHA changes after a command/capture was recorded;
2. any source/asset/verifier in the frozen candidate changes;
3. the orchestrator accepts a new task (for example NPC-CONTENT-010 or a follow-up from GAME-AUDIT-010/UI-AUDIT-007) and chooses to include it before release;
4. GAME-FIX-009 `Game.gd` is replaced by metadata coordination source or loses prior accepted Gameplay semantics;
5. another terminal/death authority is introduced outside the existing evaluator contract;
6. accepted NPC semantic edits are overwritten by a whole-file branch snapshot;
7. JSON parse/diff gate fails;
8. any verifier/shared gate exits nonzero or logs parse/assertion/runtime failure;
9. rendered evidence is captured from a different SHA than the declared candidate;
10. Web export/browser evidence comes from a different SHA or shows blocking resource/runtime failure;
11. any unexecuted parser/Godot/Web/browser command is described as PASS.

## Remaining runtime-blocked state
Repository review does not remove runtime holds.

Still blocked on real exact-SHA execution:
- QA-002 itself;
- GAME-FIX-009 runtime regression acceptance;
- UI-FIX-001..006 task-specific verifier execution;
- UI-FIX-001..006 rendered visual acceptance;
- JSON parse/diff evidence for the assembled accepted NPC content state;
- shared headless regression matrix;
- Web export;
- real browser console/network/runtime validation.

No current repository evidence justifies calling any of those runtime/render/Web checks passed.

## Validation actually performed in QA-012
Performed:
- read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and current QA report from `orchestrator/multi-agent-bootstrap`;
- confirmed QA-012 writable scope is report-only;
- confirmed QA-012 branch started at the latest coordination tip `96a202796d5b454f730bf84c566367e8564db7f4`;
- inspected accepted GAME-FIX-009 commit/report and its cumulative semantic-base handling;
- compared GAME-FIX-009 against its coordination baseline and verified only `Game.gd`, its new verifier and Gameplay report differ;
- captured exact reviewed blobs for `Game.gd` and `verify_terminal_mutation_order.gd`;
- inspected accepted UI-FIX-006 commit/report;
- compared UI-FIX-006 against its coordination baseline and verified only `ShopUI.gd`, its new verifier and Scene/UI report differ;
- captured exact reviewed blobs for `ShopUI.gd` and `verify_shop_panel_overflow.gd`;
- inspected NPC-AUDIT-009 accepted commit/report and confirmed it is report-only;
- refreshed current task-board exact tips for held UI-FIX-001..006;
- inspected the accepted UI task handoffs needed to preserve their runtime evidence requirements;
- retained the accepted NPC-CONTENT-008 two-string semantic integration warning from QA-010/QA-011;
- checked GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 branches and confirmed all three still have no worker delta at capture time;
- refreshed `main` and coordination identities;
- repository-only integration/freshness analysis.

Not performed:
- merge/cherry-pick/rebase;
- source/data/UI/workflow changes;
- JSON parser execution;
- Godot 4.7.2 launch;
- any `verify_*.gd` execution;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow run;
- runtime PASS inference.

## Handoff
QA-012 repository-only post-review integration manifest is complete and requests `NEEDS_REVIEW`.

Orchestrator review should verify:
1. GAME-FIX-009 accepted `Game.gd` becomes the cumulative Gameplay source through 009 rather than stacking stale historical snapshots;
2. `verify_terminal_mutation_order.gd` is added to the mandatory frozen-SHA Gameplay matrix;
3. UI-FIX-006 joins UI-FIX-001..005 in the same candidate and QA-002 runtime/render hold;
4. NPC-AUDIT-009 adds no source; current content remains accepted through NPC-CONTENT-008;
5. GAME-AUDIT-010 and UI-AUDIT-007 remain report-only future boundaries;
6. NPC-CONTENT-010 remains excluded until it has a reviewed exact tip;
7. one explicit post-review integration commit is frozen before any QA-002 execution;
8. all parser/headless/rendered/Web/browser evidence is collected only from that exact integration SHA.
