# Gameplay Agent Report

## Task
- ID: GAME-001
- Agent: gameplay
- Branch/worktree: `agent/game-001-blocker-audit`
- Status: NEEDS_REVIEW

## Scope
Repository audit only. Source/data/scene/assets were read-only for this task. The only modified file is this report.

## Summary
The current repository has a substantially tested minute/day gameplay loop, but the largest gameplay risk is a still-live seam between that loop and the legacy annual-life system. In the current independent-location flow, a normal location action can open a legacy regular event; closing that event calls `_year_pass()`, which performs annual income/cost/recovery/promotion logic and increments age by one. This directly violates the architecture rule that daily/minute flow and annual life events remain separate.

Two additional repository-verified state issues are important before further feature expansion: zero fullness/energy penalties are applied once per game-minute change rather than once per elapsed-hour block, and lethal health/mood states are only checked inside `_year_pass()`. Save/load also drops the fractional need-drain accumulator, so a mid-hour save/load can erase pending need consumption.

Historical QA is strong for the paths it covers, but this audit did not rerun Godot. Existing `verify_day_flow.gd`, `verify_needs.gd`, `verify_day_cycle.gd`, navigation/home/location suites and the 2026-09-13 QA results are prior evidence only.

## Repository-verified findings

### Critical — G-001: independent-location regular events still advance a whole year
- Exact path/symbols:
  - `scripts/Game.gd::_on_location_action()`
  - `scripts/Game.gd::_show_event()`
  - `scripts/Game.gd::_close_event()`
  - `scripts/Game.gd::_year_pass()`
  - `scripts/Rules.gd::year_tick()`
- Evidence:
  - `_on_location_action()` is the active `LocationManager.action_requested` handler for the independent-location mode. When `events_sys.pick(scene, _state())` returns a regular event, it calls `_show_event(event)`.
  - `_show_event()` sets `cur_event_kind = "event"`.
  - `_close_event()` only special-cases `"encounter"`; every regular event falls through to `_year_pass()`.
  - `Rules.year_tick()` applies annual income/cost/recovery/promotion/re-employment logic and finally increments `st["age"]` by 1.
  - `docs/ARCHITECTURE.md` explicitly states that minute/daily flow and old annual-life events must be strictly separated: “做一顿饭不能长一岁”.
- Player impact: pressing the normal location “action” surface and completing a regular event can jump age by one year and apply annual economy/recovery in the middle of a day-scale loop. This can rapidly distort age, money, health, job state and endings.
- Likely cause: MAP-002 independent-location actions reused the legacy `EventSystem` presentation/closure path without splitting “daily event closure” from “annual turn closure”.
- Recommended repair: make event time-scale explicit. A regular independent-location event should resolve with a minute cost (or no time cost) and must not call `_year_pass()`. Keep annual progression behind a separately named/explicit legacy path until it is removed or redesigned.
- Suggested owner/files: gameplay; `scripts/Game.gd` is a declared high-conflict file and requires explicit orchestrator assignment. `scripts/systems/EventSystem.gd` only if event metadata needs a time-scale field.

### High — G-002: zero-needs damage is charged per game-minute change, not per elapsed-hour block
- Exact path/symbol: `scripts/Game.gd::_sync_needs_to_time()`.
- Evidence:
  - `FULLNESS_PER_HOUR` and `ENERGY_PER_HOUR` are hourly constants.
  - `_sync_needs_to_time()` correctly accumulates elapsed time in `need_fraction` and drains fullness/energy inside `while need_fraction >= 1.0`.
  - The zero-state penalties (`health -= 2` when fullness <= 0; `mood -= 2` when energy <= 0) are outside that hourly loop.
  - `_process()` calls `_sync_needs_to_time()` continuously; the function proceeds whenever total game minutes increase. Therefore, once a need reaches zero, the -2 penalty is applied on each subsequent game-minute change rather than once per drained-hour unit.
  - `tools/verify_needs.gd` verifies 4-hour fullness/energy drain and low-need warnings, but it does not assert zero-need penalty cadence.
- Player impact: after fullness or energy reaches zero, health/mood can collapse far faster than the documented hourly need model suggests.
- Likely cause: starvation/exhaustion penalty was appended after the hourly accumulator loop instead of being tied to elapsed penalty units.
- Recommended repair: define an explicit cadence (most likely per elapsed hour, or another documented interval) and charge the zero-state penalty inside an elapsed-unit loop/counter. Add parity coverage for one large `advance_minutes()` call versus minute-by-minute ticking.
- Suggested owner/files: gameplay for `scripts/Game.gd`; QA/build or orchestrator-assigned test writer for `tools/verify_needs.gd` / a narrow new regression.

