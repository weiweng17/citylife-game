# Scene/UI Agent Report

## Task
- ID: UI-AUDIT-005
- Agent: scene-ui
- Branch/worktree: `agent/ui-audit-005-next-responsive-hotspot`
- Status: NEEDS_REVIEW

## Scope
Repository-only audit for the next presentation-owned responsive/layout repair after EventUI.

Per the task board, the only writable file for UI-AUDIT-005 is `agent-reports/scene-ui.md`. All production UI scripts, gameplay, data, navigation, NPC logic, `main`, and `docs/agents/**` remained read-only.

EventUI is intentionally excluded because UI-FIX-004 is already `NEEDS_REVIEW` and awaiting real Godot/rendered evidence. UI-FIX-001/002/003 are likewise not reopened while their rendered acceptance remains outstanding.

## Summary
The next smallest safe responsive repair should be **StartUI vertical overflow containment** in `scripts/ui/StartUI.gd`.

Why StartUI is next:
- it is a single presentation-owned helper with no need to touch `Game.gd`, navigation, NPC semantics, or origin data;
- current content already contains four origin cards, not a hypothetical future list;
- each card has two wrapped text rows, so narrowing the logical viewport directly increases vertical pressure;
- the optional load button is appended after all four cards and has no independent reachability contract;
- the root resizes to the viewport, but the inner content is one unbounded `VBoxContainer` with no `ScrollContainer` or bounded content region.

Compared with the other remaining candidates, ShopUI has stronger multi-axis pressure but a larger repair surface, DialogUI is smaller but current content pressure is lower, and EndingUI is both lower-frequency and currently has long prose in only a subset of endings.

## Baseline repository evidence
- `project.godot`
  - logical viewport: `1280×720`;
  - stretch mode: `canvas_items`.
- `scripts/Data.gd`
  - current start flow contains exactly four origin cards;
  - each origin has a sentence-length description and bonus text which StartUI wraps.
- `scripts/systems/Inventory.gd`
  - current shop catalog contains six items in `DISPLAY_ORDER`.
- `data/rules.json` / `scripts/Game.gd`
  - only the three dark-path endings currently have substantial ending descriptions; most other ending descriptions are empty;
  - final EndingUI text also appends reason/lifetime/money/clue summary.
- `scripts/Game.gd` StartUI callsite
  - creates `StartUIScript.new()`;
  - calls `start_ui.setup(Data.ORIGINS, Callable(self, "_fmt_money"))` **before** `ui.add_child(start_ui)`;
  - connects `origin_selected` to `_choose_origin`;
  - connects `load_requested` to `_load_game`;
  - then adds StartUI to the UI layer;
  - `_show_start_screen()` later calls `start_ui.set_load_available(save_sys != null and save_sys.has_save())` and then `start_ui.open()`;
  - after a successful save path, Game can call `start_ui.set_load_available(save_sys.has_save())` again while StartUI already exists in the tree.
  - Therefore the responsive repair must preserve both lifecycle phases: pre-tree `setup(...)` must still be valid, and post-ready `set_load_available(...)` must remain dynamically safe. A layout refactor must not require `_ready()`-created nodes that `setup()` needs before `add_child()`.
- `tools/` inventory
  - no StartUI-specific `verify_start*` regression is currently present on the coordination branch;
  - a future UI-FIX-005 can therefore add one narrow StartUI verifier without duplicating an existing dedicated regression.

These are repository facts only. No visual fit or overflow result is inferred without Godot.

## Ordered responsive hotspot inventory

### 1. StartUI — four-card stack has no vertical overflow owner
- Priority: HIGH-MEDIUM
- Candidate file: `scripts/ui/StartUI.gd`
- Ownership risk: LOW
- Current structure:
  - root manually tracks the visible viewport;
  - one plain `VBoxContainer` owns title, subtitle, all origin cards, then optional `load_button`;
  - there is no `ScrollContainer`, max-height owner, or centered width cap;
  - origin description and stat/bonus labels both use word wrapping.
- Current content pressure:
  - `Data.ORIGINS` already contains four cards;
  - every card has a description plus an `初始 ... ｜ bonus` line;
  - at narrower width, both wrapped rows can increase card height simultaneously.
- Failure mode:
  - on a shorter/narrower logical desktop/Web viewport, the content VBox can become taller than the full-screen StartUI root;
  - the fourth card and/or `读取上次存档` may fall below the visible area because root resizing does not create a scroll path;
  - a larger font metric/localization would amplify the same ownership problem.
- Lifecycle constraint:
  - `setup()` currently builds the UI before StartUI enters the scene tree;
  - `_ready()` only attaches viewport resize behavior and syncs the root afterward;
  - `set_load_available()` is also called dynamically after the node is already live, including after saves;
  - future layout work must therefore preserve both pre-tree construction and post-ready load-button toggling.
