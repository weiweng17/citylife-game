# QA/Build Agent Report

## Task
- ID: QA-CONTENT-014
- Agent: qa-build
- Branch/worktree: `agent/qa-content-014-content-pack-acceptance`
- Status: NEEDS_REVIEW

## Scope
CONTENT-WAVE-01 Pack A acceptance/integration gate.

Web-agent writable scope is **only** `agent-reports/qa-build.md`. No production source/data/UI/verifier/workflow/coordination file or `main` change is authorized here. Real parser/Godot/render/Web/browser evidence remains QA-002/Codex work on one exact frozen candidate SHA.

No parser, Godot, verifier, Web export, browser or screenshot test was run by QA-CONTENT-014.

## Coordination baseline
Latest coordination state inspected:
- branch: `orchestrator/multi-agent-bootstrap`
- exact tip: `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- QA-CONTENT-014: READY
- GAME-CONTENT-012: READY
- UI-FIX-007: READY
- NPC-CONTENT-012: READY
- wave plan: `planning/content-expansion-wave-01` at `5ca3e0140d440bf1e07597b115ed04c2bc1d17c3`

The coordination branch is the control plane, not the final semantic/runtime candidate. Existing accepted Gameplay/content semantics newer than coordination must be preserved during integration.

Relevant accepted anchors:
- GAME-FIX-009 exact tip `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`; accepted `Game.gd` blob `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`.
- NPC-CONTENT-010 branch tip `923e43541303a4f66a643bddef3a993a1ed234b5`; source change commit `46264de61d72c6b8a51bbe54003f665c36226f4a`.

For final Pack A integration, do not replace cumulative `Game.gd` or `data/events.json` from a metadata-oriented branch snapshot. Compose accepted semantics deterministically.

## Current producer snapshot
These are moving worker tips observed during this QA pass, **not accepted inputs**. Re-read exact tips before review/freeze.

### GAME-CONTENT-012
Observed exact tip:
- `8b2bf910d2831819329c10b0c34bdb59b1e8f4b3`

Current production/verifier blobs:
- `scripts/Game.gd`: `5a2ee0f952953e8e17ba91db6399ffb2429238fe`
- `scripts/systems/OfficeActivities.gd`: `ab8d2662287bf1b853f2e63e612e01dad0db338f`
- `scripts/systems/CafeActivities.gd`: `a060dd15a270aca1ab96a2ea980a08843cb13b11`
- `tools/verify_livelihood_actions.gd`: `9cbac50a43bdc4a27a5a228e132000d463a7400f`

Repository-visible implementation now includes:
- office overtime after ordinary work;
- cafe side gig;
- same-day flags using existing `GameState.flags` persistence rather than a new save section;
- overtime: 120 minutes, health -4, mood -8, pay = 60% of current shift wage;
- cafe gig: 90 minutes, +55 money, health -2, mood -4;
- livelihood time settlement calls time advance -> needs settlement -> existing authoritative terminal evaluator;
- dedicated verifier covering visibility, costs/reward, anti-spam, save-payload persistence, next-day reopening and terminal-order invariants.

Current worker report is still the inherited GAME-001 placeholder, so this observed tip is **not review-complete and must not be frozen**.

One current scope concern also remains: the livelihood settlement patch changes an existing ordinary-work `_work_growth_line()` sentence that is not required by the narrow livelihood handlers/context-feed grant. If the final review tip still contains that unrelated copy edit, either remove it or have 00 explicitly accept the expanded scope; QA should not silently absorb it.

### UI-FIX-007
Observed exact tip:
- `fe2e527616e18868df0900c3b6b8b1f2db9599d4`

Worker report at that tip: `NEEDS_REVIEW`.

Diff is limited to authorized paths:
- `scripts/ui/DialogUI.gd`
- `tools/verify_dialog_panel_overflow.gd`
- `agent-reports/scene-ui.md`

File identities:
- `DialogUI.gd`: `ebd30a2b37ad3a33ff0e86a5be52fcb9749335a8`
- verifier: `74fe12315eedcfdad5aa3888def7cb7418a41b21`

Repository/static contract is coherent: only the body scrolls; speaker/action remain outside; horizontal scrolling is disabled; line progression/reopen reset body scroll; public dialogue lifecycle remains intact. This is still not Godot/render PASS until 00 accepts an exact tip and QA-002 runs it on the frozen integration SHA.

### NPC-CONTENT-012
Observed exact tip:
- `d415ecf165fc6c90d5abf42e5929745d1739acf4`

No worker delta exists at final capture. The 20-event Pack A cannot yet be counted or reviewed.

## Event schema contract
Current `EventSystem.gd` supports condition keys:
- `money_min`, `money_max`
- `health_min`, `health_max`
- `mood_min`, `mood_max`
- `skill_min`
- `network_min`
- `age_min`
- `job`
- `flags`, `flags_not`
- `origins`

Supported option mutations:
- numeric effects: `money`, `health`, `mood`, `skill`, `network`
- `flags` dictionary
- `job`

Any Pack A condition/effect key outside these sets is a repository gate failure unless a separate Gameplay task first adds and validates support.

## Repository gate — NPC-CONTENT-012
Run only on the orchestrator-reviewed exact worker tip.

Required scope:
- `data/events.json`
- `agent-reports/npc-content.md`

Required content contract:
1. exactly 20 new events;
2. exactly 4 each at park / cafe / hospital / alley / rooftop;
3. globally unique non-empty IDs;
4. each event has 2-3 usable choices with non-empty results;
5. every event has a real downside/cost and meaningful tradeoff;
6. no unsupported condition/effect keys;
7. at least 5 remembered-choice chains: one Pack A option writes a flag and a later Pack A event/option reads and narratively acknowledges it;
8. at least 6 Pack A events naturally reference existing NPCs;
9. ordinary city life remains primary and dark content secondary;
10. no accidental change to `e_parent_gone`, `e_roommate`, `e_kid_school`, `e_second_child`, `e_downsize`, `e_empty_nest`;
11. no new Xiaoyu romance/housing canon.

Prepared parser command, **not run here**:

```powershell
py -m json.tool data/events.json > $null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

