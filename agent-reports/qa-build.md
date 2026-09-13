# QA/Build Agent Report

## Task
- ID: QA-001
- Agent: qa-build
- Branch/worktree: `agent/qa-001-repo-health`
- Status: NEEDS_REVIEW

## Scope
Repository audit only. Project/export/workflow/source files were read-only for this task. The only changed file is this report.

## Summary
The GitHub-visible project baseline is buildable-looking and has no repository-visible **Critical** blocker. `project.godot` points to an existing `scenes/Main.tscn`; the main scene's core scripts exist; the configured Chinese font exists; the Web preset exists; and the current deployment workflow uses Godot 4.7.2, matching the project version.

This task did **not** launch Godot, run local verification scripts, perform a new Web export, or open the deployed game in a browser. Existing GitHub Actions and historical local QA evidence are recorded below only as prior evidence.

The largest current QA gap is not a known build break: it is that CI proves export/static deployment, but does not run the repository's gameplay regression suites or execute the exported game in a real browser. QA-002 should establish that fresh runtime baseline.

## Findings

### Critical
- **None found from repository inspection.** No current missing main-scene/core-preload/configuration defect was identified that is proven to prevent project parsing or Web export.

### High

#### H1 — Current CI green does not prove browser runtime acceptance
- Path: `.github/workflows/deploy-web.yml`
- The workflow exports Godot Web, checks that `index.html`, `index.pck`, and `index.wasm` are non-empty, deploys Pages, then uses `curl` to confirm `/`, `/index.pck`, and `/index.wasm` can be downloaded.
- It does **not** start the game in Chromium/Firefox, wait for the first rendered frame, exercise the start/home flow, inspect JavaScript console errors, or verify runtime resource requests.
- Consequence: a game that exports successfully but fails during `_ready()`, input setup, JS/WASM startup, or a later dynamic resource load can still pass the present smoke job.
- Escalation: QA-002 browser/runtime validation required.

#### H2 — CI does not run the repository regression suites
- Path: `.github/workflows/deploy-web.yml`, `tools/verify_*.gd`
- The only workflow in `.github/workflows/` is `deploy-web.yml`; it performs export/deploy checks but does not run navigation, daily-flow, NPC, quest, save/state, home-interaction, or location regression scripts.
- Historical QA documents report broad local coverage, but those results are not enforced on current/future pushes.
- Consequence: gameplay/parser regressions that do not stop Web export can reach a green deployment.
- Recommended follow-up after QA-002 baseline: add a separate PR/branch regression job using a curated headless suite, keeping windowed input/visual checks out of headless CI unless a display runner is provided.

### Medium

#### M1 — Agent/PR branches are not automatically preflighted by the deployment workflow
- Path: `.github/workflows/deploy-web.yml`
- Automatic push triggers are only `main` and `chatgpt-dev`. There is no `pull_request` trigger and no automatic trigger for `agent/**`, `orchestrator/**`, or `codex/**` branches.
- `workflow_dispatch` accepts `source_ref`, so manual branch validation is possible, but it is not automatic.
- Consequence: multi-agent changes can remain unbuilt until the orchestrator explicitly dispatches validation or integrates them.

#### M2 — `ArtCatalog.CHARACTER_REFERENCE` contains paths whose directory is absent
- Path: `scripts/ArtCatalog.gd`
- `CHARACTER_REFERENCE` points to four files under `res://assets/characters/reference/`.
- GitHub returns 404 for `assets/characters/reference/` on the QA branch. The inspected successful Web PCK also does not contain the representative `core_cast_ten_overview.png` path.
- No current runtime call path loading these reference entries was proven during this repository audit, so this is a latent/catalog integrity defect rather than a demonstrated startup blocker.
- Follow-up: either restore the intended reference assets, remove/update the dead catalog entries, or add a catalog validation test before future code starts consuming them.

#### M3 — Web export packages development-only verification/capture scripts and inactive candidate art
- Path: `export_presets.cfg`
- Web preset uses `export_filter="all_resources"`.
- Inspection of the existing successful Pages artifact for main commit `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b` confirms the PCK contains development resources including `tools/verify_navigation.gd`, `tools/capture_activity_props.gd`, and inactive bed candidate assets such as `protagonist_sleep_side_candidate_v1.png` / `home_bed_blanket_foreground_v3.png`.
- The same PCK did **not** contain the tracked root ZIP `citylife_WEB001_SourceUpload.zip`, so the finding is specifically about exported Godot resources rather than every tracked file.
- Existing artifact sizes: `index.pck` ≈ 29.77 MB and `index.wasm` ≈ 39.51 MB (uncompressed artifact file sizes). Actual network transfer size and startup cost were not measured here.
- Consequence: unnecessary Web payload and shipping of QA/internal candidate resources.
- Follow-up: after runtime stability is confirmed, narrow the production export filter/excludes and compare artifact size plus browser first-load behavior.

