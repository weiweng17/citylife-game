# NPC/Content Agent Report

## Task
- ID: NPC-001
- Agent: npc-content
- Branch/worktree: `agent/npc-001-content-audit`
- Requested status: NEEDS_REVIEW
- Audited coordination ref: `orchestrator/multi-agent-bootstrap` at `7e3deba4fd9d51b706729261432ef8e57658f966`

## Scope
Repository audit only. NPC scripts/scenes/data/assets were treated as read-only for this task. The only modified file is this report.

The task board remains orchestrator-owned. This worker does not edit `docs/agents/TASK_BOARD.md` and does not write to `main`.

## Summary
The current repository has a coherent six-NPC content set with schedule, relationship, story, quest and verification plumbing. This is **not primarily a missing-NPC-definition problem**: all six core IDs exist in `scripts/Data.gd`, all six have entries in `data/npc_schedules.json`, and all six have static sprite resources.

The highest player-facing risk is presentation. The formal independent-location experience renders NPCs as static `Button` + `TextureRect` entities even though walk resources exist for all six. This conflicts with the iteration-plan wording that Phase 3 NPC "行走/交谈" is code-complete: the repository supports finding/clicking/talking, but current formal NPC entities do not actually walk or animate.

The next major content risk is system/content separation that is too loose in a few places: relationship tiers do not change the normal dialogue pool, dark disclosures are age-gated rather than trust-gated, random events cannot condition on per-NPC relationships, and one quest narrates giving a gift to 小雨 while mechanically checking only a generic store purchase.

A newly confirmed schedule-attachment gap is that `data/npc_schedules.json` contains per-entry `pos` coordinates, and `NPCScheduleSystem` returns them, but the formal independent-location path drops those coordinates. `LocationManager` instead uses its own `NPC_LOCATION_POS` table. Therefore changing an NPC schedule `pos` in content data will not move that NPC in the formal location scenes.

## Core NPC inventory
| ID | Name / role | Scheduled locations | Base dialogue | Dark clue | Visual resources |
| --- | --- | --- | --- | --- | --- |
| `chenjie` | 陈姐 / 便利店老板娘 | convenience_store/store 07:00-23:00 | young/mid/old, 3 lines each | yes, age 33+ | `npc_chenjie.png`, `npcwalk_chenjie.png`, prototype hi-res candidate |
| `laozhang` | 老张 / 公司老同事 | office; subway evening | young/mid/old, 3 lines each | yes, age 40+ | `npc_laozhang.png`, `npcwalk_laozhang.png` |
| `laozhou` | 老周 / 公园下棋老人 | park morning/afternoon; hidden in storm | young/mid/old, 3 lines each | yes, age 45+ | `npc_laozhou.png`, `npcwalk_laozhou.png` |
| `daoshi` | 疯道士 / 巷子里的怪人 | old_alley/alley 18:30-04:30 | young/mid/old, 3 lines each | yes, age 25+ | `npc_daoshi.png`, `npcwalk_daoshi.png` |
| `xiaoyu` | 小雨 / 合租室友 | home morning/evening/night | young/mid/old, 3 lines each | yes, age 30+ | `npc_xiaoyu.png`, `npcwalk_xiaoyu.png`, prototype hi-res candidate |
| `azhe` | 阿哲 / 地铁站卖唱的 | subway; cafe 12:00-14:00 | young/mid/old, 3 lines each | yes, age 38+ | `npc_azhe.png`, `npcwalk_azhe.png` |

Repository-side, no core NPC is missing from the content definition or schedule table.

## Findings

### P1 — Formal NPC presentation is static; existing walk resources are unattached
**Player impact:** high. This directly matches the reported "贴纸感 / 没有嵌入感" symptom.

The formal experience uses the independent-location path. `Game.gd` keeps the legacy single-world path hidden by default and synchronizes current-location NPCs into `LocationManager`.

`LocationManager._add_npc_entity()` builds NPC presentation around a flat `Button`, a `TextureRect`, a ground shadow and a hover label. It does not create an `AnimatedSprite2D`, idle/walk state, facing state, local pathing or motion.

- `xiaoyu` and `chenjie` load prototype walk sheets, but `_npc_texture()` returns only an `AtlasTexture` using `Rect2(0, 0, frame_size, frame_size)`, i.e. one frame.
- `laozhang`, `laozhou`, `azhe`, and `daoshi` load `npc_<id>.png` static fallback sprites.
- Walk assets exist for all six under `assets/sprites/npcwalk_<id>.png`, but the formal independent-location renderer does not reference them.
- The legacy `scenes/world/NPC.tscn` + `scripts/world/NPC.gd` path is also static and is not the formal default experience.

