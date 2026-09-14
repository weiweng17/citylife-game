# QA/Build Agent Report

## Task
- ID: QA-CONTENT-014
- Agent: qa-build
- Branch/worktree: `agent/qa-content-014-content-pack-acceptance`
- Status: NEEDS_REVIEW

## Scope
CONTENT-WAVE-01 Pack A acceptance/integration gate.

Web-agent writable scope is **only** `agent-reports/qa-build.md`. No production source/data/UI/verifier/workflow/coordination file or `main` change is authorized here. Real parser/Godot/render/Web/browser evidence remains QA-002/Codex work on one exact frozen candidate SHA.

## Coordination snapshot
Latest coordination tip inspected:
- `orchestrator/multi-agent-bootstrap`
- exact SHA `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- QA-CONTENT-014 remains `READY` in TASK_BOARD; writable only this report.

Critical baseline rule: the coordination branch is a control-plane branch and does **not** necessarily contain the latest accepted production semantics. Pack A must not use the coordination copy of `data/events.json` or `scripts/Game.gd` as the semantic baseline when later accepted worker work is newer.

Relevant accepted production anchors already present in the repository:
- Gameplay terminal/death baseline: `agent/game-fix-009-terminal-mutation-order` exact tip `8ff9a36e4f61f41aea943ea11ec6254ed7155b4d`; accepted `scripts/Game.gd` blob `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`.
- Content baseline through NPC-CONTENT-010: `agent/npc-content-010-generic-family-callers` exact tip `923e43541303a4f66a643bddef3a993a1ed234b5`; production data change is in source parent `46264de61d72c6b8a51bbe54003f665c36226f4a` and the branch tip carries the completion report.

For Pack A event-delta validation, use the accepted NPC-CONTENT-010 data state (or a later 00-recorded superseding accepted content baseline), **not** `d415ecf...:data/events.json`.

## Current moving producer snapshot
These SHAs are observations, not accepted inputs. Re-read exact tips immediately before any review/freeze.

### GAME-CONTENT-012
- Branch: `agent/game-content-012-daily-economy-hooks`
- exact tip inspected: `70e7ee41183173f7abe7b332fc6137fa073ead39`
- vs coordination `d415ecf...`: ahead 5 / behind 0
- changed production paths currently visible:
  - `scripts/Game.gd`
  - `scripts/systems/OfficeActivities.gd`
  - `scripts/systems/CafeActivities.gd`
- worker report is still the inherited old template at this inspected tree; no `tools/verify_livelihood_actions.gd` yet.
- current `scripts/Game.gd` blob is exactly `85d1ce4e238fac35279c11c5f86f1a24e8f4e3cc`, matching accepted GAME-FIX-009. The apparent large `Game.gd` diff against coordination is accepted-baseline reconstruction, not yet a new livelihood settlement implementation.

Current exact-tip disposition: **IN FLIGHT / DO NOT FREEZE**.

Concrete snapshot gaps:
1. `OfficeActivities.gd` exposes `overtime` after `worked_today` and advertises 2 hours / overtime pay / health −4 / mood −8, but `Game._on_office_activity()` still routes every non-`negotiate` ID to `_do_work_shift()`. At this tip, `overtime` would use the ordinary 4-hour work-shift settlement rather than the advertised overtime settlement.
2. `CafeActivities.gd` exposes `side_gig` with 90 minutes / pay 55 / health −2 / mood −4, but `Game._on_cafe_activity()` still has only `coffee` and `idle` settlement arms. No side-gig settlement exists at this tip.
3. Daily anti-spam enforcement, day rollover behavior, persisted same-day state and the required livelihood verifier are not yet in the inspected tree.

Do not create a separate audit task from these findings. They describe an actively moving worker tip; re-inspect the eventual `NEEDS_REVIEW` tip.

### UI-FIX-007
- Branch: `agent/ui-fix-007-dialog-body-overflow`
- exact tip inspected: `fe2e527616e18868df0900c3b6b8b1f2db9599d4`
- worker report status at that tip: `NEEDS_REVIEW`
- vs coordination `d415ecf...`: ahead 6 / behind 0
- diff is limited to authorized paths:
  - `scripts/ui/DialogUI.gd`
  - `tools/verify_dialog_panel_overflow.gd`
  - `agent-reports/scene-ui.md`

Repository/static contract looks aligned:
- body-only `ScrollContainer` owns dialogue text;
- speaker and `继续` / `结束` remain outside the scroll owner;
- horizontal scrolling is disabled;
- body scroll resets on next line and reopen/close paths;
- public `show_dialog()`, `close_dialog()`, `is_busy()` and `dialog_finished` lifecycle is preserved;
- verifier covers ordinary/long copy, 1280×720 and 960×540, scroll-to-bottom, next-line/reopen reset and exactly-once completion semantics.

This is **not** a Godot/render PASS. 00 still must review/accept the exact tip; QA-002 must execute it on the final frozen candidate.

### NPC-CONTENT-012
- Branch: `agent/npc-content-012-city-event-pack-a`
- exact tip inspected: `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- identical to coordination; no Pack A source/report delta yet.