For deterministic Pack A delta analysis, compare the reviewed Pack A data to the accepted pre-Pack-A content baseline (currently NPC-CONTENT-010 or a later 00-recorded superseding baseline), not blindly to coordination `d415ecf...`.

Required QA trace output after the worker lands:
- exact 20 new IDs;
- scene count map proving 4/4/4/4/4;
- option count and real cost per event;
- >=5 `writer event -> flag -> later acknowledgement event` traces;
- >=6 event IDs with the referenced existing NPC(s);
- explicit deferred-policy preservation statement.

## Repository gate — GAME-CONTENT-012
Expected authorized files:
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- narrow livelihood-only regions in `scripts/Game.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

Required semantics:
1. overtime hidden before ordinary work and available after ordinary work that day;
2. overtime once/day and repeatable after day rollover;
3. overtime about 120 minutes, meaningful pay, health/mood cost, roughly 50-70% normal shift pay unless narrowly justified;
4. cafe side gig visible/reachable in normal cafe play, once/day, 90-120 minutes, health/mood cost;
5. cafe gig pays less than ordinary work;
6. visible labels/tooltips state time/reward/major cost;
7. no opaque random success;
8. same-day retry cannot settle money/stats/time again;
9. save/load preserves same-day consumed state through an already-saved mechanism;
10. no new save-schema section / no SaveManager or GameState schema edit;
11. GAME-FIX-001..009 terminal/death ordering remains authoritative;
12. livelihood time/stat costs are observed by the existing terminal evaluator before normal continuation.

Prepared commands, **not run here**:

```powershell
$godotExe = 'F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --path . --editor --quit
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_livelihood_actions.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_daily_routine.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_day_cycle.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_day_flow.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_terminal_mutation_order.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

The current livelihood verifier is assert-driven. Real QA must capture both stdout/stderr and process exit status on the exact Godot 4.7.2 environment; do not infer branch-protection-grade failure propagation from source inspection alone.

## Repository gate — UI-FIX-007
If 00 accepts an exact UI-FIX-007 tip, require:
- body-only vertical scroll;
- speaker and continue/end action outside/reachable;
- no horizontal-scroll dependency;
- `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression, button copy and `dialog_finished` compatibility;
- scroll reset on next line and close/reopen;
- exactly-once completion emission;
- no Gameplay/content/save/navigation changes.

Prepared command, **not run here**:

```powershell
& $godotExe --headless --path . --script res://tools/verify_dialog_panel_overflow.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Headless success is not rendered PASS. On the same frozen SHA, inspect normal and long dialogue at 1280x720 and 960x540.

## Frozen-SHA / stale-evidence rule
QA-CONTENT-014 never accepts movable branch heads.

Before QA-002 execution, 00 must record accepted exact producer tips and assemble one integration commit. Record:

```powershell
git rev-parse HEAD
git status --short
& $godotExe --version
```

All parser/Godot/render/Web/browser evidence must reference that single exact SHA. Any accepted source/verifier change after evidence capture requires a new freeze and rerun of affected checks. Do not splice PASS artifacts from different SHAs.

## Runtime gate — initial Pack A frozen candidate
Prepared only; **not run here**.

### Events
Through normal play, trigger and complete at least one new Pack A event at each of:
- park
- cafe
- hospital
- alley
- rooftop

Record event ID/title, choice, before/after state/flags and UI readability. Existing pre-wave events do not count.

