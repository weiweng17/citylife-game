# CONTENT-WAVE-01 — 城市开始活起来

## Why now
The project has already completed a long critical-repair wave: GAME-FIX-001..009 are accepted, the post-009 mutation audit found no new repository-proven deterministic terminal bypass, and the current foundation already contains a complete day loop, shop/backpack/sleep, NPC schedules and relations, skill/wage growth, serial quests, five expanded locations, events/encounters, save/load, and authoritative terminal-state handling.

The next milestone should increase what the player can *see, choose, remember and replay*. Non-blocking audit churn must no longer dominate the schedule.

`00-Orchestrator` remains the only agent allowed to edit `docs/agents/TASK_BOARD.md` and other coordination files. This planning branch is a handoff proposal for the next orchestrator heartbeat.

## Wave product target
Ship one Alpha content slice where a returning player can play several in-game days and repeatedly encounter new situations, NPC developments and economic choices instead of exhausting the visible content after the basic day loop.

### Player-visible exit target
- 20 new ordinary-life events across park / cafe / hospital / alley / rooftop: 4 each.
- 8 relationship-stage NPC episodes across 陈姐 / 老张 / 小雨 / 阿哲: 2 each.
- 5 new serial quests after q3, expanding the chain from 3 to 8 quests.
- At least 2 new repeatable livelihood actions with meaningful money/time/health/mood tradeoffs.
- First-pass economic pressure improvements so money has visible short-term meaning beyond store purchases and very long-range stage goals.
- No unresolved family/romance canon is silently decided by implementation.

## Scheduling rule for this wave
At least **60% of active work must produce player-visible content**.

Recommended split:
- 60% content / narrative / playable choices
- 20% gameplay hooks and economy
- 10% Scene/UI presentation
- 10% QA / integration

Repository-only audits should be queued only when they block integration or when a concrete HIGH/CRITICAL defect is already known. Low/medium speculative audits move to backlog until the Alpha content slice exists.

## Existing READY work disposition
- `GAME-AUDIT-011`: backlog unless 00 judges the cross-midnight issue release-blocking. Preserve it as a QA stress case if needed.
- `NPC-AUDIT-011`: backlog; do not spend the next content cycle only polishing pronouns.
- `UI-FIX-007`: may continue because bounded dialogue directly supports longer new content and is player-visible infrastructure.
- `QA-013`: may finish as a short integration-preflight task; subsequent QA should validate the content candidate rather than generate another audit chain.

# First parallel batch

## Lane 01 — Gameplay
### GAME-CONTENT-012 — Daily-life economy hooks v1
Add two repeatable livelihood choices through normal player interaction, using the existing location/activity architecture.

Recommended first two:
1. **Office overtime** — higher money, meaningful time cost, health/mood cost; cannot be spammed without consequence.
2. **Temporary side gig** — lower pay than work, available from an existing public location, with a different time/state tradeoff.

Acceptance:
- both actions are visible and usable without debug jumps;
- each trades at least money + time + one survival/emotional stat;
- no zero-cost infinite money loop;
- preserve GAME-FIX-001..009 terminal semantics and existing save behavior;
- no opaque random success chance;
- narrow verifier prepared; real Godot execution remains QA-002.

Suggested writable boundary must be declared by 00 after inspecting the chosen activity scripts. Avoid unrelated `Game.gd` changes beyond the semantic integration candidate.

## Lane 03 — NPC/Content
### NPC-CONTENT-012 — City Event Pack A
Writable target: `data/events.json`, NPC/content report, and only explicitly granted content files.

Add exactly **20 ordinary-life events**:
- park: 4
- cafe: 4
- hospital: 4
- alley: 4
- rooftop: 4

Content rules:
- every event has 2–3 choices;
- at least one choice has a real downside/cost;
- avoid '+8 mood vs +5 mood' pseudo-decisions;
- choices should trade at least two of money / health / mood / skill / network / flags;
- at least 5 events remember a choice with existing flags so a later event can acknowledge it;
- at least 6 events naturally reference existing NPCs;
- do not change deferred spouse/child-policy events, `e_parent_gone`, or roommate canon;
- supernatural/dark-line content stays optional and secondary to ordinary city life.

Suggested subjects:
- Park: free exercise class; lost wallet; rain-shelter dancing aunties; recruiter call during lunch.
- Cafe: interview preparation; stranger needs a charger; coworker gossip; unpaid trial-work offer.
- Hospital: company physical result; helping an elderly patient use a kiosk; generic vs branded medicine; late-night registration queue.
- Alley: second-hand furniture; landlord repair dispute; rain-night street stall; delivery rider sheltering from rain.
- Rooftop: call after a bad performance review; neighbor drying bedding; distant fireworks; whether to answer a work message after hours.

