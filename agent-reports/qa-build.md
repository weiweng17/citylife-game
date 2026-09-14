# QA/Build Agent Report

## Task
- ID: QA-011
- Agent: qa-build
- Branch/worktree: `agent/qa-011-next-wave-codex-package`
- Status: NEEDS_REVIEW

## Scope
Report-only exact-SHA / Codex-package delta after the latest orchestrator heartbeat.

Per the current `TASK_BOARD.md`, the only writable path for QA-011 is `agent-reports/qa-build.md`. No source/data/UI file, workflow, coordination file, task board, integration branch, or `main` file was modified. No merge/cherry-pick/rebase, JSON parser, Godot, verifier, Web export, browser, screenshot, or rendered validation was executed or claimed.

This report extends the accepted QA-010 single-integration-SHA contract rather than replacing it.

## Current heartbeat baseline
Latest coordination state inspected from `orchestrator/multi-agent-bootstrap`:
- coordination tip: `86ea90c9742b31c8d562199f873ea0d0a6ca5a95`
- QA-010: DONE, accepted at `60bba20cbb9b159e583079a87cf59b1d61b36054`
- GAME-AUDIT-008: DONE, accepted at `54edcdd2b3dbaf98ce1511d4acd7a9657c920903`
- GAME-FIX-009: READY on `agent/game-fix-009-terminal-mutation-order`
- UI-AUDIT-006: DONE, accepted at `9fac5a93af60cbeb00ef390bc5b3d877d319b619`
- UI-FIX-006: READY on `agent/ui-fix-006-shop-list-overflow`
- NPC-CONTENT-008: DONE, accepted at `a787d4ab237af9db2d85eac47b9c9db504786951`
- NPC-AUDIT-009: READY on `agent/npc-audit-009-speaker-premise-triage`
- QA-002: BLOCKED on a real Godot 4.7.2/browser context plus a frozen post-review integration SHA.

Before this QA-011 report update, `agent/qa-011-next-wave-codex-package` was identical to coordination tip `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` (`ahead 0 / behind 0`) and still contained the old QA-001 bootstrap report.

## Exact branch-tip refresh

| Task / branch | Exact tip at QA-011 capture | Meaning |
| --- | --- | --- |
| coordination `orchestrator/multi-agent-bootstrap` | `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` | Metadata/control-plane heartbeat baseline; not a runtime acceptance SHA. |
| QA-011 `agent/qa-011-next-wave-codex-package` before report edit | `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` | Fresh branch, no prior QA-011 delta. |
| GAME-FIX-007 | `ff08ce9dd7d1b3abddf65348b74f3ca5403ab344` | Accepted Gameplay semantic source through sleep terminal guard. |
| GAME-AUDIT-008 | `54edcdd2b3dbaf98ce1511d4acd7a9657c920903` | Accepted report-only audit that led to GAME-FIX-009. |
| GAME-FIX-009 | `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` | READY branch currently has no worker delta yet. |
| UI-FIX-001 | `07a4d159e073e9f810cf1c3007ba907a49299ae3` | Still exact-SHA rendered hold. |
| UI-FIX-002 | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | Still exact-SHA rendered hold. |
| UI-FIX-003 | `51124e758877750d01f8b72429ead0075a73c596` | Still exact-SHA rendered hold. |
| UI-FIX-004 | `4a2ce2473dd05691fc2e1368b381497a5768d3e6` | Still verifier + 1280x720 / 960x540 rendered hold. |
| UI-FIX-005 | `a0402610cef12455dfc970641e4273c8b246d6d1` | Repository scope accepted; still verifier + rendered hold. |
| UI-AUDIT-006 | `9fac5a93af60cbeb00ef390bc5b3d877d319b619` | Accepted report-only audit that led to UI-FIX-006. |
| UI-FIX-006 | `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` | READY branch currently has no worker delta yet. |
| NPC-CONTENT-008 | `a787d4ab237af9db2d85eac47b9c9db504786951` | Accepted two-string source delta + report; parser/runtime PASS not inferred. |
| NPC-AUDIT-009 | `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` | READY branch currently has no worker delta yet; report-only by contract. |
| QA-010 | `60bba20cbb9b159e583079a87cf59b1d61b36054` | Latest accepted QA predecessor; single-SHA/stale-evidence rules remain authoritative. |

