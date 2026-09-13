# Scene/UI Agent Report

## Task
- ID: UI-FIX-004
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-004-event-panel-overflow`
- Status: NEEDS_REVIEW

## Scope
Contain EventUI vertical overflow without changing event/gameplay semantics.

Authorized writable paths from the task board:
- `scripts/ui/EventUI.gd`
- one narrow `tools/verify_*.gd` regression if needed
- `agent-reports/scene-ui.md`

`Game.gd`, `scripts/systems/LocationManager.gd`, event data, EventSystem/gameplay settlement, NPC semantics, navigation, `main`, and `docs/agents/TASK_BOARD.md` remained read-only.

## Summary
UI-FIX-004 is complete at repository/layout-contract level and ready for orchestrator review.

The previous EventUI used a fixed ~340px bottom panel with `clip_contents = true`, while wrapped narrative text, a dynamic option VBox, and the result continue button all shared the same unbounded VBox. If content minimum height exceeded the panel, lower controls could be clipped instead of gaining an explicit overflow path.

The repair keeps the public EventUI API and event semantics unchanged while making overflow ownership explicit:
1. Event panel height is bounded against the current logical viewport instead of being permanently tied to one fixed top offset.
2. Dynamic narrative text and option buttons live inside `EventScroll`, a vertical `ScrollContainer` with horizontal scrolling disabled.
3. `follow_focus = true` allows focused choice buttons to be brought into view by the scroll owner.
4. Long option labels use word wrapping and a stable minimum action height instead of forcing horizontal width growth.
5. Full option text is retained in each button tooltip.
6. The result `ContinueButton` stays outside the scroll region, so long result prose cannot push the primary continuation action below the panel.
7. Option removal detaches children from `EventOptions` immediately before queue-freeing them, avoiding stale temporary layout height when switching to result view.
8. Event/result transitions reset vertical scroll position to the top without changing signals or settlement behavior.
9. Continuation hardening extends the narrow regression beyond proving a scroll range exists: at 960×540 it now drives the scroll owner to its bottom limit and verifies that the final enabled stress option becomes fully visible inside `EventScroll`.

## Files changed
- `scripts/ui/EventUI.gd`
  - adds viewport-owned panel height constants;
  - adds `EventScroll` / `EventScrollContent` as the dynamic overflow owner;
  - keeps the header and result continue action outside dynamic scrolling where appropriate;
  - wraps long choice labels and preserves full text in tooltips;
  - immediately removes old option nodes from layout before queue-free.
- `tools/verify_event_panel_overflow.gd`
  - narrow headless-prepared EventUI-only regression;
  - injects long narrative copy plus eight long enabled options;
  - checks default 1280×720 and smaller 960×540 logical viewports;
  - verifies panel containment, explicit vertical scroll range, horizontal containment, option preservation/wrapping, and result continue-button reachability;
  - explicitly scrolls the 960×540 stress case to the bottom and verifies the final enabled choice becomes fully visible.
- `agent-reports/scene-ui.md`
  - this review request.

No gameplay/data/shared-manager file was modified.

## Repository-verified contract
- Task branch started identical to orchestrator baseline `ecb3b9331ef1b94095529a083c12636e47983176` (ahead 0 / behind 0).
- Existing public signals are unchanged:
  - `option_selected(index: int)`
  - `continue_requested`
- Existing public methods are unchanged:
  - `show_event(...)`
  - `show_result(...)`
  - `close_event()`
  - `is_busy()`
- Event option `index`, `enabled`, and text values are still consumed only for presentation/forwarding; conditions/effects/results are not modified here.
- At the normal 720px logical height the bounded formula preserves the previous ~340px panel height.
- At a shorter logical viewport the panel shrinks within top/bottom safe margins instead of preserving a fixed 340px vertical band.
- Dynamic body/options content has one vertical scroll owner; result continuation remains structurally outside that scroll owner.
- The prepared regression now tests actual bottom-of-list reachability instead of treating scrollbar existence alone as proof that all enabled choices can be reached.

## Validation
### Performed in this web worker
- Re-read the latest `TASK_BOARD`, `FILE_OWNERSHIP`, `WEB_AGENT_LAUNCHPAD`, current task report and branch comparison before continuation.
- Confirmed UI-FIX-004 remains `READY` on the orchestrator board while this worker report is already `NEEDS_REVIEW`; no new orchestrator rework finding or scope expansion was present.
- Confirmed branch remained ahead of and not behind `orchestrator/multi-agent-bootstrap` before continuation.
- Re-read the current EventUI and narrow verifier for repository-visible layout/API consistency.
- Identified one remaining acceptance-evidence gap: previous verifier proved all choices existed and a vertical scroll range existed, but did not actually prove the last enabled choice could be brought into the visible scroll area.
- Extended only the existing authorized verifier to set the narrow EventScroll to its bottom range, wait for layout settlement, and verify the final stress option is fully visible.
- Production `EventUI.gd` was not changed during this continuation.

### Not performed
- Godot was **not** launched.
- `tools/verify_event_panel_overflow.gd` was **not** executed.
- Browser/Web export/runtime inspection was **not** executed.
- No screenshot or rendered PASS is claimed.

### Prepared headless command
Run on the exact review SHA in a Godot 4.7.2-capable environment:

`godot --headless --path . --script res://tools/verify_event_panel_overflow.gd`