#### M4 — `main` is not protected by GitHub branch protection
- Repository branch metadata reports `protected: false` and required status checks are not enforced.
- Project rules correctly say workers must never write/merge directly to `main`, but GitHub itself does not enforce that rule.
- Consequence: accidental direct push/merge can bypass the orchestrator review contract.
- Follow-up is orchestrator/repository administration work, not a QA-001 source edit.

#### M5 — Current Web payload deserves a browser performance check
- Existing successful artifact contains roughly 39.51 MB WASM + 29.77 MB PCK before transport compression.
- This is not proof of poor user experience, because actual HTTP compression, caching, device performance, and startup behavior were not measured.
- QA-002 should capture first-load timing/network transfer on the deployed site before deciding whether this is a release blocker.

### Low

#### L1 — Orphan Godot `.import` sidecars remain after source preview PNGs were removed
- Confirmed example: `assets/preview_scale.png.import` declares `source_file="res://assets/preview_scale.png"`, while the source PNG returns 404.
- The root `assets/` listing contains the same pattern for several `preview_*.png.import` files.
- Current Linux Web CI has succeeded despite them, so they are cleanup/import-noise debt, not a proven blocker.

#### L2 — Legacy mojibake/non-ASCII sprite filenames remain
- Path: `assets/sprites/`
- Repository listing contains old garbled names such as `chibi_5_…`; `docs/ART_ASSETS.md` already records this as a cross-platform warning source and recommends ASCII names for formal assets.
- Existing Linux CI success lowers immediate severity, but these files remain avoidable portability/maintenance debt.

#### L3 — Documentation/deployment bootstrap files are stale relative to the current phase
- `README.md` still describes Phase 3 as the current stage, while `docs/ITERATION_PLAN.md` says Phase 4 scene expansion is already implemented and event/economy work remains.
- `web-preview/index.html` still says source migration is in progress, while the active workflow now exports and deploys `build/web` from Godot.
- `web-preview/` is not the active deployment output in the inspected workflow, so this is maintainer confusion rather than a live-site blocker.

#### L4 — Historical source archive remains tracked at repository root
- Path: `citylife_WEB001_SourceUpload.zip`
- `docs/ARCHITECTURE.md` already identifies it as a roughly 10 MB historical tracked upload and recommends removal only with authorization.
- It was not found inside the inspected successful Web PCK, so this is repository-size debt, not current Web payload evidence.

#### L5 — Godot CI container is referenced by mutable third-party tag
- Path: `.github/workflows/deploy-web.yml`
- Export uses `barichello/godot-ci:4.7.2` rather than an immutable image digest.
- This is a reproducibility/supply-chain-hardening item, not a demonstrated current failure.

## Core configuration / reference inspection

### Project entry
- `project.godot`:
  - `run/main_scene="res://scenes/Main.tscn"`
  - Godot feature `4.7`, `GL Compatibility`
  - viewport `1280×720`, `canvas_items` stretch
  - global font `res://assets/fonts/GameCN.ttf`
  - GL Compatibility renderer for desktop/mobile
- `scenes/Main.tscn` exists and references `scripts/Game.gd` and `scripts/Player.gd`; both exist.
- `assets/fonts/GameCN.ttf` exists in the repository.

### Export
- `export_presets.cfg` has `Windows Desktop` and `Web` presets.
- Web target is `build/web/index.html` and uses `export_filter="all_resources"`.
- No repository-visible invalid preset name mismatch was found: workflow exports preset `Web`, which matches the config.

### Scene/resource samples
- `scenes/interiors/Company.tscn` references existing `InteriorScene.gd`, `NPC.gd`, `office_inside.png`, `npc_laozhang.png`, and `poi.png`.
- `scenes/world/NPC.tscn` references existing `NPC.gd`.
- `scenes/world/POI.tscn` references existing `POI.gd` and `poi.png`.
- `scripts/Game.gd` core preloads were inspected against the current repository tree; no missing core preload was identified.
- `scripts/systems/LocationManager.gd` references the current player sheet, interaction visual scripts, NPC sprites, and nine location backgrounds; the inspected current tree contains those active resources.
- `scripts/world/WorldManager.gd` preloads the current NPC/POI/company scenes and loads the legacy-world ground/building/tree/lamp/lightmap/vignette/rain assets; the inspected current tree contains those active resources.
- `scripts/systems/NPCScheduleSystem.gd` uses `res://data/npc_schedules.json`; the file exists.
- `data/art_catalog.json` active background mappings point at current background assets; `prototype_sprites_active` is false.

