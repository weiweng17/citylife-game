# QA/Build Agent Report

## Task
- ID: QA-CONTENT-015
- Agent: qa-build
- Branch/worktree: `agent/qa-content-015-producer-consolidation`
- Status: NEEDS_REVIEW

## Scope
Accepted-producer consolidation manifest for CONTENT-WAVE-01.

Per the current `TASK_BOARD.md`, the only writable path for this web-agent task is this report. No merge, cherry-pick, rebase, production source/data/UI/verifier/workflow/coordination edit, `main` edit, parser execution, Godot launch, render run, Web export, browser run, screenshot capture, or audio playback was performed or claimed.

This task does not re-run QA-CONTENT-014. It consumes that accepted gate and records the deterministic exact inputs that 00 has now accepted, plus the remaining blockers before a final QA-002 frozen runtime candidate can be treated as Pack-A-playable.

## Latest control-plane source of truth
Latest coordination branch inspected:
- `orchestrator/multi-agent-bootstrap`
- exact tip at final inspection start: `58aea211ac66a27e6ff921f8a20d103d2c5f4f75`

Current TASK_BOARD state relevant to this task:
- QA-CONTENT-014: DONE; accepted gate report tip `7391aac43a602bb04490e20144a4354a76b45b3a`.
- GAME-CONTENT-012: DONE; accepted exact tip `14ca63ac569680008f9f4b20cb01514672d75caa`.
- UI-FIX-007: repository-accepted exact tip `fe2e527616e18868df0900c3b6b8b1f2db9599d4`; runtime/render evidence still blocked on QA-002.
- NPC-CONTENT-012: DONE; accepted worker tip `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`; accepted Pack-A content delta commit `fe1625c7a302ac6fc0c902f55145772fa5521580`.
- DIRECTOR-CONTENT-002: accepted final tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`.
- GAME-CONTENT-013: READY and based on accepted GAME-CONTENT-012; no task-specific delta was present at the observed branch tip.
- UI-CONTENT-008: READY but its branch has already started moving; it is not accepted and is explicitly excluded from this manifest.
- GAME-CONTENT-014: BACKLOG / next after GAME-CONTENT-013 review; it is a runtime blocker for enabling ordinary Pack-A city events after onboarding.

## Deterministic accepted input manifest
These are the only current producer identities this report authorizes 00/integration to treat as accepted inputs. A later movable branch head is not a substitute.

### A. Gameplay — GAME-CONTENT-012
Accepted exact tip:
- `14ca63ac569680008f9f4b20cb01514672d75caa`

Task delta against the CONTENT-WAVE baseline `d415ecf165fc6c90d5abf42e5929745d1739acf4` is limited to the authorized five paths:
- `scripts/Game.gd`
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

Accepted implementation file identities:
- `scripts/Game.gd`
  - blob `119f26f774f10f27a2846634661d612b39dec18d`
- `scripts/systems/OfficeActivities.gd`
  - blob `ab8d2662287bf1b853f2e63e612e01dad0db338f`
- `scripts/systems/CafeActivities.gd`
  - blob `a060dd15a270aca1ab96a2ea980a08843cb13b11`
- `tools/verify_livelihood_actions.gd`
  - blob `06c1596c517b1468de990618adb444360addaa4a`

Integration rule:
- use the accepted GAME-CONTENT-012 `Game.gd` semantic/file state as the cumulative Gameplay state through GAME-FIX-009 + livelihood work;
- do not replace it with the metadata-oriented coordination copy or reconstruct it from `main`;
- preserve overtime and cafe-gig values exactly unless a later accepted task supersedes them;
- preserve terminal ordering: elapsed time -> `_sync_needs_to_time()` -> `_evaluate_terminal_state()` -> ordinary completion feedback only if non-terminal;
- preserve existing save schema; the daily anti-spam day markers live in the already-saved `game_state.flags` dictionary.

Repository-accepted livelihood contract:
- office overtime: requires ordinary work first, once/day, 120 min, health -4, mood -8, pay = 60% of current ordinary shift wage;
- cafe temporary side gig: once/day, 90 min, +55 money, health -2, mood -4;
- cafe gig remains below ordinary minimum shift pay;
- no opaque random success;
- both reopen on a later game day by day-number comparison rather than a new save/reset subsystem.

Runtime status: NOT RUN in this task.

### B. Scene/UI — UI-FIX-007
Repository-accepted exact tip:
- `fe2e527616e18868df0900c3b6b8b1f2db9599d4`

Accepted implementation identities:
- `scripts/ui/DialogUI.gd`
  - blob `ebd30a2b37ad3a33ff0e86a5be52fcb9749335a8`
- `tools/verify_dialog_panel_overflow.gd`
  - blob `74fe12315eedcfdad5aa3888def7cb7418a41b21`

Integration rule:
- include this source/verifier pair exactly unless a later accepted UI task supersedes it;
- preserve body-only vertical scrolling, fixed speaker/action outside the scroll owner, no horizontal-scroll dependency, next-line/reopen reset, and the existing `show_dialog()` / `close_dialog()` / `is_busy()` / `dialog_finished` contract;
- repository acceptance is not headless/rendered PASS.

Runtime/render status: NOT RUN in this task.

### C. NPC/Content — NPC-CONTENT-012 Pack A
Accepted worker tip:
- `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`

Accepted content delta commit:
- `fe1625c7a302ac6fc0c902f55145772fa5521580`

Worker branch `data/events.json` blob:
- `3a62219ad9901a44cc5993159c2c32d15c7f0cad`

**The worker `events.json` blob is NOT an integration replacement identity.**

The accepted content input is the semantic append delta from `fe1625c7...`: exactly 20 new `e_cw01_*` event objects appended to the cumulative accepted pre-Pack-A event state. The worker branch was based on a stale control-plane data snapshot, so taking blob `3a62219a...` wholesale could drop earlier accepted NPC-CONTENT-010 copy changes or other cumulative semantic edits.

Required integration algorithm:
1. begin from the orchestrator-approved cumulative pre-Pack-A content state through NPC-CONTENT-010;
2. preserve every existing accepted event object unchanged;
3. append exactly the 20 accepted objects from `fe1625c7...`;
4. do not import any replacement/deletion of old event objects from the stale worker snapshot;
5. create the integration candidate only after a deterministic baseline-preservation comparison proves the above.

Accepted Pack-A IDs:
- park: `e_cw01_park_free_class`, `e_cw01_park_lost_wallet`, `e_cw01_park_rain_aunties`, `e_cw01_park_recruiter_call`
- cafe: `e_cw01_cafe_charger`, `e_cw01_cafe_interview_prep`, `e_cw01_cafe_unpaid_trial`, `e_cw01_cafe_gossip`
- hospital: `e_cw01_hospital_kiosk`, `e_cw01_hospital_report`, `e_cw01_hospital_late_queue`, `e_cw01_hospital_medicine`
- alley: `e_cw01_alley_rider_shelter`, `e_cw01_alley_secondhand`, `e_cw01_alley_rain_stall`, `e_cw01_alley_landlord_repair`
- rooftop: `e_cw01_rooftop_bedding`, `e_cw01_rooftop_bad_review`, `e_cw01_rooftop_fireworks`, `e_cw01_rooftop_afterhours`

Repository-reviewed structure:
- exactly 20 new events;
- 4 per target location;
- 3 choices each;
- supported existing condition/effect keys only;
- five remembered-choice chains;
- more than six natural existing-NPC references;
- deferred spouse/child/roommate/Xiaoyu romance-housing canon untouched by the append delta.

Parser/runtime status: NOT RUN in this task.

### D. Director implementation map — control input, not production source
Accepted exact tip:
- `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`

This tip contributes design/control requirements, not runtime source to the current producer integration.

Accepted first-day spine:
`home meal -> subway -> office Old Zhang contact -> ordinary work -> optional overtime -> store -> home first night -> Day 2`

Important integration consequences:
- Pack A is suppressed during first-day onboarding;
- q1-q3 foreground evaluation/reward noise is suppressed during onboarding;
- cafe side gig is not a Day-1 action;
- successful full-night sleep, not accidental day rollover, is intended to complete onboarding;
- accepted Pack A content cannot simply be enabled after onboarding while ordinary city events still close into the annual/year-advance path.

## Critical blocker — GAME-CONTENT-014
**Pack A repository content is accepted, but Pack A normal runtime triggering is not yet release-safe.**

DIRECTOR-CONTENT-002 identifies that ordinary `EventSystem` event completion currently still reaches `_year_pass()` in the relevant inherited flow. The task board therefore records GAME-CONTENT-014 as the required future narrow Gameplay repair: ordinary city-event completion must gain a validated non-year-advancing minute-scale path while preserving legacy annual-event semantics and terminal ordering.

Consequences for this manifest:
- do not claim Pack A runtime acceptance merely because the 20 objects parse and can be selected;
- do not enable/accept normal post-onboarding Pack-A triggering in the final QA-002 candidate before GAME-CONTENT-014 is repository-accepted and integrated;
- after that task lands, the first Pack-A runtime proof must include an explicit assertion/manual trace that completing an ordinary Pack-A event does **not** advance a year;
- until then, Pack A may be integrated data-wise but remains runtime-suppressed.

This is a real product/runtime blocker, not a reason to create another speculative QA audit.

## Pending branches explicitly excluded from this accepted input set
### GAME-CONTENT-013
Observed branch:
- `agent/game-content-013-first-day-onboarding-gate`
- observed exact tip: `14ca63ac569680008f9f4b20cb01514672d75caa`

At observation it was still identical to the accepted GAME-CONTENT-012 base for task-specific purposes; its inherited report still describes GAME-CONTENT-012. It therefore contributes no new accepted source to this manifest.

If it later moves and 00 accepts a new exact tip before the integration freeze, stop and regenerate the frozen input manifest. Do not silently absorb its new `Game.gd`, `CafeActivities.gd` or future `verify_first30_flow.gd` changes.

### UI-CONTENT-008
Observed branch:
- `agent/ui-content-008-event-choice-readability`
- observed exact tip: `df2ba2a29eb34cd9696c22f43ccd11341d409a29`

The branch has started moving and currently differs from its `58aea211...` task baseline only in `scripts/ui/EventUI.gd`. Its report is still the inherited UI-001 READY template, and 00 has not accepted an exact tip.

Therefore it is **PENDING / EXCLUDED** from this manifest.

If 00 accepts UI-CONTENT-008 before freeze, create a new manifest/freeze and add its verifier/render requirements. If evidence collection has already started, any inclusion changes the candidate SHA and affected evidence must be rerun.

### Other post-manifest producer tasks
NPC-CONTENT-015, ART-PROD-003, AUDIO follow-up work and later Director/UI/Gameplay tasks are not current accepted runtime inputs unless 00 explicitly records an accepted exact tip and the integration manifest is regenerated.

ART-PROD-002 and AUDIO-CONTENT-002 accepted outputs are candidate/specification/source-manifest work only. They do not become Godot/runtime assets simply by appearing in an accepted report.

## Stale-SHA stop rules
1. Never use a movable branch name as the final runtime evidence identity.
2. Every accepted production input must be tied to the exact tips/semantic delta listed above or to a later explicit 00 superseding acceptance.
3. If GAME-CONTENT-013, UI-CONTENT-008, GAME-CONTENT-014 or any other source-bearing task is accepted before freeze, stop and regenerate the integration manifest before QA-002.
4. Once the final integration SHA is frozen, any source/data/verifier/config change invalidates affected evidence. Do not splice PASS artifacts from different SHAs.
5. Runtime screenshots/browser captures must record the same final SHA as parser/headless/runtime runs.
6. NPC-CONTENT-012 is special: exact worker tip identifies the reviewed worker output, but final integration must consume only its accepted append delta semantically, not its stale whole-file blob.
7. Control-plane/worker report commits alone do not force runtime evidence invalidation unless they change the frozen production/verifier candidate; nevertheless the exact integration commit must remain immutable during evidence collection.

## Deterministic integration order — to be performed by 00/local integration, NOT by this web task
1. Start from the previously accepted semantic integration baseline, not from `main` and not from the coordination branch's stale production snapshots.
2. Set cumulative Gameplay source to the accepted GAME-CONTENT-012 identities above.
3. Carry previously accepted UI work and add UI-FIX-007 exact source/verifier pair.
4. Build cumulative accepted pre-Pack-A `data/events.json` through NPC-CONTENT-010.
5. Append only the 20 NPC-CONTENT-012 objects from `fe1625c7...` and prove every pre-existing baseline object remains equal.
6. Carry DIRECTOR-CONTENT-002 as an acceptance/control requirement, not as production source.
7. Exclude unaccepted GAME-CONTENT-013 and UI-CONTENT-008 output.
8. Keep Pack A runtime eligibility suppressed until GAME-CONTENT-014 is accepted/integrated.
9. Inspect the candidate diff for accidental worker-report/control-plane snapshot contamination or loss of earlier accepted semantic fixes.
10. Create one explicit integration commit and record its full 40-character SHA.
11. Only then begin the applicable local/Codex checks. Do not mutate the candidate during evidence collection.

## Minimum local/Codex execution order
Everything below is a prepared package. **Nothing was run by QA-CONTENT-015.**

### Phase 0 — candidate identity
```powershell
git rev-parse HEAD
git status --short
$godotExe = 'F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --version
```
Record the exact SHA before every evidence bundle.

### Phase 1 — static data integrity
Run JSON parsing and the already accepted QA-CONTENT-014 deterministic Pack-A checker against the exact cumulative pre-Pack-A baseline.

Required proof:
- JSON parser exit 0;
- all pre-Pack-A accepted event objects unchanged;
- exactly 20 new IDs;
- 4 park / 4 cafe / 4 hospital / 4 alley / 4 rooftop;
- unique IDs;
- supported keys only;
- five remembered-choice writer -> flag -> later acknowledgement chains;
- six-or-more natural existing-NPC reference events;
- deferred policy content unchanged.

This phase is valid before GAME-CONTENT-014 because it is data integrity, not normal-play Pack-A runtime eligibility.

### Phase 2 — accepted producer headless regressions
```powershell
& $godotExe --headless --path . --editor --quit
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_livelihood_actions.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godotExe --headless --path . --script res://tools/verify_dialog_panel_overflow.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Also run the cumulative terminal/day-flow/shared gates already required by QA-002, including at minimum:
- `verify_terminal_mutation_order.gd`
- `verify_daily_routine.gd`
- `verify_day_cycle.gd`
- `verify_day_flow.gd`
- `verify_locations.gd`
- `verify_navigation.gd`
- `verify_npc.gd`
- `verify_quests.gd`

