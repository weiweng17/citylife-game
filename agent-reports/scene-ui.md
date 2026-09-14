# Scene/UI Agent Report

## Task
- ID: UI-CONTENT-008
- Agent: scene-ui
- Branch/worktree: `agent/ui-content-008-event-choice-readability`
- Status: NEEDS_REVIEW

## Scope
Pack A event-choice readability/presentation only.

Authorized writable paths:
- `scripts/ui/EventUI.gd`
- `tools/verify_event_choice_readability.gd`
- `agent-reports/scene-ui.md`

No Game, DialogUI, HUD, event data, NPC/content, LocationManager, coordination files, or `main` edits were made.

## Baseline handling
The assigned branch had no task-specific commits but was 5 commits behind the latest coordination branch. It was fast-forwarded without force to coordination baseline `58aea211ac66a27e6ff921f8a20d103d2c5f4f75` before implementation.

## Summary
Prepared EventUI for longer Pack A-style title/body/result/choice copy at 1280×720 and 960×540.

The implementation deliberately reuses the previously reviewed UI-FIX-004 presentation pattern instead of inventing another overflow model:
- event title stays fixed above the dynamic content region;
- body + choice buttons share one bounded vertical `EventScroll`;
- long choice buttons wrap inside the scroll region;
- result `ContinueButton` stays outside the scroll region and remains structurally reachable.

UI-CONTENT-008 adds the content-readability details needed by Pack A:
- long choices use smart wrapping, left alignment and a stable minimum hit height;
- full choice text remains available as tooltip text;
- long event headers also smart-wrap and preserve full text in a tooltip;
- choice/result rebuilds reset scroll immediately and deferred so old offsets do not leak;
- old choice nodes are removed from layout before `queue_free()`, preventing stale choice height from contaminating the result state.

## Production changes
### `scripts/ui/EventUI.gd`
- Added bounded panel constants and viewport-relative panel-height calculation.
- Added stable nodes:
  - `EventContent`
  - `EventHeader`
  - `EventScroll`
  - `EventScrollContent`
  - `EventBody`
  - `EventOptions`
  - `ContinueButton`
- `EventScroll` owns body + choices only:
  - vertical `SCROLL_MODE_AUTO`;
  - horizontal scrolling disabled;
  - `follow_focus = true`;
  - expand/fill sizing.
- `EventHeader` remains outside the scroll region and now smart-wraps; `show_event()` stores the complete header as tooltip text.
- Each generated choice button:
  - preserves supplied option index;
  - preserves enabled/disabled state;
  - smart-wraps;
  - left-aligns multi-line copy for scanning;
  - expands horizontally;
  - keeps a 38px minimum hit height;
  - exposes full choice text as tooltip text.
- `ContinueButton` remains outside `EventScroll` and is shown only in result state.
- `_clear_options()` removes children from `EventOptions` immediately before deferred free.
- `_reset_scroll()` sets scroll to 0 immediately and deferred.

## Preserved Game-facing contract
Read-only inspection of current `scripts/Game.gd` confirms the unchanged contract:
- `option_selected(index)` connects to `_choose_option`;
- `continue_requested` connects to `_close_event`;
- Game calls `show_event(...)` for ordinary events and encounters;
- Game calls `show_result(...)` after settlement;
- Game calls `close_event()` from continuation flow;
- `is_busy()` is used broadly for interact visibility, save/load/quit blocking, world-click blocking and activity/input locking.

UI-CONTENT-008 changes none of those public methods/signals or busy semantics.

## Pack A evidence used
Read-only inspection of accepted NPC-CONTENT-012 append commit `fe1625c7a302ac6fc0c902f55145772fa5521580` confirmed the new slice uses ordinary-life prose with 3 choices per event and longer title/body/result/choice copy than the oldest EventUI assumptions. No Pack A content object was edited here.

