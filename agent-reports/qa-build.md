# QA/Build Agent Report

## Task
- ID: QA-003
- Agent: qa-build
- Branch/worktree: `agent/qa-003-headless-gate-spec`
- Status: NEEDS_REVIEW

## Scope
Repository inspection and regression-gate specification only.

Writable scope for QA-003 is this report only. No workflow, source, scene, asset, project/export configuration, task-board, or test-script files were modified.

## Summary
QA-003 classified every current `tools/verify*.gd` script and designed a small ordered headless regression gate that can be implemented later by the orchestrator/QA workflow task.

Classification result for the 27 current `verify*.gd` scripts:

- **20 headless-safe candidates** for the current MAP-002 architecture.
- **1 windowed-only** test: `tools/verify_home_input.gd`.
- **6 deprecated/unsafe-as-gate** scripts: `tools/verify.gd` plus five legacy `extends Node` diagnostics.
- **0 unknown** after repository inspection.

No Godot process, Web export, browser, or deployment was run in QA-003. Historical QA records are used only as prior evidence that the modern suites have previously run headless; they are not fresh results for this branch.

## Repository baseline inspected
- QA-003 branch head at task start: `daf7f7a8432f0696ff8cb4604a4fd9e9a8f03383` (`orchestrator: record autonomous cadence and second repair wave`).
- The QA-003 branch differs from `main` only by the multi-agent coordination/report layer; game/test code is the same code baseline as current `main` at `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b`.
- Existing CI uses `barichello/godot-ci:4.7.2`, which matches `project.godot` / project documentation.

## Classification

### A. Headless-safe candidates — 20

These are current-architecture tests implemented as `SceneTree` scripts and/or are explicitly recorded in the 2026-09-13 QA history as having been run headless with Godot 4.7.2. None contains the explicit rendered-window rejection used by `verify_home_input.gd`.

| Script | Primary coverage | Gate note |
| --- | --- | --- |
| `tools/verify_locations.gd` | Main scene, HUD/location header separation, event panel, all location bounds/spawns/static obstacles/continuous movement | Strong first-stage smoke; explicitly aggregates result and exits 0/1 |
| `tools/verify_navigation.gd` | All location navigation, obstacle recovery, low-FPS movement, all home routes, keyboard release, unreachable walls/polygons | Strong structural/navigation gate; explicitly aggregates result and exits 0/1 |
| `tools/verify_home_activities.gd` | Home proximity, one-time settlement, facing, feedback/props, rest visual state, door travel | Headless-safe, but mainly `assert()` driven |
| `tools/verify_home_edges.gd` | Dense home collider-edge/path traversal and no furniture crossing | Explicit failure accumulator/0-1 exit; relatively exhaustive rather than minimal |
| `tools/verify_home_presentation.gd` | Interaction anchor contract, sleep/work pose/depth state, duvet/shadow state | Logic/presentation-state check only; does not replace rendered visual QA |
| `tools/verify_daily_routine.gd` | Daily task state, save round-trip, commute/work settlement, midnight reset | Headless-safe; mainly `assert()` driven |
| `tools/verify_needs.gd` | Fullness/energy time drain, replenishment, warning cadence, save state | Historical headless regression suite member |
| `tools/verify_store.gd` | Store unlock/reachability, panel lock, purchase/use, inventory, meal linkage, save round-trip | Headless-safe; mainly `assert()` driven |
| `tools/verify_day_cycle.gd` | Day/night sleep rules, needs effects, complete in-memory save payload restore | High-value state/save seam; mainly `assert()` driven |
| `tools/verify_day_flow.gd` | Integrated home → subway → office → store → home → overnight loop through gameplay interfaces | High-value end-to-end headless seam; mainly `assert()` driven |
| `tools/verify_npc.gd` | Schedule/hotspots/dialogue signal chain, daily relation gain/tier, save round-trip | Explicit failure accumulator/0-1 exit; mouse hit-testing intentionally delegated to windowed test |
| `tools/verify_job_growth.gd` | Skill tiers/wage/EXP/negotiation algorithm, in-game work/raise flow, save state | Explicit failure accumulator/0-1 exit; larger feature regression |
| `tools/verify_quests.gd` | Quest content validation, idempotence, full chain, real settlement hooks, save round-trip | Explicit failure accumulator/0-1 exit; catches silent quest dead-end/schema mistakes |
| `tools/verify_onboard.gd` | Tutorial text contract and required concepts | Explicit 0/1 exit; low-cost content contract |
| `tools/verify_dark.gd` | Dark-path option structure and ending routing | Headless-safe; `assert()` driven, narrow content rule |
| `tools/verify_park.gd` | Park spot reachability/settlement/layer visibility | Historical headless regression suite member |
| `tools/verify_cafe.gd` | Cafe spots, purchase/failure rules, NPC noon schedule, layer visibility | Historical headless regression suite member |
| `tools/verify_hospital.gd` | Hospital spots, cost/effects/failure rules, layer visibility | Historical headless regression suite member |
| `tools/verify_alley.gd` | Alley spot reachability, incense/rest rules, insufficient-funds behavior, layer visibility | Current `SceneTree` pattern with explicit failure collection |
| `tools/verify_rooftop.gd` | Rooftop spot reachability/settlement/layer visibility | Historical headless regression suite member |

