# QA/Build Agent Report

## Task
- ID: QA-012
- Agent: qa-build
- Branch/worktree: `agent/qa-012-post-review-integration-manifest`
- Status: NEEDS_REVIEW

## Scope
Report-only post-review integration manifest for the reviewed 009/006/009 wave:
- GAME-FIX-009
- UI-FIX-006
- NPC-AUDIT-009

Writable scope is only `agent-reports/qa-build.md`.

No merge, cherry-pick, rebase, source/data/UI/workflow edit, task-board edit, parser execution, Godot launch, verifier execution, Web export, browser run, screenshot capture, or rendered validation was performed or claimed in QA-012.

This refresh supersedes the earlier QA-012 capture where the next-wave branches were still assumed to have no worker delta. Their branches have now moved, but the current TASK_BOARD still has those tasks in READY, so none of those new worker commits are accepted inputs yet.

## Current coordination snapshot
Repository state verified during this refresh:
- coordination branch: `orchestrator/multi-agent-bootstrap`
- coordination tip: `96a202796d5b454f730bf84c566367e8564db7f4`
- `main`: `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b`
- QA-012 branch before this refresh commit: `a78b9a2dd269ddb753a6a9729282197884d334bc`

Neither `main` nor the coordination branch is the runtime-acceptance candidate. The coordination branch is the metadata/control-plane source of truth; QA-002 still requires one separately assembled, explicitly frozen integration SHA.

## Authoritative reviewed manifest — inputs allowed into the next frozen candidate
The current TASK_BOARD records the following reviewed identities.

| Task | Orchestrator disposition | Accepted/reviewed exact tip | Runtime-candidate effect |
| --- | --- | --- | --- |
| GAME-FIX-009 | DONE | `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d` | Include reviewed Gameplay source + verifier. |
| UI-FIX-006 | BLOCKED only on exact-SHA Godot/rendered evidence | `d328f227b8473297d4b74c058dfd1a7101a68074` | Include reviewed ShopUI source + verifier; do not call it runtime/rendered PASS. |
| NPC-AUDIT-009 | DONE | `a16920be7462436c1070e79e833cbadb7bdd0bd1` | Report-only; contributes no runtime source/data delta. |

Repository comparison against common pre-worker coordination baseline `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` confirms:
- GAME-FIX-009 changes only `scripts/Game.gd`, `tools/verify_terminal_mutation_order.gd`, and `agent-reports/gameplay.md`.
- UI-FIX-006 changes only `scripts/ui/ShopUI.gd`, `tools/verify_shop_panel_overflow.gd`, and `agent-reports/scene-ui.md`.
- NPC-AUDIT-009 changes only `agent-reports/npc-content.md`.

### Exact implementation file identities
Use the reviewed commit identities, not a later movable branch HEAD.

GAME-FIX-009:
- `scripts/Game.gd`
  - blob `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`
- `tools/verify_terminal_mutation_order.gd`
  - blob `79d07a38ac0ea07a8e17530028c776606f24070c`

UI-FIX-006:
- `scripts/ui/ShopUI.gd`
  - blob `200d60bc34200dda3b6c2a1ff51c25c3bd8788d7`
- `tools/verify_shop_panel_overflow.gd`
  - blob `1924219242ba146e40106cdd03bbda3374af712a`

## Source deltas that belong in the next frozen candidate
QA-012 is a manifest only; the orchestrator/integration lane must assemble these semantics.

### A. Gameplay — cumulative source through GAME-FIX-009
For `scripts/Game.gd`, use the accepted GAME-FIX-009 semantic file identity above as the authoritative cumulative Gameplay state through 009.

Preserve the reviewed 009 ordering contract:
1. settled-frame need/time mutation is observed by `_evaluate_terminal_state()` before reward-bearing quest evaluation;
2. shop-use elapsed time is synchronously settled and terminal-evaluated before another item mutation can revive a terminal state;
3. shop use is rejected after `game_over`;
4. existing terminal thresholds, item effects/time costs, quest rewards, save schema and previously accepted Gameplay semantics remain unchanged;
5. `_evaluate_terminal_state()` remains the single terminal/death authority.

Do not blindly stack historical Gameplay branch snapshots. GAME-FIX-009 was reviewed as the cumulative semantic result built on the earlier accepted Gameplay state; taking `Game.gd` from `main` or the metadata coordination branch would risk dropping accepted fixes.

