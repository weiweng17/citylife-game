# Orchestrator Control Loop

`00-Orchestrator` is the persistent control plane for the web-agent system. Workers 01-07 are execution nodes; they do not advance the global workflow themselves.

## Single-controller rule
- Only `00-Orchestrator` may edit `docs/agents/TASK_BOARD.md`.
- Only `00-Orchestrator` may decide that a worker task is accepted, rejected, superseded, blocked, or ready for the next task.
- Workers only update their own `agent-reports/*.md` files and their task branches.
- Never run two orchestrators against the same coordination branch at the same time.

## Worker lanes
- `01-Gameplay` -> `agent-reports/gameplay.md`
- `02-Scene-UI` -> `agent-reports/scene-ui.md`
- `03-NPC-Content` -> `agent-reports/npc-content.md`
- `04-QA-Review` -> `agent-reports/qa-build.md`
- `05-Art-Animation` -> `agent-reports/art-animation.md`
- `06-Audio-Music` -> `agent-reports/audio-music.md`
- `07-Game-Director` -> `agent-reports/game-director.md`

## Orchestrator heartbeat
On every orchestrator wake/run, execute this loop in order:

1. Read `docs/agents/TASK_BOARD.md` from `orchestrator/multi-agent-bootstrap`.
2. Read all current worker reports for lanes 01-07.
3. Inspect the referenced worker branches / exact SHAs for any report in `NEEDS_REVIEW`.
4. Review completed work immediately; do not wait for all workers.
5. Update `TASK_BOARD.md` only after review:
   - accepted -> `DONE`
   - incomplete/incorrect -> create a narrow correction task or return it to worker
   - execution-context blocked -> `BLOCKED` with exact blocker
6. Keep every idle worker fed with at most one `READY` task unless intentionally paused.
7. Keep scopes non-overlapping and respect `FILE_OWNERSHIP.md`.
8. When a task needs real Godot, terminal, browser, Web export, screenshots, or exact-SHA runtime evidence, package a single narrow Codex/Local QA task instead of asking web workers to fake runtime proof.
9. Art/animation and audio production are separate lanes: 00 may specify requirements and acceptance criteria but must not substitute itself for asset production.
10. `07-Game-Director` defines player experience, mainline, pacing and prioritization; it does not directly own gameplay source, art assets or narrative production unless the task board explicitly grants a narrow file.
11. Record the orchestrator's current state in `agent-reports/orchestrator.md`.
12. Stop the loop only when one of these is true:
   - all active work is waiting on the user/product decision,
   - all active work is blocked on real runtime/Codex execution,
   - no safe non-overlapping next task exists,
   - release/integration gate is ready for user approval,
   - the user has explicitly paused development.

## Dispatch policy
The orchestrator should prefer continuous pipeline flow:

`Worker report NEEDS_REVIEW -> Orchestrator review -> task DONE/rejected -> immediately create next READY task for that role`

Do not leave a worker idle merely because another role is still working. When development is explicitly paused, preserve READY tasks but do not wake workers.

## Current-cycle priority order
1. Review any `NEEDS_REVIEW` worker report.
2. Resolve coordination contradictions / stale task state.
3. Apply Game Director product priorities to task ordering without allowing 07 to edit coordination files directly.
4. Fill idle workers with the smallest useful next task.
5. Refresh QA integration/runtime manifest.
6. Escalate only the minimum required exact-SHA package to Codex/local execution.
7. After runtime evidence, form one deterministic integration candidate and review before touching `main`.

## Automation model
For regular ChatGPT web conversations, the chat does not automatically wake on a GitHub commit by itself. Therefore 00 needs an external wake mechanism.

Preferred low-cost mode is the local CityLife Dispatcher. A scheduled ChatGPT automation may be used only as an intentional fallback; do not run it simultaneously with the local dispatcher.

Every wake should be idempotent: if no worker/report/branch state changed, do not create duplicate tasks or duplicate edits.

## Required orchestrator output per heartbeat
Update `agent-reports/orchestrator.md` with:
- heartbeat timestamp / run sequence label
- worker state summary for 01-07
- reviews completed this run
- task-board changes made
- next task per worker
- Codex/runtime escalations waiting
- art/audio asset-production blockers
- user/product decisions waiting
- integration readiness / blockers