Historical evidence: `docs/QA_2026-09-13.md` records a 19-suite headless full regression containing all of the above except the later bed-presentation test; `docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md` separately records `verify_home_presentation.gd` as having passed headless. These are **historical results only** and were not rerun for QA-003.

### B. Windowed-only — 1

#### `tools/verify_home_input.gd`
The script explicitly checks:

```gdscript
if DisplayServer.get_name() == "headless":
    printerr("This test requires a rendered window for GUI hit-testing. Run without --headless.")
    quit(2)
```

It uses real GUI hit-testing behavior, `Input.warp_mouse`, viewport input, actual button rectangles and keyboard/mouse event injection. It must stay outside the headless gate.

Required execution form for a later local/Codex acceptance pass:

```powershell
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/verify_home_input.gd
```

Expected meaning:
- exit 0: windowed input regression passed;
- exit 1: regression failure;
- exit 2: invalid execution environment (headless), **not a pass**.

### C. Deprecated / unsafe as CI gate — 6

#### `tools/verify.gd`
Explicitly deprecated after MAP-002. Its header says the old single-world-map APIs are gone and that continuing could produce misleading green output. On the current architecture it intentionally exits 2 and directs callers to replacement suites. Never put this script in a required gate.

#### `tools/verify_art.gd`
Legacy `extends Node` diagnostic invoked through `tools/VerifyArt.tscn`, not directly with `--script`. It asserts old pixel-asset dimensions and old light-node assumptions. It is not part of the current 19-suite regression baseline and is unsafe as a modern required gate.

#### `tools/verify_hud.gd`
Legacy `extends Node` diagnostic invoked through `tools/VerifyHud.tscn`. It only checks for at least two progress bars and legacy width assumptions; current HUD has evolved beyond that contract. Keep only as an old diagnostic until rewritten.

#### `tools/verify_interior.gd`
Legacy `extends Node` diagnostic invoked through `tools/VerifyInterior.tscn`. It reads stale root fields/methods such as `_world`, `_interior`, `inside`, `_enter_interior`, `_exit_interior` and old interior-node naming, while current world/interior ownership lives behind newer systems. Unsafe as a current gate.

#### `tools/verify_layout.gd`
Legacy `extends Node` visual/layout diagnostic invoked through `tools/VerifyLayout.tscn`. It binds to specific StartPanel child structure and fixed pixel widths. It is not a current regression-suite member and should not be a required headless gate without revalidation/rewrite.

#### `tools/verify_min.gd`
Legacy `extends Node` isolation diagnostic invoked through `tools/VerifyMin.tscn`. It reads old root `_world`, `_interior`, and `npc_nodes` assumptions. It is a debugging probe, not a current acceptance test.

### D. Unknown — 0
No current `tools/verify*.gd` remains unclassified.

## Recommended smallest ordered headless PR gate

The recommended **minimum useful gate is six scripts**, ordered from structural/startup checks to integrated systems. This deliberately avoids running all 20 suites on every PR while still covering the highest-risk cross-system seams.

1. `verify_locations.gd`
   - proves the main scene can instantiate far enough to build the current HUD/location systems;
   - exercises all location bounds/spawns/obstacles and UI separation;
   - explicit 0/1 result.
2. `verify_navigation.gd`
   - exercises all location navigation profiles, dense movement, home paths, keyboard-state regression and unreachable targets;
   - explicit 0/1 result.