### High — G-003: health/mood can reach zero in the day loop without entering an ending state
- Exact path/symbols:
  - `scripts/Game.gd::_sync_needs_to_time()`
  - `scripts/Game.gd::_do_work_shift()` and other daily activity settlements
  - `scripts/Game.gd::_year_pass()`
  - `scripts/Rules.gd::death_reason()`
- Evidence:
  - Daily systems can clamp health/mood to zero (`_sync_needs_to_time()` and work/activity settlements).
  - In the current `Game.gd`, `rules_sys.death_reason(st)` is invoked from `_year_pass()`; there is no shared lethal-state check after normal minute/day settlements.
  - `Rules.death_reason()` treats health <= 0 and mood <= 0 as ending conditions.
- Player impact: the player can remain in the active daily loop with a value that the rules layer defines as dead/ended until some annual path happens to execute. Because G-001 makes that annual path accidentally reachable via regular events, ending timing is currently coupled to the wrong interaction.
- Likely cause: death/ending checks remained attached to the original annual-turn architecture while minute-scale activities were added later.
- Recommended repair: split “validate terminal player state” from “advance one year”. Run terminal validation after every authoritative settlement point (or through one centralized post-settlement function) without incrementing age or applying annual economy.
- Suggested owner/files: gameplay; likely `scripts/Game.gd` plus a narrow helper in `scripts/Rules.gd` only if orchestration needs a cleaner API.

### Medium — G-004: save/load discards partial-hour need consumption
- Exact path/symbols:
  - `scripts/Game.gd::need_fraction`
  - `scripts/Game.gd::build_save_payload()`
  - `scripts/Game.gd::apply_save_payload()`
- Evidence:
  - `need_fraction` stores sub-hour elapsed need drain so minutes are not rounded away.
  - `build_save_payload()` persists `game_state`, time, weather, events, encounters, world, locations, daily routine, inventory and origin, but not `need_fraction`.
  - `apply_save_payload()` explicitly sets `need_fraction = 0.0` after loading.
- Player impact: saving at (for example) 59 minutes of accumulated sub-hour need time and loading loses that pending 59-minute fraction. Repeated save/load can postpone need drain and means the restored state is not equivalent to the saved state.
- Likely cause: the accumulator was treated as transient implementation state even though it affects future authoritative gameplay settlement.
- Recommended repair: persist the accumulator in a small gameplay-runtime/save field, with a safe default of 0 for old saves. Add a regression that saves with a non-zero fraction, reloads, then advances the remaining minutes and asserts the same result as uninterrupted play.
- Suggested owner/files: gameplay for `scripts/Game.gd`; no `SaveManager.gd` schema change is required if stored inside the existing payload.

### Low — G-005: save file write is single-file destructive overwrite with no recovery copy
- Exact path/symbol: `scripts/systems/SaveManager.gd::save_game()`.
- Evidence: `save_game()` opens `user://savegame.json` directly with `FileAccess.WRITE` and writes the replacement document; there is no temp-file + rename or known-good backup.
- Player impact: an interrupted/failed write can leave the only save unreadable. `load_game()` correctly rejects malformed JSON, but no recovery path exists.
- Likely cause: initial single-slot implementation optimized for simplicity.
- Recommended repair: later hardening task: write temp → validate/close → rotate previous save to backup → atomic-ish rename where Godot/platform APIs permit. This is lower priority than G-001–G-004.
- Suggested owner/files: gameplay/save-system task with `scripts/systems/SaveManager.gd`; QA should define corruption/recovery cases.

## History-only / reconciled items (do not treat as current confirmed bugs)

### Cross-midnight commute reset note
`docs/QA_2026-09-13.md` records an earlier limitation saying a commute completed across midnight could be reset away. Current source ordering in `scripts/Game.gd::_on_location_travel()` is different from that failure description: it first calls `time_sys.advance_minutes(...)`, allowing `day_changed` / `DailyRoutine.reset()` to occur, and only then calls `daily_routine.complete("commute")` for office arrival. Static inspection therefore does not support reporting “commute mark is cleared” as a current bug. Keep a midnight boundary regression test because semantics across day boundaries are still easy to regress.

### Home/input/navigation issues already documented as fixed
The current handoff/QA history records fixes and prior passing evidence for home navigation dead zones, interaction facing, activity props, input-gate test flakiness and the basic day flow. This audit found no repository evidence justifying reopening those as current gameplay bugs. Visual acceptance remains separate.

