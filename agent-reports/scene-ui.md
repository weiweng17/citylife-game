# Scene/UI Agent Report

## Task
- ID: UI-AUDIT-004
- Agent: scene-ui
- Branch/worktree: `agent/ui-audit-004-responsive-hotspots`
- Status: NEEDS_REVIEW

## Scope
Repository-only responsive/presentation audit. Per the task contract, the only writable file is `agent-reports/scene-ui.md`.

Read-only inspection was allowed across the repository to identify the next smallest presentation-owned repair. No production scene/script/data/tool/workflow file was modified. `Game.gd`, `scripts/systems/LocationManager.gd`, gameplay settlement, NPC semantics, navigation, `main`, and `docs/agents/**` remained read-only.

## Summary
The next responsive risk is no longer the top HUD: UI-FIX-003 is already `NEEDS_REVIEW` and repository-accepted pending real rendered evidence. The same is true for the active-NPC and home-bed presentation tasks, so this audit deliberately avoids reopening those surfaces.

The current project targets a logical `1280×720` viewport with `window/stretch/mode="canvas_items"`. Several presentation helpers correctly resize their root Control to the visible viewport, but their internal content still relies on fixed heights, fixed minimum widths, or content-driven VBox growth without scroll/overflow ownership. That makes them the next responsive hotspots when content grows or the logical viewport becomes narrower/shorter.

Recommended next task: **Event panel overflow containment** in `scripts/ui/EventUI.gd` only. It is the smallest high-value repair because the panel is already explicitly clipped to a fixed 340px vertical band while its body and option list are dynamic and non-scrollable; an overflow can make choices or continuation controls unreachable rather than merely cosmetically compressed.

## Baseline repository evidence
- `project.godot`
  - logical viewport: `1280×720`;
  - stretch mode: `canvas_items`.
- `Data.gd`
  - current start screen has four origin cards;
  - origin descriptions and stat/bonus lines can wrap as width decreases.
- `data/events.json` / `Data.gd`
  - current events already include multi-line body copy and examples with three choices;
  - event/result copy is content-driven and can grow independently of the presentation helper.
- `Inventory.gd`
  - current shop catalog contains six display-order items;
  - item descriptions are sentence-length strings and ShopUI wraps them.

No runtime claim is inferred from these code/data facts.

## Ordered responsive hotspot inventory

### 1. EventUI fixed bottom panel can clip dynamic choices
- Priority: HIGH-MEDIUM
- Candidate file: `scripts/ui/EventUI.gd`
- Ownership risk: LOW. The repair can remain inside a directly presentation-owned UI helper. No `Game.gd`, EventSystem, event data, or location manager change should be required.
- Current contract:
  - EventUI root follows viewport size.
  - `EventPanel` uses `PRESET_BOTTOM_WIDE` with `offset_top = -350` and `offset_bottom = -10`, giving an approximately 340px fixed bottom band.
  - `panel.clip_contents = true`.
  - body text uses word wrapping and `custom_minimum_size.y = 100`.
  - `options_box` is a plain `VBoxContainer`; generated option buttons are appended directly.
  - continue button is below the option list in the same VBox.
- Failure mode:
  - longer narrative/result copy, more choices, larger font metrics, or a shorter logical viewport increases VBox minimum height while the outer panel stays fixed;
  - because the panel clips and there is no `ScrollContainer`, lower options or the continue button can be visually clipped and therefore effectively unreachable;
  - long option-button labels also have no explicit wrap/overrun contract.
- Current-content relevance:
  - the repository already has events with multi-line bodies and three-choice cases, so this is not purely hypothetical content growth;
  - the exact point at which current localized font metrics overflow requires Godot execution/rendering and is not claimed here.
- Minimal repair direction:
  - keep existing signals and public methods unchanged;
  - make the panel height viewport-aware within a bounded range;
  - give dynamic body/options content an explicit scrollable region while keeping the primary continuation/choice interaction reachable;
  - add a narrow regression later that injects long body copy plus several long options at 1280×720 and a declared narrower/shorter logical viewport.

### 2. StartUI full-screen VBox has no vertical overflow strategy
- Priority: MEDIUM
- Candidate file: `scripts/ui/StartUI.gd`
- Ownership risk: LOW. Presentation-only repair can remain in `StartUI.gd`; origin definitions in `Data.gd` do not need to change.
- Current contract:
  - root fills the visible viewport manually;
  - content is one plain `VBoxContainer` containing title, subtitle, every origin card, then the optional load button;
  - there is no `ScrollContainer` or bounded content region;
  - each origin description and stat/bonus label uses word wrapping.
