# QA/Build Agent Report

## Task
- ID: QA-CONTENT-014
- Agent: qa-build
- Branch/worktree: `agent/qa-content-014-content-pack-acceptance`
- Status: NEEDS_REVIEW

## Scope
CONTENT-WAVE-01 Pack A repository acceptance / frozen-runtime handoff gate.

Authorized web-agent write scope: **`agent-reports/qa-build.md` only**. This task did not edit production source/data/UI/verifiers/workflows/coordination files or `main`.

Parser/Godot/headless/render/Web/browser checks below are validation packages only unless explicitly marked repository/static inspection. They were **NOT RUN** by this web worker.

## Coordination source of truth
Latest control-plane tip inspected:
- `orchestrator/multi-agent-bootstrap`
- exact SHA: `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- TASK_BOARD still records QA-CONTENT-014, GAME-CONTENT-012, UI-FIX-007 and NPC-CONTENT-012 as `READY` at this control-plane snapshot.

The coordination branch is metadata/control-plane state, **not** the cumulative accepted production-source baseline. Final integration must preserve accepted semantic work newer than the control-plane source snapshots.

Accepted anchors relevant to this gate:
- GAME-FIX-009 exact tip: `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`
  - accepted `scripts/Game.gd` blob: `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`
- NPC-CONTENT-010 exact branch tip: `923e43541303a4f66a643bddef3a993a1ed234b5`
  - source/content commit: `46264de61d72c6b8a51bbe54003f665c36226f4a`

**Baseline rule:** Pack A event integration must use the accepted pre-Pack-A content state through NPC-CONTENT-010 (or a later 00-recorded superseding content baseline). Do not use `d415ecf...:data/events.json` as the semantic pre-Pack-A baseline.

## Producer tips now requesting review
All three active producer branches moved while QA-CONTENT-014 was being prepared. Final observed worker states for this report are:

| Task | Exact tip | Worker report | Repository disposition |
| --- | --- | --- | --- |
| GAME-CONTENT-012 | `14ca63ac569680008f9f4b20cb01514672d75caa` | `NEEDS_REVIEW` | Repository implementation/verifier formed; real Godot execution pending. |
| UI-FIX-007 | `fe2e527616e18868df0900c3b6b8b1f2db9599d4` | `NEEDS_REVIEW` | Scope-clean repository implementation/verifier; rendered/runtime evidence pending. |
| NPC-CONTENT-012 | `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2` | `NEEDS_REVIEW` | 20-event append delta is repository-reviewable; full `events.json` snapshot is based on stale control-plane data and must be semantically composed onto accepted content baseline. |

These are still worker tips, not orchestrator-accepted inputs. Re-read exact branch heads immediately before 00 review/freeze.

---

## GAME-CONTENT-012 repository review
Observed exact tip: `14ca63ac569680008f9f4b20cb01514672d75caa`.

Compared with coordination `d415ecf...`, the branch is ahead and changes only task-authorized paths:
- `scripts/Game.gd`
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

### Repository-visible contract
The final worker report and source inspection now show the previously in-flight gaps are closed:

**Office overtime**
- normal interaction id `overtime`;
- hidden until ordinary work is completed that day;
- once per day using `GameState.flags` day marker `cw01_overtime_day`;
- 120 minutes;
- health −4;
- mood −8;
- pay = 60% of current ordinary work-shift wage;
- no additional work-shift quest count / skill-growth reward;
- visible interaction copy states time/pay/major costs/daily limit.

**Cafe temporary side gig**
- normal interaction id `side_gig`;
- once per day using `GameState.flags` day marker `cw01_cafe_gig_day`;
- 90 minutes;
- +55 money;
- health −2;
- mood −4;
- 55 is below the existing minimum ordinary work-shift pay of 90;
- visible interaction copy states time/pay/major costs/daily limit.

**Persistence / schema**
- no new `GameState` field;
- no new `SaveManager` schema;
- no new top-level livelihood save section;
- existing `game_state.flags` persistence carries the day markers;
- marker compares with `time_sys.day`, so next day naturally reopens without a new reset schema.

**Terminal ordering**
New livelihood settlement uses:
1. elapsed-minute advance;
2. `_sync_needs_to_time()`;
3. existing `_evaluate_terminal_state()`;
4. normal completion feedback only if still alive.

This is aligned with accepted GAME-FIX-009 ordering and does not introduce a second terminal/death authority.

### Prepared verifier
`tools/verify_livelihood_actions.gd` now covers repository/source invariants plus intended runtime checks for:
- terminal evaluator ordering;
- visible time/reward/cost copy;
- overtime hidden pre-work / visible post-work;
- Office/Cafe navigation reachability;
- overtime 60% pay / 120 minutes / −4 health / −8 mood;
- same-day duplicate prevention;
- existing save-payload persistence;
- cafe +55 / 90 minutes / −2 health / −4 mood;
- cafe pay lower than ordinary shift;
- next-day reopening.

The worker hardened the verifier to wait for interaction layers and deep-copy the in-memory save payload before restore checks.

**Important QA boundary:** this verifier is still `assert()` driven and has not been executed here. Real QA-002 must capture both process exit code and stdout/stderr on Godot 4.7.2; do not infer mandatory-gate failure propagation from source inspection alone.

### Gameplay repository disposition
**Repository contract: READY FOR 00 REVIEW.**

**Runtime acceptance: PENDING QA-002.**

No Godot PASS is claimed.

---

## UI-FIX-007 repository review
Observed exact tip: `fe2e527616e18868df0900c3b6b8b1f2db9599d4`.

Scope is limited to authorized paths:
- `scripts/ui/DialogUI.gd`
- `tools/verify_dialog_panel_overflow.gd`
- `agent-reports/scene-ui.md`

Repository/static contract:
- only body text belongs to the vertical `ScrollContainer`;
- speaker and `继续` / `结束` remain siblings outside the scroll region;
- horizontal scrolling disabled;
- body scroll reset on next line and close/reopen;
- fixed 220px panel contract preserved;
- `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression and `dialog_finished` lifecycle preserved;
- prepared verifier covers 1280×720 and 960×540, real long-text overflow, scroll-to-bottom, reset and exactly-once completion semantics.