**Exact files:**
- `scripts/Game.gd`
- `scripts/systems/LocationManager.gd`
- `scenes/world/NPC.tscn`
- `scripts/world/NPC.gd`
- `scripts/world/WorldManager.gd`
- `assets/sprites/npcwalk_azhe.png`
- `assets/sprites/npcwalk_chenjie.png`
- `assets/sprites/npcwalk_daoshi.png`
- `assets/sprites/npcwalk_laozhang.png`
- `assets/sprites/npcwalk_laozhou.png`
- `assets/sprites/npcwalk_xiaoyu.png`
- `assets/characters/sprites/prototype/chenjie_walk_candidate.png`
- `assets/characters/sprites/prototype/xiaoyu_walk_candidate.png`

**Recommended owner / next task:** Scene/UI + orchestrator. Fix the current `LocationManager` presentation path first. Do not spend the first repair pass polishing only legacy `NPC.tscn`, because that will not change the formal independent-location experience.

### P1 — Iteration-plan acceptance language overstates current NPC movement
`docs/ITERATION_PLAN.md` marks Phase 3 as "代码完成，待人工验收" and lists `NPC 行走/交谈` in the stage scope. The same plan records NPC entity/hotspot/dialogue completion, but the formal entity code is static as described above.

**Risk:** later agents may assume NPC walking is already implemented and limit testing to click/talk behavior, leaving the most visible presentation gap unowned.

**Recommended owner / next task:** Orchestrator/Scene-UI task wording should explicitly say the current accepted code covers schedule hotspot + talk/relationship logic, while actual NPC idle/walk animation remains a follow-up visual implementation and manual acceptance item.

### P1 — Dialogue presentation removes most NPC visual identity
`scripts/ui/DialogUI.gd` is a generic text panel: speaker label, body text and Continue/End button. It has no NPC portrait, expression state, contextual portrait crop, per-character presentation or location-aware dialogue composition. Once dialogue opens, NPC identity is mostly reduced to the speaker name/title text.

**Exact file:** `scripts/ui/DialogUI.gd`

**Recommended owner / next task:** Scene/UI, with NPC/content supplying portrait/expression/content requirements if the orchestrator authorizes the necessary presentation data.

### P1 — Quest `q3_someone_waits` narrates a gift to 小雨 but only checks a generic store purchase
The quest step says `路过便利店，给她带一样东西`, but its implementation is `counter: store_buy >= 1`. `QuestSystem` checks the counter only. There is no selected item, recipient, gift handoff, inventory removal or 小雨 reaction bound to this step.

Historical `tools/verify_quests.gd` intentionally confirms that a purchase while q3 is active advances this step. That validates the current mechanic, but also proves the narrative/mechanical mismatch is structural rather than a random runtime bug.

**Exact files:**
- `data/quests.json`
- `scripts/systems/QuestSystem.gd`
- `scripts/Game.gd` store-purchase notification path
- likely future dependency: `scripts/systems/Inventory.gd`

**Recommended owner / next task:** Gameplay + NPC/content. Either implement a real NPC gift/handoff step, or rewrite the quest line so it honestly describes buying something on the way home without claiming delivery occurred.

### P2 — Schedule position data is detached from the formal independent-location renderer
`NPCScheduleSystem._state_for()` reads each schedule entry's `pos` and returns it as `position`. The legacy `WorldManager` path can consume schedule position state.

In the formal path, however, `Game._sync_location_npcs()` uses schedule state only to test visibility and location. The object passed to `LocationManager.set_visible_npcs()` contains `id`, `name` and relation `note`, but not schedule `position`. `LocationManager` then places the NPC from a second table, `NPC_LOCATION_POS`.

**Consequence:**
- content edits to `data/npc_schedules.json` `pos` values do not move NPCs in formal independent locations;
- NPC location/time live in content data while visual position lives in code;
- the two sources can silently drift, especially when a scheduled location is visually re-composed.

**Exact files:**
- `data/npc_schedules.json`
- `scripts/systems/NPCScheduleSystem.gd`
- `scripts/Game.gd` (`_sync_location_npcs`)
- `scripts/systems/LocationManager.gd` (`NPC_LOCATION_POS`, `set_visible_npcs`)

