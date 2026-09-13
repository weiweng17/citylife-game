# Multi-Agent Development Rules

## Purpose
This document defines how autonomous development agents work in this repository.

## Core rules
1. Never commit directly to `main`.
2. Every implementation task gets its own branch or isolated worktree. Repository-only audit tasks may use an orchestrator-created audit branch and may write only their assigned report.
3. An agent may only modify files explicitly assigned to its task.
4. Before editing, read `MASTER_PLAN.md`, `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, and the latest relevant report.
5. Do not overwrite another agent's in-progress files.
6. Every completed task must include: changed files, test result, known risks, and handoff notes.
7. Broken builds, missing assets, parser errors, console errors, and unreviewed merge conflicts are blockers.
8. The orchestrator is the only role allowed to approve integration into `main`.
9. `docs/agents/TASK_BOARD.md` is orchestrator-owned. Workers must not edit task status directly. A worker requests review by setting its own `agent-reports/<role>.md` status to `NEEDS_REVIEW`; the orchestrator audits the report/diff and then updates the task board.
10. A web agent must clearly separate repository-verified findings from checks that require Godot, terminal, CI, browser runtime, or Codex. Never report an unperformed runtime/build test as passed.

## Standard roles
- `orchestrator`: task decomposition, scheduling, review, integration, acceptance.
- `gameplay`: game logic, player systems, interaction systems.
- `scene-ui`: Godot scenes, HUD, menus, layout and interaction polish.
- `npc-content`: NPC behavior, dialogue, events and narrative content.
- `qa-build`: regression testing, web export, deployment verification, bug reporting.

## Task contract
Each task must define:
- Task ID
- Owner
- Branch
- Objective
- Allowed files/directories
- Forbidden files/directories
- Acceptance criteria
- Test command or test procedure

## Status ownership
- `READY`: orchestrator has issued a task contract; worker has not started.
- `IN_PROGRESS`: orchestrator records that the worker has started and the declared files are locked.
- `NEEDS_REVIEW`: worker report is ready; orchestrator has not accepted it yet.
- `DONE`: orchestrator accepted the task.
- `BLOCKED`: work cannot proceed because of a dependency, asset, permission, or decision.

Workers write their requested status in their own report. The orchestrator is the authority that mirrors accepted status changes into `TASK_BOARD.md`.

## Completion report
Agents must update their report with:
- Status: DONE / BLOCKED / NEEDS_REVIEW
- Summary
- Files changed
- Tests performed
- Screenshots or URLs when relevant
- Known issues
- Suggested next task
