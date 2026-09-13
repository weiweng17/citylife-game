# QA/Build Agent Report

## Task
- ID: QA-006
- Agent: qa-build
- Branch/worktree: `agent/qa-006-integration-conflict-manifest`
- Status: NEEDS_REVIEW

## Scope
Repository-only merge/conflict manifest. QA-006 is report-only: this task did not merge branches, edit worker code, edit workflows, modify `main`, or modify orchestrator-owned coordination files.

No Godot, Web export, browser, rendered capture, JSON parser, or local integration execution was performed. All runtime commands below are prepared instructions only and are not claimed evidence.

## Summary
The accepted repair branches are not safe to merge wholesale. In particular, GAME-FIX-001/002/003 were created from different historical coordinator states and all modify `scripts/Game.gd`; branch comparison shows divergence rather than a clean ancestor chain. Integration must therefore be constructed deliberately on one fresh exact integration candidate SHA, applying only each accepted task's authorized product/regression changes in deterministic order and rerunning cumulative regressions after every `Game.gd` overlap.

Content work has a similar ordered-copy dependency: NPC-CONTENT-002 and NPC-CONTENT-003 both operate in quest/event content space and should be applied in task order so the later naming/relationship-copy audit does not accidentally resurrect text corrected by NPC-CONTENT-002.

UI-FIX-001/002/003 remain repository-reviewed but runtime/rendered-unpromoted. They must not be treated as accepted integration inputs until the exact candidate SHA receives required real Godot rendered evidence. UI-FIX-003 has also advanced since QA-005: its current captured tip is `51124e758877750d01f8b72429ead0075a73c596`, replacing the older QA-005 capture `ff36fe6368d4f0b8088c266dab6331fce71e6454`; any runtime evidence tied to the older SHA is stale for the current branch tip.

GAME-FIX-004 and NPC-CONTENT-004 are still `READY` on the task board and are intentionally excluded from the orchestrator-accepted integration set for this manifest.

## Current coordinator base captured for comparison
- `orchestrator/multi-agent-bootstrap`: `26919477e86fabda1094f3955b0a570028c63a86`

This SHA is a comparison anchor for QA-006 only. Before real integration execution, capture the then-current coordinator/integration base again and record it with the resulting integration candidate SHA.

## Exact branch-tip manifest

### Orchestrator-accepted gameplay/content inputs
| Task | Branch | Captured tip SHA | Board state | Integration class |
| --- | --- | --- | --- | --- |
| GAME-FIX-001 | `agent/game-fix-001-daily-event-separation` | `2e1ca3a06a6f5eddded794b2d7b0faaf49a264f7` | DONE | Accepted, overlapping `Game.gd` |
| GAME-FIX-002 | `agent/game-fix-002-need-zero-cadence` | `ef88708a3ab120da4129fea7e0efad125fb7b0a6` | DONE | Accepted, overlapping `Game.gd` |
| GAME-FIX-003 | `agent/game-fix-003-terminal-state-evaluation` | `9ae0e807a59cba366a6013f61f22ab8d76000c82` | DONE | Accepted, overlapping `Game.gd` |
| NPC-CONTENT-002 | `agent/npc-content-002-narrative-alignment` | `fcc70368e60a2ea8d247aa1a304d2c0a9049c89e` | DONE | Accepted, quest/event copy |
| NPC-CONTENT-003 | `agent/npc-content-003-naming-consistency` | `def4f9ab5df04562d43380f533a4cb07cf259459` | DONE | Accepted, quest/event copy |

### UI candidates that must remain unpromoted pending real rendered evidence
| Task | Branch | Captured tip SHA | Board state | Integration class |
| --- | --- | --- | --- | --- |
| UI-FIX-001 | `agent/ui-fix-001-active-npc-integration` | `07a4d159e073e9f810cf1c3007ba907a49299ae3` | NEEDS_REVIEW | Hold: real grounding/scale/occlusion/click render evidence required |
| UI-FIX-002 | `agent/ui-fix-002-home-bed-seam` | `b480befaedc3a3b0cbdaca1916e31dbba7283121` | NEEDS_REVIEW | Hold: real sleep/duvet seam render evidence required |
| UI-FIX-003 | `agent/ui-fix-003-hud-header-decoupling` | `51124e758877750d01f8b72429ead0075a73c596` | NEEDS_REVIEW | Hold: real 1280x720 and 1024x720 layout evidence required |

If any tip changes after this report, the entry is stale and must be re-reviewed before use.

## Conflict inventory

### 1. Gameplay high-conflict chain — `scripts/Game.gd`
GAME-FIX-001, GAME-FIX-002 and GAME-FIX-003 all modify the orchestrator-declared high-conflict file `scripts/Game.gd`.