**Recommended owner / next task:** Scene/UI + gameplay architecture review. Keep per-background grounding positions presentation-owned if necessary, but make the source of truth explicit. Either remove misleading unused schedule positions from the formal content contract or pass/transform them deliberately. Avoid creating a third coordinate table.

### P2 — Relationship tiers do not change the normal dialogue pool
`NpcRelations.gd` defines meaningful tiers (`0/20/45/70`) and gives +4 only on the first completed conversation each day. However, `Data.npc_lines()` selects normal dialogue only by age bucket (`young/mid/old`). `StorySystem.build_npc_dialog()` does not use the relation tier to select ordinary lines.

A player working toward relation 20 or 45 can therefore see the same three-line age bucket repeatedly before the relationship milestone is reached. The number changes, but the person does not progressively sound more familiar.

**Exact files:**
- `scripts/Data.gd`
- `scripts/systems/NpcRelations.gd`
- `scripts/systems/StorySystem.gd`
- `scripts/Game.gd` direct-dialog flow

**Recommended owner / next task:** NPC/content after the orchestrator approves a low-conflict content shape. Add relationship-tier variants or a small anti-repeat/rotation layer without changing the global save schema unless necessary.

### P2 — Dark-story trust is age-gated, not relationship-gated
`StorySystem.build_npc_dialog()` appends a core NPC's dark conversation when `Data.dark_ready()` passes and that clue has not yet been claimed. `Data.dark_ready()` checks age. It does not require acquaintance/familiar/friend status.

Result: a player can reach an age threshold, talk to an otherwise-stranger NPC and immediately receive intimate supernatural testimony. This underuses the relationship system and weakens the sense that trust was earned.

**Exact files:**
- `scripts/Data.gd`
- `scripts/systems/StorySystem.gd`
- `scripts/systems/NpcRelations.gd`

**Recommended owner / next task:** NPC/content + gameplay review. Consider a relation floor per dark clue, with a safe fallback so clues cannot become permanently missable.

### P2 — Random events / encounters cannot react to NPC relationships
`EventSystem.cond_ok()` supports money, health, mood, skill, network, age, job, flags and origins, but not per-NPC relationship values. `EncounterSystem` reuses those conditions and adds location/time/weather/clue gates.

Therefore events cannot currently branch on conditions such as "老张 is familiar" or "小雨 is a friend" without new condition plumbing.

**Exact files:**
- `scripts/systems/EventSystem.gd`
- `scripts/systems/EncounterSystem.gd`
- `data/events.json`
- `data/encounters.json`

**Recommended owner / next task:** Gameplay owns condition-schema changes; NPC/content can author relation-aware variants after that plumbing exists.

### P2 — `events.json` contains an ambiguous 老张 introduction disconnected from the core 老张 relationship
An event result says `病房里你认识了老张。你们约好出院后一起去钓鱼。` The core NPC `laozhang` is already "公司老同事". This event result does not update `relations["laozhang"]`, establish an identity flag or reconcile whether this is the same person.

**Risk:** if intended to be the same 老张, it can contradict an existing relationship; if intended to be a different 老张, the duplicate name creates avoidable ambiguity.

**Exact file:** `data/events.json`

**Recommended owner / next task:** NPC/content. Rename the generic hospital character, or explicitly make it a relation-aware core-老张 event once relation-aware event conditions exist.

### P3 — Two NPC presentation paths increase repair risk
There is a legacy world NPC scene/script path (`scenes/world/NPC.tscn`, `scripts/world/NPC.gd`, `scripts/world/WorldManager.gd`) and a separate formal independent-location renderer inside `scripts/systems/LocationManager.gd`.

**Risk:** an agent can "fix NPCs" in the legacy scene and see no change in the current game, wasting iterations and creating diverging behavior.

**Recommended owner / next task:** Orchestrator should label the legacy path explicitly as compatibility-only in future repair briefs, then later decide whether to retire it after the independent-location migration stabilizes.

## Repository-verified strengths / non-bugs
These items were inspected so already-fixed behavior is not incorrectly reported as broken:

