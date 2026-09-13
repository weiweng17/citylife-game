# Scene/UI Agent Report

## Task
- ID: UI-AUDIT-006
- Agent: scene-ui
- Branch/worktree: `agent/ui-audit-006-next-responsive-hotspot`
- Status: NEEDS_REVIEW

## Scope
Repository-only audit for the next independent responsive/reachability repair after StartUI.

Per the task board, the only writable path for UI-AUDIT-006 is `agent-reports/scene-ui.md`. Production UI, gameplay, data, navigation, NPC logic, held UI-FIX files, `main`, and `docs/agents/**` remained read-only.

UI-FIX-001 through UI-FIX-005 remain in exact-SHA rendered/runtime hold and were not reopened.

## Summary
The next smallest independent responsive repair should be **ShopUI list vertical overflow containment** in `scripts/ui/ShopUI.gd`.

This recommendation is intentionally narrower than a full ShopUI responsive redesign:
- keep the existing 660px panel-width contract for the declared 1280×720 / 960×540 desktop-Web acceptance window;
- do not reflow row columns in this task;
- make only `ShopList` a bounded vertical overflow owner;
- keep title/subtitle, status, footer, and close action outside the scroll region so the exit/control path stays reachable;
- preserve both `buy` and `bag` modes and all existing signals/data semantics.

The horizontal 660px floor is a separate real weakness for narrower-than-declared viewports, but combining horizontal row reflow with the vertical reachability repair would make the next task larger than necessary.

## Repository evidence
### Current unlocked candidate set
The current `scripts/ui/` presentation helpers are `DialogUI.gd`, `EndingUI.gd`, `EventUI.gd`, `HUD.gd`, `ShopUI.gd`, and `StartUI.gd`.

- `EventUI.gd` is held by UI-FIX-004.
- `HUD.gd` is held by UI-FIX-003.
- `StartUI.gd` is held by UI-FIX-005.
- active NPC / home-bed presentation surfaces are held by UI-FIX-001 / UI-FIX-002.
- `LocationManager.gd`, Gameplay, NPC/content, save semantics, and shared roots are explicitly outside this audit boundary.

That leaves ShopUI, DialogUI, and EndingUI as the clean presentation-owned candidates.

### Chosen candidate — `scripts/ui/ShopUI.gd`
Exact layout evidence:
- `_sync_viewport()` makes `ShopCenter` follow the logical viewport.
- `_build_ui()` creates one centered `ShopPanel` with `custom_minimum_size = Vector2(660, 0)`.
- title, subtitle, `ShopList`, status, and footer/close all live in the same outer `VBoxContainer`.
- the source explicitly avoids a `ScrollContainer`; its own comment says the panel is allowed to grow directly with content and assumes the six-item shelf can be shown without bounded scrolling.
- `ShopList` is a plain `VBoxContainer`, so there is no explicit vertical overflow owner.
- `ShopStatus` has a 34px minimum height and the close button has a 34px minimum height, but both come **after** the dynamic list in the same VBox; list growth therefore competes directly with bottom-control reachability.
- every item row contains wrapped description text plus fixed effect/meta/action columns, so narrower available width can increase row height even when item count is unchanged.

Current content evidence from `scripts/systems/Inventory.gd`:
- `DISPLAY_ORDER` contains exactly six items today.
- buy mode always builds one row for every item in `DISPLAY_ORDER`.
- bag mode uses `owned_items()`, which iterates the same `DISPLAY_ORDER`; there is no rule preventing all six items from being owned simultaneously, so bag mode can also build six rows.
- current item descriptions are sentence-length strings and are displayed with word wrapping in `_add_row()`.

Current integration contract from `scripts/Game.gd`:
- Game creates one `ShopUIScript` instance and connects `buy_requested`, `use_requested`, and `closed` back into gameplay.
- `_open_shop()` calls `shop_ui.open_buy(money, inventory)`.
- `_open_bag()` calls `shop_ui.open_bag(money, inventory)`.
- both buy and use flows call `shop_ui.refresh(money, inventory)` after inventory/money mutation, then call `shop_ui.set_status(...)` with the resulting user-facing status copy.
- This means the responsive repair does not require a Game callsite or settlement change if ShopUI preserves its public methods/signals, but a future regression must cover same-mode `refresh()` rebuilds in addition to buy↔bag mode switches.