Carry the accepted Gameplay verifier set already required by QA-011, now including the 009 verifier:
- `tools/verify_event_year_separation.gd`
- `tools/verify_need_zero_cadence.gd`
- `tools/verify_needs.gd`
- `tools/verify_terminal_state_evaluation.gd`
- `tools/verify_save_terminal_reentry.gd`
- `tools/verify_sleep_terminal_guard.gd`
- `tools/verify_terminal_mutation_order.gd`

### B. Scene/UI — reviewed held deltas through UI-FIX-006
Carry the already repository-reviewed UI-FIX-001..005 source/assets/verifiers and add UI-FIX-006.

Exact reviewed tips currently recorded by TASK_BOARD:
- UI-FIX-001 — `07a4d159e073e9f810cf1c3007ba907a49299ae3`
- UI-FIX-002 — `b480befaedc3a3b0cbdaca1916e31dbba7283121`
- UI-FIX-003 — `51124e758877750d01f8b72429ead0075a73c596`
- UI-FIX-004 — `4a2ce2473dd05691fc2e1368b381497a5768d3e6`
- UI-FIX-005 — `a0402610cef12455dfc970641e4273c8b246d6d1`
- UI-FIX-006 — `d328f227b8473297d4b74c058dfd1a7101a68074`

UI-FIX-006 adds the reviewed list-only ShopUI overflow containment and `verify_shop_panel_overflow.gd`. Preserve fixed title/status/footer/close regions, list-only vertical scrolling, viewport-relative panel sizing, rebuild scroll reset, existing public signals/methods, and inventory/gameplay semantics.

All UI-FIX-001..006 remain runtime/rendered holds. Repository review does not equal rendered PASS.

### C. NPC/content — carry accepted content state through NPC-CONTENT-008
NPC-AUDIT-009 itself adds no source/data input.

Carry forward the previously accepted NPC-CONTENT-002..008 semantic content state. In particular, NPC-CONTENT-008's accepted source contribution remains exactly these two `data/events.json` string substitutions:
1. `e_first_salary`: `然后给妈妈转了两千。` -> `然后把两千块转了出去。`
2. `e_sidejob`: `那八千块后来变成了你妈的一台洗衣机。` -> `那八千块后来变成了一台洗衣机。`

Do not replace `data/events.json` with a single worker snapshot in a way that reverts separately accepted NPC-CONTENT-003/004/006 or other accepted semantic edits. Content integration must be semantic/cumulative.

## Current next-wave branches — moved, but NOT accepted inputs
TASK_BOARD still records all three tasks below as READY. GitHub branches have nevertheless moved and their worker reports request NEEDS_REVIEW. This divergence is important: worker output exists, but the orchestrator has not accepted it yet.

### GAME-AUDIT-010 — report-only, pending orchestrator review
- TASK_BOARD status: READY
- current branch tip: `fee1ee8072aeea821fd78881fbb4b0a06404526b`
- diff from coordination `96a2027...`: only `agent-reports/gameplay.md`
- worker report status: NEEDS_REVIEW
- worker conclusion: no new repository-proven deterministic terminal revival/masking bypass after GAME-FIX-009; one cafe immediate-reentry/event-loop ordering scenario is left as runtime-only stress evidence.

Candidate rule:
- contributes no source even if later accepted because the task is report-only;
- do not change the frozen source candidate for this audit alone;
- if the orchestrator accepts its runtime-only stress recommendation, add that stress case to QA-002 on the same final SHA without calling it pre-proven failure.

### UI-AUDIT-007 — report-only, pending orchestrator review
- TASK_BOARD status: READY
- current branch tip: `d4559faa17dd089fae82fcd0fd8b8cf605f77f37`
- diff from coordination `96a2027...`: only `agent-reports/scene-ui.md`
- worker report status: NEEDS_REVIEW
- worker recommendation: a later isolated `UI-FIX-007` for DialogUI body overflow containment.

Candidate rule:
- contributes no source now or when this audit itself is accepted;
- any later DialogUI implementation is a separate source task and would require a new reviewed candidate/freeze before runtime acceptance.

### NPC-CONTENT-010 — source delta exists, pending orchestrator review
- TASK_BOARD status: READY
- current branch tip: `923e43541303a4f66a643bddef3a993a1ed234b5`
- source commit: `46264de61d72c6b8a51bbe54003f665c36226f4a`
- current diff from coordination `96a2027...`: `data/events.json` `+3/-3` plus `agent-reports/npc-content.md`
- worker report status: NEEDS_REVIEW