- Six core NPC definitions exist in `scripts/Data.gd`.
- Six core schedule entries exist in `data/npc_schedules.json`.
- Schedule time/location logic has explicit store/alley aliases in `Game.gd` (`convenience_store -> store`, `old_alley -> alley`).
- 老周 and 阿哲 have storm-hide schedule rules in data; `NPCScheduleSystem` has `hide_in_weather` handling.
- Direct NPC click is connected through `LocationManager.npc_requested` to `Game._on_location_npc_requested()` and `_talk_to()`.
- Relationship settlement is deliberately deferred until dialogue completion, avoiding affinity gain from opening/abandoning a conversation.
- Relationship and talk-day state live inside `GameState`, so the current relationship system does not require a separate top-level save payload key.
- `QuestSystem.validate()` exists and checks duplicate IDs, broken `next` links and unknown step types.

## Repair order
1. **P1 visual integration:** animate/ground NPCs in the current `LocationManager` path using existing resources; validate scale, feet anchor, shadow, z/depth, lighting and click target in every scheduled location.
2. **P1 dialogue presentation:** give direct conversations stronger NPC identity while keeping content logic separate from UI.
3. **P1 quest semantic fix:** make `q3_someone_waits` either a real gift handoff or honest non-gift prose.
4. **P2 coordinate/source-of-truth cleanup:** resolve `npc_schedules.json.pos` versus `LocationManager.NPC_LOCATION_POS` so content and presentation cannot silently drift.
5. **P2 relationship-aware dialogue:** add familiarity-specific lines / anti-repeat behavior so repeated days feel like a developing relationship.
6. **P2 trust/content integration:** gate dark disclosures by relationship in a non-deadlocking way.
7. **P2 relation-aware events:** extend event conditions, then author event/encounter variants tied to core NPC relationships; resolve the ambiguous hospital "老张" line.
8. **P3 cleanup:** document/retire the legacy NPC rendering path after current-scene behavior is stable.

## Proposed non-overlapping follow-up tasks
### NPC-CONTENT follow-up
**Scope:** content-only after schema/logic dependencies are decided.
- Expand ordinary NPC lines by familiarity tier or define a relation-aware dialogue content shape.
- Define dark-clue trust thresholds and fallback text.
- Resolve duplicate/ambiguous 老张 copy.
- Rewrite q3 copy if gameplay chooses not to implement real gifting.

Likely files: `scripts/Data.gd` and/or explicitly assigned narrative data only. Do not change shared schemas without orchestrator approval.

### SCENE/UI follow-up
**Scope:** presentation only.
- Replace static formal NPC entity presentation with idle/walk-capable rendering in the active independent-location path.
- Validate feet anchors, shadow, scale, occlusion, lighting, clickable bounds and dialogue identity presentation.
- Reconcile visual-position ownership for `NPC_LOCATION_POS` versus schedule data.

Likely files: `scripts/systems/LocationManager.gd`, `scripts/ui/DialogUI.gd`, NPC visual resources only if explicitly assigned. `LocationManager.gd` is high-conflict and requires explicit orchestrator assignment.

### GAMEPLAY follow-up
**Scope:** condition/interaction semantics.
- Decide/implement relation-aware event conditions.
- Decide whether q3 gets a real `gift_to_npc` mechanic and recipient/inventory semantics.
- If dark clues become relation-gated, guarantee no deadlock/missable-clue regression.

Likely files: `scripts/systems/EventSystem.gd`, `QuestSystem.gd`, inventory/game coordination files only under an explicit task contract.

### QA/Codex acceptance follow-up
**Scope:** runtime/manual validation only after fixes.
- Scheduled NPC presence in every time window/location.
- Storm hiding for 老周/阿哲.
- NPC animation/grounding/occlusion and click hitboxes.
- Relationship progression 0→20→45→70 with visible content differences.
- q3 semantics and dark-clue trust flow.