Current `tools/` inventory contains no dedicated `verify_shop*` regression. A future UI-FIX-006 can therefore add one narrow ShopUI-only verifier without replacing or reconciling an existing task-specific ShopUI test.

## Failure mode
At shorter logical heights, six content-driven rows can make the centered panel's minimum height exceed the viewport because `ShopList` has no bounded scroll path. Since status/footer/close are below that list in the same VBox, the bottom controls can be displaced outside the visible region rather than remaining independently reachable.

This is a repository-visible ownership problem even without claiming that a particular font build already clips at a specific pixel: dynamic list growth is unbounded, while the control path below it has no pinned region.

The existing source comment also records a historical failure mode to avoid: wrapping the **entire** variable panel in a generic scroll region previously caused stale measured height when switching between shelf and a sparse/empty bag. A future fix should therefore bound only the list region, not blindly make the whole ShopPanel scroll.

## Why this is the next smallest task
### Compared with DialogUI
`DialogUI.gd` has a real fixed-height text-pressure weakness: a 220px bottom panel contains wrapped dialogue plus the action button with no bounded text region. However current dialogue lines are generally one-line-at-a-time and the repair must be careful around line progression and `dialog_finished`. It is a valid later candidate, but current cumulative content pressure is lower than ShopUI's six-row list.

### Compared with EndingUI
`EndingUI.gd` also has an unbounded wrapped description above the restart action. Game composes reason + ending prose + lifetime/money/clue summary, and three dark-path endings currently have substantial descriptions. But most ending descriptions are empty and the screen is low-frequency. Its repair remains isolated, but the present reachability pressure is lower than the always-six-row shop shelf.

### Why ShopUI can still stay narrow
Although ShopUI has two modes, both modes already share the same `ShopList` and `_add_row()` path. A vertical-only fix can therefore be one presentation-file change: introduce one bounded scroll owner around the existing list while leaving header/status/footer and all data/action semantics untouched.

## Recommended next task
### UI-FIX-006 — Shop list vertical overflow containment
- Owner: scene-ui
- Suggested branch: `agent/ui-fix-006-shop-list-overflow`
- Suggested priority: MEDIUM
- Suggested writable paths:
  - `scripts/ui/ShopUI.gd`
  - one narrow `tools/verify_shop_panel_overflow.gd` regression if explicitly granted
  - `agent-reports/scene-ui.md`
- Explicitly out of scope:
  - `scripts/Game.gd`
  - `scripts/systems/Inventory.gd`
  - prices/effects/item order/inventory counts
  - buy/use settlement semantics
  - navigation/NPC/save logic
  - horizontal redesign for sub-660px viewports
  - any UI-FIX-001..005 held file

### Suggested objective
Give only the ShopUI item-list region an explicit bounded vertical overflow path so shelf/bag content cannot push status/footer/close out of reach at the declared desktop/Web logical viewports.

### Suggested acceptance
1. Preserve public signals exactly: `buy_requested(item_id)`, `use_requested(item_id)`, and `closed`.
2. Preserve public behavior of `open_buy()`, `open_bag()`, `refresh()`, `set_status()`, `close()`, and `is_open()`.
3. At 1280×720 and 960×540 logical viewports, ShopPanel remains vertically contained by the visible viewport.
4. Title/subtitle and status/footer/close remain outside the scroll region and stay reachable while the list overflows.
5. Buy mode with all six current `DISPLAY_ORDER` rows exposes a usable vertical scroll path when required and the last row can be brought fully into view.
6. Bag mode with all six current items owned exposes the same bounded list behavior; switching between buy/bag does not preserve an invalid old scroll offset or stale list height.
7. Calling `refresh()` after a buy or use rebuild does not preserve an invalid old scroll offset or stale list height in the same mode.
8. A buy-row activation still emits exactly the selected item id once; a bag-row activation still emits exactly the selected item id once; close still emits once.
9. `set_status()` still updates the fixed non-scrolling status region after a rebuild.
10. Current wrapped descriptions/effect/meta/action content does not create a new horizontal scrollbar at the declared 960px width.
11. Do not change item data, counts, prices/effects, settlement, save schema, gameplay, navigation, or NPC semantics.
12. Rendered PASS still requires actual Godot evidence on the exact review/integration SHA.