- Failure mode:
  - the current four cards grow vertically when the viewport narrows because two text rows wrap more aggressively;
  - on a shorter desktop/Web viewport or larger effective font metrics, the last origin card and/or `读取上次存档` can fall below the visible viewport;
  - because the root is full-screen but the VBox has no scroll owner, resizing the root does not make the content itself responsive.
- Current-content relevance:
  - four origin cards already exist, so the vertical stack is substantial today;
  - normal 1280×720 fit has not been freshly rendered in this audit and is not claimed.
- Minimal repair direction:
  - keep the full-screen shell and origin-selection signals;
  - place the card stack in a centered, width-capped, vertically scrollable content region;
  - keep title/subtitle and load action reachable or intentionally part of the same scroll contract;
  - avoid changing `Data.ORIGINS` or selection semantics.

### 3. ShopUI has a hard 660px panel minimum and content-driven height
- Priority: MEDIUM
- Candidate file: `scripts/ui/ShopUI.gd`
- Ownership risk: LOW-MEDIUM. UI repair can stay in `ShopUI.gd`, but the helper reads `Inventory.gd`; inventory/catalog semantics should remain read-only.
- Current contract:
  - root, dim layer and center container follow viewport size;
  - `ShopPanel.custom_minimum_size = Vector2(660, 0)`;
  - panel height is allowed to grow directly from content;
  - comments explicitly defer adding a `ScrollContainer` until the catalog grows;
  - current catalog has six items;
  - each row also reserves fixed horizontal slices for effect text (`128px`), price/count (`56px`) and action button (`78px`) while the description wraps in the remaining space.
- Failure mode:
  - logical widths below the fixed panel minimum can force the centered panel outside the viewport;
  - narrower widths cause descriptions to wrap more, increasing every row height and therefore total panel height;
  - the six-row catalog plus title/status/footer can exceed shorter viewports, with no vertical scrolling path;
  - future catalog growth makes the known comment-level risk immediate.
- Current-content relevance:
  - six rows and wrapped sentence descriptions already exist; this is a present layout pressure, not only a future catalog concern.
- Minimal repair direction:
  - derive panel width from viewport with a desktop max width and safe side margins instead of an unconditional 660px minimum;
  - cap panel height to the viewport and put only the item-list region in a scroll owner;
  - preserve buy/use/close signals and Inventory semantics.

### 4. DialogUI owns a fixed 220px height but unbounded wrapped text
- Priority: MEDIUM-LOW
- Candidate file: `scripts/ui/DialogUI.gd`
- Ownership risk: LOW. Presentation-only helper; dialogue/NPC semantics need not change.
- Current contract:
  - panel width follows viewport minus 32px;
  - panel is positioned at `viewport_height - 230` with a fixed `220px` height;
  - text label wraps and has a `96px` minimum height;
  - no scroll, clipping, max-line, or text-overrun rule exists.
- Failure mode:
  - a long single dialogue line can make the VBox minimum height exceed the intended panel;
  - depending on Godot container minimum-size resolution, this can enlarge/overflow the panel or push the next button out of the intended bottom-band contract;
  - shorter viewports magnify the issue.
- Current-content relevance:
  - most current NPC dialogue lines are comparatively short, so the present risk is lower than EventUI/StartUI/ShopUI.
- Minimal repair direction:
  - define a bounded text viewport/scroll contract or a viewport-relative panel height while leaving `show_dialog`, `close_dialog`, and `dialog_finished` unchanged.

### 5. EndingUI has viewport-relative outer size but no inner overflow owner
- Priority: LOW
- Candidate file: `scripts/ui/EndingUI.gd`
- Ownership risk: LOW.
- Current contract:
  - outer panel uses fixed 28px horizontal / 90px vertical margins with minimum width 300 and minimum height 260;
  - description wraps and declares a 220px minimum height;
  - title + description + restart button all live in one plain VBox.
- Failure mode:
  - on short logical viewports the outer requested height can approach its minimum while the inner VBox minimum from the 220px description plus title/button can exceed it;
  - long ending prose has no scroll/overflow behavior.
- Current-content relevance:
  - endings are infrequent and normal desktop height gives substantially more room, so this is lower priority.
- Minimal repair direction:
  - cap the content column and make ending prose scrollable if it exceeds the available height; preserve restart behavior.

