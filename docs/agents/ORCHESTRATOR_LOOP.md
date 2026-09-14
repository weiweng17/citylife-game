# Orchestrator Control Loop

`00-Orchestrator` is the persistent control plane for the web-agent system. Workers 01-07 are execution nodes; they do not advance the global workflow themselves.

## Single-controller rule
- Only `00-Orchestrator` may edit `docs/agents/TASK_BOARD.md`.
- Only `00-Orchestrator` may decide that a worker task is accepted, rejected, superseded, blocked, queued, or currently dispatched.
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

## Global execution gate
The dispatcher is **orchestrator-gated**, not worker-push driven.

- `READY` means **queued only**. A READY task must not automatically wake its worker.
- `IN_PROGRESS` means **00 explicitly decided this is the team that should execute now**.
- Default policy: at most **one web worker task globally** may be `IN_PROGRESS` at a time.
- Parallel web execution is exceptional. It is allowed only when 00 records `Parallel dispatch: YES` in the task board/control state and verifies that the tasks are independent, non-overlapping, and worth the extra coordination cost.
- A worker that reaches `NEEDS_REVIEW` stops receiving continuation prompts. The dispatcher wakes 00; 00 reviews, updates the board, and chooses the next worker.
- `BLOCKED`, `BACKLOG`, and `READY` tasks are never treated as execution commands.
- 00 chooses the next worker based on critical path, player-visible value, dependency order, and rework risk — not on keeping every chat busy.

Preferred default flow:

`READY queue -> 00 selects one -> IN_PROGRESS -> worker produces GitHub delta -> NEEDS_REVIEW -> 00 reviews -> DONE/correction -> 00 selects next`

## Fresh-control barrier and dispatch lease
The CLI does not know the game's development sequence by itself. It reads GitHub state and executes decisions written by 00.

Therefore every dispatcher startup/resume must begin with a **fresh 00 control heartbeat before any worker message is sent**, even if `TASK_BOARD.md` already contains an old `IN_PROGRESS` task.

Rules:
- On startup/resume, freeze 01-07 and wake 00 first.
- The worker freeze remains in place until 00 finishes the heartbeat and writes a fresh result to either `TASK_BOARD.md` or `agent-reports/orchestrator.md`.
- After the fresh 00 write, the dispatcher re-reads GitHub on a new polling cycle. It must not dispatch from the stale pre-heartbeat board snapshot.
- Any new `NEEDS_REVIEW`, multiple-`IN_PROGRESS` contradiction, missing branch, or other control-plane anomaly re-engages the same barrier: 00 first, workers frozen until a fresh control write.
- Worker branch commits alone do not authorize another chat prompt.
- One `IN_PROGRESS` task gets one automatic worker prompt per dispatch lease. Repeated worker prompts are not generated merely because the branch SHA changes.
- If 00 intentionally wants to re-dispatch the same task, add or increment `Dispatch-Revision: N` inside that task entry. A new revision creates a new dispatch lease.
- A stalled worker is escalated to 00 for a decision; the CLI must not autonomously keep telling the worker to continue.

This prevents an old `IN_PROGRESS` marker from bypassing the control plane after a restart and prevents message volume from being mistaken for development progress.

## Orchestrator heartbeat
On every orchestrator wake/run, execute this loop in order:

1. Read `docs/agents/TASK_BOARD.md` from `orchestrator/multi-agent-bootstrap`.
2. Read all current worker reports for lanes 01-07.
3. Inspect the referenced worker branches / exact SHAs for any report in `NEEDS_REVIEW`.
4. Review completed work immediately; do not wait for unrelated workers.
5. Update `TASK_BOARD.md` only after review:
   - accepted -> `DONE`
   - incomplete/incorrect -> create a narrow correction task or return it to worker
   - execution-context blocked -> `BLOCKED` with exact blocker