- Safe repair boundary:
  - keep `setup(origins, money_formatter)`, `origin_selected(origin)`, `load_requested`, `open()`, `close()`, and `set_load_available(value)` behavior unchanged;
  - keep `Data.ORIGINS` read-only;
  - give the start content a centered, width-bounded, vertically scrollable owner;
  - preserve full-card click targets and load-button reachability;
  - do not move required setup-time UI construction behind `_ready()` unless `setup()` remains valid before `add_child()`.

### 2. ShopUI — fixed 660px minimum width plus six content-driven rows
- Priority: MEDIUM
- Candidate file: `scripts/ui/ShopUI.gd`
- Ownership risk: LOW-MEDIUM
- Current structure:
  - root/dim/center follow viewport size;
  - `ShopPanel.custom_minimum_size = Vector2(660, 0)` hard-codes the horizontal floor;
  - item-list height is content-driven with no scroll owner;
  - code comments explicitly acknowledge that catalog growth can make the panel exceed screen height;
  - every item row also reserves fixed horizontal slices: effect text 128px, price/count 56px, action button 78px, plus gaps and margins.
- Current content pressure:
  - the catalog already has six rows;
  - sentence-length descriptions wrap in the remaining horizontal area;
  - narrower width therefore increases both horizontal pressure and total panel height.
- Failure mode:
  - below the panel minimum width, the centered panel can extend outside the logical viewport;
  - wrapped descriptions can grow six rows enough to exceed a shorter viewport;
  - close/status controls have no guaranteed fixed reachable region when the panel becomes too tall.
- Why not first:
  - still one UI file, but it has two modes (`buy` / `bag`) and row-level fixed-width dependencies, so the smallest correct repair is broader than StartUI.

### 3. DialogUI — fixed 220px bottom panel with unbounded wrapped dialogue line
- Priority: MEDIUM-LOW
- Candidate file: `scripts/ui/DialogUI.gd`
- Ownership risk: LOW
- Current structure:
  - width follows viewport minus 32px;
  - height is always 220px and positioned at `viewport_height - 230`;
  - wrapped dialogue text has only a 96px minimum; there is no scroll, clipping policy, max-lines rule, or bounded text viewport;
  - next/finish button shares the same VBox with dynamic text.
- Failure mode:
  - a long dialogue line or narrower logical viewport can increase text minimum height beyond the fixed panel contract;
  - Godot minimum-size negotiation may grow the panel unexpectedly or push the action button outside the intended bottom band.
- Current-content relevance:
  - current NPC/dialogue lines are generally shorter than StartUI's cumulative four-card stack, so this is a real contract weakness but lower present pressure.
- Safe future boundary:
  - keep `dialog_finished`, `show_dialog`, `close_dialog`, and line progression semantics unchanged;
  - bound/scroll only the text region or make panel height viewport-relative.

### 4. EndingUI — ending prose has no independent overflow region
- Priority: LOW
- Candidate file: `scripts/ui/EndingUI.gd`
- Ownership risk: LOW
- Current structure:
  - outer panel uses fixed 28px horizontal and 90px vertical margins with minimum dimensions;
  - description wraps and declares a 220px minimum;
  - title, description, and restart action share one VBox;
  - no scroll owner exists for description text.
- Failure mode:
  - on a short logical viewport or long ending prose, description minimum height can compete with the restart button and outer panel height;
  - restart reachability is not structurally separated from prose growth.
- Current-content relevance:
  - three dark-path endings currently contain substantial prose;
  - most other ending descriptions are empty, so present pressure/frequency is lower than StartUI and ShopUI.

## Recommended next minimal task
### UI-FIX-005 — Start screen vertical overflow containment
- Owner: scene-ui
- Suggested branch: `agent/ui-fix-005-start-screen-overflow`
- Suggested priority: MEDIUM
- Suggested writable paths:
  - `scripts/ui/StartUI.gd`
  - one narrow `tools/verify_*.gd` regression if explicitly granted
  - `agent-reports/scene-ui.md`
- Explicitly forbidden:
  - `scripts/Game.gd`
  - `scripts/Data.gd`
  - `scripts/systems/LocationManager.gd`
  - save/origin/gameplay semantics
  - navigation/NPC logic
- Objective:
  - make the start screen own vertical overflow so all four existing origin cards and the optional load action remain reachable as the logical viewport becomes narrower/shorter.
- Suggested acceptance:
  1. `setup(origins, money_formatter)` remains callable before StartUI enters the scene tree, matching the current Game call order;
  2. `origin_selected(origin)`, `load_requested`, `open()`, `close()`, and `set_load_available(value)` remain behaviorally compatible;
  3. `set_load_available(...)` remains safe both before opening and when called again later after StartUI is already ready/in-tree;
  4. StartUI stays inside the logical viewport at 1280×720 and one smaller declared desktop/Web logical viewport (recommend 960×540 for consistency with UI-FIX-004);
  5. all four current origin cards remain fully reachable through an explicit vertical scroll path when content exceeds available height;
  6. the optional load button remains reachable when enabled;
  7. origin descriptions/stat lines wrap without forcing horizontal overflow;
  8. full-card hit targets still emit the exact origin dictionary supplied to `setup`;
  9. the load button still emits `load_requested` once per activation;
  10. no origin data, save behavior, gameplay, navigation, or NPC semantics change;
  11. rendered PASS waits for actual Godot evidence.
