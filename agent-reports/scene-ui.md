# Scene/UI Agent Report

## Task
- ID: UI-FIX-005
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-005-start-screen-overflow`
- Status: NEEDS_REVIEW

## Scope
Contain StartUI vertical overflow without changing start/origin/save/gameplay semantics.

Authorized writable paths from the task board:
- `scripts/ui/StartUI.gd`
- `tools/verify_start_screen_overflow.gd`
- `agent-reports/scene-ui.md`

`Game.gd`, `Data.gd`, save/gameplay systems, navigation, NPC logic, `main`, and `docs/agents/TASK_BOARD.md` remained read-only.

## Summary
UI-FIX-005 is complete at repository/layout-contract level and ready for orchestrator review.

The previous StartUI resized its outer `PanelContainer` to the logical viewport, but title, subtitle, all origin cards, and the optional load button lived in one unbounded `VBoxContainer`. Four wrapped cards plus the trailing load action therefore had no explicit vertical overflow owner when logical height shrank or wrapped text grew.

The repair keeps the existing public API and Game callsite contract while making vertical overflow explicit:
1. `setup(origins, money_formatter)` still builds the entire presentation before the node enters the scene tree.
2. `StartScroll` is now the bounded vertical owner; vertical scrolling is automatic and horizontal scrolling is disabled.
3. `StartContent` keeps title, subtitle, all supplied origin cards, and the optional load action in one ordered stack.
4. Origin descriptions/stat lines keep word wrapping, while the scroll container absorbs resulting height growth instead of letting lower controls fall outside the viewport.
5. Origin cards retain their full-card overlay button and still emit the supplied origin dictionary through `origin_selected`.
6. `set_load_available(value)` still works after `_ready()` and dynamically toggles the existing load button.
7. `open()` resets the scroll position to the top so a StartUI instance reused after restart does not inherit a previous run's bottom-of-list position.
8. `open()`, `close()`, `load_requested`, and the existing viewport synchronization remain behaviorally compatible.

## Files changed
- `scripts/ui/StartUI.gd`
  - adds `StartScroll` / `StartContent` as the explicit vertical overflow path;
  - preserves pre-tree `setup()` construction;
  - disables horizontal scrolling and enables automatic vertical scrolling;
  - names origin cards/hit targets for stable task-specific verification;
  - preserves wrapped descriptions/stat lines and exact origin forwarding;
  - resets scroll to top whenever the reused start screen is opened.
- `tools/verify_start_screen_overflow.gd`
  - narrow headless-prepared StartUI-only regression;
  - calls `setup()` before `add_child()` to match the real Game lifecycle;
  - checks 1280×720 and 960×540 logical viewport contracts;
  - uses four stress-shaped origins to force a real vertical scroll range;
  - verifies all four cards stay present and horizontally contained;
  - toggles the load action after `_ready()` and verifies visibility remains safe;
  - scrolls to the bottom and verifies the fourth card plus load button become fully visible;
  - activates the fourth card and load action and checks signal counts/payload forwarding;
  - closes/reopens after bottom scrolling and verifies the reused start screen resets to the top.
- `agent-reports/scene-ui.md`
  - this review request.

No gameplay/data/shared-manager file was modified.

## Repository-verified contract
- Task branch started identical to orchestrator baseline `e60060cd559c46ff73af81354fafa50e3a8a7245` (ahead 0 / behind 0).
- Existing public signals remain unchanged:
  - `origin_selected(origin: Dictionary)`
  - `load_requested`
- Existing public methods remain available and compatible:
  - `setup(origins, money_formatter)`
  - `open()`
  - `close()`
  - `set_load_available(value)`
- `setup()` still creates the complete hierarchy before `_ready()` / `add_child()`, matching the current `Game.gd` initialization order.
- `set_load_available()` still mutates the already-created button after the node is ready, matching both initial start-screen presentation and later save-availability refreshes.
- Origin dictionaries are not copied or rewritten by the presentation path; the button callback continues to forward the supplied dictionary.
- The outer StartUI still manually follows the visible logical viewport through `_sync_viewport()`.
- Dynamic content now has one explicit vertical overflow owner rather than relying on the outer full-screen panel to absorb all minimum-height growth.

## Validation
### Performed in this web worker
- Read the latest `TASK_BOARD`, `FILE_OWNERSHIP`, `WEB_AGENT_LAUNCHPAD`, task-branch report, current StartUI source, branch comparison, and existing regression style before editing.
- Confirmed UI-FIX-005 is `READY`, owned by `scene-ui`, and grants exactly StartUI + the named narrow regression + Scene/UI report.
- Confirmed the assigned branch was identical to the latest coordination baseline before implementation.
- Re-read the edited StartUI and verifier for node paths, public API preservation, lifecycle order, logical viewport handling, and signal forwarding.
- Hardened verifier timing so layout is inspected only after the hidden StartUI is opened and container layout has had frames to settle.
- Added an explicit post-`setup()` dictionary mutation in the verifier so the origin callback must still observe the supplied dictionary rather than a setup-time copy.
- Added reopen/reset coverage after recognizing that introducing scroll state could otherwise leak the previous run's bottom position into a restarted start screen.
- Before this report update, branch diff was limited to the two authorized implementation/verification paths and was ahead 5 / behind 0.

### Not performed
- Godot was **not** launched.
- `tools/verify_start_screen_overflow.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No screenshot or rendered PASS is claimed.

