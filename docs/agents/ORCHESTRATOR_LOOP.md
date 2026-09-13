# Orchestrator Control Loop

`00-Orchestrator` is the persistent control plane for the web-agent system. Workers 01-04 are execution nodes; they do not advance the global workflow themselves.

## Single-controller rule
- Only `00-Orchestrator` may edit `docs/agents/TASK_BOARD.md`.
- Only `00-Orchestrator` may decide that a worker task is accepted, rejected, superseded, blocked, or ready for the next task.
- Workers only update their own `agent-reports/*.md` files and their task branches.
- Never run two orchestrators against the same coordination branch at the same time.

## Orchestrator heartbeat
On every orchestrator wake/run, execute this loop in order:

1. Read `docs/agents/TASK_BOARD.md` from `orchestrator/multi-agent-bootstrap`.
2. Read all current worker reports:
   - `agent-reports/gameplay.md`
   - `agent-reports/scene-ui.md`
   - `agent-reports/npc-content.md`
   - `agent-reports/qa-build.md`
3. Inspect the referenced worker branches / exact SHAs for any report in `NEEDS_REVIEW`.
4. Review completed work immediately; do not wait for all workers.
5. Update `TASK_BOARD.md` only after review:
   - accepted -> `DONE`
   - incomplete/incorrect -> create a narrow correction task or return it to worker
   - execution-context blocked -> `BLOCKED` with exact blocker
6. Keep every idle worker fed with at most one `READY` task unless intentionally paused.
7. Keep scopes non-overlapping and respect `FILE_OWNERSHIP.md`.
8. When a task needs real Godot, terminal, browser, Web export, screenshots, or exact-SHA runtime evidence, package a single narrow Codex/Local QA task instead of asking web workers to fake runtime proof.
9. Record the orchestrator's current state in `agent-reports/orchestrator.md`.
10. Stop the loop only when one of these is true:
   - all active work is waiting on the user/product decision,
   - all active work is blocked on real runtime/Codex execution,
   - no safe non-overlapping next task exists,
   - release/integration gate is ready for user approval.

## Dispatch policy
The orchestrator should prefer continuous pipeline flow:

`Worker report NEEDS_REVIEW -> Orchestrator review -> task DONE/rejected -> immediately create next READY task for that role`

Do not leave a worker idle merely because another role is still working.

## Current-cycle priority order
1. Review any `NEEDS_REVIEW` worker report.
2. Resolve coordination contradictions / stale task state.
3. Fill idle workers with the smallest useful next task.
4. Refresh QA integration/runtime manifest.
5. Escalate only the minimum required exact-SHA package to Codex/local execution.
6. After runtime evidence, form one deterministic integration candidate and review before touching `main`.

## Automation model
For regular ChatGPT web conversations, the chat does not automatically wake on a GitHub commit by itself. Therefore 00 needs an external wake mechanism:

- Preferred low-cost mode: a ChatGPT scheduled automation in the `00-总调度中心` conversation that runs the heartbeat periodically.
- Minimum supported schedule: hourly.
- Manual fallback: user sends `执行一次调度心跳` to the 00 conversation.

Every wake should be idempotent: if no worker/report/branch state changed, do not create duplicate tasks or duplicate edits.

## Required orchestrator output per heartbeat
Update `agent-reports/orchestrator.md` with:
- heartbeat timestamp / run sequence label
- worker state summary
- reviews completed this run
- task-board changes made
- next task per worker
- Codex/runtime escalations waiting
- user decisions waiting
- integration readiness / blockers