The regression explicitly sets/asserts the logical viewport rather than assuming physical window size equals logical layout size. It now also proves the bottom-most enabled choice can be made visible by the scroll owner before transitioning to the result-view checks.

### Required rendered evidence before visual PASS
On the exact review SHA, inspect EventUI at 1280×720 and 960×540 logical viewports with intentionally long content. Confirm:
1. EventPanel remains fully inside the viewport with the expected side/bottom margins.
2. Header remains visible while long body/choice content scrolls vertically.
3. All choice buttons can be reached by scrolling/focus and long choice text wraps without horizontal overflow.
4. The last choice is fully reachable at the bottom of the scroll range in the 960×540 stress case.
5. Switching from choices to a long result removes old choices immediately.
6. Long result prose scrolls while `ContinueButton` remains visible/clickable inside the panel.
7. Background/shade presentation still fills the EventUI root when a background is supplied.
8. Selecting an option and continuing still emit the same signals and preserve normal event flow.

## Known risks / review notes
- This web worker did not execute Godot, so actual Control minimum-size negotiation, scrollbar metrics, focus-driven scrolling and font wrapping remain runtime acceptance items.
- The chosen smaller contract is 960×540 desktop/Web. Mobile layouts are not claimed by this task.
- The outer panel still uses clipping defensively, but normal dynamic overflow should be owned by `EventScroll`; rendered evidence should confirm no unexpected child escapes the scroll contract.
- Option text wrapping can increase individual button height by design. The vertical scroll region is intended to absorb that growth rather than truncating choices or increasing panel height.
- The new bottom-scroll reachability assertion is prepared repository evidence only; it is not a claimed runtime result until Godot executes the script.

## Commits
- `989764669c047344a6da1fbf6fc4a7fa9829b7b7` — `fix: contain event panel overflow`
- `10c2d26471a08ba58ff615c04d28db695f4f2d4d` — `test: guard event panel overflow contract`
- `ba7b5f2c61407b017695de628c23839525c21937` — `test: keep EventUI verifier dynamically typed`
- `a372d3684a690dc7ee21f6d76ade5a8cc13b00e1` — `test: prove final event choice remains reachable`

## Handoff
UI-FIX-004 remains ready for orchestrator review at repository level. The implementation is isolated to EventUI presentation plus one task-specific regression, and the prepared verifier now covers concrete final-choice reachability in addition to overflow existence. Do not mark rendered visual acceptance complete until the prepared Godot regression and real 1280×720 / 960×540 EventUI captures pass on the exact review SHA.