- Suggested narrow verifier boundary:
  - instantiate StartUI directly rather than booting `Game.gd`;
  - intentionally mirror production lifecycle: call `setup()` **before** adding StartUI to the test scene tree;
  - only then add the node and allow `_ready()` / viewport synchronization to run;
  - call `set_load_available(false)` and then `set_load_available(true)` after the node is live to prove dynamic load-button toggling still works;
  - use four current-shape origin dictionaries and a deterministic formatter;
  - set/assert 1280×720 and 960×540 logical viewports explicitly (not just physical window size);
  - prove the content exposes a vertical scroll range under stress and that the last origin card plus load button can be brought fully into view;
  - activate one full-card hit target and assert the exact supplied origin dictionary is emitted once;
  - activate load and assert `load_requested` is emitted once.
- Why this boundary is smallest:
  - one directly presentation-owned file;
  - current four-card content already exercises the risky structure;
  - the current Game callsite needs no change if StartUI preserves its existing API/signals/lifecycle;
  - no existing StartUI-specific verifier has to be replaced or reconciled;
  - unlike ShopUI, no dual-mode list rows or inventory dependency needs to be reflowed.

## Files inspected
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `project.godot`
- `scripts/ui/StartUI.gd`
- `scripts/ui/ShopUI.gd`
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EndingUI.gd`
- `scripts/Data.gd` (origin-content pressure, read-only)
- `scripts/systems/Inventory.gd` (catalog size, read-only)
- `scripts/Game.gd` (StartUI lifecycle/callsites and EndingUI composition, read-only)
- `scripts/Rules.gd` and `data/rules.json` (ending description pressure, read-only)
- `tools/` directory inventory (existing regression coverage, read-only)

## Validation
### Repository checks performed
- Confirmed UI-AUDIT-005 is still `READY`, owned by `scene-ui`, and report-only on the latest coordination branch.
- Confirmed the assigned branch originally started identical to orchestrator baseline `4249687c2c20a5680ed5914c01f4f55665d397d9` (ahead 0 / behind 0).
- On continuation, confirmed the audit branch remained ahead 2 / behind 0 before this lifecycle refinement; no orchestrator rework finding or scope change was present.
- Re-read all four preferred remaining UI candidates from the current coordination branch rather than relying on the prior audit.
- Ranked candidates using current content pressure, repair size, and ownership risk.
- Re-read the actual StartUI construction order in `Game.gd` and confirmed `setup()` runs before `ui.add_child(start_ui)`.
- Re-read StartUI load-availability callsites and confirmed `set_load_available(...)` is invoked both during start-screen presentation and later after saves, so post-ready dynamic toggling is part of the existing contract.
- Checked the coordination-branch `tools/` inventory and found no StartUI-specific `verify_start*` regression, so the proposed narrow verifier does not duplicate an existing dedicated check.
- Excluded EventUI because UI-FIX-004 is already `NEEDS_REVIEW` pending rendered evidence.
- Excluded HUD/NPC/bed surfaces because their existing UI-FIX tasks remain pending rendered acceptance.

### Not performed
- Godot was not launched.
- No headless or windowed regression was executed.
- No Web export/browser inspection was performed.
- No screenshots or rendered PASS are claimed.
- No assertion is made that StartUI currently overflows at 1280×720; the repository-visible finding is that four wrapped cards plus the load action have no bounded vertical overflow owner.

## Known risks / review notes
- Exact Godot minimum-size negotiation and current-font wrapping require runtime validation before a future UI-FIX-005 can claim failure or PASS at a specific viewport.
- Because the project uses `canvas_items`, future responsive regression must manipulate/assert the logical viewport, not only physical `Window.size`.
- A future StartUI fix should avoid making the whole card stack narrower than necessary: excessive narrowing increases vertical wrap pressure even if scrolling prevents clipping.
- A future refactor that moves child creation from `setup()` to `_ready()` without preserving pre-tree setup compatibility would be a functional regression even if the rendered layout looks correct.
- ShopUI remains the strongest follow-up after StartUI because its fixed 660px width and six rows create both horizontal and vertical pressure.

## Handoff
UI-AUDIT-005 is complete at repository-audit level and requests orchestrator review. The recommended next isolated Scene/UI repair is **UI-FIX-005 — Start screen vertical overflow containment** in `scripts/ui/StartUI.gd`, with a narrow StartUI-only regression that mirrors the current pre-tree setup and post-ready load-toggle lifecycle. Any actual visual acceptance remains deferred to real Godot execution.