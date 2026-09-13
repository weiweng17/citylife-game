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
- Safe repair boundary:
  - keep `origin_selected(origin)` and `load_requested` unchanged;
  - keep `Data.ORIGINS` read-only;
  - give the start content a centered, width-bounded, vertically scrollable owner;
  - preserve full-card click targets and load-button reachability.

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
  1. `origin_selected(origin)` and `load_requested` remain unchanged;
  2. StartUI stays inside the logical viewport at 1280×720 and one smaller declared desktop/Web logical viewport (recommend 960×540 for consistency with UI-FIX-004);
  3. all four current origin cards remain fully reachable through an explicit vertical scroll path when content exceeds available height;
  4. the optional load button remains reachable when enabled;
  5. origin descriptions/stat lines wrap without forcing horizontal overflow;
  6. full-card hit targets still emit the correct origin dictionary;
  7. no origin data, save behavior, gameplay, navigation, or NPC semantics change;
  8. rendered PASS waits for actual Godot evidence.
- Why this boundary is smallest:
  - one directly presentation-owned file;
  - current four-card content already exercises the risky structure;
  - no external system needs semantic changes;
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
- `scripts/Game.gd` (EndingUI composition/callsite, read-only)
- `scripts/Rules.gd` and `data/rules.json` (ending description pressure, read-only)

## Validation
### Repository checks performed
- Confirmed UI-AUDIT-005 is `READY`, owned by `scene-ui`, and report-only.
- Confirmed the assigned branch started identical to current orchestrator baseline `4249687c2c20a5680ed5914c01f4f55665d397d9` (ahead 0 / behind 0).
- Re-read all four preferred remaining UI candidates from the current coordination branch rather than relying on the prior audit.
- Ranked candidates using current content pressure, repair size, and ownership risk.
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
- ShopUI remains the strongest follow-up after StartUI because its fixed 660px width and six rows create both horizontal and vertical pressure.

## Handoff
UI-AUDIT-005 is complete at repository-audit level and requests orchestrator review. The recommended next isolated Scene/UI repair is **UI-FIX-005 — Start screen vertical overflow containment** in `scripts/ui/StartUI.gd`, with any actual visual acceptance deferred to real Godot execution.