Observed repository comparison facts:
- GAME-FIX-001 differs from the current coordinator branch in `scripts/Game.gd`, `tools/verify_event_year_separation.gd`, and `agent-reports/gameplay.md`.
- GAME-FIX-002 differs in `scripts/Game.gd`, `tools/verify_need_zero_cadence.gd`, and `agent-reports/gameplay.md`.
- GAME-FIX-003 differs in `scripts/Game.gd`, `tools/verify_terminal_state_evaluation.gd`, and `agent-reports/gameplay.md`.
- Direct GAME-FIX-002 -> GAME-FIX-003 comparison is `diverged`, not a clean fast-forward/ancestor relationship.

Consequence: do not merge these branch tips wholesale and do not resolve `Game.gd` by choosing "ours" or "theirs". The integration result must preserve all three accepted contracts simultaneously:
1. normal event close does not advance year/age;
2. zero-need penalties occur only on explicit completed-hour cadence;
3. terminal-state evaluation is centralized and idempotent.

### 2. Gameplay coordination-file noise
Branch-to-branch comparisons may also show `docs/agents/TASK_BOARD.md`, orchestrator reports, or worker report differences because worker branches forked from different coordinator snapshots. These are historical branch-base differences, not product changes to transplant. QA/build must not use them as merge inputs. Only orchestrator owns coordination files.

### 3. NPC/content ordered overlap
NPC-CONTENT-002 and NPC-CONTENT-003 both touch content under `data/quests.json` / `data/events.json` within their declared scopes. Their intended semantics are cumulative:
- NPC-CONTENT-002 removes the unsupported q3 gift-handoff implication and hospital naming ambiguity;
- NPC-CONTENT-003 performs the later naming/relationship-copy consistency pass while preserving mechanics.

Consequence: apply NPC-CONTENT-002 before NPC-CONTENT-003, then parse both JSON files and rerun quest/hospital regressions. If line-level conflicts occur, preserve IDs, counters, conditions, rewards, effects and schema exactly; only the reviewed strings may change.

### 4. UI pending branches
UI-FIX-001, UI-FIX-002 and UI-FIX-003 do not belong in the accepted integration candidate yet. Their repository ownership review is not equivalent to visual acceptance. Treat their current tips as frozen validation candidates only.

Likely source overlap among the three UI tasks is lower than the gameplay chain because their declared product paths differ (`LocationManager.gd`/NPC presentation, home sleep presentation, HUD presentation), but this does not relax the rendered-evidence requirement. Any later integration candidate including one of these UI tasks must rerun its task-specific contract and visual checks on the exact resulting SHA.

## Deterministic integration order

Construct a fresh integration candidate from the current orchestrator-approved base. Do not merge whole worker branches. Apply only the authorized task implementation/regression deltas in this order:

1. **GAME-FIX-001** — establish daily-event vs annual-progression separation.
2. Run `verify_event_year_separation.gd`.
3. **GAME-FIX-002** — place zero-need penalties on the completed-hour cadence while preserving step 1.
4. Run `verify_event_year_separation.gd`, then `verify_need_zero_cadence.gd`, then `verify_needs.gd`.
5. **GAME-FIX-003** — centralize terminal evaluation while preserving steps 1-4.
6. Run all prior gameplay narrow regressions plus `verify_terminal_state_evaluation.gd`.
7. **NPC-CONTENT-002** — narrative/mechanic alignment strings.
8. Parse `quests.json` and `events.json`; run `verify_quests.gd` and `verify_hospital.gd`.
9. **NPC-CONTENT-003** — later naming/relationship-copy consistency strings.
10. Repeat JSON parsing plus `verify_quests.gd` and `verify_hospital.gd`.
11. Run the shared six-script headless integration gate on the final exact gameplay/content integration SHA.
12. Only after UI-FIX-001/002/003 each has real rendered PASS on its exact candidate SHA may the orchestrator elect to add it. When adding any UI task, rerun its narrow checks and the shared gate again on the new SHA; do not inherit PASS from a prior SHA.

Reason for gameplay ordering: it follows accepted task sequence and minimizes semantic replacement risk. GAME-FIX-003 is intentionally last because its centralized evaluator should operate on the already-corrected event/time-cadence behavior rather than being integrated first and then edited around by older fixes.

## Cumulative rerun matrix