### UI repository disposition
**Repository contract: READY FOR 00 REVIEW.**

**Godot/rendered acceptance: PENDING QA-002.**

Headless success, scrollbar behavior, typography and clipping are not claimed from source inspection.

---

## NPC-CONTENT-012 repository review
Observed final worker tip: `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`.

Content commit: `fe1625c7a302ac6fc0c902f55145772fa5521580`.

Final branch diff vs its assigned control-plane base is task-scope clean:
- `data/events.json`: +720 / -0
- `agent-reports/npc-content.md`
- no script/schema/quest/schedule/coordination production change.

Final `data/events.json` blob on the worker branch: `3a62219ad9901a44cc5993159c2c32d15c7f0cad`.

### Exact Pack A event IDs
Static diff inspection identifies exactly 20 appended `e_cw01_*` event objects:

**park (4)**
1. `e_cw01_park_free_class`
2. `e_cw01_park_lost_wallet`
3. `e_cw01_park_rain_aunties`
4. `e_cw01_park_recruiter_call`

**cafe (4)**
1. `e_cw01_cafe_charger`
2. `e_cw01_cafe_interview_prep`
3. `e_cw01_cafe_unpaid_trial`
4. `e_cw01_cafe_gossip`

**hospital (4)**
1. `e_cw01_hospital_kiosk`
2. `e_cw01_hospital_report`
3. `e_cw01_hospital_late_queue`
4. `e_cw01_hospital_medicine`

**alley (4)**
1. `e_cw01_alley_rider_shelter`
2. `e_cw01_alley_secondhand`
3. `e_cw01_alley_rain_stall`
4. `e_cw01_alley_landlord_repair`