Important runtime boundary from the latest task board: Pack A runtime eligibility is still blocked behind GAME-CONTENT-014's non-year-advancing ordinary-city-event completion path. This task only makes EventUI presentation ready; it does not claim Pack A is triggerable yet.

## Narrow verifier
Added `tools/verify_event_choice_readability.gd`.

Prepared coverage:
1. 1280×720 long Pack A-style event presentation.
2. 960×540 same event after viewport resize.
3. Long header is preserved, smart-wrapped and keeps full tooltip text.
4. Event panel remains inside viewport and under its 340px maximum.
5. Long body is preserved and wrapped.
6. Dynamic body/choices use automatic vertical overflow and no horizontal scroll.
7. Exactly 3 deliberately long choice buttons remain present.
8. Choice text is preserved, smart-wrapped, left-aligned and tooltip-complete.
9. Stress choices expand beyond one-line minimum height and do not overlap each other.
10. Choice buttons stay horizontally contained by `EventScroll`.
11. Stress content creates a real vertical scroll range.
12. Final wrapped choice can be scrolled fully into view at 960×540.
13. One choice activation emits `option_selected` once and preserves a non-sequential supplied index.
14. Choice -> result removes old choices from layout immediately and resets scroll to top.
15. Long result copy scrolls while `ContinueButton` remains fixed outside the scroll owner.
16. Result header/tooltip resets to `结果`.
17. One Continue activation emits `continue_requested` once.
18. `close_event()` leaves busy=false and fabricates no signals.

## Validation
### Repository/static checks performed
- Re-read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and branch report.
- Confirmed task is `READY`, owner `scene-ui`, with exactly three writable paths.
- Fast-forwarded stale empty task branch to current coordination baseline before editing.
- Read current coordination `EventUI.gd` and previous UI-FIX-004 EventUI/verifier as read-only reference.
- Read accepted Pack A append diff for real content shape.
- Read current Game EventUI integration contract without modifying Game.
- Confirmed branch production/test diff stayed within authorized `EventUI.gd` + dedicated verifier before report update.

### Prepared but NOT run
Godot/headless command:

`godot --headless --path . --script res://tools/verify_event_choice_readability.gd`

Required rendered acceptance on the exact frozen integration SHA:
- 1280×720 and 960×540 long title/body/3-choice state;
- multi-line choices remain visually separated and fully readable;
- final choice is reachable by scroll;
- long result scrolls without moving/hiding Continue;
- choice -> result starts at top.

### Explicitly not performed
- Godot was not launched.
- The verifier was not executed.
- No Web export/browser run was performed.
- No screenshots were captured.
- No runtime/rendered PASS is claimed or inferred.

## Task commits before report update
- `df2ba2a29eb34cd9696c22f43ccd11341d409a29` — `ui: keep long event choices readable`
- `5377c826521462796ab7fe7ac378fdaee528c6d3` — `test: add Pack A event choice readability verifier`
- `286bc7aba89b66015ead1f16e7c7c441239985ed` — `ui: wrap long event headers`
- `0c0acb728ad724eb730248925dfc845329a515ac` — `test: cover long event header readability`

## Known risks / review notes
- Actual text wrapping, scrollbar geometry and visual density depend on real Godot font/layout metrics; QA-002 must validate the exact frozen SHA.
- The verifier intentionally uses longer copy than current Pack A so later content growth does not silently reintroduce clipped choices.
- This task does not resolve GAME-CONTENT-014 and does not make Pack A runtime-triggerable by itself.
- The fixed 340px maximum panel height is intentionally preserved from the earlier reviewed EventUI overflow direction rather than expanding the panel to consume more of the scene.

## Handoff
UI-CONTENT-008 is complete at repository implementation level and requests orchestrator review. If accepted, include `verify_event_choice_readability.gd` plus rendered 1280×720 / 960×540 checks in the single frozen QA-002 package. Pack A runtime triggering remains separately blocked by GAME-CONTENT-014.
