# Scene/UI Agent Report

## Task
- ID: UI-AUDIT-007
- Agent: scene-ui
- Branch/worktree: `agent/ui-audit-007-next-presentation-hotspot`
- Status: NEEDS_REVIEW

## Scope
Repository-only audit for the next unlocked presentation hotspot after ShopUI.

Per the task board, the only writable path for UI-AUDIT-007 is `agent-reports/scene-ui.md`. Production UI, Gameplay, LocationManager, NPC/content, save semantics, held UI-FIX files, `main`, and `docs/agents/**` remained read-only.

UI-FIX-001 through UI-FIX-006 remain blocked on exact-SHA runtime/rendered evidence and were not reopened.

## Summary
The next smallest independent presentation repair should be **DialogUI body overflow containment** in `scripts/ui/DialogUI.gd`.

The recommendation is intentionally narrow:
- keep the current bottom-dialog placement and 220px panel-height contract;
- keep speaker and `继续` / `结束` action outside the overflow region;
- give only the wrapped dialogue body an explicit bounded vertical overflow path;
- preserve `show_dialog()`, `close_dialog()`, `is_busy()`, line-by-line progression, and the single `dialog_finished` signal contract;
- do not edit Game dialogue queues, NPC/content data, events, clues, relationship settlement, or navigation.

## Repository evidence
### Current unlocked candidate set
With UI-FIX-001..006 held, the clean presentation-owned helpers left for this audit are primarily:
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EndingUI.gd`

Shared HUD/Event/Start/Shop presentation files are held by earlier UI-FIX tasks. Gameplay-owned UI assembly in `scripts/Game.gd` and LocationManager-owned surfaces are explicitly outside the writable boundary.

### Chosen candidate — `scripts/ui/DialogUI.gd`
Exact layout evidence:
- `_sync_viewport()` always assigns the dialog a fixed height of `220.0` while placing it near the bottom of the logical viewport.
- `_build_ui()` creates one `VBoxContainer` containing, in order:
  1. `speaker_label`
  2. wrapped `text_label`
  3. `next_button`
- `text_label` uses `AUTOWRAP_WORD_SMART` and has `custom_minimum_size = Vector2(0, 96)`, but there is no `ScrollContainer`, clipping owner, maximum line count, or other bounded text region.
- The action button therefore participates in the same minimum-size negotiation as arbitrary wrapped text. If one dialogue line grows because of copy length, localization, font metrics, or accessibility/text scaling, the body can claim more vertical minimum height and compete directly with the continue/end action inside a panel whose height remains fixed at 220px.
- `_render()` shows exactly one `lines[_index]` entry at a time. This makes the responsive repair especially narrow: overflow handling can be isolated to the body text without changing dialogue sequencing.

### Real Game integration contract
Read-only inspection of `scripts/Game.gd` confirms:
- Game creates one `DialogUIScript` instance.
- Game connects only `dialog_ui.dialog_finished` into `_on_dialog_finished()`.
- `_show_dialog(speaker, lines)` forwards the speaker and line array directly to `dialog_ui.show_dialog(...)`.
- `_on_dialog_finished()` performs the existing NPC/clue completion work and then pops the next queued dialogue, if any.

Therefore a presentation-only body overflow repair does not require any Game callsite change as long as `show_dialog()`, `close_dialog()`, `is_busy()`, button progression, and one final `dialog_finished` emission remain unchanged.

### Current content pressure
Read-only inspection of `scripts/Data.gd` confirms dialogue is already content-driven and includes multiple sources:
- dream intro lines;
- tutorial lines;
- age/state-specific NPC lines;
- dark-line variants and queued dialogue.

Current Chinese lines are generally short enough that this audit does **not** claim an existing rendered clip at 960×540. The defect is the missing containment contract: arbitrary wrapped line height is allowed to compete with the fixed action path in a fixed-height panel.

This matters because the UI helper is generic and its public contract accepts any `Array` of strings; it has no presentation-side bound for a longer future/localized line.

## Why DialogUI before EndingUI
`EndingUI.gd` has a similar structural weakness—wrapped description and restart action share one VBox with no independent overflow owner—but its present pressure is lower:
- `_sync_viewport()` gives EndingUI a viewport-relative height (`viewport.y - 180`, floored at 260), so at 960×540 the panel is approximately 360px high rather than a fixed 220px.
- `desc_label` has a 220px minimum, but current `data/rules.json` has substantial prose only for the three dark-path endings; most other ending `desc` values are currently empty.
- Game composes reason + ending description + lifetime summary, so EndingUI remains a valid later candidate, but its current content frequency/pressure is lower than the generic high-frequency DialogUI.

DialogUI is therefore the smaller next repair: one helper file, one text region, one existing action button, and no data/queue changes.

## Recommended next task
### UI-FIX-007 — Dialog body overflow containment
- Owner: scene-ui
- Suggested branch: `agent/ui-fix-007-dialog-body-overflow`
- Suggested priority: LOW / MEDIUM
- Suggested writable paths:
  - `scripts/ui/DialogUI.gd`
  - one narrow `tools/verify_dialog_panel_overflow.gd` if explicitly granted
  - `agent-reports/scene-ui.md`
- Explicitly out of scope:
  - `scripts/Game.gd`
  - `scripts/Data.gd`
  - NPC/content/event files
  - clue/relationship/queue semantics
  - HUD/Event/Start/Shop/held UI files
  - LocationManager/navigation/save changes

### Suggested objective
Keep the existing bottom dialog panel bounded while allowing only the wrapped dialogue body to overflow vertically, so speaker and `继续` / `结束` remain reachable even for a deliberately long single dialogue line.

### Suggested acceptance
1. Preserve public signal exactly: `dialog_finished`.
2. Preserve public methods and behavior: `show_dialog(speaker, lines)`, `close_dialog()`, `is_busy()`.
3. Preserve one-line-at-a-time `_index` progression and button copy (`继续` until the final line, `结束` on the final line).
4. Speaker remains outside the body scroll region and visible.
5. Continue/end action remains outside the body scroll region and reachable.
6. A deliberately long wrapped line exposes a usable vertical body scroll path rather than increasing the whole dialog beyond its bounded panel.
7. Moving to the next dialogue line resets body scroll to the top so a previous long line does not leak its offset into the next line.
8. Closing and reopening a dialogue also starts the body at the top.
9. Exactly one final activation emits `dialog_finished`; intermediate next presses do not emit it.
10. No Game queue, NPC/content, clue, relationship, save, navigation, or held-UI semantics change.
11. Rendered PASS still requires actual Godot evidence on the exact review/integration SHA.

### Suggested verifier boundary
A future narrow verifier can instantiate `GameDialogUI` directly and exercise:
- 1280×720 and 960×540 logical viewports;
- a normal multi-line dialogue sequence;
- one deliberately long single string that forces real wrapped-body overflow;
- speaker/action containment while body scrolls;
- long-line scroll -> next-line reset;
- close/reopen reset;
- `继续` / `结束` copy and exactly-once `dialog_finished` behavior.

It should not boot Game or mutate any dialogue/content source.

## Files inspected
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EndingUI.gd`
- `scripts/Game.gd` (read-only integration evidence)
- `scripts/Data.gd` (read-only dialogue-content evidence)
- `data/rules.json` (read-only ending-content comparison)