### Suggested verifier boundary
A future narrow verifier can instantiate ShopUI directly rather than booting Game, supply a lightweight inventory object compatible with the existing read methods, and exercise:
- logical 1280×720 and 960×540;
- buy mode with the six current catalog items;
- bag mode with all six items owned;
- last-row reachability after scrolling;
- fixed status/footer/close reachability;
- buy/use/closed signal forwarding;
- buy → bag → buy rebuilds with scroll reset and no stale measured height;
- same-mode `refresh()` after a simulated buy/use update with scroll reset and no stale measured height;
- `set_status()` after refresh while the list is scrolled, proving the status region remains outside the scroll owner and reachable.

The verifier should not modify inventory/gameplay state beyond the presentation-facing stub required to render rows.

## Files inspected
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `scripts/ui/` directory inventory
- `scripts/ui/ShopUI.gd`
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EndingUI.gd`
- `scripts/systems/Inventory.gd` (read-only content/count evidence)
- `scripts/Game.gd` (read-only ShopUI/DialogUI/EndingUI integration evidence)
- `scripts/Data.gd` (read-only dialogue-content pressure)
- `data/rules.json` (read-only ending-description pressure)
- `tools/` directory inventory (read-only verifier coverage)

## Validation
### Repository checks performed
- Confirmed UI-AUDIT-006 is still `READY`, owned by `scene-ui`, and report-only on the latest coordination branch.
- Confirmed the audit branch remains ahead 1 / behind 0 and differs only in `agent-reports/scene-ui.md` before this continuation update.
- Confirmed UI-FIX-001..005 remain held for exact-SHA rendered/runtime evidence and were excluded from write scope.
- Re-read all clean remaining UI helpers from the latest coordination branch rather than relying only on UI-AUDIT-005's prior ranking.
- Confirmed the current shop catalog still has exactly six ordered items and both buy/bag modes can render the same six-row maximum through existing code.
- Confirmed the proposed repair can preserve the current Game-facing ShopUI signal contract without editing Game.
- Re-read exact Game callsites and confirmed `open_buy`, `open_bag`, `refresh`, and `set_status` are all active integration surfaces; therefore same-mode refresh behavior belongs in the future acceptance contract.
- Checked the current coordination-branch `tools/` inventory and found no dedicated `verify_shop*` regression.

### Not performed
- Godot was not launched.
- No headless/windowed verifier was executed.
- No Web export/browser inspection was performed.
- No screenshot or rendered PASS is claimed.
- No production source, test, data, or coordination file was modified by this audit.

## Known risks / review notes
- Exact Control minimum-size negotiation, current-font wrapping, final row heights, and whether production copy already overflows at 960×540 require real Godot evidence; this audit does not fabricate that result.
- The fixed 660px horizontal minimum remains a separate responsive limitation below the declared 960px-width contract. Do not silently expand UI-FIX-006 into a full narrow/mobile row redesign.
- If a list ScrollContainer is introduced, `_rebuild()` and same-mode `refresh()` must explicitly avoid carrying a stale bottom scroll offset across buy/bag/refresh transitions.
- Header/status/footer should remain outside the scrolling list; moving the whole panel into a scroll region would recreate the historical stale-height/control-reachability problem documented in the source comment.

## Handoff
UI-AUDIT-006 is complete at repository-audit level and requests orchestrator review. The recommended next isolated Scene/UI repair is **UI-FIX-006 — Shop list vertical overflow containment** in `scripts/ui/ShopUI.gd`. Runtime/rendered acceptance remains deferred to real Godot execution.