# NPC/Content Agent Report

## Task
- ID: NPC-001
- Agent: npc-content
- Branch/worktree: `agent/npc-001-content-audit`
- Status: NEEDS_REVIEW

## Scope
Repository audit only. NPC scripts/scenes/data/assets were treated as read-only for this task. The only modified file is this report.

## Summary
The repository contains a coherent six-NPC content set and working schedule/relationship/story plumbing, so this is not primarily a "missing NPC files" problem. The largest player-facing issue is presentation: the current independent-location experience renders every NPC as a static image/button hotspot even though walk assets exist for all six. A second issue is that the newer relationship system is only weakly connected to dialogue, dark-story trust, random events, and quest semantics, so repeated conversations can feel mechanical and some narrative actions are only simulated by generic counters.

### Core NPC inventory
| ID | Name / role | Scheduled locations | Base dialogue | Dark clue | Visual resources |
| --- | --- | --- | --- | --- | --- |
| `chenjie` | 陈姐 / 便利店老板娘 | store 07:00-23:00 | young/mid/old, 3 lines each | yes, age 33+ | `npc_chenjie.png`, `npcwalk_chenjie.png`, prototype hi-res candidate |
| `laozhang` | 老张 / 公司老同事 | office; subway evening | young/mid/old, 3 lines each | yes, age 40+ | `npc_laozhang.png`, `npcwalk_laozhang.png` |
| `laozhou` | 老周 / 公园下棋老人 | park morning/afternoon; hidden in storm | young/mid/old, 3 lines each | yes, age 45+ | `npc_laozhou.png`, `npcwalk_laozhou.png` |
| `daoshi` | 疯道士 / 巷子里的怪人 | old alley 18:30-04:30 | young/mid/old, 3 lines each | yes, age 25+ | `npc_daoshi.png`, `npcwalk_daoshi.png` |
| `xiaoyu` | 小雨 / 合租室友 | home morning/evening/night | young/mid/old, 3 lines each | yes, age 30+ | `npc_xiaoyu.png`, `npcwalk_xiaoyu.png`, prototype hi-res candidate |
| `azhe` | 阿哲 / 地铁站卖唱的 | subway; cafe 12:00-14:00 | young/mid/old, 3 lines each | yes, age 38+ | `npc_azhe.png`, `npcwalk_azhe.png` |

Repository-side, all six IDs are represented in `Data.NPCS`, `data/npc_schedules.json`, and static sprite assets. No core NPC is missing from the content definition or schedule table.

## Findings

### P1 — Current formal NPC presentation is static; existing walk assets are unattached
**Player impact:** high. This directly matches the reported "贴纸感 / 没有嵌入感" symptom.

The formal experience now uses `LocationManager` independent locations; the legacy single-world path is hidden by `Game.gd`. `LocationManager` creates each NPC as a flat `Button` containing a `TextureRect`, a shadow, and a hover label. It does not create an `AnimatedSprite2D`, idle animation, walk animation, facing state, or local movement.

- `xiaoyu` and `chenjie` load prototype walk sheets but `_npc_texture()` crops only the first square frame into an `AtlasTexture`, so they are still static.
- `laozhang`, `laozhou`, `azhe`, and `daoshi` load `npc_<id>.png` static fallback sprites.
- Walk assets exist for all six under `assets/sprites/npcwalk_<id>.png`, but the current independent-location renderer does not reference them.
- The legacy `scenes/world/NPC.tscn` + `scripts/world/NPC.gd` path is also static and is not the current formal presentation path.

**Exact files:**
- `scripts/systems/LocationManager.gd`
- `scripts/Game.gd`
- `scenes/world/NPC.tscn`
- `scripts/world/NPC.gd`
- `assets/sprites/npcwalk_azhe.png`
- `assets/sprites/npcwalk_chenjie.png`
- `assets/sprites/npcwalk_daoshi.png`
- `assets/sprites/npcwalk_laozhang.png`
- `assets/sprites/npcwalk_laozhou.png`
- `assets/sprites/npcwalk_xiaoyu.png`
- `assets/characters/sprites/prototype/chenjie_walk_candidate.png`
- `assets/characters/sprites/prototype/xiaoyu_walk_candidate.png`

**Recommended owner / next task:** Scene/UI + orchestrator. Fix the current `LocationManager` presentation path first; do not spend the first repair pass polishing only legacy `NPC.tscn`, because that will not change the formal independent-location experience.

### P1 — Dialogue presentation removes most NPC visual identity
`DialogUI.gd` is a generic text panel: speaker label, body text, Continue/End button. It has no NPC portrait, expression state, contextual portrait crop, per-character presentation, or location-aware dialogue composition. Once dialogue opens, the visual identity of the NPC is mostly reduced to a speaker name.