## Files inspected
### Coordination / current-state docs
- `HANDOFF.md`
- `docs/ARCHITECTURE.md`
- `docs/ITERATION_PLAN.md`
- `docs/QA_2026-09-13.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `docs/agents/MASTER_PLAN.md`
- `docs/agents/TASK_BOARD.md`
- `docs/agents/AGENT_RULES.md`
- `docs/agents/FILE_OWNERSHIP.md`

### NPC/content runtime and data
- `scripts/Data.gd`
- `scripts/Game.gd` (read-only coordination glue)
- `scripts/systems/NPCScheduleSystem.gd`
- `scripts/systems/NpcRelations.gd`
- `scripts/systems/StorySystem.gd`
- `scripts/systems/EventSystem.gd`
- `scripts/systems/EncounterSystem.gd`
- `scripts/systems/QuestSystem.gd`
- `scripts/systems/LocationManager.gd` (read-only presentation dependency)
- `scripts/world/NPC.gd`
- `scripts/world/WorldManager.gd`
- `scripts/ui/DialogUI.gd`
- `scenes/world/NPC.tscn`
- `data/npc_schedules.json`
- `data/quests.json`
- `data/events.json`
- `data/encounters.json`
- NPC resources under `assets/characters/` and `assets/sprites/`

### Verification assets inspected
- `tools/verify_npc.gd`
- `tools/verify_quests.gd`
- `tools/capture_npc.gd` (existence/scope only)
- `tools/capture_quest.gd` (existence/scope only)

## Validation
### Performed in this web audit
- GitHub repository inspection only; no Godot process, terminal, Web export or browser runtime was executed.
- Confirmed the NPC/data/schedule/presentation paths described above from the current coordination ref.
- Confirmed the worker branch is based directly on the current coordination ref and differs only in `agent-reports/npc-content.md` before this refresh.
- Confirmed `tools/verify_npc.gd` covers schedule presence, hotspot-to-dialog signal flow, delayed relationship settlement, daily limit, next-day gain, tier milestone feedback, hotspot label/tooltip tier refresh and save round-trip.
- Confirmed `tools/verify_quests.gd` covers quest content validation, idempotence, full-chain completion, real settlement notifications and save round-trip.

### Historical runtime evidence (not rerun by this agent)
`docs/QA_2026-09-13.md` records prior local Godot runs:
- `verify_npc.gd`: **8 groups, 0 failures** at historical HEAD `53a06cb`; the recorded full regression set was green at that point.
- `verify_quests.gd`: **6 groups, 0 failures** at historical HEAD `4709122`; the recorded 14-suite regression set was green at that point.
- Rendered `capture_npc.gd` and `capture_quest.gd` screenshots were historically produced according to the QA document.

These are useful evidence that relationship/quest wiring previously worked, but they are **not fresh acceptance evidence for the current coordination HEAD**. Phase 3 also still has an explicit manual-play acceptance gap in `docs/ITERATION_PLAN.md`.

## Runtime/manual checks still required
- Visit every scheduled NPC at in-window and out-of-window times.
- Verify storm hiding for 老周 and 阿哲.
- Verify the displayed NPC position against each independent-location background; specifically test that editing/using schedule `pos` is not assumed to affect formal placement until the dual-source issue is resolved.
- Verify NPC feet/shadow/occlusion, scale and lighting against scene geometry.
- After animation work, confirm no first-frame crop/static fallback remains and that click targets still match visible characters.
- Talk across relation thresholds 0→20→45→70 and judge whether dialogue feels repetitive before content expansion.
- Verify q3 gift semantics and dark-clue trust behavior after their respective fixes.
- Run the Phase 3 manual play path called out in `docs/ITERATION_PLAN.md`: NPC find/talk, relationship/skill affecting later choices, task flow, HUD text length and progression feel.

## Known issues / risks
- The top visual fix crosses `scripts/systems/LocationManager.gd`, a shared high-conflict file; NPC-content is not authorized to edit it in NPC-001.
- Dialogue UI repair belongs to Scene/UI ownership.
- Relation-aware event conditions and a true NPC gift mechanic require gameplay/schema work before content can safely depend on them.
- The schedule-position dual source can mislead future content edits unless the task contract states which coordinate source owns formal independent-location placement.
- Do not edit `project.godot`, shared/autoload state, save schemas or `scripts/Game.gd` as part of a content-only follow-up without explicit orchestrator assignment.

## Files changed
- `agent-reports/npc-content.md` only.

## Handoff
NPC-001 repository audit is complete and requests `NEEDS_REVIEW`.

Recommended immediate orchestrator split:
- **Scene/UI:** formal current-location NPC animation/grounding + dialogue presentation + visual coordinate-source cleanup.
- **Gameplay:** relation-aware event conditions + q3 gift/handoff decision/semantics.
- **NPC/content:** relation-tier dialogue expansion, dark-trust thresholds and event-copy consistency after required plumbing decisions.
- **QA/Codex:** fresh Phase 3 runtime/manual acceptance after the above tasks, not inside this audit.

Do not merge directly to `main`. Do not edit `docs/agents/TASK_BOARD.md` from this worker task.