Disposition: **WAITING FOR SOURCE**. No event-count/flag/NPC-reference/deferred-policy PASS is claimed yet.

## Event-system schema contract
Current `scripts/systems/EventSystem.gd` supports these condition keys:
- `money_min`, `money_max`
- `health_min`, `health_max`
- `mood_min`, `mood_max`
- `skill_min`
- `network_min`
- `age_min`
- `job`
- `flags`, `flags_not`
- `origins`

Event-level `age: [min,max]`, `scene` and `weight` are also supported by matching/picking.

Supported numeric `effects` keys:
- `money`
- `health`
- `mood`
- `skill`
- `network`

Existing supported non-`effects` option outcomes are `flags` dictionary and `job` string/null. Any new condition/effect key is a gate failure unless a separate Gameplay task adds and validates support first.

## Repository gate — NPC-CONTENT-012 / City Event Pack A
Run only against an orchestrator-accepted exact Pack A tip and compare against the accepted pre-Pack-A content baseline.

Required:
- producer production diff is `data/events.json` only; report may change `agent-reports/npc-content.md`;
- exactly 20 new events;
- exactly 4 each at `park`, `cafe`, `hospital`, `alley`, `rooftop`;
- globally unique non-empty event IDs;
- every Pack A event has 2–3 non-empty usable choices/results;
- every event has a real downside/cost and meaningful tradeoff;
- no unsupported condition/effect keys;
- at least 5 remembered-choice chains: a Pack A option writes a flag and a later Pack A event/option reads and narratively acknowledges it;
- at least 6 Pack A events naturally reference existing NPCs;
- ordinary city life remains primary; dark/supernatural material remains optional/secondary;
- deferred-policy events remain exactly unchanged from the accepted pre-Pack-A content baseline:
  - `e_parent_gone`
  - `e_roommate`
  - `e_kid_school`
  - `e_second_child`
  - `e_downsize`
  - `e_empty_nest`
- no new text/flags establish Xiaoyu romance/housing canon.

### Prepared deterministic JSON/data checker — NOT RUN
Use the orchestrator-recorded accepted content baseline. At the current planning point the known accepted NPC-CONTENT-010 branch tip is `923e43541303a4f66a643bddef3a993a1ed234b5`.

```powershell
$BASE='923e43541303a4f66a643bddef3a993a1ed234b5'
git rev-parse HEAD
git show "$BASE`:data/events.json" | Set-Content -Encoding utf8 "$env:TEMP\events-pack-a-base.json"
py -m json.tool data/events.json > $null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Then run from the frozen/reviewed candidate worktree:

```powershell
@'
import json, pathlib, collections
base = json.loads(pathlib.Path(r"__BASE__").read_text(encoding="utf-8-sig"))
cur = json.loads(pathlib.Path("data/events.json").read_text(encoding="utf-8-sig"))
assert isinstance(base, list) and isinstance(cur, list)
base_by_id = {str(e.get("id", "")): e for e in base}
cur_by_id = {str(e.get("id", "")): e for e in cur}
ids = [str(e.get("id", "")) for e in cur]
assert all(ids) and len(ids) == len(set(ids)), "event IDs must be non-empty and globally unique"
new = [e for e in cur if str(e.get("id", "")) not in base_by_id]
assert len(new) == 20, f"expected 20 new Pack A events, got {len(new)}"
counts = collections.Counter(str(e.get("scene", "")) for e in new)
expected = {"park":4,"cafe":4,"hospital":4,"alley":4,"rooftop":4}
assert dict(counts) == expected, f"scene counts mismatch: {dict(counts)}"
allowed_cond = {"money_min","money_max","health_min","health_max","mood_min","mood_max","skill_min","network_min","age_min","job","flags","flags_not","origins"}
allowed_effect = {"money","health","mood","skill","network"}

def check_cond(cond, where):
    if cond is None: return
    assert isinstance(cond, dict), f"{where}: cond must be dict/null"
    extra = set(cond) - allowed_cond
    assert not extra, f"{where}: unsupported cond keys {sorted(extra)}"

def conds(e):
    yield e.get("cond")
    for o in e.get("options", []): yield o.get("cond")

for e in new:
    eid = str(e["id"])
    assert str(e.get("title", "")).strip() and str(e.get("text", "")).strip(), f"{eid}: missing title/text"
    check_cond(e.get("cond"), eid)
    opts = e.get("options", [])
    assert isinstance(opts, list) and 2 <= len(opts) <= 3, f"{eid}: expected 2-3 options"
    has_numeric_cost = False
    axes = set()
    for i, o in enumerate(opts):
        assert str(o.get("text", "")).strip() and str(o.get("result", "")).strip(), f"{eid}[{i}]: missing text/result"
        check_cond(o.get("cond"), f"{eid}[{i}]")
        effects = o.get("effects") or {}
        assert isinstance(effects, dict), f"{eid}[{i}]: effects must be dict/null"
        extra = set(effects) - allowed_effect
        assert not extra, f"{eid}[{i}]: unsupported effects {sorted(extra)}"
        for k, v in effects.items():
            axes.add(k)
            if isinstance(v, (int,float)) and v < 0: has_numeric_cost = True
        flags = o.get("flags")
        assert flags is None or isinstance(flags, dict), f"{eid}[{i}]: flags must be dict/null"
        if isinstance(flags, dict) and flags: axes.add("flags")
        job = o.get("job")
        assert job is None or isinstance(job, str), f"{eid}[{i}]: job must be string/null"
    assert has_numeric_cost, f"{eid}: no machine-traceable downside/cost"
    assert len(axes) >= 2, f"{eid}: consequences do not span two supported dimensions"

writers = {}
for i,e in enumerate(new):
    for o in e.get("options", []):
        for flag in (o.get("flags") or {}): writers.setdefault(str(flag), []).append((i,str(e["id"])))
readers = {}
for i,e in enumerate(new):
    for c in conds(e):
        if not isinstance(c, dict): continue
        for key in ("flags","flags_not"):
            for flag in c.get(key, []) or []: readers.setdefault(str(flag), []).append((i,str(e["id"])))
pairs=[]
for flag, ws in writers.items():
    for wi,wid in ws:
        later=[(ri,rid) for ri,rid in readers.get(flag,[]) if ri > wi and rid != wid]
        if later:
            pairs.append((flag,wid,later[0][1])); break
assert len({p[0] for p in pairs}) >= 5, f"need >=5 remembered flag chains, got {pairs}"

for eid in ["e_parent_gone","e_roommate","e_kid_school","e_second_child","e_downsize","e_empty_nest"]:
    assert eid in base_by_id and eid in cur_by_id, f"missing deferred event {eid}"
    assert cur_by_id[eid] == base_by_id[eid], f"deferred-policy event changed: {eid}"

print("PACK_A_STATIC_OK")
print("NEW_IDS", [e["id"] for e in new])
print("SCENE_COUNTS", dict(counts))
print("REMEMBERED_FLAG_PAIRS", pairs)
'@.Replace('__BASE__', "$env:TEMP\events-pack-a-base.json") | py -
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Required later success evidence: exit 0, literal `PACK_A_STATIC_OK`, exact 20 IDs, 4/4/4/4/4 counts and >=5 remembered flag chains.

Machine checks do not prove writing quality. QA/reviewer must also record a manual trace table:
- remembered flag -> writer event/choice -> later reader event -> acknowledgement copy;
- at least 6 event IDs -> existing NPC referenced -> where/how it appears;
- any Xiaoyu reference -> explicit confirmation it stays relationship-neutral and does not define romance/housing canon.

## Repository gate — GAME-CONTENT-012 / livelihood actions
Expected authorized surface:
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- narrow livelihood handlers/context in `scripts/Game.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