## Validation
### Repository checks performed
- Confirmed UI-AUDIT-007 is `READY`, owned by `scene-ui`, and report-only.
- Confirmed the assigned branch started identical to the latest coordination baseline `96a202796d5b454f730bf84c566367e8564db7f4` (ahead 0 / behind 0).
- Confirmed UI-FIX-001..006 are runtime/rendered holds and excluded from write scope.
- Re-read the remaining clean helpers from the latest coordination branch rather than relying on the prior audit ranking.
- Confirmed DialogUI progression/finished semantics are presentation-local and Game consumes only the final `dialog_finished` notification.
- Confirmed EndingUI currently has more viewport height and lower present prose pressure, making it the later candidate.

### Not performed
- Godot was not launched.
- No verifier was created or executed because UI-AUDIT-007 is report-only.
- No Web export/browser inspection was performed.
- No screenshot or rendered PASS is claimed.
- No production source, test, data, or coordination file was modified by this audit.

## Known risks / review notes
- Current production Chinese dialogue may fit the declared desktop/Web viewports with current font metrics; this audit does not claim a rendered failure that was not observed.
- The repository-visible defect is the lack of a bounded text-overflow owner inside a fixed-height generic dialog helper.
- Future implementation should scroll only the text body. Making the entire dialog scroll would make the speaker/action path less stable and would be broader than necessary.
- Future implementation must reset body scroll whenever `_render()` advances to a new line, not only when `show_dialog()` first opens.

## Handoff
UI-AUDIT-007 is complete at repository-audit level and requests orchestrator review. The recommended next isolated Scene/UI repair is **UI-FIX-007 — Dialog body overflow containment** in `scripts/ui/DialogUI.gd`. Runtime/rendered acceptance remains deferred to real Godot execution.