**rooftop (4)**
1. `e_cw01_rooftop_bedding`
2. `e_cw01_rooftop_bad_review`
3. `e_cw01_rooftop_fireworks`
4. `e_cw01_rooftop_afterhours`

Static source/report review shows every new event has three choices. The new data uses existing supported numeric effects (`money`, `health`, `mood`, `skill`, `network`) and existing `flags` conditions/mutations; no new schema key was observed.

### Five traceable remembered-choice chains
Repository text directly exposes five writer -> reader continuity pairs:

1. `e_cw01_park_free_class`
   - writes `cw01_joined_park_class`
   - later `e_cw01_park_rain_aunties` requires the flag and says the exercise-class auntie recognizes the player.
2. `e_cw01_cafe_charger`
   - writes `cw01_lent_cafe_charger`
   - later `e_cw01_cafe_unpaid_trial` requires the flag and identifies the same young person from the charger interaction.
3. `e_cw01_hospital_kiosk`
   - writes `cw01_helped_hospital_kiosk`
   - later `e_cw01_hospital_late_queue` requires the flag and refers back to the person encountered while helping 陈姐 at the kiosk.
4. `e_cw01_alley_rider_shelter`
   - writes `cw01_shared_rider_shelter`
   - later `e_cw01_alley_rain_stall` requires the flag and recognizes the rider who shared the shelter.
5. `e_cw01_rooftop_bedding`
   - writes `cw01_helped_rooftop_bedding`
   - later `e_cw01_rooftop_fireworks` requires the flag and brings back the neighbor whose bedding was saved.

This satisfies the repository-traceability shape for >=5 remembered choices. Runtime reachability still requires QA-002.

### Existing NPC references
More than six Pack A events naturally mention existing NPCs. Repository-visible examples include:
- 老周: `park_free_class`, `park_lost_wallet`, `park_recruiter_call`
- 小雨: `cafe_charger`, `alley_secondhand`
- 陈姐: `hospital_kiosk`, `hospital_medicine`
- 阿哲: `alley_rider_shelter`
- 老张: `cafe_interview_prep`, `hospital_report`, `rooftop_afterhours`

The 小雨 references inspected are relationship-neutral and do not establish romance/cohabitation/housing canon.

### Critical integration-baseline finding
The Pack A content commit is **append-only against control-plane `d415ecf...`**, and its parent is that stale control-plane source snapshot. This is important because accepted NPC-CONTENT-010 changed existing earlier event copy after the underlying source lineage represented in that control-plane snapshot.

Therefore:
- the **20-event append delta itself is reviewable**;
- the worker branch's **whole `data/events.json` snapshot must not be used as a replacement for the accepted cumulative content state**;
- blindly taking the worker file would risk dropping accepted NPC-CONTENT-010 generic-family copy changes.

Required integration behavior:
1. start from the orchestrator-accepted pre-Pack-A content baseline through NPC-CONTENT-010;
2. semantically append only these 20 new `e_cw01_*` objects;
3. preserve every pre-existing accepted event object exactly;
4. then freeze and run the deterministic parser/data gate.

This also means the deterministic acceptance checker should assert **all baseline event objects remain equal**, not only the six deferred-policy IDs.

### NPC repository disposition
**20-event Pack A delta: READY FOR 00 REVIEW.**

**Whole worker `events.json` snapshot: NOT SAFE AS A CUMULATIVE INTEGRATION REPLACEMENT.**

**Parser/runtime acceptance: PENDING frozen semantic integration + QA-002.**

The reported `e_cw01_alley_landlord_repair` rented-space premise remains a content/playtest risk; it does not itself mutate housing/Xiaoyu policy state.

---

## Supported EventSystem key contract
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

Supported numeric option effects:
- `money`
- `health`
- `mood`
- `skill`
- `network`

Supported additional mutation fields:
- `flags` dictionary
- `job`