## Historical QA evidence — not rerun by QA-001

### Broad regression baseline
`docs/QA_2026-09-13.md` records that at commit `af2aa88` the Phase 4 interaction-base refactor ended with 19 suites green, including park/cafe/hospital/alley/rooftop/quests/job-growth/NPC/needs/daily-routine/store/day-cycle/day-flow/locations/navigation/home-activities/home-edges/onboard/dark. The document records `Navigation checks: 6646; failures: 0` and `Home edge checks: 6252; failures: 0` in that historical run.

This is **historical evidence only**. Source changed after `af2aa88`, including the later home-bed visual integration.

### Later home-bed visual regression evidence
`docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md` records later Godot 4.7.2 checks after the home-bed visual work:
- `tools/verify_home_presentation.gd`: passed historically.
- `tools/verify_home_activities.gd`: passed historically.
- `tools/verify_home_edges.gd`: 6252 checks, 0 failures historically.
- Rendered A/B screenshots were generated historically via `capture_activity_props.gd`.

The same handover explicitly marks the **bed visual acceptance as MIXED / not passed**: the remaining issue is sleep-pose lower-edge/leg blending with the baked bed/foreground. This is a visual acceptance item, not a proven logic/build blocker.

### Existing GitHub Actions evidence
Existing workflow run `34764373199` for main commit `df5ca5dd8ffce7c2a538495a3e8fec5ef2d6539b` completed successfully before this audit. Its recorded jobs show:
- `Export Godot Web`: success.
- `Verify Web build`: success.
- Pages `deploy`: success.
- static `smoke`: success.
- recovery reporting: success.

The earlier automated CI failure issue #3 is closed as recovered.

This QA-001 agent **inspected** those existing GitHub records/artifact; it did not trigger that build, rerun the export, or perform a browser runtime test.

## Files inspected
- Coordination/rules: `docs/agents/WEB_AGENT_LAUNCHPAD.md`, `MASTER_PLAN.md`, `TASK_BOARD.md`, `AGENT_RULES.md`, `FILE_OWNERSHIP.md`.
- Current context: `HANDOFF.md`, `docs/ARCHITECTURE.md`, `docs/ITERATION_PLAN.md`, `docs/TODAY_HANDOFF_2026-09-13.md`, `docs/QA_2026-09-13.md`, `docs/HANDOVER_HOME_BED_VISUAL_QA_2026-09-13.md`, `docs/ART_ASSETS.md`, `README.md`.
- Build/config: `project.godot`, `export_presets.cfg`, `.github/workflows/deploy-web.yml`, `.gitignore`, `web-preview/index.html`.
- Scenes: `scenes/Main.tscn`, `scenes/interiors/Company.tscn`, `scenes/world/NPC.tscn`, `scenes/world/POI.tscn`.
- Runtime/reference samples: `scripts/Game.gd`, `scripts/ArtCatalog.gd`, `scripts/Data.gd`, `scripts/systems/LocationManager.gd`, `scripts/systems/NPCScheduleSystem.gd`, `scripts/world/WorldManager.gd`, `data/art_catalog.json`.
- Asset/reference checks: `assets/fonts/`, `assets/characters/reference/`, root `assets/` preview sidecars, `assets/sprites/` listing.
- GitHub deployment evidence: current main branch metadata, Actions run `34764373199` + jobs + Pages artifact, auto-CI issue #3.

## Validation performed by QA-001
- **Fresh Godot startup:** not run.
- **Fresh local verification scripts:** not run.
- **Fresh Web export:** not run.
- **Fresh browser/play test:** not run.
- **Repository/API inspection:** performed.
- **Commit/ref comparisons:** performed.
- **Existing CI job/artifact inspection:** performed; this is prior evidence, not a new validation run.

Repository-audit result: **no Critical repository-visible blocker found; runtime acceptance remains outstanding.**

## QA-002 runtime validation package
QA-002 should be created/unblocked by the orchestrator only after reviewing this report. Test one exact source SHA and record it in all evidence. Default intent is validation-only; failures become separate repair tasks rather than being silently fixed inside QA-002.

### A. Fresh Godot project startup/import
From the project root on the known Godot 4.7.2 Windows environment:

