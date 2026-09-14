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

## Baseline handling
The assigned branch initially had no unique commits but was 11 commits behind the current coordination branch. Before implementation it was safely fast-forwarded to the latest `orchestrator/multi-agent-bootstrap` baseline `d415ecf165fc6c90d5abf42e5929745d1739acf4`; no force update or semantic reconstruction was required.

## Summary
Implemented bounded body-only overflow for the fixed-height bottom dialog.

The existing 220px dialog placement/size contract is preserved. Only the wrapped dialogue body now lives inside `DialogBodyScroll`; speaker and `继续` / `结束` remain outside the scroll region and therefore remain structurally reachable when a single line becomes very long.

Every `_render()` resets body scroll to the top, covering both next-line progression and every `show_dialog()` reopen. `close_dialog()` also clears the scroll position without fabricating a completion signal.

## Production changes
### `scripts/ui/DialogUI.gd`
- Added `body_scroll: ScrollContainer`.
- Added stable presentation node names used by the narrow verifier:
  - `DialogContent`
  - `DialogSpeaker`
  - `DialogBodyScroll`
  - `DialogText`
  - `DialogNext`
- `DialogBodyScroll` owns only body text and uses:
  - vertical `SCROLL_MODE_AUTO`;
  - horizontal `SCROLL_MODE_DISABLED`;
  - `follow_focus = true`;
  - horizontal + vertical expand/fill.
- Preserved smart body wrapping and the prior 96px body minimum.
- Added `_reset_body_scroll()` with immediate plus deferred `scroll_vertical = 0`, preventing a long line's old bottom offset from leaking into the next line after layout recalculates.
- `_render()` still renders exactly `str(_lines[_index])` and preserves button copy:
  - `继续` before final line;
  - `结束` on final line.
- `is_busy()` remains `visible`-driven.
- Final activation still closes the dialog then emits `dialog_finished` once.

## Preserved Game-facing contract
UI-FIX-007 does not change `scripts/Game.gd` or dialogue/content data.

The preserved public contract is:
- signal: `dialog_finished`;
- methods: `show_dialog(speaker, lines)`, `close_dialog()`, `is_busy()`;
- one supplied array entry shown at a time;
- intermediate next presses do not emit completion;
- the final activation closes first and emits completion once;
- programmatic `close_dialog()` does not emit completion.

This keeps the existing Game-facing busy/queue semantics intact without requiring any caller edits.

## Narrow verifier
Added and hardened `tools/verify_dialog_panel_overflow.gd`.

Prepared coverage now includes:
1. 1280×720 ordinary two-line dialogue.
2. Existing 220px panel-height contract.
3. Ordinary short text does not expose needless vertical scrolling.
4. Speaker stays above/outside the body scroll region.
5. Continue/end action stays below/outside the body scroll region.
6. `继续` / `结束` copy remains unchanged.
7. Intermediate next activation keeps `is_busy() == true` and emits no `dialog_finished`.
8. Final activation closes and emits once for that completed sequence.
9. **1280×720 deliberately long body** must exceed the bounded middle region, expose a real vertical scroll range, preserve source text, and keep speaker/action outside the scroll owner.
10. Resize the same open long dialogue to **960×540** and require the same containment/overflow contract there.
11. At 960×540, scroll the body to its usable bottom and verify only body content moves; speaker and continue action keep the same global rects.
12. Bottom reachability is checked against the vertical bar's usable end rather than only asserting a non-zero offset.
13. Long-line -> next short line resets body scroll to top.
14. `close_dialog()` leaves busy=false and does not fabricate a completion signal.
15. Close/reopen with another long line starts at top again.
16. Reopened final line completes with one final emission.
17. No Game, content/data, relationship, clue, navigation or save source is mutated by the verifier.

The stress line repeats a long Chinese paragraph 12 times so overflow does not depend on a marginal font-width assumption.

## Validation
### Repository/static checks performed
- Re-read latest `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, `WEB_AGENT_LAUNCHPAD.md` and branch report before implementation.
- Confirmed UI-FIX-007 is `READY`, owned by `scene-ui`, with exactly the three writable paths used here.
- Detected the assigned branch was stale (ahead 0 / behind 11) and fast-forwarded it to the current coordination baseline before editing.
- Re-read current `scripts/ui/DialogUI.gd` after the fast-forward and preserved its public API/220px placement contract.
- Verified the branch diff after implementation remains limited to the three authorized paths.
- Static inspection confirms the overflow owner contains only `DialogText`; `DialogSpeaker` and `DialogNext` are siblings outside it.
- Static inspection confirms scroll reset is called from both `_render()` and `close_dialog()`.

### Prepared but NOT run
Godot/headless command:

`godot --headless --path . --script res://tools/verify_dialog_panel_overflow.gd`

Required final rendered acceptance on the exact frozen integration SHA:
- 1280×720: ordinary and deliberately long dialogue remain visually bounded; long body scrolls only in the middle region.
- 960×540: the same long body remains bounded; speaker and continue/end action remain visible/reachable.
- Scroll-to-bottom -> next-line visibly starts at top.
- Close/reopen visibly starts at top.

### Explicitly not performed
- Godot was not launched by this web worker.
- The verifier was not executed.
- No Web export or browser run was performed.
- No screenshot/rendered PASS is claimed.
- No runtime PASS is inferred from source inspection.

## Task commits
- `9ebfcf866e3e8b949eccd5aa63dcc540103a1804` — `fix: contain dialog body overflow`
- `5f1e4d3831007a131fbbd20d2342447a4f6575f7` — `test: add DialogUI overflow verifier`
- `6e14b0f3da2245f55ef90f6e345cc0f5fb07a1bd` — `test: harden DialogUI overflow stress case`
- `fc94583b9e490638ef176a4f08f00c6b2f552e55` — `test: cover long dialog at both viewports`

## Known risks / review notes
- Final scrollbar behavior, typography, clipping and visual quality depend on actual Godot font/layout metrics; those remain QA-002 exact-SHA work.
- The production change intentionally does not redesign the fixed 220px dialog, theme, typography, dialogue queue, or content. It only assigns overflow ownership to the body.
- The verifier deliberately stresses copy far beyond current Chinese dialogue length so CONTENT-WAVE-01 can grow prose without making button reachability depend on today's content.

## Handoff
UI-FIX-007 is complete at repository implementation level and requests orchestrator review. Final acceptance still requires real exact-SHA Godot/headless plus rendered 1280×720 and 960×540 evidence through QA-002.