## Excluded / intentionally not recommended now
- `scripts/ui/HUD.gd`: UI-FIX-003 is already `NEEDS_REVIEW` with repository-level acceptance; do not create a competing responsive branch before its real Godot evidence is collected.
- `scripts/systems/LocationManager.gd`: high-conflict and explicitly outside this audit's target repair boundary. Header/action/travel layout work there would need a separately authorized task.
- Home bed presentation: UI-FIX-002 remains pending rendered evidence; do not stack more bed edits without screenshots.
- Active NPC presentation: UI-FIX-001 remains pending rendered evidence; do not stack more NPC visual integration edits without runtime evidence.
- `Game.gd` UI nodes such as toast/interact setup were not selected because the task explicitly asks for a next repair that avoids gameplay/shared coordination surfaces.

## Recommended next minimal task
### UI-FIX-004 — Event panel overflow containment
- Owner: scene-ui
- Suggested branch: `agent/ui-fix-004-event-panel-overflow`
- Suggested priority: MEDIUM
- Suggested writable paths:
  - `scripts/ui/EventUI.gd`
  - one narrow `tools/verify_*.gd` regression if explicitly granted
  - `agent-reports/scene-ui.md`
- Explicitly forbidden:
  - `scripts/Game.gd`
  - `scripts/systems/LocationManager.gd`
  - event/gameplay systems
  - `data/events.json`
  - navigation/NPC semantics
- Objective:
  - make EventUI own its vertical overflow so long narrative/result copy and multiple choices cannot be silently clipped out of reach as viewport/content size changes.
- Suggested acceptance:
  1. public signals and methods remain unchanged;
  2. event panel stays inside the logical viewport at 1280×720 and at one smaller declared desktop/Web viewport;
  3. long body/result content has an explicit bounded scroll/overflow path;
  4. all enabled choice buttons and the continue control remain reachable;
  5. no event conditions/effects/results or gameplay settlement semantics change;
  6. repository regression is prepared, but rendered visual PASS waits for actual Godot evidence.
- Why this one first:
  - one directly-owned UI file;
  - no overlap with UI-FIX-001/002/003 implementation paths except the shared Scene/UI report lifecycle;
  - failure can block user choice rather than only degrade appearance;
  - existing code already marks the dangerous boundary through a fixed-height clipped panel and dynamic option VBox.

## Files inspected
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `project.godot`
- `scripts/ui/StartUI.gd`
- `scripts/ui/EventUI.gd`
- `scripts/ui/ShopUI.gd`
- `scripts/ui/DialogUI.gd`
- `scripts/ui/EndingUI.gd`
- `scripts/Data.gd`
- `data/events.json`
- `scripts/systems/Inventory.gd`
- `tools/` directory inventory, read-only, to check for obvious existing task-specific responsive regressions.

## Validation
### Repository checks performed
- Confirmed UI-AUDIT-004 is `READY`, owned by `scene-ui`, and is report-only.
- Confirmed task branch started identical to the current orchestrator baseline `26919477e86fabda1094f3955b0a570028c63a86` (ahead 0 / behind 0).
- Tied every ranked hotspot to an exact current repository path and an observable fixed-size/overflow contract in source.
- Separated current content pressure from future growth risk.
- Avoided recommending files currently awaiting rendered acceptance where practical.

### Not performed
- Godot was not launched.
- No headless or windowed regression was executed.
- No Web export/browser inspection was performed.
- No screenshot or rendered PASS is claimed.
- No claim is made that any listed hotspot currently fails visually at 1280×720; the report identifies repository-visible risk contracts to prioritize for targeted runtime verification/repair.

## Known risks / review notes
- Godot container minimum-size behavior can make some fixed-size conflicts appear as expansion instead of clipping. Exact visual manifestation must be confirmed in Godot; the repository evidence here is the absence of a bounded overflow owner, not a fabricated screenshot result.
- `canvas_items` stretching means physical browser/window size and logical viewport size are not interchangeable. Future responsive regressions should explicitly manipulate/assert the logical viewport contract, as learned during UI-FIX-003.
- A future localization pass could increase text pressure substantially; the recommended fixes should solve layout ownership rather than hard-code current Chinese string lengths.

## Handoff
UI-AUDIT-004 is complete at repository-audit level and requests orchestrator review. The next recommended isolated repair is UI-FIX-004 on `scripts/ui/EventUI.gd` only, with real Godot evidence required before any rendered acceptance.