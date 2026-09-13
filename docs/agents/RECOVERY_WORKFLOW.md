# Multi-Agent Recovery Workflow

## Goal
Any agent chat may disappear or be replaced. The project must be recoverable from GitHub without relying on chat memory.

## Source of truth
- `main` is the integrated product source of truth.
- `orchestrator/multi-agent-bootstrap` is the current coordination source of truth while the multi-agent layer is being established.
- `docs/agents/TASK_BOARD.md` is the authoritative task/status/lock register.
- `agent-reports/*.md` are worker handoff records, not the authority for integration status.
- Open pull requests and branch commits are the evidence for proposed code changes.

## Resume procedure for the orchestrator
1. Read `HANDOFF.md` and all files under `docs/agents/` from the coordination branch.
2. Read `docs/ARCHITECTURE.md`, `docs/ITERATION_PLAN.md`, the latest `docs/TODAY_HANDOFF_*.md`, and the latest QA report referenced by the handoff.
3. Inspect current branches and open pull requests.
4. Read every report for tasks marked `IN_PROGRESS`, `NEEDS_REVIEW`, or `BLOCKED`.
5. Compare each worker branch against its declared base/target before accepting anything.
6. Verify that changed files stay inside the task's writable scope. Any unexpected high-conflict file change is a review blocker.
7. Distinguish repository inspection evidence from runtime evidence. If Godot/build/browser execution is required and no actual evidence exists, create a narrow Codex/local validation task instead of assuming success.
8. Update `TASK_BOARD.md` only after the evidence and locks are reconciled.

## Resume procedure for a worker
1. Read the coordination docs and its own latest report.
2. Confirm the assigned task is still `READY` or `IN_PROGRESS` and that its branch matches the task board.
3. Do not take another role's task or edit another role's report.
4. If the branch contains unexpected changes outside the allowed writable scope, stop and set the report to `BLOCKED` with the unexpected paths.
5. Finish by updating only the assigned report to `NEEDS_REVIEW` or `BLOCKED`. Do not edit `TASK_BOARD.md` and do not merge.

## Stale task / lock recovery
A task is considered stale when its report and branch show no usable handoff but the board says `IN_PROGRESS`.

The orchestrator must:
1. Inspect the branch and report before releasing the lock.
2. Preserve any useful commits; never destroy work with force-push/reset as a recovery shortcut.
3. Record why the old attempt was abandoned or blocked.
4. Move the task back to `READY` or create a replacement task with a new branch when isolation is safer.
5. Release or reassign only the explicitly declared writable files.

## Review gate
Before a task becomes `DONE`, the orchestrator checks:
- Task scope and file ownership.
- Diff contains no unrelated edits.
- Report lists changed files, validation, risks and handoff.
- Acceptance criteria are actually evidenced.
- Required runtime/build checks have real Codex/local/CI evidence.
- No unresolved merge conflict, parser/build error, missing asset/reference or unreviewed regression remains.

## Integration recovery
If integration is interrupted:
1. Treat `main` as untouched unless a merge/commit is visible there.
2. Re-read the PR/branch diff and current `main` head; do not assume a previous chat merged anything.
3. Re-run required validation when the target changed materially after the worker's evidence was produced.
4. Integrate only reviewed work. Never use a worker branch as a silent replacement for `main`.
