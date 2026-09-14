# QA/Build Agent Report

## Task
- ID: QA-CONTENT-014
- Agent: qa-build
- Branch/worktree: `agent/qa-content-014-content-pack-acceptance`
- Status: NEEDS_REVIEW

## Scope
Prepare and maintain the repository/runtime acceptance gate for CONTENT-WAVE-01 Pack A.

Web-agent writable scope for this task is **only** `agent-reports/qa-build.md`. No source, data, UI, verifier, workflow, coordination file, or `main` edit is authorized here. Executable verifier additions require a later explicit 00-Orchestrator grant.

No parser command, Godot launch, verifier execution, Web export, browser run, screenshot capture, or rendered validation was performed or claimed in this web-agent task.

## Coordination source of truth
Read from `orchestrator/multi-agent-bootstrap`:
- coordination tip at inspection: `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- TASK_BOARD: QA-CONTENT-014 is `READY`; GAME-CONTENT-012, UI-FIX-007, NPC-CONTENT-012 are also `READY`.
- wave plan source: `planning/content-expansion-wave-01` / `planning/CONTENT_EXPANSION_WAVE_01.md`.
- QA rule: runtime/render/Web evidence is valid only on one exact frozen QA-002 candidate SHA.

Wave-start repository baseline used by this manifest:
- `d415ecf165fc6c90d5abf42e5929745d1739acf4`
- baseline `data/events.json` blob: `7d2460d089668f27058d91c2ceb48517c56afcf9`
- baseline `scripts/systems/EventSystem.gd` blob: `628e18a0a1cbb0f67e63d0f25486713dd1a451d8`
- baseline `scripts/systems/OfficeActivities.gd` blob: `eb3c593e0f71438bfad79041fdd33f8f4175a097`
- baseline `scripts/systems/CafeActivities.gd` blob: `f7e0037af1f4eef262b98ff6b1db8585787a3bc8`
- baseline `scripts/systems/DailyRoutine.gd` blob: `8ca80180d1b16a0bd0a327d50039ebf7a5677dd0`

## Current source-branch snapshot
This is a snapshot, not an acceptance decision. All three producer tasks remain `READY` in TASK_BOARD, so none of these moving branch tips is an orchestrator-accepted input yet.

| Producer task | Branch | Exact tip observed | Delta vs wave baseline | QA-CONTENT-014 disposition |
| --- | --- | --- | --- | --- |
| GAME-CONTENT-012 | `agent/game-content-012-daily-economy-hooks` | `608e0ede3760bf15a0dd9cb458877d40577d480c` | 2 commits; only `scripts/Game.gd` and `scripts/systems/OfficeActivities.gd` changed | **INCOMPLETE / DO NOT FREEZE**. Cafe side gig, `tools/verify_livelihood_actions.gd`, and gameplay report are not yet in this observed tip. |
| UI-FIX-007 | `agent/ui-fix-007-dialog-body-overflow` | `6e14b0f3da2245f55ef90f6e345cc0f5fb07a1bd` | 3 commits; `scripts/ui/DialogUI.gd` + `tools/verify_dialog_panel_overflow.gd` | Repository shape is reviewable, but task board is still READY and branch report is still stale. **DO NOT FREEZE** until 00 accepts an exact tip. |
| NPC-CONTENT-012 | `agent/npc-content-012-city-event-pack-a` | `d415ecf165fc6c90d5abf42e5929745d1739acf4` | no worker delta | **WAITING**. No 20-event Pack A exists at the observed tip. |

### Current Gameplay partial evidence
At `608e0ede3760bf15a0dd9cb458877d40577d480c`, `OfficeActivities.gd` already exposes an `overtime` spot with:
- visibility only after `worked_today`;
- explicit label/tooltip with 2-hour time cost, pay, health −4, mood −8;
- `overtime_today` display state for one-per-day intent.

This is useful intermediate repository evidence, **not** acceptance. The observed diff does not yet contain the required cafe temporary side gig or the task verifier/report, so QA must not infer that GAME-CONTENT-012 is complete.

### Current UI repository evidence
At `6e14b0f3da2245f55ef90f6e345cc0f5fb07a1bd`:
- `DialogUI.gd` places only the wrapped body inside `ScrollContainer`;
- speaker and `继续` / `结束` remain outside the body scroll;
- body scroll is reset on next line and close/reopen;
- public `show_dialog()`, `close_dialog()`, `is_busy()`, `dialog_finished` semantics remain present.

`tools/verify_dialog_panel_overflow.gd` is explicit 0/1-exit verifier code covering:
- 1280×720 normal dialogue;
- 960×540 long dialogue;
- real body overflow/scroll range;
- speaker/button staying outside the scroll region;
- long -> short reset;
- close/reopen reset;
- exactly-once `dialog_finished` for completed dialogues;
- no emission on programmatic close;
- Game-facing busy semantics.

The verifier has **not** been executed by QA-CONTENT-014. Rendered readability remains QA-002 work.

## Event-system schema contract for Pack A
Repository source `scripts/systems/EventSystem.gd` establishes the supported event semantics. The Pack A data-only branch must stay inside these existing keys.

### Supported event condition keys
- `money_min`, `money_max`
- `health_min`, `health_max`
- `mood_min`, `mood_max`
- `skill_min`
- `network_min`
- `age_min`
- `job`
- `flags`
- `flags_not`
- `origins`

Event-level `age: [min, max]`, `scene`, and `weight` are also already supported by event matching/picking.

### Supported option mutation keys
Numeric `effects` keys:
- `money`
- `health`
- `mood`
- `skill`
- `network`

Other supported option mutation fields:
- `flags` dictionary
- `job`

Any new condition/effect key outside those sets is a Pack A gate failure unless Gameplay first adds and separately validates support under an explicit task.

## Repository acceptance gate — NPC-CONTENT-012 / City Event Pack A
Run against the **orchestrator-accepted exact NPC-CONTENT-012 tip**, never a movable branch name.

### A. Diff/scope
Expected producer writable scope is only:
- `data/events.json`
- `agent-reports/npc-content.md`

Fail if the accepted NPC Pack A implementation changes scripts, schemas, scenes, assets, quests, schedules, or coordination files.

### B. JSON parse and deterministic event-set delta
Later real QA command package, not run here:

```powershell
$BASE='d415ecf165fc6c90d5abf42e5929745d1739acf4'
git rev-parse HEAD
git show "$BASE`:data/events.json" | Set-Content -Encoding utf8 "$env:TEMP\events-wave-base.json"
py -m json.tool data/events.json > $null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Then run this non-persistent checker from the frozen candidate worktree:

```powershell
@'
import json, pathlib, collections, sys

base_path = pathlib.Path(r"__BASE__")
cur_path = pathlib.Path("data/events.json")
base = json.loads(base_path.read_text(encoding="utf-8-sig"))
cur = json.loads(cur_path.read_text(encoding="utf-8-sig"))

assert isinstance(base, list) and isinstance(cur, list)
base_by_id = {str(e.get("id", "")): e for e in base}
cur_ids = [str(e.get("id", "")) for e in cur]
assert all(cur_ids), "every event must have a non-empty id"
assert len(cur_ids) == len(set(cur_ids)), "event IDs must be globally unique"

new = [e for e in cur if str(e.get("id", "")) not in base_by_id]
assert len(new) == 20, f"expected exactly 20 new Pack A events, got {len(new)}"

target_scenes = {"park", "cafe", "hospital", "alley", "rooftop"}
scene_counts = collections.Counter(str(e.get("scene", "")) for e in new)
assert set(scene_counts) == target_scenes, f"Pack A scenes differ: {scene_counts}"
for scene in target_scenes:
    assert scene_counts[scene] == 4, f"{scene}: expected 4, got {scene_counts[scene]}"

allowed_cond = {
    "money_min", "money_max", "health_min", "health_max", "mood_min", "mood_max",
    "skill_min", "network_min", "age_min", "job", "flags", "flags_not", "origins",
}
allowed_effect = {"money", "health", "mood", "skill", "network"}

def check_cond(cond, where):
    if cond is None:
        return
    assert isinstance(cond, dict), f"{where}: cond must be null/dict"
    unknown = set(cond) - allowed_cond
    assert not unknown, f"{where}: unsupported condition keys {sorted(unknown)}"

def strings(v):
    if isinstance(v, str): return [v]
    if isinstance(v, dict):
        out=[]
        for x in v.values(): out += strings(x)
        return out
    if isinstance(v, list):
        out=[]
        for x in v: out += strings(x)
        return out
    return []

for e in new:
    eid = str(e["id"])
    assert str(e.get("title", "")).strip(), f"{eid}: missing title"
    assert str(e.get("text", "")).strip(), f"{eid}: missing text"
    check_cond(e.get("cond"), f"{eid}.cond")
    opts = e.get("options", [])
    assert isinstance(opts, list) and 2 <= len(opts) <= 3, f"{eid}: expected 2-3 options"
    has_numeric_downside = False
    consequence_axes = set()
    for i, o in enumerate(opts):
        assert isinstance(o, dict), f"{eid}.options[{i}] must be object"
        assert str(o.get("text", "")).strip(), f"{eid}.options[{i}] missing text"
        assert str(o.get("result", "")).strip(), f"{eid}.options[{i}] missing result"
        check_cond(o.get("cond"), f"{eid}.options[{i}].cond")
        effects = o.get("effects", {})
        assert effects is None or isinstance(effects, dict), f"{eid}.options[{i}].effects must be null/dict"
        effects = effects or {}
        unknown = set(effects) - allowed_effect
        assert not unknown, f"{eid}.options[{i}]: unsupported effects {sorted(unknown)}"
        for k, v in effects.items():
            consequence_axes.add(k)
            if isinstance(v, (int, float)) and v < 0:
                has_numeric_downside = True
        flags = o.get("flags")
        if isinstance(flags, dict) and flags:
            consequence_axes.add("flags")
    assert has_numeric_downside, f"{eid}: no machine-traceable real downside/cost"
    assert len(consequence_axes) >= 2, f"{eid}: consequences do not span two supported dimensions"

# Remembered-choice traceability: a Pack A option sets a flag and a later Pack A
# event/event-option condition reads that flag. Count distinct remembered flags.
new_index = {str(e["id"]): i for i, e in enumerate(new)}
flag_writes = {}
for i, e in enumerate(new):
    for o in e.get("options", []):
        flags = o.get("flags")
        if isinstance(flags, dict):
            for f in flags:
                flag_writes.setdefault(str(f), i)

ack_flags = set()
for j, e in enumerate(new):
    conds = [e.get("cond")]
    conds += [o.get("cond") for o in e.get("options", [])]
    for c in conds:
        if not isinstance(c, dict):
            continue
        refs = list(c.get("flags", []) or []) + list(c.get("flags_not", []) or [])
        for f in refs:
            f = str(f)
            if f in flag_writes and flag_writes[f] < j:
                ack_flags.add(f)
assert len(ack_flags) >= 5, f"expected >=5 remembered-choice acknowledgement flags, got {sorted(ack_flags)}"

# Machine trace only; QA still manually checks that each mention is natural in context.
known_npcs = {"陈姐", "老张", "小雨", "阿哲", "老周", "疯道士"}
npc_events=[]
for e in new:
    text="\n".join(strings(e))
    if any(name in text for name in known_npcs):
        npc_events.append(str(e["id"]))
assert len(npc_events) >= 6, f"expected >=6 Pack A events referencing existing NPCs, got {npc_events}"

# Deferred product-policy events must be byte-semantically unchanged as JSON objects.
deferred = {"e_parent_gone", "e_roommate", "e_kid_school", "e_second_child", "e_downsize", "e_empty_nest"}
cur_by_id = {str(e.get("id", "")): e for e in cur}
for eid in deferred:
    assert eid in base_by_id and eid in cur_by_id, f"deferred event missing: {eid}"
    assert cur_by_id[eid] == base_by_id[eid], f"deferred event changed: {eid}"

print("Pack A repository shape PASS")
print("new ids:", [e["id"] for e in new])
print("scene counts:", dict(scene_counts))
print("ack flags:", sorted(ack_flags))
print("NPC-reference events:", npc_events)
'@.Replace('__BASE__', "$env:TEMP\events-wave-base.json") | py -
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

The hard numeric-downside rule intentionally gives QA a deterministic minimum. If an event claims a non-numeric narrative/opportunity cost instead, it requires explicit human review and must not silently pass this machine gate.

### C. Human content review after the deterministic checker
For the 20 exact new IDs:
- verify ordinary city life remains primary; supernatural/dark line is optional/secondary;
- verify 2–3 options are genuinely distinct choices, not cosmetic paraphrases;
- verify at least one real cost/downside per event is understandable before/after choosing;
- verify remembered-choice acknowledgements read as continuity rather than invisible flag plumbing;
- verify at least 6 existing-NPC references are natural, not name-dropping added only to satisfy a count;
- verify no new text/flags silently defines spouse/child/roommate/Xiaoyu romance-or-housing canon;
- explicitly report the 20 IDs, 4-per-location counts, the >=5 acknowledgement pairs, and >=6 NPC-reference event IDs.

## Repository acceptance gate — GAME-CONTENT-012 / livelihood actions
Run only against an orchestrator-accepted exact Gameplay tip.

### Required implementation surface
Expected task-authorized files:
- `scripts/systems/OfficeActivities.gd`
- `scripts/systems/CafeActivities.gd`
- narrow livelihood-only regions in `scripts/Game.gd`
- `tools/verify_livelihood_actions.gd`
- `agent-reports/gameplay.md`

Reject unrelated `Game.gd` refactors or any quest/event/NPC/LocationManager/schema edit.

### Repository checks
Both actions must be reachable from normal existing Office/Cafe interaction layers and their visible label/tooltip must state time and major tradeoff.

Required semantics:
1. Office overtime appears only after ordinary work is completed that day.
2. Overtime is once per in-game day.
3. Overtime takes about 120 minutes, adds meaningful pay, and costs health/mood; recommended first pass is health −4, mood −8 and roughly 50–70% of a normal shift wage.
4. Cafe temporary side gig is visible at the existing cafe, once per in-game day, takes roughly 90–120 minutes, costs health/mood, and pays less than an ordinary work shift.
5. Neither action uses opaque random success.
6. A second same-day attempt cannot settle money/stats/time again.
7. Day rollover makes the action available again.
8. Anti-spam persistence reuses existing saved generic state/flags or another already-saved mechanism; **no new save schema**.
9. Existing GAME-FIX terminal/death mutation ordering remains intact.

Save-schema static review:
- `SaveManager.gd` is outside this task and must remain unchanged.
- inspect the `Game.gd` save/load diff; no new top-level save payload key may be introduced for these actions;
- if anti-spam uses `flags`, confirm it travels through the already existing `GameState.flags` save/load path;
- if it reuses `DailyRoutine.done`, confirm no new serialization shape is introduced.

Expected later real QA commands include the producer verifier plus the existing relevant regression set:

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
```