**Exact file:** `scripts/ui/DialogUI.gd`

**Recommended owner / next task:** Scene/UI, with NPC/content supplying portrait/expression requirements and speaker presentation data if the orchestrator authorizes a schema extension.

### P1 — Quest `q3_someone_waits` narrates a gift to 小雨 but only checks a generic store purchase
The quest step says `路过便利店，给她带一样东西`, but its implementation is `counter: store_buy >= 1`. `QuestSystem` only checks that counter; there is no selected item, recipient, gift handoff, inventory removal, or 小雨 reaction bound to this step. The prose promises a relationship action that the mechanics do not actually perform.

**Exact files:**
- `data/quests.json`
- `scripts/systems/QuestSystem.gd`
- likely implementation dependency: store/inventory/gameplay flow

**Recommended owner / next task:** Gameplay + NPC/content. Either implement a real `gift_to_npc`/handoff step or rewrite the quest step so the text honestly describes "buy something on the way home" without pretending the player delivered a gift.

### P2 — Relationship tiers do not currently change the normal dialogue pool
`NpcRelations` has meaningful tiers (`0/20/45/70`) and only grants +4 on the first completed conversation each day. However, `Data.npc_lines()` selects dialogue only by age bucket (`young/mid/old`). Normal dialogue does not branch by relationship tier.

This means a player working toward relation 20 or 45 can repeatedly see the same three-line age bucket before the relationship milestone is reached. The relation number changes, but the person does not sound progressively more familiar.

**Exact files:**
- `scripts/Data.gd`
- `scripts/systems/NpcRelations.gd`
- `scripts/systems/StorySystem.gd`

**Recommended owner / next task:** NPC/content after orchestrator approves a low-conflict content shape. Add relationship-tier variants or a small anti-repeat/rotation layer without changing the global save schema unless necessary.

### P2 — Dark-story trust is age-gated, not relationship-gated
`StorySystem.build_npc_dialog()` unlocks each NPC's dark conversation when `Data.dark_ready()` passes and the clue has not been claimed. `dark_ready()` is age-based. It does not require the player to be acquaintance/familiar/friend with that NPC.

Result: a player can reach an age threshold, talk to an otherwise-stranger NPC, and immediately receive intimate supernatural testimony. This underuses the relationship system and weakens the sense that trust was earned.

**Exact files:**
- `scripts/Data.gd`
- `scripts/systems/StorySystem.gd`
- `scripts/systems/NpcRelations.gd`

**Recommended owner / next task:** NPC/content + gameplay review. Consider a relation floor per dark clue (for example acquaintance/familiar depending on character), with a safe fallback line so clues do not become permanently missable.

### P2 — Random event / encounter conditions cannot react to NPC relationships
`EventSystem.cond_ok()` supports money, health, mood, skill, network, age, job, flags, and origins, but not NPC relationship values. `EncounterSystem` reuses those conditions and adds location/time/weather/clue gates. Therefore broader events and encounters cannot currently branch on "you know 老张 well" or "小雨 trusts you" without new plumbing.

This leaves the relation system mostly inside direct conversation + quest checks instead of letting relationships alter the city around the player.

**Exact files:**
- `scripts/systems/EventSystem.gd`
- `scripts/systems/EncounterSystem.gd`
- `data/events.json`
- `data/encounters.json`

**Recommended owner / next task:** Gameplay owns condition-schema changes; NPC/content can then author relation-aware event variants.

### P2 — `events.json` contains an ambiguous 老张 introduction disconnected from the core 老张 relationship
One event result says: `病房里你认识了老张。你们约好出院后一起去钓鱼。` The repository also has a core NPC `laozhang` / 老张, "公司老同事". This event result does not update `relations["laozhang"]`, establish an identity flag, or otherwise reconcile whether this is the same person.

**Risk:** if intended to be the same 老张, it can contradict an existing relationship (the player may already know him); if intended to be a different 老张, the duplicate name creates avoidable ambiguity.

**Exact file:** `data/events.json`

**Recommended owner / next task:** NPC/content. Rename the generic hospital character or explicitly make the event a relation-aware core-老张 event after gameplay condition plumbing exists.

### P3 — Two NPC presentation paths increase repair risk
There is a legacy world NPC scene/script path (`scenes/world/NPC.tscn`, `scripts/world/NPC.gd`, `WorldManager`) and a separate current independent-location renderer inside `LocationManager`. Both are static, but only the latter is the formal experience by default.

**Risk:** an agent can "fix NPCs" in the legacy scene and see no change in the current game, wasting iterations and creating diverging behavior.

**Recommended owner / next task:** Orchestrator should label the legacy path explicitly as compatibility-only in task briefs, then later decide whether to retire it after the independent-location migration stabilizes.