Worker-proposed three string edits:
1. `e_parents_call.speaker`: `母亲` -> `家里来电`
2. `e_parent_sick.speaker`: `父亲` -> `家里来电`
3. first `e_parent_sick` option result:
   - old: `你在病房陪了十一天。这十一天，是你成年后跟父亲说话最多的一段时间。`
   - new: `你在病房陪了十一天。这十一天，是你成年后陪家里人最久的一段时间。`

Candidate rule:
- **exclude NPC-CONTENT-010 from the current frozen candidate** until orchestrator review records an accepted exact tip;
- do not infer parser/Godot PASS from the branch diff or worker report;
- if later accepted before QA-002 begins, integrate only the reviewed three-string semantic delta on top of the cumulative accepted content state, create a new final integration SHA, and run the full final-SHA package;
- if accepted after evidence collection already began, stop promotion: the final SHA changes and previous evidence cannot be used as the final one-SHA acceptance package.

## Deterministic integration order
Recommended orchestrator/integration sequence; not performed by QA-012:

1. Start from the previously accepted semantic integration baseline from QA-010/QA-011, not from `main` or coordination source snapshots.
2. Compose Gameplay to the reviewed GAME-FIX-009 semantic state and include `verify_terminal_mutation_order.gd`.
3. Carry reviewed UI-FIX-001..005 source/assets/verifiers, then add reviewed UI-FIX-006 `ShopUI.gd` + verifier.
4. Carry accepted NPC-CONTENT-002..008 semantic content. NPC-AUDIT-009 contributes no data/source.
5. Exclude current unreviewed GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 worker outputs from source integration. Report-only audit findings may inform later tasks, but branch existence is not acceptance.
6. Inspect the assembled diff for accidental worker-report/control-plane snapshot contamination and for overwriting cumulative Gameplay or NPC semantics.
7. Create exactly one explicit integration commit and record its 40-character SHA.
8. Start QA-002/Codex/local acceptance only from that exact frozen SHA.
9. Do not modify candidate source, assets, data, verifiers or configuration during evidence collection. Any candidate change means a new SHA and a fresh final-SHA acceptance run.

## QA-002 exact-SHA acceptance package
Everything below must be run on one and the same final integration SHA. QA-012 prepared this package only; nothing below was executed here.

### Step 0 — identity and clean worktree
```bash
git rev-parse HEAD
git status --short
```
Required evidence:
- exact 40-character SHA;
- clean/declared worktree state;
- every later command, screenshot and browser capture tied to the same SHA.

### Step 1 — JSON parser and semantic diff gate
```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```
Required evidence:
- exit code 0;
- literal `JSON_PARSE_OK`;
- manual/recorded diff confirmation that only orchestrator-accepted content edits are present;
- no accidental condition/ID/flag/effect/reward/schema/flow change.

If NPC-CONTENT-010 is still unreviewed at freeze time, its three strings must not enter the candidate as an unreviewed input.

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

All pre-009 Gameplay evidence is stale for a post-009 final candidate and must be rerun on the frozen SHA.

Minimum 009 behavioral proof:
- terminal/pending-terminal state is observed before quest rewards can revive it;
- shop-use elapsed time is settled/evaluated before another healing item mutation;
- post-`game_over` shop use is rejected;
- normal healthy quest rewards and item-use paths still function;
- no second terminal/death authority bypasses `_evaluate_terminal_state()`.

Conditional extra stress if GAME-AUDIT-010 is later accepted as a report-only audit:
- arrange pending travel elapsed-time/need settlement near a terminal boundary;
- stress immediate cafe recovery input before the next ordinary settled frame;
- record real Godot event ordering and prove the terminal state cannot be revived;
- do not treat repository speculation as a pre-existing runtime failure.

### Step 3 — UI task-specific headless-prepared regressions
```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd
```

Headless success is necessary evidence but is not rendered visual PASS.