Important: `verify_livelihood_actions.gd` contains assert-driven checks. Capture stdout/stderr **and process exit code**; do not infer failure propagation from source inspection.

### Phase 3 — livelihood real-runtime proof
On the same exact candidate SHA:
- office overtime hidden before ordinary work;
- ordinary work -> overtime visible/reachable;
- execute overtime and record money/time/health/mood;
- second same-day attempt has no second settlement;
- save/load preserves consumed state;
- next day requires ordinary work again and overtime reopens;
- cafe side gig reachable in normal cafe play when allowed by the current onboarding state;
- execute once, prove +55 / 90 min / health -2 / mood -4;
- same-day duplicate prevented;
- save/load consumed state;
- next-day reopening;
- cafe gig pay remains below ordinary work pay.

If GAME-CONTENT-013 is accepted before freeze, replace this standalone scheduling assumption with its accepted onboarding gate and run `verify_first30_flow.gd` as part of the same SHA package.

### Phase 4 — UI-FIX-007 rendered proof
Same SHA:
- headless verifier result captured;
- 1280x720 ordinary dialogue;
- 1280x720 deliberately long body;
- 960x540 deliberately long body;
- only body scrolls;
- speaker/action remain visible/reachable;
- scroll-to-bottom -> next line resets to top;
- close/reopen resets to top;
- no completion-signal duplication.

