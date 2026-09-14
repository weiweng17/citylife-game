# Scene/UI Agent Report

## Task
- ID: UI-FIX-007
- Agent: scene-ui
- Branch/worktree: `agent/ui-fix-007-dialog-body-overflow`
- Status: NEEDS_REVIEW

## Scope
Player-visible DialogUI readability infrastructure for CONTENT-WAVE-01.

Authorized writable paths from the task board:
- `scripts/ui/DialogUI.gd`
- `tools/verify_dialog_panel_overflow.gd`
- `agent-reports/scene-ui.md`

No Gameplay, content/data, LocationManager, save, held UI-FIX files, coordination files, or `main` edits were made.

## Summary
Implemented bounded body-only overflow for the fixed-height bottom dialog.

The existing 220px dialog placement/size contract is preserved. Only the wrapped dialogue body now lives inside `DialogBodyScroll`; speaker and `继续` / `结束` remain outside the scroll region and therefore remain structurally reachable when a single line becomes very long.

Every `_render()` resets body scroll to the top, covering both:
- next-line progression after reading/scolling a long line;
- reopen through `show_dialog()`.

`close_dialog()` also resets the scroll state while preserving the existing lifecycle contract.

## Production changes
### `scripts/ui/DialogUI.gd`
- Added `body_scroll: ScrollContainer`.
- Named stable presentation nodes for narrow verification:
  - `DialogContent`
  - `DialogSpeaker`
  - `DialogBodyScroll`
  - `DialogText`
  - `DialogNext`
- `DialogBodyScroll` owns only the body text and uses:
  - vertical `SCROLL_MODE_AUTO`;
  - horizontal `SCROLL_MODE_DISABLED`;
  - `follow_focus = true`;
  - horizontal + vertical expand/fill.
- Preserved body wrapping and its existing 96px minimum.
- Added `_reset_body_scroll()` with immediate + deferred `scroll_vertical = 0` so layout completion cannot retain the previous line's bottom offset.
- `_render()` still renders exactly `str(_lines[_index])` and preserves button copy:
  - `继续` before final line;
  - `结束` on final line.
- `is_busy()` remains exactly presentation-driven by `visible`; scrolling and intermediate line progression do not alter busy state.
- Final activation still calls `close_dialog()` then emits `dialog_finished` once.

## Preserved Game-facing contract
Repository inspection from UI-AUDIT-007 established that Game uses `DialogUI.is_busy()` broadly for:
- interact-button visibility;
- save/load/quit gating;
- world-click blocking;
- LocationManager/activity input blocking.

UI-FIX-007 does not alter that contract. While the dialog is visible—including while the body is scrolled and while moving between lines—`is_busy()` remains true. It becomes false only after `close_dialog()` / final completion hides the dialog.

No Game callsite change is required.

## Narrow verifier
Added `tools/verify_dialog_panel_overflow.gd`.

Prepared coverage:
1. Logical 1280x720 with ordinary short two-line dialogue.
2. Existing 220px panel-height contract remains.
3. Ordinary short text does not expose needless vertical scrolling.
4. Speaker stays above/outside the body scroll region.
5. Continue/end action stays below/outside the body scroll region.
6. `继续` / `结束` copy remains unchanged.
7. Intermediate next activation keeps `is_busy() == true` and does not emit `dialog_finished`.
8. Final activation closes the dialog and emits exactly once for that completed sequence.
9. Logical 960x540 with an intentionally very long repeated single string that deterministically forces vertical overflow.
10. Long body exposes a usable vertical scroll range.
11. Scrolling to the bottom does not move speaker or continue action.
12. Scrolling does not alter Game-facing busy semantics.
13. Long-line -> next short line resets body scroll to top.
14. `close_dialog()` leaves busy=false and does not fabricate a completion signal.
15. Close/reopen with another long line starts at top again.
16. Reopened final line completes with one final emission.
17. No Game, content/data, relationship, clue, navigation or save source is loaded for mutation.

The stress text is intentionally repeated 12 times so the verifier does not depend on a marginal font-width assumption to create overflow.

## Validation
### Repository/static checks performed
- Re-read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and branch report before editing.
- Confirmed UI-FIX-007 is `READY`, owner `scene-ui`, with exactly the three writable paths listed above.
- Confirmed the task branch's starting `DialogUI.gd` blob matched the latest coordination `DialogUI.gd` blob (`61c2d8b561ebcba1cf21706eccc2a2a5a1a32adb`) before implementation.
- Cross-checked the scroll/layout pattern against the already reviewed EventUI implementation: body content owns vertical auto scrolling while primary action remains outside the scroll owner.
- After production/verifier commits, compared against the latest coordination branch: ahead 3 / behind 0 before this report update, with only `scripts/ui/DialogUI.gd` and `tools/verify_dialog_panel_overflow.gd` changed.

### Prepared but NOT run
Godot/headless command:

`godot --headless --path . --script res://tools/verify_dialog_panel_overflow.gd`

Required final rendered acceptance on the exact frozen integration SHA:
- 1280x720: ordinary dialogue reads naturally; speaker/body/action hierarchy is visually correct.
- 960x540: long body scrolls inside the middle region only; speaker and action remain visible/reachable.
- Scroll-to-bottom -> next-line visibly starts at top.
- Close/reopen visibly starts at top.

### Explicitly not performed
- Godot was not launched by this web worker.
- The verifier was not executed.
- No Web export or browser run was performed.
- No screenshot/rendered PASS is claimed.
- No runtime PASS is inferred from source inspection.

## Commits before report update
- `9ebfcf866e3e8b949eccd5aa63dcc540103a1804` — `fix: contain dialog body overflow`
- `5f1e4d3831007a131fbbd20d2342447a4f6575f7` — `test: add DialogUI overflow verifier`
- `6e14b0f3da2245f55ef90f6e345cc0f5fb07a1bd` — `test: harden DialogUI overflow stress case`

## Known risks / review notes
- Final visual quality and actual scrollbar behavior depend on real Godot font/layout metrics and therefore remain QA-002 exact-SHA work.
- The production change intentionally does not redesign the fixed 220px dialog, typography, theme, queue semantics or content. It only assigns overflow ownership to the body.
- The verifier deliberately tests a much longer body than current Chinese copy so CONTENT-WAVE-01 can safely grow dialogue/event prose without relying on today's content length.

## Handoff
UI-FIX-007 is complete at repository implementation level and requests orchestrator review. If repository review accepts the scope, final acceptance still requires real exact-SHA Godot/headless plus rendered 1280x720 and 960x540 evidence through QA-002.