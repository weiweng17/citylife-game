# Multi-Agent Development Rules

## Purpose
This document defines how autonomous development agents work in this repository.

## Core rules
1. Never commit directly to `main`.
2. Every task gets its own branch or isolated worktree.
3. An agent may only modify files explicitly assigned to its task.
4. Before editing, read `MASTER_PLAN.md`, `TASK_BOARD.md`, `FILE_OWNERSHIP.md`, and the latest relevant report.
5. Do not overwrite another agent's in-progress files.
6. Every completed task must include: changed files, test result, known risks, and handoff notes.
7. Broken builds, missing assets, parser errors, console errors, and unreviewed merge conflicts are blockers.
8. The orchestrator is the only role allowed to approve integration into `main`.

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

## Completion report
Agents must update their report with:
- Status: DONE / BLOCKED / NEEDS_REVIEW
- Summary
- Files changed
- Tests performed
- Screenshots or URLs when relevant
- Known issues
- Suggested next task
