# Scene/UI Agent Report

## Task
- ID: UI-FIX-006
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-006-shop-list-overflow`
- Status: NEEDS_REVIEW

## Scope
Contain ShopUI vertical list overflow without changing inventory/gameplay semantics.

Authorized writable paths from the task board:
- `scripts/ui/ShopUI.gd`
- `tools/verify_shop_panel_overflow.gd`
- `agent-reports/scene-ui.md`

Forbidden/high-conflict files such as `scripts/Game.gd`, `scripts/systems/Inventory.gd`, UI-FIX-001..005 files, `main`, and `docs/agents/**` remained read-only.

## Summary
UI-FIX-006 is complete at repository/layout-contract level and ready for orchestrator review.

The previous ShopUI placed title, subtitle, the entire dynamic item list, status, and footer/close in one unbounded VBox. Buy mode always renders the six catalog rows and bag mode can also render all six owned rows. Because the list had no vertical overflow owner, row growth competed directly with the status/footer/close region.

The repair keeps the existing ShopUI public API and gameplay-facing signals while narrowing overflow ownership to the list only:
1. `ShopList` now lives inside `ShopListScroll`.
2. `ShopListScroll` owns automatic vertical scrolling and explicitly disables horizontal scrolling.
3. Title/subtitle remain above the scroll region.
4. Status/footer/close remain below and outside the scroll region, so the exit/control path is not part of list scrolling.
5. `ShopPanel` receives a viewport-relative height target capped for the declared desktop/Web window: 620px max, with 48px total viewport margin; at 960×540 the target is 492px.
6. `open_buy()`, `open_bag()`, and visible `refresh()` rebuild the existing rows and reset list scroll to the top synchronously plus deferred, avoiding stale offsets after layout settles.
7. Buy/bag data flow, item order, prices/effects/counts, action labels, settlement ownership, and signals remain unchanged.
8. Stable presentation-only node names were added for the task-specific verifier; they do not change external semantics.

## Files changed
### `scripts/ui/ShopUI.gd`
- adds `ShopListScroll` around only `ShopList`;
- keeps header/status/footer outside the scroll owner;
- gives the centered panel a viewport-relative vertical target while preserving the existing 660px minimum width contract;
- preserves both `buy` and `bag` modes;
- resets list scroll after every rebuild, including same-mode `refresh()`;
- names title/subtitle/footer/close/rows/actions and empty state for deterministic verification;
- does not alter inventory data or gameplay callbacks.

### `tools/verify_shop_panel_overflow.gd`
Narrow headless-prepared ShopUI-only regression that:
- instantiates ShopUI directly instead of booting Game;
- uses a read-only presentation stub matching `owned_items()`, `total_count()`, and `count()`;
- checks logical 1280×720 and 960×540 viewport contracts;
- checks the centered ShopPanel remains inside the declared viewport;
- checks only the list owns vertical scrolling;
- checks status/footer/close remain outside the list scroll region and inside the panel;
- checks all six buy rows and all six bag rows remain present;
- scrolls to the bottom and verifies the final catalog row can become fully visible;
- checks buy/use signals still emit exactly the selected item id once;
- recreates the real Game presentation call order `refresh() -> set_status()` and verifies same-mode rebuild resets scrolling while status remains fixed;
- checks buy -> full bag and empty bag -> buy rebuilds reset scroll position;
- directly covers the historical tall-list -> empty-bag stale-height/stale-range risk;
- checks close emits once and closes the UI.

### `agent-reports/scene-ui.md`
This review handoff.

## Repository-verified contract
- Task branch started identical to orchestrator baseline `86ea90c9742b31c8d562199f873ea0d0a6ca5a95` (ahead 0 / behind 0).
- Public signals remain exactly:
  - `buy_requested(item_id: String)`
  - `use_requested(item_id: String)`
  - `closed`
- Public methods remain available and behaviorally compatible:
  - `open_buy(money_value, inventory)`
  - `open_bag(money_value, inventory)`
  - `is_open()`
  - `refresh(money_value, inventory)`
  - `set_status(text)`
  - `close()`
- Buy mode still iterates `InventoryScript.DISPLAY_ORDER` in the existing order.
- Bag mode still uses only the supplied inventory object's `owned_items()`, `total_count()`, and `count()` data.
- Buy/use buttons still forward the same item id through the existing signals; ShopUI still does not mutate money/inventory/effects itself.
- The existing 660px panel minimum width remains intentionally unchanged; sub-660px horizontal redesign is outside this task.

## Validation
### Performed in this web worker
- Read the latest `TASK_BOARD`, `FILE_OWNERSHIP`, `WEB_AGENT_LAUNCHPAD`, branch report, current ShopUI source, branch comparison, and the previous narrow UI verifier style before editing.
- Confirmed UI-FIX-006 is `READY`, owned by `scene-ui`, and grants exactly ShopUI + `verify_shop_panel_overflow.gd` + Scene/UI report.
- Confirmed the task branch was identical to the latest coordination baseline before implementation.
- Re-read the edited ShopUI and verifier for public API preservation, node paths, list-only overflow ownership, rebuild reset behavior, and signal forwarding.
- Extended the verifier after static review to cover the historical six-row/tall-list -> empty bag stale-height scenario rather than testing only full buy/full bag states.
- Before this report update, branch diff was ahead 4 / behind 0 and limited to the two authorized implementation/verification paths.

### Not performed
- Godot was **not** launched.
- `tools/verify_shop_panel_overflow.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No screenshot or rendered PASS is claimed.

### Prepared headless command
Run on the exact review/integration SHA in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_shop_panel_overflow.gd`

### Required rendered evidence before final PASS
On the exact review/integration SHA, inspect ShopUI at logical 1280×720 and 960×540 and confirm:
1. ShopPanel remains fully inside the visible logical viewport.
2. Title/subtitle stay fixed above the list.
3. Status/footer/close stay fixed below the list and remain reachable while the list is scrolled.
4. Buy mode shows all six current catalog rows through the bounded list region; the final row is reachable.
5. A bag containing all six catalog items has the same bounded behavior and final row reachability.
6. Switching from a tall/full list to an empty bag does not preserve an old scrollbar range, blank tall area, or bottom scroll offset.
7. Same-mode refresh after buying/using an item returns the rebuilt list to the top; the subsequent status message remains visible outside the scroll region.
8. No horizontal scrollbar is needed at the declared 960px width and row descriptions remain visually sane.
9. Buy/use/close interactions preserve existing gameplay flow.

## Known risks / review notes
- This web worker did not execute Godot, so actual Container minimum-size negotiation, font wrapping, scrollbar metrics, click hit rectangles, and deferred reset timing remain runtime acceptance items.
- The panel-height strategy relies on `ScrollContainer` absorbing the dynamic child minimum height on the scrolling axis; real Godot execution must prove that the centered panel stays at the intended bounds at both declared viewports.
- The fixed 660px width remains a known limitation for narrower/mobile layouts and was intentionally not expanded into this task.
- `ShopStatus` remains wrapped and outside the scroll region. Current gameplay status strings are expected to fit the declared viewports, but unusually large future status copy could become a separate pressure source.
- The verifier intentionally requires the current six-row catalog to produce a real vertical overflow range at 960×540; if exact Godot font/container metrics make all six rows fit without scrolling, review should treat that assertion as a verifier calibration issue rather than inventing a gameplay/layout regression.

## Commits
- `03450f4e3e2a5b3f2c25070fd9822d15b443b9c4` — `fix: contain ShopUI list overflow`
- `02c2750922c48a94680b8f1c3589ff176604dc38` — `test: guard ShopUI list overflow contract`
- `420ef6e898249443a29df530af959935f24cbb0f` — `test: expose ShopUI empty state for regression`
- `8ad997db18af46f8370dd7c7751379faebf68fc4` — `test: cover ShopUI empty-bag rebuild`

## Handoff
UI-FIX-006 is ready for orchestrator repository review. The code change is isolated to ShopUI presentation plus one task-specific verifier. Do not mark final/rendered acceptance complete until the prepared verifier and actual 1280×720 / 960×540 rendered checks pass on the exact review/integration SHA.