If UI-CONTENT-008 is later accepted before freeze, regenerate the manifest and add its exact EventUI verifier/render cases rather than using its current unaccepted branch head.

### Phase 5 — Pack-A runtime eligibility gate — BLOCKED until GAME-CONTENT-014
Do **not** execute five-location Pack-A runtime acceptance as a release PASS until GAME-CONTENT-014 is accepted and integrated.

After unblock, first prove:
- completing one ordinary accepted Pack-A event does not call the annual advancement path / does not advance age/year;
- legacy annual-event semantics still work on their intended path;
- terminal ordering remains intact.

Only then trigger at least one accepted Pack-A event through normal play at each of:
- park
- cafe
- hospital
- alley
- rooftop

For each capture event ID/title, chosen option, before/after money/health/mood/skill/network/flags, and whether any remembered-chain follow-up becomes eligible.

### Phase 6 — save/load content slice
Prefer a save state containing:
- one consumed livelihood action;
- one Pack-A remembered-choice flag after GAME-CONTENT-014 allows Pack A runtime;
- normal time/location/player state.

After reload verify:
- same-day anti-spam survives;
- remembered flag survives;
- later acknowledgement eligibility survives;
- no duplicate rewards;
- day rollover reopens the livelihood action correctly.

### Phase 7 — Web/browser exact-SHA acceptance
Only after the frozen source set is final and applicable Godot/runtime gates pass:
```powershell
Remove-Item -Recurse -Force build\web -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force build\web | Out-Null
& $godotExe --headless --path . --export-release "Web" build/web/index.html
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Get-Item build/web/index.html, build/web/index.js, build/web/index.pck, build/web/index.wasm | Select-Object Name,Length
py -m http.server 8000 --directory build/web
```