If the frozen integration candidate contains the previously accepted terminal/death verifiers, run them as well; do not substitute historical green evidence for the frozen candidate run.

## Repository acceptance gate — UI-FIX-007 / dialogue overflow support
Only an orchestrator-accepted exact UI tip can enter the content candidate.

Static expectations:
- changed implementation stays inside `scripts/ui/DialogUI.gd` plus its narrow verifier/report;
- wrapped body alone owns vertical scrolling;
- speaker and `继续` / `结束` remain outside the scroll region;
- `dialog_finished`, `show_dialog()`, `close_dialog()`, `is_busy()`, one-line progression, button copy and exactly-once final emission are preserved;
- no gameplay/content semantics are changed.

Later real QA command:

```powershell
& $godotExe --headless --path . --script res://tools/verify_dialog_panel_overflow.gd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

Headless PASS is not rendered PASS. On the same frozen SHA, visually inspect representative normal and long dialogue at **1280×720 and 960×540**, scroll the body, advance to the next line, close/reopen, and confirm speaker/button remain reachable with no clipping/overlap.

## Freeze / stale-SHA rules
QA-CONTENT-014 does **not** bless movable branch heads.

Before candidate assembly, 00 must provide exact accepted tips for GAME-CONTENT-012, UI-FIX-007, and NPC-CONTENT-012. QA then records:
- each accepted producer commit SHA;
- each accepted producer diff scope;
- the integration/frozen candidate SHA created from those accepted inputs;
- `git status --short` = clean before execution.

Stop and invalidate affected evidence if **any** of these moves after capture:
- accepted producer SHA;
- integration candidate SHA;
- `data/events.json`;
- livelihood implementation or verifier;
- `DialogUI.gd` or overflow verifier;
- shared event/save/time/activity logic used by the slice;
- export/runtime files relevant to Web acceptance.

A moved SHA means re-freeze and rerun affected checks. Never report PASS by combining evidence from different SHAs.

## Runtime gate — one frozen QA-002 candidate
This section is a prepared package only. **Not run in QA-CONTENT-014 web phase.**

### Preflight
Record before every run:
```powershell
git rev-parse HEAD
git status --short
& $godotExe --version
```
Expected: exact frozen SHA, clean worktree, Godot 4.7.2.

### Pack A event playthrough
From normal play/navigation, trigger and complete at least one **new Pack A event** at each:
- park
- cafe
- hospital
- alley
- rooftop

Capture for each: exact event ID/title, location, selected choice, resulting money/health/mood/skill/network/flag change, and whether UI remained readable.

Do not count an existing pre-wave event toward this gate.

### Livelihood playthrough
Office overtime:
- complete ordinary work first;
- confirm overtime becomes visible;
- execute it once and record before/after money/time/health/mood;
- attempt again the same day and prove no second settlement;
- advance to next in-game day and prove it becomes available again.

Cafe temporary side gig:
- confirm normal-play visibility at cafe;
- execute once and record before/after money/time/health/mood;
- prove same-day anti-spam;
- prove next-day availability;
- confirm pay is lower than the current ordinary work shift.

### Save/load during new slice
Use a save point after at least one new-content state has changed, preferably after both:
- a remembered Pack A flag is set; and
- one livelihood action has been consumed for the day.

Save, reload, and prove:
- player state/time/location expected by current save contract survive;
- remembered flag survives and its later acknowledgement remains eligible when conditions are met;
- consumed same-day livelihood action does not become a second money settlement merely because of reload;
- next-day rollover still re-enables the repeatable action.

### Dialogue/readability runtime
At 1280×720 and 960×540:
- open a short dialogue and a long/overflow dialogue;
- scroll only the body;
- verify speaker and advance/end control remain visible/reachable;
- advance line and reopen to prove scroll reset;
- inspect for clipping/overlap.

### Later-pack extension — intentionally deferred for initial Pack A
The TASK_BOARD requires these only **after** NPC-CONTENT-013 / NPC-CONTENT-014 are implemented and accepted:
- progress at least two q4–q8 quest steps;
- trigger one relationship-stage episode.

Do not block the initial 20-event + livelihood Pack A repository review because later packs do not exist yet. When those packs land, create a new frozen SHA and execute these added runtime cases; old Pack A SHA evidence does not cover them.

### Web/browser exact-SHA acceptance
After headless/runtime checks on the same frozen candidate:
```powershell
Remove-Item -Recurse -Force build\web -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force build\web | Out-Null
& $godotExe --headless --path . --export-release "Web" build/web/index.html
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Get-Item build/web/index.html, build/web/index.js, build/web/index.pck, build/web/index.wasm | Select-Object Name,Length
py -m http.server 8000 --directory build/web
```

In a real browser against that export:
- first frame renders;
- no fatal console errors;
- no required-resource 404s;
- enter normal gameplay;
- reproduce representative Pack A event, livelihood, and long-dialogue flows;
- capture screenshots/evidence tied to the same SHA.

## Current gate disposition
**Gate specification: READY FOR ORCHESTRATOR REVIEW.**

**Candidate acceptance: NOT READY TO FREEZE.**

Reasons at this snapshot:
1. NPC-CONTENT-012 has no worker delta yet, so the required 20-event pack cannot be counted or reviewed.
2. GAME-CONTENT-012 has moved but is visibly partial: the observed tip contains only Office overtime/Game changes and does not yet contain Cafe side gig, the dedicated verifier, or a task report.
3. UI-FIX-007 has a coherent repository implementation/verifier shape, but its task board state is still READY and its branch report is still the stale UI-001 placeholder; 00 has not accepted an exact tip.
4. No real parser/Godot/render/Web/browser evidence exists for this wave yet.

## Files changed by QA-CONTENT-014
- `agent-reports/qa-build.md` only.

## Validation performed in this web phase
Repository inspection only:
- read latest TASK_BOARD, FILE_OWNERSHIP, WEB_AGENT_LAUNCHPAD, MASTER_PLAN, AGENT_RULES, HANDOFF;
- read accepted wave planning document;
- captured current coordination/producer branch tips;
- compared moved producer branches against the wave baseline;
- inspected current EventSystem supported condition/effect keys;
- inspected current Gameplay partial Office-overtime surface;
- inspected current UI-FIX-007 implementation and its verifier source.

Not performed:
- JSON parser execution;
- Godot import/start;
- any `.gd` verifier execution;
- rendered viewport validation;
- Web export;
- browser console/network/runtime validation;
- screenshot capture.

## Known risks / stop conditions
- Producer branches are actively moving; every tip in this report is snapshot evidence only until 00 accepts it.
- The current Gameplay partial tip must not be mistaken for a completed livelihood implementation.
- Long-dialogue verifier code has not been executed; static quality does not establish Godot/layout PASS.
- Pack A quality/count/flag/NPC/deferred-policy checks cannot be evaluated until NPC-CONTENT-012 actually changes `data/events.json`.
- Content data that parses can still produce poor or unreachable choices; deterministic checks must be followed by human content review and frozen-SHA runtime play.
- Existing historical QA results are background only and cannot replace current frozen-candidate evidence.

## Handoff to 00-Orchestrator
1. Review this acceptance-gate specification and this report-only diff.
2. Continue producer tasks independently; do not freeze the current partial branch tips.
3. When each producer requests review, audit its diff and record one accepted exact tip.
4. Re-open/refresh QA-CONTENT-014 against those accepted exact tips; run the deterministic repository checks before integration.
5. Assemble one frozen integration SHA only from accepted inputs.
6. Hand that exact SHA to QA-002/Codex/local for parser + Godot + rendered + Web/browser evidence using the package above.
7. Any source/tip movement after freeze invalidates affected evidence and requires a new freeze/rerun.
