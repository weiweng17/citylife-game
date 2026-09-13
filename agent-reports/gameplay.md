# Gameplay Agent Report

## Task
- ID: GAME-FIX-004
- Agent: gameplay
- Branch/worktree: `agent/game-fix-004-save-terminal-reentry`
- Status: NEEDS_REVIEW

## Scope
Save/load terminal-state re-entry hardening only. Authorized paths are `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression, and this report. No `main`, coordination files, `LocationManager.gd`, UI/NPC assets, data/schema, or unrelated gameplay systems were modified by this task.

## Dependency alignment
The assigned GAME-FIX-004 branch was initially created from `orchestrator/multi-agent-bootstrap`, which did not yet contain the already accepted GAME-FIX-003 source implementation. GAME-FIX-004 explicitly depends on the existing authoritative `_evaluate_terminal_state()` contract, so this isolated branch is based on the accepted GAME-FIX-003 tip `9ae0e807a59cba366a6013f61f22ab8d76000c82`.

No new terminal thresholds, ending semantics, balance values, save fields, or schema changes were introduced.

## Repository finding
The accepted GAME-FIX-003 implementation already establishes the required save/load re-entry behavior without adding a second save-specific terminal path:
- `apply_save_payload()` clears the prior runtime `game_over` latch and restores `game_started = true` after replacing loaded state;
- `_load_game()` routes state replacement through `apply_save_payload()` and does not call `Rules.death_reason()` or `_show_ending()` directly;
- the next settled `_process()` pass routes terminal evaluation through the authoritative `_evaluate_terminal_state()` path;
- `_evaluate_terminal_state()` owns the only direct `rules_sys.death_reason(st)` consumption in `Game.gd` and guards `if game_over: return true`, preventing duplicate ending transitions after settlement;
- non-terminal loaded states therefore remain playable, while terminal loaded states settle through the same centralized path as ordinary gameplay.

Because the accepted dependency already satisfies the gameplay behavior contract, GAME-FIX-004 does not duplicate or fork terminal evaluation logic in `Game.gd`.

## Changes
### `tools/verify_save_terminal_reentry.gd`
Added and then strengthened one narrow runtime-capable headless regression package.

Repository-contract checks verify:
1. `apply_save_payload()` clears the stale `game_over` latch and restores started state;
2. `_load_game()` still routes through `apply_save_payload()`;
3. `_load_game()` does not bypass the authoritative evaluator with direct `_show_ending()` / `death_reason()` calls;
4. post-load settled-frame processing still routes through `_evaluate_terminal_state()`;
5. the evaluator retains the `game_over` idempotency guard;
6. `Game.gd` still has exactly one direct `rules_sys.death_reason(...)` call site owned by the evaluator.

Runtime package checks, when Godot is actually executed, cover:
- re-entry from a prior terminal runtime into a healthy payload clears `game_over` and remains playable;
- loading a terminal payload clears the stale latch, then the shared evaluator settles the ending;
- repeated refresh/evaluator re-entry after terminal settlement is idempotent and preserves the first ending title/description;
- loading a healthy payload again after terminal settlement recovers normal playability.

Initial regression commit: `cda80b471955b5c3b30131c062a02788b41005a2` (`test: guard save/load terminal re-entry contract`).
Strengthened regression commit: `4e10f50c4ae33ba4112c65d4a65ce7e38945ef2a` (`test: exercise save terminal re-entry contract`).

## Repository verification performed
Fresh GitHub comparison against the accepted GAME-FIX-003 tip confirms GAME-FIX-004's own diff is limited to:
- `tools/verify_save_terminal_reentry.gd` — added narrow regression package;
- `agent-reports/gameplay.md` — this handoff.

The inherited `scripts/Game.gd` and `tools/verify_terminal_state_evaluation.gd` are the already accepted GAME-FIX-003 dependency, not new GAME-FIX-004 semantics.

## Runtime validation not performed
No Godot/Web/browser runtime was available in this web-agent execution. No runtime PASS is claimed.

Prepared focused command for QA/local execution:
`godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd`

Expected successful output ends with:
`GAME-FIX-004 PASS: save/load re-entry preserves centralized terminal evaluation and idempotency`

The dependency regression should also be rerun on the exact candidate SHA:
`godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd`

## Integration risk
The latest coordination branch has advanced in review metadata while this task branch intentionally sits on the accepted GAME-FIX-003 dependency line. Multiple accepted gameplay tasks (`GAME-FIX-001` through `GAME-FIX-004`) overlap `scripts/Game.gd`; QA-006 owns the repository-only integration/conflict manifest. This worker does not merge into `main` or the coordination branch and does not claim cross-branch runtime compatibility.

## Handoff
GAME-FIX-004 is ready for orchestrator review at repository level. Requested task status: `NEEDS_REVIEW`. Fresh Godot execution remains pending QA/local acceptance and must not be inferred from repository inspection.