## Repair order
1. **P1 visual integration:** animate/ground NPCs in the current `LocationManager` path using existing walk/idle resources; validate scale, feet anchor, shadow, z/depth, lighting, and click target in every scheduled location.
2. **P1 dialogue presentation:** give direct conversations a stronger NPC identity (portrait/expression or equivalent) while keeping content logic separate from UI.
3. **P1 quest semantic fix:** make `q3_someone_waits` either a real gift handoff or honest non-gift prose.
4. **P2 relationship-aware dialogue:** add familiarity-specific lines / anti-repeat behavior so repeated days feel like a developing relationship.
5. **P2 trust/content integration:** gate dark disclosures by relationship in a non-deadlocking way.
6. **P2 relation-aware events:** extend event conditions, then author event/encounter variants tied to core NPC relationships; resolve the ambiguous hospital "老张" line.
7. **P3 cleanup:** document/retire the legacy NPC rendering path after current-scene behavior is stable.

## Files inspected
- `scripts/Data.gd`
- `scripts/Game.gd`
- `scripts/systems/NPCScheduleSystem.gd`
- `scripts/systems/NpcRelations.gd`
- `scripts/systems/StorySystem.gd`
- `scripts/systems/EventSystem.gd`
- `scripts/systems/EncounterSystem.gd`
- `scripts/systems/QuestSystem.gd`
- `scripts/systems/LocationManager.gd`
- `scripts/world/NPC.gd`
- `scripts/world/WorldManager.gd`
- `scripts/ui/DialogUI.gd`
- `scenes/world/NPC.tscn`
- `data/npc_schedules.json`
- `data/quests.json`
- `data/events.json`
- `data/encounters.json`
- repository asset tree under `assets/characters/`, `assets/sprites/`, and `assets/backgrounds/dialogue/`

## Validation
- Commands/tests run: none. This was a GitHub/web static audit and must not be reported as a new Godot/runtime test run.
- Repository consistency checks performed:
  - confirmed six core NPC IDs in content and schedules;
  - confirmed static sprite resources for all six;
  - confirmed `npcwalk_*` resources for all six;
  - traced the formal independent-location NPC path from `Game._sync_location_npcs()` to `LocationManager.set_visible_npcs()` / `_npc_texture()`;
  - traced direct dialogue from location NPC click to `StorySystem.build_npc_dialog()`;
  - traced relationship thresholds and quest relation/counter checks;
  - inspected random event / encounter condition capabilities.
- Manual runtime checks recommended for the next implementation task:
  - visit every scheduled NPC at in-window and out-of-window times;
  - verify storm hiding for 老周/阿哲;
  - verify NPC feet/shadow/occlusion against scene geometry;
  - verify no first-frame crop or static fallback remains after animation integration;
  - talk across relation thresholds 0→20→45→70 and confirm visible content changes;
  - verify q3 gift semantics and dark-clue gating after fixes.

## Evidence
- Six NPC definitions and age/dark dialogue: `scripts/Data.gd`.
- Six-NPC time/location coverage: `data/npc_schedules.json`.
- Current direct-location presentation and texture selection: `scripts/systems/LocationManager.gd`.
- Legacy NPC scene/static sprite path: `scenes/world/NPC.tscn`, `scripts/world/NPC.gd`.
- Relationship progression: `scripts/systems/NpcRelations.gd`.
- Dark dialogue/clue flow: `scripts/systems/StorySystem.gd`.
- Generic dialogue UI: `scripts/ui/DialogUI.gd`.
- Quest semantics: `data/quests.json`, `scripts/systems/QuestSystem.gd`.
- Event/encounter content and condition systems: `data/events.json`, `data/encounters.json`, `scripts/systems/EventSystem.gd`, `scripts/systems/EncounterSystem.gd`.
- Runtime/build evidence: none generated by this audit.

## Known issues / risks
- The visual P1 fix crosses into `LocationManager.gd`, a shared/current scene system; this audit does not authorize NPC-content to edit it.
- Dialogue UI repair belongs to Scene/UI ownership.
- Relation-aware event conditions and a true NPC gift mechanic require gameplay/schema work before content can safely depend on them.
- Do not edit `project.godot`, shared/autoload state, or save schemas as part of a content-only follow-up without explicit orchestrator assignment.

## Handoff
NPC-001 is complete and ready for orchestrator review. Recommended immediate split:
- **Scene/UI:** current-location NPC animation/grounding + dialogue presentation.
- **Gameplay:** relation-aware event conditions + q3 gift/handoff semantics.
- **NPC/content follow-up:** relation-tier dialogue expansion, dark-trust thresholds, event copy consistency after the required plumbing lands.

Do not merge directly to `main`. Do not edit `docs/agents/TASK_BOARD.md` from this worker task.