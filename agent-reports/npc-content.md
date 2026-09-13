# NPC/Content Agent Report

## Task
- ID: NPC-CONTENT-003
- Agent: npc-content
- Branch/worktree: `agent/npc-content-003-naming-consistency`
- Status: IN_PROGRESS

## Scope
Audit `data/quests.json` and `data/events.json` for core-NPC naming collisions, unsupported relationship claims, and contradictory identity wording. Only `data/quests.json`, `data/events.json`, and this report are writable.

## Current progress
- Re-read latest coordination contract and ownership rules from `orchestrator/multi-agent-bootstrap`.
- Branch started identical to coordination commit `6215005b34e860a5d346fa38ee339537a819cd66`.
- Corrected q3 purchase wording so the `store_buy` counter no longer claims a completed handoff to 小雨.
- Prepared hospital-event correction so the new hospital acquaintance no longer reuses core NPC `老张`; final wording is `隔壁床的病友`.
- Continuing audit of relationship-copy cases before requesting review.

## Runtime / validation
- Godot/Web/browser/runtime: NOT RUN.
- No runtime result is claimed.