```powershell
$godotExe = 'F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --path . --editor --quit
```

Required evidence:
- process exit code;
- stdout/stderr captured;
- no parser error, missing-resource error, or failed main-scene load/import error.

### B. Minimum current-HEAD regression gate
Run the high-value cross-system suites plus the later home-presentation suite:

```powershell
& $godotExe --headless --path . --script res://tools/verify_navigation.gd
& $godotExe --headless --path . --script res://tools/verify_home_edges.gd
& $godotExe --headless --path . --script res://tools/verify_home_activities.gd
& $godotExe --headless --path . --script res://tools/verify_home_presentation.gd
& $godotExe --headless --path . --script res://tools/verify_locations.gd
& $godotExe --headless --path . --script res://tools/verify_day_flow.gd
& $godotExe --headless --path . --script res://tools/verify_npc.gd
& $godotExe --headless --path . --script res://tools/verify_job_growth.gd
& $godotExe --headless --path . --script res://tools/verify_quests.gd
```

Then run the real-input test **with a window**:

```powershell
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/verify_home_input.gd
```

Required evidence:
- command + exact tested commit SHA;
- exit code and final summary for every script;
- navigation/home-edge numeric failure counts;
- any parser warnings/errors separated from assertion failures.

Do **not** use `tools/verify.gd` as a generic gate: current project docs mark it intentionally deprecated with expected exit code 2. Also do not invoke the documented `extends Node` legacy helper scripts with `--script` as though a hang were a product failure.

### C. Fresh Web export from the same tested SHA

```powershell
Remove-Item -Recurse -Force build\web -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force build\web | Out-Null
& $godotExe --headless --path . --export-release "Web" build/web/index.html
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Get-Item build/web/index.html, build/web/index.js, build/web/index.pck, build/web/index.wasm |
    Select-Object Name,Length
```

Required evidence:
- export exit code 0;
- non-empty `index.html`, `index.js`, `index.pck`, `index.wasm`;
- exported file sizes;
- no parser/missing-resource errors in export log.

### D. Browser runtime check — required because current CI only curls files
Serve `build/web` over HTTP (do not open `index.html` directly from `file://`), for example:

```powershell
py -m http.server 8000 --directory build/web
```

Then open `http://127.0.0.1:8000/` in a real browser and capture:
1. first rendered game/start screen;
2. choose an origin and enter the home scene;
3. perform one ground movement and one home interaction (bed is preferred because it exercises the latest presentation path);
4. browser console: no uncaught fatal JS/WASM/Godot errors;
5. network: `index.js`, `index.wasm`, and `index.pck` return successfully; record any 404/resource failures;
6. screenshot of the loaded home state and, if bed is exercised, record the known visual MIXED item separately from functional pass/fail.

### E. Deployment acceptance
After local checks pass, manually dispatch `.github/workflows/deploy-web.yml` from an orchestrator-approved context using the exact QA-002 source ref/SHA.

Required evidence:
- Actions run URL and tested source SHA;
- build/export job success;
- deploy job success;
- static smoke success;
- Pages URL;
- **separate real-browser check of the deployed Pages URL**, confirming the game renders and reaches home with no fatal console errors/404s. Do not treat the curl smoke alone as browser acceptance.

### F. Performance observation, not an automatic blocker
On the deployed browser check, record:
- transferred/cached sizes for WASM/PCK/JS;
- approximate first-load-to-first-frame timing on the test machine/network;
- whether a refresh benefits from cache.

Use this evidence to decide whether the current broad `all_resources` export needs a separate payload-optimization task.

## Known issues / risks carried forward
- Bed sleep visual integration is historically marked MIXED; it still needs human visual acceptance.
- Phase 2 and Phase 3 full real-play pacing/text acceptance remain documented as not completed by historical QA.
- Phase 4 event/economy integration remains unfinished by product plan; this is scope/content debt, not a build blocker.
- Runtime/browser status for the exact current source SHA is unknown until QA-002 executes the package above.

## Files changed
- `agent-reports/qa-build.md` only.

## Handoff / requested next action
1. Orchestrator reviews QA-001 and, if accepted, mirrors the task to `DONE` in its own task board.
2. Orchestrator unblocks/creates `QA-002 — Godot/Web runtime acceptance` on `codex/qa-002-runtime-acceptance` (or another explicitly recorded validation branch) and supplies the exact source SHA to test.
3. QA-002 runs the startup/regression/export/browser/deployment package above without opportunistic source fixes.
4. Any failure becomes a separate narrowly owned repair task; after repair, rerun only the affected gate plus the minimum release gate.