### Important freshness consequence
At this capture, all three newly queued worker branches (`GAME-FIX-009`, `UI-FIX-006`, `NPC-AUDIT-009`) still point exactly at coordination SHA `86ea90c9...`. Therefore there is **no implementation/report result to accept from those tasks yet**.

Do not pre-label future worker output as accepted and do not bind Codex evidence to `86ea90c9...` merely because the branches currently start there. After each worker commits, refresh its exact tip and review the actual branch delta before forming the runtime candidate.

## New task-boundary delta

### GAME-FIX-009 — terminal mutation ordering
Authorized files:
- `scripts/Game.gd`
- `tools/verify_terminal_mutation_order.gd`
- `agent-reports/gameplay.md`

Required semantic boundary:
- use the existing authoritative `_evaluate_terminal_state()` before reward-bearing quest mutation on settled frames;
- synchronously settle/evaluate shop-use elapsed time before another item can revive a terminal state;
- reject further shop-use mutation after `game_over`;
- preserve existing thresholds, item effects/time costs, quest rewards, save schema, and GAME-FIX-001..007 semantics;
- no second death path/consumer.

QA implication after worker completion: repository review must compare final `Game.gd` semantics against accepted GAME-FIX-007, not only against the metadata-oriented coordination branch.

### UI-FIX-006 — ShopUI bounded list
Authorized files:
- `scripts/ui/ShopUI.gd`
- `tools/verify_shop_panel_overflow.gd`
- `agent-reports/scene-ui.md`

Required semantic/layout boundary:
- only item-list region scrolls;
- title/status/footer/close remain fixed and reachable;
- preserve ShopUI public signals/methods and all inventory/gameplay semantics;
- no `Game.gd`, `Inventory.gd`, item-data/effect/price/order, settlement, held UI-FIX-001..005, or sub-660px horizontal redesign changes;
- final PASS still requires real exact-SHA Godot/rendered evidence.

QA implication after worker completion: add its verifier and rendered 1280x720 + 960x540 ShopUI acceptance to the same frozen integration SHA package; do not treat its isolated worker branch as visual PASS.

### NPC-AUDIT-009 — speaker/premise triage
Authorized file:
- `agent-reports/npc-content.md` only.

Required boundary:
- inspect remaining non-family-policy speaker/premise assumptions including `e_parents_call`, `e_parent_sick`, `e_parent_gone`, `e_roommate`;
- classify each as safe copy-only, condition/schema-dependent, or product-policy-dependent;
- propose at most one smallest safe follow-up;
- no source/data edit and no parser/runtime claim.

QA implication: NPC-AUDIT-009 itself contributes **no runtime source delta** and adds no parser/Godot command to QA-002. Only a later separately authorized content implementation would re-enter JSON parse/diff gates.

## Conflict and integration hazards

### 1. GAME-FIX-009 starts from metadata coordination, not accepted GAME-FIX-007 source
The new GAME-FIX-009 branch currently starts at `86ea90c9...`, while accepted GAME-FIX-007 semantic source is `ff08ce9d...` and historically reconstructed earlier Gameplay fixes because coordination is metadata-oriented.

This is the highest-risk integration point. Do not assume a future GAME-FIX-009 branch snapshot automatically contains accepted GAME-FIX-001..007 semantics. At review time:
1. inspect its `scripts/Game.gd` against `ff08ce9d...` semantic state;
2. require one deterministic combined `Game.gd` containing accepted prior semantics plus the narrow 009 ordering guard;
3. reject blind stacking of all historical Gameplay branches or a snapshot overwrite that drops prior fixes.

### 2. UI-FIX-006 is source-isolated but evidence-coupled
`ShopUI.gd` is intentionally outside the UI-FIX-001..005 held files, so direct source conflict should be low if scope is respected. Runtime/render evidence is still coupled to the final integration SHA; any UI source movement invalidates affected evidence.

### 3. NPC-AUDIT-009 is metadata only
Do not merge its report as if it were a content implementation and do not add a parser gate for the audit itself. If it recommends a future fix, that must be a new orchestrator-assigned task with its own exact writable boundary.

### 4. NPC-CONTENT-008 still requires semantic content integration
The accepted 008 implementation is only two string substitutions in `data/events.json`. Integrate those string deltas without replacing the whole file in a way that reverts earlier accepted NPC-CONTENT-003/004/006 changes.