| Integration point | Required narrow checks before proceeding | Why |
| --- | --- | --- |
| after GAME-FIX-001 | `verify_event_year_separation.gd` | Protect daily event closure / annual progression separation |
| after GAME-FIX-002 | `verify_event_year_separation.gd`; `verify_need_zero_cadence.gd`; `verify_needs.gd` | Both tasks overlap `Game.gd`; prove the cadence edit did not reintroduce annual progression coupling |
| after GAME-FIX-003 | all prior gameplay checks + `verify_terminal_state_evaluation.gd` | Third `Game.gd` overlap; prove centralized ending logic coexists with event/time fixes |
| after NPC-CONTENT-002 | JSON parse both files; `verify_quests.gd`; `verify_hospital.gd` | Ensure copy edits did not damage schema/quest/hospital loading |
| after NPC-CONTENT-003 | repeat same content checks | Later copy audit overlaps same content domain |
| final gameplay/content candidate | six-script shared headless gate | Cross-system compatibility on one exact SHA |
| after any later UI inclusion | UI task-specific headless contract + six-script gate + mandatory real rendered checks | A changed SHA invalidates earlier visual/runtime evidence |

## Exact prepared commands

### Gameplay narrow checks
```bash
godot --headless --path . --script res://tools/verify_event_year_separation.gd
godot --headless --path . --script res://tools/verify_need_zero_cadence.gd
godot --headless --path . --script res://tools/verify_needs.gd
godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd
```

### Content checks
```bash
python -m json.tool data/quests.json > /dev/null
python -m json.tool data/events.json > /dev/null
godot --headless --path . --script res://tools/verify_quests.gd
godot --headless --path . --script res://tools/verify_hospital.gd
```
PowerShell: redirect parser output to `$null` instead of `/dev/null`.

### Shared six-script headless gate
```bash
godot --headless --path . --script res://tools/verify_locations.gd
godot --headless --path . --script res://tools/verify_navigation.gd
godot --headless --path . --script res://tools/verify_day_cycle.gd
godot --headless --path . --script res://tools/verify_day_flow.gd
godot --headless --path . --script res://tools/verify_npc.gd
godot --headless --path . --script res://tools/verify_quests.gd
```

Retain the QA-003 caveat: `verify_day_cycle.gd` and `verify_day_flow.gd` are assert-heavy; QA-002/local execution must confirm an intentionally forced assertion failure produces a non-zero process exit under the actual Godot 4.7.2 execution environment before relying on that property as a CI gate contract.

## UI hold requirements

### UI-FIX-001
Do not promote without actual rendered evidence on exact SHA confirming feet/shadow/scale/depth coherence, occlusion, click/hover alignment and preserved talk routing.

### UI-FIX-002
Run its home seam/presentation/activity headless checks and obtain actual rendered sleep-state evidence proving no duplicated bed, no hard lower-body/duvet seam, coherent pillow/head anchor and correct foreground layering.

### UI-FIX-003
The current candidate tip is `51124e758877750d01f8b72429ead0075a73c596`. Any prior manifest or screenshot tied to `ff36fe6368d4f0b8088c266dab6331fce71e6454` is stale. Run the HUD layout contract and real rendered checks at both 1280x720 and 1024x720 on the current exact candidate/integration SHA.

## Stop conditions
Stop integration and open a minimal follow-up issue/task rather than silently resolving when any of the following occurs:
- any reviewed branch tip has changed without re-review;
- a `Game.gd` conflict cannot preserve all previously accepted contracts simultaneously;
- conflict resolution introduces a threshold, balance, save schema, annual progression, or ending behavior change not authorized by the source tasks;
- content conflict requires changing conditions, IDs, rewards, effects, counters, schema or relationship mechanics;
- any narrow regression or shared headless gate exits non-zero;
- the exact tested SHA cannot be recorded;
- a UI task is called PASS without real rendered Godot evidence;
- Web/browser success is inferred from headless results rather than actually executed.

## Minimal failure handoff format
If integration fails, record:
1. exact integration SHA before the failing step;
2. exact source task branch/tip being applied;
3. conflicting file and smallest conflicting function/data entry;
4. exact command and exit code;
5. smallest reproducible observed mismatch;
6. recommended owner (`gameplay`, `npc-content`, `scene-ui`, or `qa-build`) without QA directly repairing business code.

## What QA-006 proved / did not prove
QA-006 proved only repository-visible branch identity, divergence/conflict risk, deterministic application order, and the required rerun/stop matrix. It did **not** prove runtime correctness, Web export success, browser behavior, visual correctness, or integrated build success.

## Handoff
QA-006 repository work is complete and requests `NEEDS_REVIEW`.

Next execution should construct one exact gameplay/content integration candidate from orchestrator-approved task deltas using the order above, then run cumulative narrow regressions followed by the shared six-script gate. UI branches remain held until real rendered evidence exists on the exact candidate SHA.