Browser evidence on the same SHA:
- first frame renders;
- no fatal console errors;
- no required-resource 404s;
- normal gameplay starts;
- accepted livelihood flow works;
- accepted dialog overflow path works;
- Pack-A representative runtime flow is included only after GAME-CONTENT-014 unblock;
- screenshots/network/console evidence are all tied to the same SHA.

## Current consolidation disposition
### Repository input consolidation
**READY FOR ORCHESTRATOR REVIEW.**

The accepted producer inputs are now deterministic and can be assembled without using movable worker heads or stale full-file content replacement.

### Final Pack-A runtime candidate
**NOT READY FOR FULL PACK-A RUNTIME ACCEPTANCE.**

Primary blocker:
- GAME-CONTENT-014 has not yet been implemented/accepted, so ordinary Pack-A city-event completion cannot yet be certified as minute-scale/non-year-advancing after onboarding.

Pending source branches that must not be silently absorbed:
- GAME-CONTENT-013 — currently no task-specific delta at observed tip, but may move;
- UI-CONTENT-008 — already moving at observed `df2ba2a29eb34cd9696c22f43ccd11341d409a29`, not accepted.

## Validation actually performed in QA-CONTENT-015
Repository/static inspection only:
- read latest TASK_BOARD, FILE_OWNERSHIP and WEB_AGENT_LAUNCHPAD;
- read this branch's current qa-build report before writing;
- confirmed 00 accepted GAME-CONTENT-012 / NPC-CONTENT-012 / UI-FIX-007 / DIRECTOR-CONTENT-002 exact identities;
- compared GAME-CONTENT-012 to the CONTENT-WAVE baseline and confirmed only authorized task paths changed;
- read accepted Gameplay worker report and captured final production/verifier blob identities;
- read accepted NPC Pack-A worker report and content commit; confirmed accepted integration unit is the append delta, not the stale whole `events.json` blob;
- read accepted UI-FIX-007 report and captured final source/verifier identities;
- read accepted Director first-30-minute report and carried forward the ordinary-event annual-advance blocker;
- inspected GAME-CONTENT-013 and UI-CONTENT-008 current branch movement and excluded both from accepted inputs.

Not performed:
- JSON parser execution;
- Godot import/start;
- any `.gd` verifier execution;
- rendered viewport validation;
- Web export;
- browser console/network/runtime validation;
- screenshots;
- audio playback;
- any production integration commit.

## Files changed by QA-CONTENT-015
- `agent-reports/qa-build.md` only.

## Handoff to 00-Orchestrator
1. Review this report-only consolidation manifest.
2. Assemble accepted GAME-CONTENT-012 + UI-FIX-007 + semantic NPC-CONTENT-012 append delta onto the cumulative accepted integration baseline; do not take stale control-plane/worker snapshots wholesale.
3. Keep currently unaccepted GAME-CONTENT-013 and UI-CONTENT-008 outside the candidate unless separately reviewed; if accepted before freeze, regenerate this manifest/freeze.
4. Do not call Pack A runtime-ready until GAME-CONTENT-014 provides and validates the non-year-advancing ordinary-city-event path.
5. Once the chosen source set is final, create one immutable integration SHA and hand that exact SHA to QA-002/Codex/local for the ordered package above.

QA-CONTENT-015 requests **NEEDS_REVIEW**.