### Step 4 — shared headless regression gate
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```
Capture command, SHA, exit code and stdout/stderr sufficient to prove no hidden parser/assertion/runtime failure.

### Step 5 — rendered UI acceptance
All rendered evidence must use the same frozen integration SHA.

UI-FIX-001:
- active NPC grounding/scale/occlusion/click alignment.

UI-FIX-002:
- home bed/sleep sprite/duvet seam and wake transition.

UI-FIX-003..006:
- verify at both 1280x720 and 960x540;
- HUD reserved-header layout;
- EventUI bounded overflow/action reachability;
- StartUI bounded overflow/reopen behavior;
- ShopUI list scrolling with title/status/footer/close fixed and last row reachable.

For ShopUI specifically exercise buy and bag modes, enough items to force real vertical overflow, transitions/rebuilds, and scroll-reset behavior.

### Step 6 — Web export and browser acceptance
On the same frozen SHA:
- run the configured Godot 4.7.2 Web export;
- record command, exit code, stdout/stderr and artifact identities/sizes;
- serve/open the exported build in a real browser;
- inspect console/network for fatal JS/WASM/Godot/resource errors;
- exercise start/origin/load, normal progression, terminal-sensitive flows, NPC interaction, and held UI paths;
- capture screenshots for the rendered UI acceptance points.

No Web/browser PASS exists from QA-012.

## One-frozen-SHA and stale-evidence stop rules
These rules are mandatory for final acceptance:

1. **One final SHA only.** Final parser, Godot, headless, rendered, Web and browser evidence must all identify the same frozen integration SHA.
2. **Worker branch HEAD is not authority.** Use orchestrator-recorded accepted exact tips. If a reviewed branch moves later, ignore the new HEAD unless the orchestrator explicitly reviews and accepts a new exact tip.
3. **READY/NEEDS_REVIEW worker output is not candidate input.** The current GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 branch commits are excluded until orchestrator review.
4. **Any accepted source/data/asset/verifier change after freeze invalidates the final package.** Stop, assemble a new candidate SHA, and rerun the complete required final-SHA package; do not mix evidence across SHAs.
5. **Report-only audit acceptance does not mutate source SHA.** A newly accepted report-only audit may add a runtime stress/check to QA-002 without changing the candidate, but its result must still be collected on the same frozen SHA.
6. **No repair during evidence collection.** If QA-002 finds a defect, record the exact failing SHA/command/evidence, open a separate repair task, then freeze a new candidate after review.
7. **Headless is not rendered.** A verifier PASS cannot satisfy UI-FIX rendered acceptance, and curl/static asset success cannot satisfy real browser runtime acceptance.
8. **No partial final promotion.** Do not call the candidate accepted while UI-FIX-001..006 remain without their required exact-SHA rendered evidence.

## Repository validation performed by QA-012
Performed:
- re-read latest TASK_BOARD, FILE_OWNERSHIP and WEB_AGENT_LAUNCHPAD from coordination tip `96a2027...`;
- re-read QA-012 branch report and current target branch identity;
- confirmed `main` remains `df5ca5d...`;
- confirmed GAME-FIX-009 branch still points at reviewed exact tip `8ff9a36...`;
- confirmed UI-FIX-006 branch still points at reviewed exact tip `d328f227...`;
- confirmed NPC-AUDIT-009 branch still points at reviewed exact tip `a16920be...`;
- compared reviewed 009/006/009 branches against common baseline `86ea90c9...` and confirmed authorized changed-file boundaries;
- verified exact blobs for GAME-FIX-009 `Game.gd` + verifier and UI-FIX-006 `ShopUI.gd` + verifier;
- inspected current GAME-AUDIT-010, UI-AUDIT-007 and NPC-CONTENT-010 branch tips/diffs/reports;
- confirmed GAME-AUDIT-010 and UI-AUDIT-007 are report-only deltas;
- confirmed NPC-CONTENT-010 currently contains `data/events.json` `+3/-3` plus its report, but is not yet accepted by TASK_BOARD.

Not performed:
- JSON parser execution;
- Godot launch;
- any verifier execution;
- local/Codex shell execution;
- Web export;
- browser execution;
- screenshots/render validation;
- deployment;
- runtime/build/parser/render PASS claim.

## Risks / handoff
- The current metadata task board lags the three new worker branches: they have moved and request review, but remain READY until the orchestrator heartbeat audits them. Do not silently promote those branch tips.
- NPC-CONTENT-010 is the only current next-wave branch with a source/data delta; accepting it later requires semantic integration on top of prior accepted NPC content, not a full-file snapshot replacement.
- GAME-AUDIT-010's cafe immediate-reentry scenario is a runtime scheduling question, not a repository-proven defect.
- UI-AUDIT-007's DialogUI recommendation is a future task boundary only; no DialogUI source belongs in the current candidate.
- UI-FIX-001..006 still require real exact-SHA rendered evidence before final acceptance.

QA-012 requests orchestrator review at **NEEDS_REVIEW**. The next safe control-plane action is to review this manifest plus the three moved next-wave worker branches, then either freeze the reviewed source set or refresh the manifest again if the accepted source set changes.