3. `verify_day_cycle.gd`
   - covers day rollover, overnight rules, needs changes and the broad in-memory save payload restore;
   - uniquely protects persistence/time state not covered by the first two.
4. `verify_day_flow.gd`
   - headless end-to-end daily loop through travel, office, store, home actions and overnight reset;
   - catches wiring failures that isolated tests miss.
5. `verify_npc.gd`
   - covers schedule → hotspot → dialogue signal → relation settlement → save state;
   - explicit 0/1 result.
6. `verify_quests.gd`
   - validates `quests.json`, full serial quest chain, real settlement hooks, idempotence and saved progress;
   - explicit 0/1 result.

Why the other headless tests are not in the minimum PR gate:
- scene-specific activity suites (`park/cafe/hospital/alley/rooftop`) are valuable but narrower and can run in the extended suite;
- `home_activities`, `store`, `daily_routine`, `needs`, `job_growth` overlap portions of `day_flow`, `day_cycle`, `npc`, and `quests`, though they remain important for full regression;
- `home_edges` is deliberately exhaustive and better suited to full/nightly regression unless navigation files change;
- `home_presentation` checks logical presentation state, not actual pixels, and rendered acceptance remains separate;
- `onboard` and `dark` are narrow content contracts.

## Exact proposed CI commands

These commands mirror the existing workflow's Godot 4.7.2 Docker image. They are a **specification only; QA-003 did not execute them**.

Run in this order and stop on the first non-zero exit:

```bash
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_locations.gd
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_navigation.gd
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_day_cycle.gd
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_day_flow.gd
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_npc.gd
docker run --rm -v "$PWD:/workspace" -w /workspace barichello/godot-ci:4.7.2 godot --headless --path /workspace --script res://tools/verify_quests.gd
```

A future workflow implementation should use fail-fast shell behavior (`set -e`) or separate Actions steps so any non-zero process result blocks the check.

## Extended headless regression pack

After the six-script minimum gate is stable, the following 14 suites form the extended headless pack. Recommended use: merge-to-main, nightly/manual full regression, or path-targeted runs when their owning system changes.

```text
verify_home_activities.gd
verify_home_edges.gd
verify_home_presentation.gd
verify_daily_routine.gd
verify_needs.gd
verify_store.gd
verify_job_growth.gd
verify_onboard.gd
verify_dark.gd
verify_park.gd
verify_cafe.gd
verify_hospital.gd
verify_alley.gd
verify_rooftop.gd
```

Together with the six-script minimum set, this reproduces the current 20-script modern headless candidate inventory.

## Important gate-hardening finding: `assert()`-driven tests

Several modern suites (`verify_day_cycle.gd`, `verify_day_flow.gd`, `verify_home_activities.gd`, `verify_daily_routine.gd`, `verify_store.gd`, `verify_dark.gd`, and potentially other older suites) primarily use `assert()` and may finish with an unconditional `quit(0)`/`quit()` after successful execution.

Repository inspection cannot prove how an assertion failure propagates through the exact `barichello/godot-ci:4.7.2` binary used in GitHub Actions. Historical green runs prove success execution, but **do not prove the negative-path exit-code contract**.

Therefore `verify_day_cycle.gd` and `verify_day_flow.gd` should not become branch-protection-required checks until QA-002/local execution confirms that a failed assertion produces a non-zero process result in the CI image. If that cannot be proven reliably, a later QA implementation task should harden those scripts to collect failures and explicitly exit 1, matching `verify_navigation.gd`, `verify_npc.gd`, and `verify_quests.gd`.

## QA-002 / local validation package required before enforcement

This package is prepared but **not run** in QA-003.

### 1. Clean baseline
- Use Godot 4.7.2.
- Test the exact integration candidate SHA, not an unrelated local working tree.
- Record `git rev-parse HEAD` and engine version before the suite.
- Do not modify player save data; the selected save checks use in-memory payloads.

### 2. Run the six proposed commands individually
Capture for each command:
- exact command;
- exit code;
- stdout/stderr;
- elapsed runtime;
- whether `.godot/` or ignored build output was the only generated state.

