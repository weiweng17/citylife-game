# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-005
- Agent: npc-content
- Branch/worktree: `agent/npc-content-005-family-state-ambiguity-audit`
- Status: NEEDS_REVIEW

## Scope
Report-only audit of remaining event copy/speaker dependencies on spouse/child state. The task authorizes only `agent-reports/npc-content.md`; no event data, conditions, speakers, flags, scripts, schema, coordination files, or `main` changes were made.

## Baseline and source-of-truth note
- Latest coordination baseline inspected: `orchestrator/multi-agent-bootstrap` at `ecb3b9331ef1b94095529a083c12636e47983176`.
- Before this report update, the task branch matched that coordination baseline exactly (`ahead 0 / behind 0`).
- `TASK_BOARD.md` marks NPC-CONTENT-004 as DONE, but the coordination branch's `data/events.json` still contains the pre-004 strings such as `老婆`, `孩子跟她`, plural mortgage wording, and `带家属一起`.
- Therefore this inventory treats the accepted NPC-CONTENT-004 delta (`fb0b932c63542a61bc6a00d7c8e67cebf1e09cde`) as already resolved and does **not** reclassify those four accepted copy fixes as remaining defects.

## Repository-state semantics verified
Read-only inspection of `scripts/systems/EventSystem.gd` confirms:
- event eligibility checks only the explicitly declared `cond` keys;
- `flags` require the named flag to be true and `flags_not` require it to be false;
- applying an option mutates only the flags explicitly present in that option's `flags` dictionary;
- there is no automatic family-state normalization or cascading cleanup.

`GameState.gd` also stores `flags` as one generic dictionary with no separate spouse/child invariant enforcement.

This matters because `e_divorce` sets only:
- `married = false`
- `divorced = true`

It does **not** clear `hasChild`. Therefore a divorced player can still legitimately carry `hasChild = true`, and any later event that requires only `hasChild` remains eligible unless that event was already used.

## Remaining hard ambiguities
These are the four events whose current speaker/relationship presentation is not guaranteed by current eligibility. None can be fully repaired by a simple result-string substitution because the contradiction includes the event speaker and/or core scene premise.

### 1. `e_kid_school` — HARD
Current eligibility:
- age `33–45`
- `flags: [hasChild]`
- no `married` requirement

Relationship-dependent presentation:
- `speaker = 妻子`
- dialogue is framed as a current joint household decision
- successful result says `你们搬进了五十平的老房子`

Contradiction:
- after `e_divorce`, `hasChild` can remain true while `married` is false;
- during the overlapping age window (divorce can occur from 38 onward), this event can still be eligible with a speaker labeled current wife.

Future-fix classification:
- **Requires condition/speaker policy ownership.**
- If design intent is “current married household only”, a future task could gate the event on current marriage.
- If design intent is “divorced/single-parent school decision also allowed”, the speaker and shared-household wording must be redesigned.
- This audit does not choose between those semantics.

### 2. `e_second_child` — HARD
Current eligibility:
- age `30–42`
- `flags: [hasChild]`
- `flags_not: [noChild]`
- no `married` requirement

Relationship-dependent presentation:
- `speaker = 妻子`
- text says `一个我们已经快养不起了` and `两个人都笑了`
- first result assumes a new second child is born into the same family unit
- second result ends with `谢谢你们没让他分摊`

Contradiction:
- a divorce path can occur from age 38 while `hasChild` remains true;
- between ages 38–42, this event can therefore remain eligible after divorce despite using a current-wife/current-couple premise.

Future-fix classification:
- **Requires condition/speaker mechanics ownership**, not copy-only cleanup.
- Marriage gating would preserve the current story; co-parent/single-parent support would require a larger speaker/copy rewrite.

### 3. `e_downsize` — HARD
Current eligibility:
- age `48–60`
- `flags: [hasChild]`
- no `married` requirement

Relationship-dependent presentation:
- `speaker = 妻子`
- text says `她擦着桌子` and proposes a shared move
- first result says `你们搬进了小房子`

Contradiction:
- `e_divorce` can occur through age 55 and does not remove `hasChild`;
- this event is therefore directly reachable in a divorced state during much of its age window while still presenting a current wife/shared household.

Future-fix classification:
- **Requires condition/speaker policy ownership.**
- A result-string neutralization alone would leave the `妻子` speaker contradiction intact.

### 4. `e_empty_nest` — HARD
Current eligibility:
- age `48–60`
- `flags: [hasChild]`
- no `married` requirement

Relationship-dependent presentation:
- `speaker = 妻子`
- body says `桌上只剩两副碗筷`
- option says `重新经营两个人的生活`
- result says `你们开始一起散步、看电影` and refers to `她`

Contradiction:
- a divorced player can retain `hasChild` and therefore satisfy this event;
- the full scene, not just one result line, assumes a current two-person spouse household.

Future-fix classification:
- **Requires condition/speaker policy ownership.**
- This is the least suitable of the four for copy-only neutralization because speaker, body, option, and result all share the same spouse premise.

## Additional low-priority relationship-copy risk
### `e_house` — COPY-ONLY CANDIDATE / LOW
Current eligibility:
- age `27–40`
- `flags_not: [hasHouse]`
- first choice additionally requires `money_min = 600000`
- no `dating` or `married` condition