New unsupported keys are a stop condition.

---

## Deterministic Pack A data gate — prepared, NOT RUN
Run this only on the **semantically integrated frozen candidate**, with `$BASE` set to the exact accepted pre-Pack-A content baseline.

```powershell
$BASE='923e43541303a4f66a643bddef3a993a1ed234b5'
git rev-parse HEAD
git status --short
py -m json.tool data/events.json > $null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
git show "$BASE`:data/events.json" | Set-Content -Encoding utf8 "$env:TEMP\events-pack-a-base.json"
```

Then:

```powershell
@'
import json, pathlib, collections
base = json.loads(pathlib.Path(r"__BASE__").read_text(encoding="utf-8-sig"))
cur = json.loads(pathlib.Path("data/events.json").read_text(encoding="utf-8-sig"))
assert isinstance(base, list) and isinstance(cur, list)
b = {str(e.get("id", "")): e for e in base}
c = {str(e.get("id", "")): e for e in cur}
ids = [str(e.get("id", "")) for e in cur]
assert all(ids) and len(ids) == len(set(ids)), "IDs must be non-empty and globally unique"

# NPC-CONTENT-012 is append-only: every accepted baseline event must survive unchanged.
for eid, obj in b.items():
    assert eid in c, f"baseline event missing: {eid}"
    assert c[eid] == obj, f"accepted baseline event changed: {eid}"

new = [e for e in cur if str(e.get("id", "")) not in b]
assert len(new) == 20, f"expected 20 new events, got {len(new)}"
counts = collections.Counter(str(e.get("scene", "")) for e in new)
assert dict(counts) == {"park":4,"cafe":4,"hospital":4,"alley":4,"rooftop":4}, counts

allowed_cond = {"money_min","money_max","health_min","health_max","mood_min","mood_max","skill_min","network_min","age_min","job","flags","flags_not","origins"}
allowed_effect = {"money","health","mood","skill","network"}

def check_cond(cond, where):
    if cond is None: return
    assert isinstance(cond, dict), f"{where}: cond must be dict/null"
    assert not (set(cond)-allowed_cond), f"{where}: unsupported cond keys {set(cond)-allowed_cond}"

def conds(e):
    yield e.get("cond")
    for o in e.get("options", []): yield o.get("cond")

for e in new:
    eid = str(e["id"])
    assert str(e.get("title", "")).strip() and str(e.get("text", "")).strip(), eid
    check_cond(e.get("cond"), eid)
    opts = e.get("options", [])
    assert 2 <= len(opts) <= 3, f"{eid}: option count"
    axes=set(); has_cost=False
    for i,o in enumerate(opts):
        assert str(o.get("text", "")).strip() and str(o.get("result", "")).strip(), f"{eid}[{i}]"
        check_cond(o.get("cond"), f"{eid}[{i}]")
        effects=o.get("effects") or {}
        assert isinstance(effects, dict)
        assert not (set(effects)-allowed_effect), f"{eid}[{i}]: unsupported effects"
        for k,v in effects.items():
            axes.add(k)
            if isinstance(v,(int,float)) and v < 0: has_cost=True
        flags=o.get("flags")
        assert flags is None or isinstance(flags,dict)
        if flags: axes.add("flags")
        assert o.get("job") is None or isinstance(o.get("job"),str)
    assert has_cost, f"{eid}: no machine-traceable downside"
    assert len(axes) >= 2, f"{eid}: <2 consequence axes"

writers={}; readers={}
for i,e in enumerate(new):
    for o in e.get("options",[]):
        for f in (o.get("flags") or {}): writers.setdefault(str(f),[]).append((i,str(e["id"])))
    for cond in conds(e):
        if isinstance(cond,dict):
            for key in ("flags","flags_not"):
                for f in cond.get(key,[]) or []: readers.setdefault(str(f),[]).append((i,str(e["id"])))