Required final semantics:
- overtime appears only after ordinary work that day;
- overtime once/day, repeatable after day rollover;
- about 120 minutes, meaningful extra pay, recommended health −4 / mood −8 and roughly 50–70% of ordinary-shift wage unless narrowly justified;
- cafe gig once/day, 90–120 minutes, about 45–60 money, health −2/−3, mood −3/−4;
- cafe gig pays less than ordinary work;
- both labels/tooltips state time/reward/major cost;
- no opaque random success;
- second same-day attempt cannot settle time/money/stats again;
- save/load same day preserves the consumed state;
- day rollover re-enables the action;
- no new save schema or livelihood-specific top-level payload; reuse already-saved generic state;
- GAME-FIX-001..009 terminal/death ordering remains authoritative and no second terminal authority is added.

At the final worker tip `tools/verify_livelihood_actions.gd` must exist and be inspected. Prefer explicit failure aggregation + `quit(1)` on failure rather than assert-only behavior whose process exit semantics have not been separately proven.

Current `70e7ee...` fails this gate only because it is an in-flight snapshot; do not freeze it.

## Repository gate — UI-FIX-007
If 00 accepts exact tip `fe2e527616e18868df0900c3b6b8b1f2db9599d4`, carry exactly the reviewed DialogUI/verifier semantics into the candidate.

Prepared command — **NOT RUN**:

```powershell
& $godotExe --headless --path . --script res://tools/verify_dialog_panel_overflow.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Headless success is not rendered acceptance. Final frozen-SHA render checks must cover 1280×720 and 960×540 normal/long text, body-only scrolling, no horizontal dependency, fixed/reachable speaker/action controls, next-line/reopen top reset, and exactly-once completion behavior.

## One-frozen-SHA / stale-evidence rule
Before execution:

```powershell
git rev-parse HEAD
git status --short
& $godotExe --version
```

Record exact candidate SHA, clean worktree and Godot 4.7.2. Stop/invalidate affected evidence if any accepted producer SHA, candidate SHA, Pack A data, livelihood implementation/verifier, DialogUI/verifier, shared save/time/event logic, or export-relevant source changes after capture.

Never combine PASS evidence from different SHAs.

## QA-002 runtime package — prepared, NOT RUN
Execute only after 00 has accepted final worker tips and formed one integration SHA.

### Headless/static minimum
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
```

Run the JSON/data checker above on the same SHA. Capture command, exit code, stdout/stderr and exact SHA for every run.

### Normal-play Pack A slice
On the same frozen SHA:
- trigger and complete at least one **new Pack A** event at park, cafe, hospital, alley and rooftop;
- record actual event ID/title, choice and resulting state change for each;
- if reachable in the slice, prove one remembered-choice writer -> later acknowledgement path;
- confirm ordinary event completion does not unexpectedly advance age/year;
- confirm long event/dialogue copy remains readable.

### Livelihood slice
Office:
1. overtime unavailable before ordinary work;
2. complete ordinary work;
3. overtime becomes visible;
4. execute once and record money/time/health/mood before/after;
5. same-day retry is blocked/no second settlement;
6. save/load same day remains blocked;
7. next day, after ordinary work, overtime is available again.

Cafe:
1. execute side gig once and record money/time/health/mood before/after;
2. same-day retry blocked/no second settlement;
3. save/load same day remains blocked;
4. next day available again;
5. pay is lower than the ordinary work shift under the same character state.