### 5. QA/Codex branch identity is not evidence
The task board names `codex/qa-002-runtime-acceptance`, but a current GitHub branch lookup returned **Branch not found (404)**. This does not change QA-002's BLOCKED state and is not a runtime failure.

When local/Codex execution is actually authorized, create/select the QA worktree from the **final frozen integration SHA**, record that SHA first, and do not reuse an unrelated historical branch head as evidence.

## Deterministic integration order after worker review
This order is a handoff rule, not an action performed by QA-011.

1. **Review/accept worker outputs first.** Refresh exact tips for GAME-FIX-009, UI-FIX-006 and NPC-AUDIT-009 after they actually move off `86ea90c9...`. No runtime candidate should include unreviewed READY work.
2. **Compose Gameplay deterministically.** Treat accepted GAME-FIX-007 semantics as the prior Gameplay source contract; layer only the reviewed GAME-FIX-009 semantic delta into one final `scripts/Game.gd` plus its verifier. Do not branch-stack historical Gameplay snapshots blindly.
3. **Apply isolated UI deltas.** Integrate the already held UI-FIX-001..005 accepted repository deltas plus reviewed UI-FIX-006 using exact-file diffs; preserve their independent verifier files.
4. **Apply accepted content semantically.** Carry NPC-CONTENT-008's exact two strings plus all separately accepted prior NPC deltas. NPC-AUDIT-009 contributes no data/source file.
5. **Create one explicit integration commit and freeze it.** Runtime acceptance begins only after this exact integration SHA exists. Any source movement afterward invalidates affected evidence.
6. **Create/select the QA-002 Codex/local worktree from that exact SHA** and run the package below without mixing output from worker tips.

## Minimal QA-002 handoff delta
QA-010's package remains the base. QA-011 adds only the conditional 009/006 requirements and clarifies that NPC-AUDIT-009 adds no runtime command.

### Step 0 — freeze identity
On the final reviewed integration candidate only:

```bash
git rev-parse HEAD
git status --short
```

Record the exact 40-character SHA and worktree state. If HEAD changes, stop and refresh/rerun affected evidence.

### Step 1 — JSON parse/diff gate
Because accepted NPC-CONTENT-008 changes JSON, the final candidate must run:

```bash
python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ['data/events.json','data/quests.json']]; print('JSON_PARSE_OK')"
```

Required evidence: exact SHA, command, exit code 0, literal `JSON_PARSE_OK`, and diff confirmation that 008 contributes only its two authorized strings. NPC-AUDIT-009 itself does not alter this gate.

### Step 2 — Gameplay regressions
Retain all previously required Gameplay regressions on the same SHA:

```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd
godot --headless --path . --script res://tools/verify_sleep_terminal_guard.gd
```

**If and only if GAME-FIX-009 is reviewed/accepted into the frozen candidate**, add:

```bash
godot --headless --path . --script res://tools/verify_terminal_mutation_order.gd
```

Minimum 009 behavioral proof:
- settled/pending terminal state is observed before quest rewards can revive it;
- shop-use elapsed time is settled/evaluated before another healing item mutation;
- further shop use is rejected after `game_over`;
- normal non-terminal quest rewards and item use remain unchanged;
- no new direct terminal/death authority is introduced outside `_evaluate_terminal_state()`.

A post-009 candidate must rerun the full Gameplay sequence; pre-009 PASS output is stale for Gameplay acceptance.

### Step 3 — UI task-specific headless regressions
Retain UI-FIX-001..005 verifiers on the same candidate SHA:

```bash
godot --headless --path . --script res://tools/verify_active_npc_visual.gd
godot --headless --path . --script res://tools/verify_home_bed_seam.gd
godot --headless --path . --script res://tools/verify_hud_header_layout.gd
godot --headless --path . --script res://tools/verify_event_panel_overflow.gd
godot --headless --path . --script res://tools/verify_start_screen_overflow.gd
```

**If and only if UI-FIX-006 is reviewed/accepted into the frozen candidate**, add:

```bash
godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd
```

Headless success is necessary but never a rendered PASS.

### Step 4 — shared headless gate
After task-specific regressions pass, run the existing shared QA gate on the same SHA:
- `verify_locations`
- `verify_navigation`
- `verify_day_cycle`
- `verify_day_flow`
- `verify_npc`
- `verify_quests`