pairs=[]
for flag,ws in writers.items():
    for wi,wid in ws:
        later=[(ri,rid) for ri,rid in readers.get(flag,[]) if ri>wi and rid!=wid]
        if later: pairs.append((flag,wid,later[0][1])); break
assert len({x[0] for x in pairs}) >= 5, pairs

print("PACK_A_STATIC_OK")
print("NEW_IDS", [e["id"] for e in new])
print("SCENE_COUNTS", dict(counts))
print("REMEMBERED_FLAG_PAIRS", pairs)
'@.Replace('__BASE__', "$env:TEMP\events-pack-a-base.json") | py -
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Required later evidence: exit 0 + literal `PACK_A_STATIC_OK`, exact 20 IDs, 4/4/4/4/4 counts, >=5 remembered pairs, and no baseline-object mutation failure.

Manual QA must still confirm NPC references are natural and narrative acknowledgements read coherently; a machine checker cannot prove writing quality.

---

## Frozen QA-002 package — prepared, NOT RUN
Only after 00 records accepted exact producer tips and creates **one semantic integration SHA**.

### Identity
```powershell
git rev-parse HEAD
git status --short
& $godotExe --version
```
Expected: recorded exact SHA, clean worktree, Godot 4.7.2.

### Minimum headless set
```powershell
& $godotExe --headless --path . --editor --quit
& $godotExe --headless --path . --script res://tools/verify_livelihood_actions.gd
& $godotExe --headless --path . --script res://tools/verify_dialog_panel_overflow.gd
& $godotExe --headless --path . --script res://tools/verify_locations.gd
& $godotExe --headless --path . --script res://tools/verify_navigation.gd
& $godotExe --headless --path . --script res://tools/verify_day_cycle.gd
& $godotExe --headless --path . --script res://tools/verify_day_flow.gd
& $godotExe --headless --path . --script res://tools/verify_npc.gd
& $godotExe --headless --path . --script res://tools/verify_quests.gd
& $godotExe --headless --path . --script res://tools/verify_terminal_mutation_order.gd
```

Capture command, exact SHA, exit code, stdout and stderr separately. Any parser/script/assert/runtime failure stops promotion.

### Pack A normal-play slice
On the same frozen SHA:
- trigger one **new** Pack A event at each of park/cafe/hospital/alley/rooftop;
- record exact event ID/title, choice and state/flag result;
- prove at least one remembered-choice writer -> later acknowledgement path if reachable in the run;
- verify ordinary event completion does not unexpectedly advance age/year;
- verify long event/dialogue copy remains readable.

### Livelihood slice
**Office**
1. overtime hidden before ordinary work;
2. complete ordinary work;
3. overtime appears;
4. complete overtime and record before/after money/time/health/mood;
5. same-day retry does not settle again;
6. save/load same day remains consumed;
7. next day, after ordinary work, overtime is available again.

**Cafe**
1. side gig reachable through normal cafe interaction;
2. complete once and record before/after money/time/health/mood;
3. same-day retry blocked/no second settlement;
4. save/load same day remains consumed;
5. next day available again;
6. pay remains lower than ordinary work.

### Save/load during new content
Save after at least one remembered Pack A flag and one consumed livelihood action. Reload and verify:
- remembered flag persists;
- later acknowledgement remains eligible when its other conditions are met;
- same-day livelihood anti-spam persists;
- event-used/player/time/location state remains compatible;
- no save migration/schema error.

### Rendered dialogue acceptance
Same frozen SHA at 1280×720 and 960×540:
- normal + deliberately long dialogue;
- body-only vertical scrolling;
- speaker and continue/end control remain fixed/reachable;
- no horizontal-scroll dependency;
- next-line and reopen visibly reset to top;
- no clipping/overlap.

### Web/browser
Same frozen SHA:
- export configured Web build;
- record export command/exit/stdout/stderr/artifact identity;
- serve/open in a real browser;
- inspect fatal console/network/resource/runtime errors;
- exercise start/origin/load, one Pack A event, both livelihood actions, save/load and long-dialog path;
- screenshots/evidence must be tied to the same SHA.