### Prepared headless command
Run on the exact review SHA in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_start_screen_overflow.gd`

The regression explicitly sets/asserts the logical viewport via the root window's content scale size and size rather than assuming physical window dimensions equal layout dimensions.

### Required rendered evidence before visual PASS
On the exact review SHA, inspect StartUI at 1280×720 and 960×540 logical viewports. Confirm:
1. The dark StartUI panel remains fully inside/fills the intended logical viewport.
2. Title/subtitle and origin cards remain horizontally contained with no horizontal scrollbar dependency.
3. At 960×540, long/wrapped content has a usable vertical scrollbar and all four cards are reachable.
4. When load is available, `读取上次存档` can be reached at the bottom of the scroll path and remains clickable.
5. Card description/stat text wraps cleanly without forcing horizontal overflow.
6. Clicking each card still behaves as one full-card action and emits the intended origin.
7. Hiding/showing the load action after the UI is ready does not leave stale spacing or break scrolling.
8. Closing and reopening/restarting the start screen begins at the top rather than preserving an old bottom scroll offset.
9. Selecting an origin and loading a save preserve the existing Game flow.

## Known risks / review notes
- This web worker did not execute Godot, so actual Control minimum-size negotiation, scrollbar metrics, font wrapping, input hit rectangles, and deferred scroll reset remain runtime acceptance items.
- The smaller declared contract is 960×540 desktop/Web; mobile layouts are not claimed.
- The verifier uses deliberately long current-shape origin copy to force overflow. It does not claim that the current production four-card copy necessarily overflows at 1280×720.
- Horizontal scrolling is intentionally disabled. Rendered evidence should confirm the wrapped labels and current font metrics keep cards inside the available width at both declared viewports.
- Resetting scroll on `open()` is presentation-only and restores the intuitive pre-scroll behavior for a reused StartUI; runtime review should confirm it does not interfere with any desired focus behavior.

## Commits
- `87191bca02ad344b43dcd30d763bccdc50bb0f1a` — `fix: contain start screen vertical overflow`
- `95f2417516270d3830648689834d173b6256b2ec` — `test: guard start screen overflow contract`
- `f8905d9faf5401832a4b4b3044428d0486b52f59` — `test: stabilize StartUI layout verification`
- `5267d07de304c0da3e75198c8784bb0059772dc6` — `fix: reset reused start screen scroll`
- `332f9c0a09468ac3ce7c3c91c6d212fc3f2688d0` — `test: cover StartUI reopen scroll reset`

## Handoff
UI-FIX-005 is ready for orchestrator review at repository level. The implementation is isolated to StartUI presentation plus one task-specific regression. Do not mark rendered visual acceptance complete until the prepared Godot regression and real 1280×720 / 960×540 StartUI captures pass on the exact review/integration SHA.