### Save/load during new slice
Save after at least one Pack A remembered flag and one used livelihood action. Reload and prove:
- player/time/content state remains consistent;
- remembered flag persists;
- event-used state behaves as designed;
- same-day livelihood anti-spam persists;
- no migration/schema error appears.

### Rendered UI
Same frozen SHA at 1280×720 and 960×540:
- short + long dialogue;
- body scroll only;
- speaker/action visible and reachable;
- next-line and reopen reset to top;
- no clipping/overlap/horizontal-scroll dependency.

### Web/browser
Same frozen SHA:
- export configured Web build with Godot 4.7.2-compatible tooling;
- record command/exit/stdout/stderr/artifact identity;
- serve/open in a real browser;
- inspect console/network/runtime/resource failures;
- exercise start/origin/load, one Pack A event, both livelihood actions, save/load and long-dialog path.

No Web/browser PASS without actual browser execution on the recorded SHA.

### Later-pack extension — not a current Pack A blocker
Only after NPC-CONTENT-013 relationship episodes and NPC-CONTENT-014 q4–q8 are separately implemented/reviewed/accepted:
- trigger at least one relationship-stage episode;
- progress at least two q4–q8 steps.

Those later packs require a then-current frozen SHA; old Pack A evidence does not cover them. Do not hold the initial Event Pack A repository review waiting for content that the task board schedules later.

## Validation performed in this web phase
Repository/GitHub inspection only:
- read latest TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, MASTER_PLAN, AGENT_RULES, HANDOFF, orchestrator report and this QA report;
- captured current coordination and producer branch tips;
- compared moved producer branches against coordination;
- verified current Gameplay `Game.gd` blob matches accepted GAME-FIX-009 blob;
- inspected current livelihood interaction surfaces and handlers;
- inspected EventSystem supported keys;
- inspected UI-FIX-007 implementation/verifier/report;
- confirmed NPC-CONTENT-012 had no source delta at the final pre-write snapshot;
- reconciled a concurrent QA report write rather than overwriting it with a stale blob.

## Explicitly NOT performed
- JSON parser/Python acceptance execution;
- Godot/headless/verifier execution;
- rendered viewport validation;
- Web export;
- browser console/network/runtime validation;
- screenshots/deployment;
- merge/cherry-pick/rebase/integration;
- runtime/build/parser/render/Web PASS claim.

## Current gate disposition
**Gate specification: READY FOR ORCHESTRATOR REVIEW.**

**Candidate acceptance: NOT READY TO FREEZE.**

Reasons:
1. NPC-CONTENT-012 has no worker delta yet.
2. GAME-CONTENT-012 is still an in-flight tree with visible labels ahead of settlement/anti-spam/verifier completion.
3. UI-FIX-007 has a `NEEDS_REVIEW` worker report at `fe2e527...`, but 00 has not yet accepted that exact tip in TASK_BOARD.
4. No real parser/Godot/render/Web/browser evidence exists for this wave yet.

## Files changed by QA-CONTENT-014
- `agent-reports/qa-build.md` only.

## Known risks / stop conditions
- Producer branches are actively moving; branch-name evidence becomes stale immediately after movement.
- Coordination source snapshots can lag accepted semantic baselines; using them as production baselines can create false regressions or silently drop accepted edits.
- Static JSON/source quality is not runtime reachability/readability.
- Any accepted source change after QA-002 evidence begins invalidates affected evidence and requires a new frozen SHA.

## Handoff to 00-Orchestrator
1. Review this report-only QA-CONTENT-014 diff.
2. Independently review UI-FIX-007 exact tip `fe2e527616e18868df0900c3b6b8b1f2db9599d4`.
3. Wait for GAME-CONTENT-012 and NPC-CONTENT-012 final `NEEDS_REVIEW` tips; do not freeze their current in-flight snapshots.
4. Re-run the repository gate against those exact accepted tips using the accepted semantic baselines above.
5. Compose one semantic integration SHA from accepted inputs.
6. Hand that exact SHA to QA-002/Codex/local for parser + Godot + rendered + Web/browser evidence.

No additional speculative QA/audit task is requested.