No browser/Web PASS without actual execution.

### Later-pack extension
Only after NPC-CONTENT-013 and NPC-CONTENT-014 are separately implemented/reviewed/accepted:
- trigger one relationship-stage episode;
- progress at least two q4–q8 quest steps.

Do not block initial Pack A repository integration on those later tasks. They will require a new then-current frozen SHA.

---

## One-frozen-SHA / stale-evidence stop rules
- Worker branch names are movable; accepted inputs must be exact 40-character SHAs.
- 00 must record accepted exact tips before semantic integration.
- NPC Pack A must be appended onto the accepted cumulative content baseline, not whole-file copied from the stale worker base.
- Gameplay must preserve accepted GAME-FIX-009 semantics while adding livelihood deltas.
- Any source/data/UI/verifier/config change after freeze creates a new candidate identity.
- Do not combine PASS evidence from different SHAs.
- Stop on JSON/parser failure, non-zero verifier exit, assertion/script error, render mismatch, merge conflict, stale branch evidence, or blocking Web/browser failure.

## Validation performed by QA-CONTENT-014
Repository/GitHub inspection only:
- latest TASK_BOARD / FILE_OWNERSHIP / WEB_AGENT_LAUNCHPAD / MASTER_PLAN / AGENT_RULES / HANDOFF / orchestrator report;
- producer exact tips and reports;
- branch scope comparisons;
- EventSystem condition/effect implementation;
- Gameplay livelihood handlers/context/save/terminal ordering and verifier source;
- UI-FIX-007 implementation/report/verifier source;
- NPC Pack A append diff, exact 20 IDs, 4-per-location distribution, five flag chains and >6 existing-NPC references;
- accepted baseline ancestry hazard for `data/events.json`;
- concurrent QA report writes were reconciled rather than overwritten from stale blobs.

## Explicitly NOT performed
- JSON parser execution;
- Python deterministic checker execution;
- Godot/editor/headless execution;
- any `.gd` verifier execution;
- rendered viewport validation;
- Web export;
- browser console/network/runtime validation;
- screenshot/deployment;
- merge/cherry-pick/rebase/integration;
- runtime/build/parser/render/Web PASS claim.

## Current gate disposition
**QA-CONTENT-014 gate specification: READY FOR ORCHESTRATOR REVIEW.**

**Producer repository deltas:**
- GAME-CONTENT-012 `14ca63ac569680008f9f4b20cb01514672d75caa`: repository contract ready for 00 review; runtime pending.
- UI-FIX-007 `fe2e527616e18868df0900c3b6b8b1f2db9599d4`: repository contract ready for 00 review; render/runtime pending.
- NPC-CONTENT-012 `a86c953d475c6f6eb18d99a02ef87b2d6932e4b2`: Pack A append delta ready for 00 review; whole worker file snapshot must not replace accepted cumulative content baseline.

**Frozen candidate:** NOT YET CREATED / NOT QA-002-ACCEPTED.

## Files changed by QA-CONTENT-014
- `agent-reports/qa-build.md` only.

## Handoff to 00-Orchestrator
1. Review the three current `NEEDS_REVIEW` producer tips above and record accepted exact identities.
2. Build the candidate semantically:
   - Gameplay from accepted GAME-FIX-009 cumulative source + reviewed livelihood deltas;
   - UI from accepted cumulative UI state + reviewed UI-FIX-007 delta;
   - Content from accepted NPC-CONTENT-010 cumulative `events.json` + exactly the 20 Pack A appended events.
3. Run the deterministic baseline-preservation/Pack-A checker on that assembled candidate.
4. Freeze exactly one integration SHA.
5. Hand that SHA to QA-002/Codex/local for parser + Godot + rendered + Web/browser evidence.

No additional speculative QA/audit task is requested.