Expected success evidence from the scripts includes:
- `verify_locations`: final `全部通过` result and exit 0;
- `verify_navigation`: `failures: 0` and exit 0;
- `verify_day_cycle`: all PASS assertions complete and exit 0;
- `verify_day_flow`: reaches `day flow total money:` and exit 0;
- `verify_npc`: `NPC relation failures: 0` and exit 0;
- `verify_quests`: `quest failures: 0` and exit 0.

### 3. Repeat the complete six-script sequence twice on the same SHA
Purpose: detect frame/order/flakiness before making the check required. Both runs must pass with the same logical outcomes.

### 4. Validate negative-path / exit-code behavior
This is especially required for the two minimum-gate scripts that rely heavily on `assert()`:
- `verify_day_cycle.gd`
- `verify_day_flow.gd`

Use a disposable local/Codex worktree or non-committed scratch change that forces one assertion false, then verify the exact CI-image command exits non-zero. Revert/discard the scratch edit immediately; do not merge the forced failure.

If either test can print an assertion failure yet return 0, it is **not safe as a required CI gate** until a separate authorized task changes it to explicit 0/1 failure aggregation.

### 5. Confirm exclusions
- Run `verify_home_input.gd` only in a rendered window and confirm it is not invoked by headless CI.
- Do not run `verify.gd` as a pass/fail regression; exit 2 is its expected current deprecation path.
- Do not add the five legacy `Verify*.tscn` diagnostics to a required gate without a separate modernization review.

### 6. Web/browser checks remain separate
A headless GDScript gate does not replace:
- Web export;
- artifact existence checks;
- deployed HTTP smoke;
- browser startup/console/runtime inspection;
- rendered visual acceptance.

Those belong to QA-002 / deployment acceptance and must continue to be reported separately.

## Suggested follow-up implementation order
1. Orchestrator reviews QA-003 classification and six-test minimum.
2. QA-002/Codex validates the six commands and assertion failure propagation on Godot 4.7.2.
3. Only after that evidence exists, create a separately authorized workflow task to add a PR headless regression job; do not mix workflow editing into QA-003.
4. If runtime cost is acceptable, add the 14 extended suites to merge/manual/nightly coverage or path-targeted jobs.
5. Later modernize/remove the six deprecated diagnostics so future agents do not mistake them for current acceptance gates.

## Files inspected
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `docs/agents/AGENT_RULES.md`
- `agent-reports/qa-build.md`
- repository tree under `tools/**`
- all current `tools/verify*.gd` inventory, with direct detailed inspection of gate/exclusion-critical scripts including:
  - `tools/verify.gd`
  - `tools/verify_navigation.gd`
  - `tools/verify_locations.gd`
  - `tools/verify_home_input.gd`
  - `tools/verify_home_presentation.gd`
  - `tools/verify_home_activities.gd`
  - `tools/verify_home_edges.gd`
  - `tools/verify_day_cycle.gd`
  - `tools/verify_day_flow.gd`
  - `tools/verify_npc.gd`
  - `tools/verify_job_growth.gd`
  - `tools/verify_quests.gd`
  - `tools/verify_onboard.gd`
  - `tools/verify_store.gd`
  - `tools/verify_dark.gd`
  - representative scene-specific suites (`verify_alley.gd`, `verify_cafe.gd`)
  - legacy `verify_art.gd`, `verify_hud.gd`, `verify_interior.gd`, `verify_layout.gd`, `verify_min.gd`
- historical QA/handoff evidence in `docs/QA_2026-09-13.md` and `docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md`
- existing `.github/workflows/deploy-web.yml` command pattern (read-only context only)

## Validation performed in QA-003
- GitHub repository inspection only.
- Branch existence/baseline and file inventory inspected through GitHub.
- No local commands executed.
- No Godot process launched.
- No headless regression script rerun.
- No Web export performed.
- No browser or deployment check performed.

## Known risks
- The proposed minimum suite has not yet been timed in CI.
- Assertion failure propagation for `verify_day_cycle.gd` and `verify_day_flow.gd` is not freshly proven in the CI image.
- Historical headless green results are useful prior evidence, not a substitute for QA-002 execution on the integration SHA.
- Headless presentation-state tests cannot prove actual rendered visual quality or browser compatibility.

## Handoff
QA-003 is ready for orchestrator review. Requested status: `NEEDS_REVIEW`.

No workflow/source/test changes should be integrated from this task because none were authorized or made. The next safe action is the prepared QA-002/local validation package above; only after that evidence should a separate workflow task implement the required PR gate.