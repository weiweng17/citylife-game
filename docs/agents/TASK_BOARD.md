# Multi-Agent Task Board

## Sprint: Bootstrap & Stabilization

### ORCH-001 — Multi-agent control layer
- Owner: orchestrator
- Branch: `orchestrator/multi-agent-bootstrap`
- Status: IN_PROGRESS
- Objective: establish rules, task board, ownership, reporting and review process.
- Allowed: `docs/agents/**`, `.github/**` after review.
- Forbidden: gameplay code/assets during bootstrap.
- Acceptance:
  - Rules documented
  - Ownership documented
  - Worker roles documented
  - Recovery workflow documented

### QA-001 — Current project health audit
- Owner: qa-build
- Status: READY
- Objective: inspect current Godot project, identify build/export errors, missing resources, broken scene references, and deployment blockers.
- Acceptance:
  - Project opens
  - Web export tested
  - Errors grouped by severity
  - Repro steps recorded

### GAME-001 — Current gameplay blocker inventory
- Owner: gameplay
- Status: READY
- Objective: identify current gameplay/system blockers before feature expansion.
- Acceptance:
  - Player interaction blockers listed
  - Save/state issues listed
  - Scene transition issues listed

### UI-001 — Scene/UI visual integration audit
- Owner: scene-ui
- Status: READY
- Objective: inspect scene composition, character/background integration, layering and obvious visual mismatches.
- Acceptance:
  - Problem scenes identified
  - Each issue has target behavior and files involved

### NPC-001 — NPC/content audit
- Owner: npc-content
- Status: READY
- Objective: identify missing NPCs, broken NPC presentation, dialogue/event gaps and scene attachment issues.
- Acceptance:
  - NPC inventory
  - Missing/broken NPC list
  - Recommended repair order

## Status values
`READY` → `IN_PROGRESS` → `NEEDS_REVIEW` → `DONE`

Use `BLOCKED` when another task, asset, permission or decision prevents progress.