Use the repository's accepted command form for each script in QA-002. Capture command, exact SHA, exit code and stdout/stderr sufficient to prove no hidden parse/assertion/runtime failure.

### Step 5 — rendered UI acceptance
Retain exact-SHA rendered acceptance for UI-FIX-001..005.

If UI-FIX-006 is integrated, add real ShopUI evidence at both:
- 1280x720
- 960x540

Minimum ShopUI rendered checks:
- six-row buy list and six-owned-item bag path remain usable;
- last row reachable vertically;
- title/status/footer/close stay fixed/reachable outside the list scroll owner;
- buy <-> bag transitions and same-mode `refresh()` do not retain invalid scroll offsets/stale list height;
- buy/use/closed signal flow remains correct;
- no horizontal-scroll dependency at 960 logical width.

Any UI source change after capture makes affected rendered evidence stale.

### Step 6 — Web export/browser
QA-002 remains blocked until real Godot 4.7.2/browser execution is available. On the same frozen SHA:
- perform configured Web export;
- capture command, exit code, stdout/stderr and artifact path;
- open/serve the exported build in a real browser;
- capture blocking console/network/runtime/resource failures;
- exercise start/origin/load, normal progression, terminal-state flows, ShopUI, and visually held UI paths represented in the final candidate.

No Web/browser PASS exists from QA-011.

## Stale-SHA / stop conditions
Stop promotion and refresh the package if any of the following occurs:
1. GAME-FIX-009, UI-FIX-006 or NPC-AUDIT-009 moves after this report's captured `86ea90c9...` starter tips; review the new tip before integration.
2. runtime/parser/render evidence references anything other than the single declared integration SHA.
3. integration candidate changes after evidence collection.
4. final `Game.gd` drops any accepted GAME-FIX-001..007 semantic contract while adding 009.
5. GAME-FIX-009 introduces a second death/terminal authority instead of `_evaluate_terminal_state()`.
6. quest reward or shop-use mutation can still revive a terminal/pending-terminal state before observation.
7. UI-FIX-006 changes gameplay/inventory/item semantics, edits held UI-FIX-001..005 files, moves status/footer/close into the list scroll owner, or depends on horizontal scrolling at 960px.
8. NPC-AUDIT-009 changes source/data despite its report-only contract.
9. NPC-CONTENT-008 integration changes more than its two authorized strings or reverts earlier accepted NPC content.
10. JSON parse, any task-specific verifier, any shared gate, Godot startup, Web export, or browser startup fails.
11. required rendered evidence is absent/stale.
12. an unexecuted command is described as PASS.

## Validation actually performed in QA-011
Performed repository-only:
- read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md`;
- read current QA-011 branch report state;
- verified QA-011 branch was initially identical to coordination `86ea90c9...`;
- read accepted QA-010 report so this delta extends its handoff;
- refreshed repository branch tips for current Gameplay/UI/NPC/QA branches;
- confirmed GAME-FIX-009, UI-FIX-006 and NPC-AUDIT-009 currently have no worker delta beyond coordination;
- refreshed UI-FIX-001..005 hold tips;
- checked the named `codex/qa-002-runtime-acceptance` GitHub branch and observed it is currently absent (404);
- prepared the conditional minimal QA-002 delta and stop conditions.

Not performed:
- JSON parser execution;
- Godot 4.7.2 launch;
- any `verify_*.gd` execution;
- merge/cherry-pick/rebase;
- creation of an integration or Codex branch/worktree;
- Web export;
- browser execution;
- screenshot/render inspection;
- workflow execution or edits;
- worker source/data/UI edits.

## Handoff
QA-011 requests `NEEDS_REVIEW`.

Immediate orchestrator review points:
1. treat the three new READY branch tips as starter SHAs only; refresh them after worker commits before acceptance;
2. review future GAME-FIX-009 against accepted GAME-FIX-007 semantic source, not only against coordination;
3. keep UI-FIX-001..005 in rendered hold and add UI-FIX-006 verifier/render requirements only after its worker delta is accepted;
4. keep NPC-AUDIT-009 report-only; it adds no QA-002 runtime command unless a separate later content task is created;
5. form one post-review integration SHA first, then create/select the QA-002 Codex/local worktree from that exact SHA and execute the package without mixing evidence from worker branches.