## Runtime/manual checks still required (not performed here)
- Trigger at least one normal independent-location “行动” event in Godot and capture before/after age, money, health, mood and time. Expected current-risk reproduction: closing a regular event should reveal whether `_year_pass()` is observable in live play. This is the first runtime check to run.
- Drive fullness to 0 and compare 60 minutes advanced at once versus minute-by-minute ticking; capture health delta. Repeat for energy/mood.
- Drive health or mood to 0 through daily activities/needs without a regular event and confirm whether gameplay continues instead of opening an ending.
- Save with a deliberately non-zero `need_fraction`, load, then advance only the remaining fraction to one hour and compare against uninterrupted play.
- Run the outstanding 20–30 minute no-debug-jump manual day-flow acceptance from `docs/ITERATION_PLAN.md` / `docs/QA_2026-09-13.md`.
- Continue the already-documented manual visual checks (all walk directions, activity presentation, rough office/store anchor calibration) under Scene/UI rather than mixing them into gameplay fixes.

## Recommended repair order / follow-up tasks
1. **GAME-FIX-001 — Separate daily event closure from annual progression (Critical).** Explicit orchestrator assignment for high-conflict `scripts/Game.gd`; acceptance: independent-location regular events never change age or run `Rules.year_tick()`, while any intentionally retained annual path remains explicit and separately testable.
2. **GAME-FIX-002 — Normalize need-zero penalty cadence (High).** Define cadence, fix `_sync_needs_to_time()`, add large-step vs minute-step parity regression.
3. **GAME-FIX-003 — Centralize terminal-state evaluation (High).** Health/mood/money terminal checks must not require a year advance; add regressions for daily-loop zero states.
4. **GAME-FIX-004 — Preserve need accumulator across save/load (Medium).** Persist `need_fraction` compatibly and extend save/day-cycle coverage.
5. **SAVE-HARDEN-001 — Atomic/backup single-slot save (Low).** Defer until current gameplay blockers are stable.
6. **QA runtime package after fixes.** Rerun the existing day/needs/save/location suites plus targeted regressions and the manual 20–30 minute flow. Do not bundle unrelated gameplay changes into the QA run.

## Files inspected
Coordination/context:
- `HANDOFF.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `docs/agents/MASTER_PLAN.md`
- `docs/agents/TASK_BOARD.md`
- `docs/agents/AGENT_RULES.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/ARCHITECTURE.md`
- `docs/ITERATION_PLAN.md`
- `docs/QA_2026-09-13.md`

Gameplay/state code and tests:
- `scripts/Game.gd`
- `scripts/GameState.gd`
- `scripts/Rules.gd`
- `scripts/systems/TimeManager.gd`
- `scripts/systems/DailyRoutine.gd`
- `scripts/systems/SaveManager.gd`
- `scripts/systems/LocationManager.gd`
- `scripts/systems/HomeActivities.gd`
- `scripts/systems/SpotActivities.gd`
- systems directory inventory including Inventory/Office/Store/NPC/Quest/location activity systems
- `tools/verify_needs.gd`
- latest documented day-flow/save/location/navigation test inventory in `docs/QA_2026-09-13.md`

## Validation
- Commands/tests run: none. This was a GitHub repository inspection task and the task contract forbids claiming a Godot rerun.
- Repository validation: inspected current branch source, current coordination docs, current architecture/iteration plan, existing verification script coverage, and historical QA evidence.
- Branch hygiene before report update: `agent/game-001-blocker-audit` was identical to `orchestrator/multi-agent-bootstrap`; no pre-existing worker diff was present.
- Runtime/build evidence produced by this task: none.

## Historical evidence (not a fresh run)
`docs/QA_2026-09-13.md` records prior Godot 4.7.2 passes for `verify_navigation.gd`, `verify_home_edges.gd`, `verify_day_flow.gd`, `verify_day_cycle.gd`, `verify_store.gd`, `verify_needs.gd`, `verify_daily_routine.gd`, `verify_home_activities.gd`, `verify_locations.gd`, `verify_onboard.gd`, `verify_dark.gd`, and rendered `verify_home_input.gd`. Those results support that the implemented happy paths had prior coverage, but they do not cover G-001–G-004 as described above and were not rerun by this web agent.

## Known issues / risks
- `scripts/Game.gd` is a high-conflict file under `FILE_OWNERSHIP.md`; the orchestrator must explicitly assign each repair scope before any worker edits it.
- G-001 changes event/time semantics, so it should be fixed before adding more Phase 4 events or economic balancing; otherwise new content will inherit the wrong year-advance behavior.
- G-002/G-003 can alter survival/economy balance significantly. Fix semantics first, then rebalance only if post-fix data shows it is necessary.
- Do not use historical QA text as proof that the current branch was run after these findings.

## Handoff
GAME-001 is complete and requests orchestrator review. Please audit this report and the branch diff, then mirror task status in `docs/agents/TASK_BOARD.md` if accepted. The gameplay agent did not edit `TASK_BOARD`, `main`, source code, data, scenes, assets, project/export configuration or workflows.