### NPC-CONTENT-013 — Relationship Episode Pack A
After Event Pack A, add **8 relationship-stage episodes**, two each for 陈姐 / 老张 / 小雨 / 阿哲.

Each NPC gets:
- one `认识 -> 熟络` episode;
- one `熟络 -> 朋友` episode;
- at least one consequence beyond relationship points: money/skill/network/mood, meaningful choice, or future flag acknowledgement.

Keep Xiaoyu relationship-neutral. Do not define romance or housing canon in this wave.

### NPC-CONTENT-014 — Serial Quest Pack B
Extend `data/quests.json` from q1–q3 to q1–q8. Use only QuestSystem-supported step types unless Gameplay explicitly adds a validated new counter hook first.

Suggested direction:
- q4 `这个月先过完` — several work shifts + day threshold + cash buffer.
- q5 `别只认识公司的人` — deepen a second everyday NPC relationship.
- q6 `身体不是耗材` — use safe supported state/flag conditions until a hospital counter exists.
- q7 `给自己留一天` — low-pressure life goal using day/relation/money/flag state.
- q8 `这座城有你的位置` — capstone requiring progress across skill, relationships and savings.

Quest rules remain: no deadline, no failure state, no cycles, no one-time missable dead ends, reward exactly once.

## Lane 02 — Scene/UI
### UI-CONTENT-008 — Content readability pass
Run after or alongside UI-FIX-007. This is not a generic redesign.

Goal:
- long event/dialogue copy remains readable at 1280x720 and 960x540;
- quest objectives and quest completion feedback are reachable and not silently clipped;
- important choice costs are visually scannable using the existing UI vocabulary;
- do not change gameplay mechanics or narrative meaning.

If UI-FIX-007 already solves the practical readability problem, keep this task intentionally small instead of inventing UI work.

## Lane 04 — QA/Build
### QA-CONTENT-014 — Content pack acceptance gate
Repository gate:
- JSON parses;
- event IDs unique;
- every event has usable options;
- condition/effect keys are supported;
- quest IDs/next links/step types validate;
- no accidental edits to deferred-policy events;
- exact content counts and branch tips captured.

Runtime gate on one frozen QA-002 candidate:
- trigger at least one new event from each of the five locations;
- complete one new livelihood action;
- progress at least two new quest steps;
- trigger one relationship-stage episode;
- save/load during the new content slice;
- preserve Web/browser validation on the same exact candidate SHA.

# Second batch after the first playable slice
Only select these after Pack A has been integrated and actually played:

1. **Economy pressure v1** — recurring rent/fixed expenses only if the playtest shows money still has no pressure. This must have explicit save/migration design and cannot be slipped into a data-only task.
2. **Event Pack B** — another 15–20 events selected from playtest repetition gaps, not quota alone.
3. **NPC Episode Pack B** — 老周 / 疯道士 plus midlife continuations for everyday NPCs; dark story remains optional.
4. **Quest Pack C** — branch/chapter structure only after q1–q8 pacing is actually played.
5. **Alpha freeze** — stop new features, form one exact integration SHA, run full Godot/Web QA, then publish a test build.

## Content quality bar
Every new event/activity must answer at least one:
- Does it show what being an ordinary worker in this city feels like?
- Does it force a small but understandable tradeoff?
- Does it make an NPC feel like a person with continuity?
- Does yesterday's choice matter today?
- Does it give the player a reason to revisit a location?

If none apply, do not add it merely to increase event count.

## User decisions
Nothing is required from the user before Pack A starts. Use these defaults:
- Xiaoyu stays a relationship-neutral close friend; no romance canon yet.
- Deferred spouse/child/family-state cases stay untouched.
- The supernatural dark line remains secondary to ordinary city life.
- Pack A requires no new external art/audio.

Ask the user only when implementation becomes blocked by one of these:
1. Xiaoyu canon: roommate / romance possibility / close friend only.
2. Family semantics: married-household-only vs co-parent-inclusive.
3. Whether recurring rent/fixed expenses should become a core survival mechanic.
4. Whether the first public Alpha should market realistic daily life first or the supernatural dark line first.

## User playtest checkpoint
After the first integrated Pack A build, request one 10–15 minute playtest and only three judgments:
- Which location still feels empty?
- Which NPC do you actually want to see again?
- Did money/time/health ever force a decision, or were you simply clicking the best-looking reward?

Use those answers to choose Pack B rather than blindly generating more content.

## Handoff to 00-Orchestrator
On the next heartbeat, 00 should review this planning branch, backlog non-blocking audit churn, and translate the **First parallel batch** into TASK_BOARD entries with non-overlapping writable scopes. Preserve the player-visible exit target and the 60% player-visible scheduling rule even if exact task IDs/scopes are adjusted to current branch state.