6. Maintain useful future work as `READY`, but do not wake READY workers. After reviews/dependency reconciliation, choose the single highest-value executable task and promote only that task to `IN_PROGRESS`. Add/increment `Dispatch-Revision` only when a fresh worker prompt is actually intended.
7. If more than one ordinary web task is `IN_PROGRESS` and no explicit `Parallel dispatch: YES` exists, reconcile immediately back to one active execution lane.
8. Keep scopes non-overlapping and respect `FILE_OWNERSHIP.md`.
9. When a task needs real Godot, terminal, browser, Web export, screenshots, audio audition, or exact-SHA runtime evidence, package a single narrow Codex/Local QA task instead of asking web workers to fake runtime proof.
10. Art/animation and audio production are separate lanes: 00 may specify requirements and acceptance criteria but must not substitute itself for asset production.
11. `07-Game-Director` defines player experience, mainline, pacing and prioritization; it does not directly own gameplay source, art assets or narrative production unless the task board explicitly grants a narrow file.
12. Record the orchestrator's current state in `agent-reports/orchestrator.md`.
13. Stop the loop only when one of these is true:
   - all queued work is waiting on a user/product decision,
   - all executable work is blocked on real runtime/Codex execution,
   - no safe next task exists,
   - release/integration gate is ready for user approval,
   - the user has explicitly paused development.

## Dispatch policy
The orchestrator should optimize for **finished GitHub output**, not number of active chats.

Do not create or activate work simply to keep a lane busy. Do not wake multiple workers just because several tasks are READY. Choose the next lane only when its inputs are sufficiently stable that useful work can be completed without predictable rework.

For dependency chains, prefer finishing the blocker first. Example: if Scene/UI requires an objective-state API from Gameplay, keep Scene/UI queued and dispatch Gameplay first.

When development is explicitly paused, preserve queued READY tasks but do not promote them to IN_PROGRESS.

## Current-cycle priority order
1. Review any `NEEDS_REVIEW` worker report.
2. Resolve coordination contradictions / stale task state.
3. If multiple ordinary web tasks are IN_PROGRESS without explicit parallel authorization, choose the critical-path winner and return the others to READY.
4. Apply Game Director product priorities to task ordering without allowing 07 to edit coordination files directly.
5. Select **one** next executable web task from the READY queue and mark it IN_PROGRESS. Increment its `Dispatch-Revision` only if a new worker prompt is intended.
6. Refresh QA integration/runtime manifest only when it adds new integration value; do not generate report-only busywork.
7. Escalate only the minimum required exact-SHA package to Codex/local execution.
8. After runtime evidence, form one deterministic integration candidate and review before touching `main`.

## Automation model
For regular ChatGPT web conversations, the chat does not automatically wake on a GitHub commit by itself. Therefore 00 needs an external wake mechanism.

Preferred low-cost mode is the local CityLife Dispatcher. A scheduled ChatGPT automation may be used only as an intentional fallback; do not run it simultaneously with the local dispatcher.

Dispatcher contract:
- keep 00 available as the control plane;
- on every startup/resume, send the first automatic message to 00 and block all workers until a fresh 00 GitHub write is observed;
- lazily open/wake only the worker whose task is currently `IN_PROGRESS` after that fresh-control barrier clears;
- do not auto-open all 01-07 chats at startup;
- do not dispatch READY tasks;
- send at most one worker prompt per `Dispatch-Revision`;
- worker GitHub/report progress, not chat-message count, is the progress signal;
- when a worker reaches `NEEDS_REVIEW`, re-engage the 00 barrier before any next worker is dispatched;
- every wake is idempotent: unchanged worker/report/branch/control state must not create duplicate prompts or duplicate edits.

## Required orchestrator output per heartbeat
Update `agent-reports/orchestrator.md` with:
- heartbeat timestamp / run sequence label
- worker state summary for 01-07
- reviews completed this run
- task-board changes made
- queued READY tasks
- the single currently selected IN_PROGRESS worker/task (or explicit reason none is selected)
- current `Dispatch-Revision` for the selected worker when a new dispatch is intended
- Codex/runtime escalations waiting
- art/audio asset-production blockers
- user/product decisions waiting
- integration readiness / blockers