### Office overtime
- prove hidden before ordinary work;
- complete ordinary work and prove overtime appears;
- execute once and record money/time/health/mood;
- retry same day and prove no second settlement;
- save/load while consumed and prove no duplicate payout;
- next day, satisfy the prerequisite again and prove it is repeatable.

### Cafe side gig
- prove normal-play visibility/reachability;
- execute once and record money/time/health/mood;
- prove same-day anti-spam;
- prove pay < ordinary work;
- save/load consumed state;
- prove next-day repeatability.

### Save/load content slice
Prefer a save after both a remembered Pack A flag and a consumed livelihood action exist. After reload, verify the remembered flag, later acknowledgement eligibility, same-day anti-spam, normal player/time/location state, and next-day reopening.

### Dialogue/readability
At 1280x720 and 960x540, verify body-only scrolling, speaker/action reachability, next-line reset, reopen reset and no clipping/overlap.

### Shared regressions
Run on the same frozen SHA at minimum:
- `verify_locations.gd`
- `verify_navigation.gd`
- `verify_day_cycle.gd`
- `verify_day_flow.gd`
- `verify_npc.gd`
- `verify_quests.gd`
- accepted terminal-state regressions applicable to cumulative `Game.gd`

## Later-pack extension — not an initial Pack A blocker
Current `data/quests.json` is still q1-q3. The following runtime requirements activate only after NPC-CONTENT-013 / NPC-CONTENT-014 are implemented and accepted:
- progress at least two q4-q8 steps;
- trigger one relationship-stage episode.

When those packs land, freeze a new candidate. Existing Pack A evidence does not cover new source.

## Web/browser exact-SHA gate
After parser/headless/runtime checks pass on the same candidate:

```powershell
Remove-Item -Recurse -Force build\web -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force build\web | Out-Null
& $godotExe --headless --path . --export-release "Web" build/web/index.html
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Get-Item build/web/index.html, build/web/index.js, build/web/index.pck, build/web/index.wasm | Select-Object Name,Length
py -m http.server 8000 --directory build/web
```

Browser acceptance on that exact export:
- first frame renders;
- no fatal console errors;
- no required-resource 404s;
- normal gameplay starts;
- representative Pack A event, livelihood and long-dialogue flow work;
- screenshots/evidence are tied to the same frozen SHA.

## Current gate disposition
**Gate specification: READY FOR ORCHESTRATOR REVIEW.**

**Pack A integration candidate: NOT READY TO FREEZE at this snapshot.**

Reasons:
1. NPC-CONTENT-012 has no worker delta, so the required 20-event Pack A does not exist yet.
2. GAME-CONTENT-012 has implementation + verifier at observed `8b2bf910...`, but its worker report is still stale and one unrelated ordinary-work copy change needs removal or explicit 00 scope acceptance.
3. UI-FIX-007 has a scope-clean worker `NEEDS_REVIEW` result at observed `fe2e5276...`, but TASK_BOARD is still READY and 00 has not recorded an accepted exact tip.
4. No real parser/Godot/render/Web/browser evidence has been executed for CONTENT-WAVE-01.

## Validation performed in this web phase
Repository/static inspection only:
- read latest TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, MASTER_PLAN, AGENT_RULES and HANDOFF;
- read CONTENT-WAVE-01 plan;
- repeatedly refreshed moving producer tips;
- compared producer diffs to coordination/wave start;
- inspected EventSystem supported condition/effect semantics;
- inspected current Gameplay settlement patch and livelihood verifier;
- inspected current UI-FIX-007 implementation/report/verifier;
- confirmed NPC-CONTENT-012 still has no event-pack delta at final capture.

Not performed:
- JSON parser execution;
- Godot import/start;
- any `.gd` verifier execution;
- rendered viewport validation;
- Web export;
- browser console/network/runtime validation;
- screenshots.

## Files changed by QA-CONTENT-014
- `agent-reports/qa-build.md` only.

## Handoff to 00-Orchestrator
1. Review this report-only gate.
2. Do not freeze moving producer branch heads merely because QA observed them.
3. Review UI-FIX-007 exact worker tip and record the accepted identity if scope/contract passes.
4. Require GAME-CONTENT-012 to submit its own `NEEDS_REVIEW` report and resolve/explicitly accept the unrelated `_work_growth_line()` copy edit before 00 accepts an exact tip.
5. Continue NPC-CONTENT-012 until exactly 20 reviewable events exist, then run the repository shape/content gate against its exact review tip.
6. Assemble one frozen integration SHA only from accepted inputs.
7. Hand that exact SHA to QA-002/Codex/local for parser + Godot + rendered + Web/browser evidence.
8. Any source/tip movement after freeze invalidates affected evidence and requires a new freeze/rerun.