Potential assumption:
- first option text is `掏空六个钱包，买`.
- In common usage, “six wallets” implies the buyer couple plus both sets of parents, which indirectly assumes a spouse/partner even though the event does not require one.

Why this is lower severity:
- unlike the four hard cases, the event speaker is `房产顾问`, not a falsely identified spouse;
- the result itself is singular (`你拿到了钥匙`) and does not require a spouse;
- the phrase can be neutralized in a future copy-only task without changing mechanics if the orchestrator wants strictly state-grounded wording.

Suggested safe future copy boundary:
- only the option string, e.g. replace the relationship-loaded idiom with a neutral “凑够首付，买” style phrase.
- No change is made here because NPC-CONTENT-005 is report-only.

## Relationship-state cases checked and not classified as remaining defects
These were explicitly checked so the inventory does not over-report generic relationship language.

- `e_child`: `speaker = 妻子` and eligibility explicitly requires `married`; spouse premise is supported.
- `e_marry_life`: `speaker = 妻子` and eligibility explicitly requires `married`; spouse premise is supported.
- `e_divorce`: `speaker = 妻子` and eligibility explicitly requires `married`; after the accepted NPC-004 removal of the unsupported child-custody clause, its spouse premise is supported.
- `e_marry` and `e_longdistance`: `speaker = 恋人` and eligibility explicitly requires `dating`; relationship label is supported.
- `e_kid_grow`, `e_grandchild`, and `e_kid_rebel`: `speaker = 孩子` and eligibility explicitly requires `hasChild`; the parent/child relationship exists even after divorce. Their child life-stage/chronology assumptions are a different content-model question, not this spouse/child-existence audit.
- `e_will`: `跟家人交代` does not specifically assert spouse/child state and the broader narrative already contains family-of-origin relationships; not classified here.
- `e_house` text `你们家能凑多少` can refer broadly to family of origin; only the more specific `六个钱包` idiom is flagged as the low-priority spouse assumption.
- NPC-CONTENT-004 accepted cases `e_boss_talk`, the child-custody clause in `e_divorce`, `e_mortgage_pressure`, and `e_old_colleague` are not counted as remaining even though coordination data has not yet absorbed their accepted worker commit.

## Inventory summary
- Hard speaker/eligibility contradictions: **4**
  - `e_kid_school`
  - `e_second_child`
  - `e_downsize`
  - `e_empty_nest`
- Additional low-priority copy-only relationship assumption: **1**
  - `e_house` / `掏空六个钱包，买`
- Previously accepted NPC-004 copy fixes intentionally excluded from the remaining count: **4**

## Smallest recommended follow-up task boundary
Recommended next task: **Family-state event policy repair**, limited to `data/events.json` plus the NPC report, but only after the orchestrator explicitly chooses the intended family-state policy for the four hard events.

The task should authorize both event conditions and speaker/copy fields for exactly:
- `e_kid_school`
- `e_second_child`
- `e_downsize`
- `e_empty_nest`

Decision required before implementation:
1. **Married-household policy:** these four events are intended only while currently married. Then preserve wife/couple copy and add an explicit current-marriage eligibility requirement.
2. **Co-parent-inclusive policy:** these events should remain possible after divorce. Then preserve `hasChild` eligibility but replace the `妻子` speaker and couple-household copy with relationship-neutral/co-parent wording.

Do not mix these two policies event-by-event without an explicit narrative rule. This audit does not invent which policy is correct.

The `e_house` “six wallets” phrase can be handled separately as a one-string copy-only cleanup and does not need family-state mechanics ownership.

## Files inspected
Read-only:
- `HANDOFF.md`
- `docs/agents/MASTER_PLAN.md`
- `docs/agents/TASK_BOARD.md`
- `docs/agents/AGENT_RULES.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- `data/events.json`
- `scripts/systems/EventSystem.gd`
- `scripts/GameState.gd`
- accepted NPC-CONTENT-004 report on `agent/npc-content-004-relationship-neutral-copy`

Writable:
- `agent-reports/npc-content.md` only

## Validation / execution evidence
Repository inspection performed:
- task branch was verified identical to the coordination baseline before this report update;
- event eligibility, option flag mutation, and generic flag storage were read directly from repository source;
- spouse/child relationship terms were cross-checked against event eligibility;
- no source/data file was edited.

Not run:
- Godot 4.7.2: **NOT RUN**
- Web export/browser: **NOT RUN**
- terminal scripts / JSON parser: **NOT RUN**
- no runtime/build/parser PASS is claimed.

## Known risks / integration note
- Coordination metadata has accepted NPC-CONTENT-004 while the coordination branch data file has not yet absorbed that worker source delta. Integration review must not lose the accepted 004 string fixes when later family-state work is combined.
- The four hard cases are policy ambiguities, not merely typo-level content defects. A repair without an explicit current-marriage vs co-parent-inclusive decision risks silently changing intended event reachability.

## Handoff
NPC-CONTENT-005 requests `NEEDS_REVIEW`.

This task is complete as a report-only inventory. No conditions, speakers, event data, mechanics, schemas, or runtime behavior were changed.