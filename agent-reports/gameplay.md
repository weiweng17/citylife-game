# Gameplay Agent Report

## Task
- ID: GAME-FIX-004
- Agent: gameplay
- Branch/worktree: `agent/game-fix-004-save-terminal-reentry`
- Status: NEEDS_REVIEW

## Scope
Save/load terminal-state re-entry hardening only. Authorized paths are `scripts/Game.gd`, one narrow `tools/verify_*.gd` regression, and this report. No `main`, coordination files, `LocationManager.gd`, UI/NPC assets, data/schema, or unrelated gameplay systems were modified.

## Dependency alignment
The assigned GAME-FIX-004 branch was initially created from `orchestrator/multi-agent-bootstrap`, which did not contain the already accepted GAME-FIX-003 source implementation. Because GAME-FIX-004 explicitly depends on the existing authoritative `_evaluate_terminal_state()` contract, this isolated branch was aligned to the accepted GAME-FIX-003 tip `9ae0e807a59cba366a6013f61f22ab8d76000c82` before adding GAME-FIX-004 verification.

No new terminal thresholds, ending semantics, balance values, save fields, or schema changes were introduced.

## Repository finding
The accepted GAME-FIX-003 implementation already establishes the required re-entry behavior:
- `apply_save_payload()` clears the prior runtime `game_over` latch and restores `game_started = true` after replacing the loaded state.
- `_load_game()` routes state replacement only through `apply_save_payload()` and does not call `Rules.death_reason()` or `_show_ending()` directly.
- the next settled `_process()` pass routes terminal evaluation through the authoritative `_evaluate_terminal_state()` path.
- `_evaluate_terminal_state()` owns the only direct `rules_sys.death_reason(st)` consumption in `Game.gd` and guards `if game_over: return true`, so later refresh/process re-entry cannot trigger a second ending transition after the first terminal settlement.
- non-terminal loaded states therefore remain playable, while terminal loaded states are evaluated by the same centralized path as ordinary gameplay.

Because the accepted dependency already satisfies the GAME-FIX-004 behavior contract, this task does not add a second save-specific terminal path to `Game.gd`; doing so would duplicate the evaluator and violate GAME-FIX-003's centralization goal.

## Changes
### `tools/verify_save_terminal_reentry.gd`
Added one narrow repository/headless regression that checks:
1. `apply_save_payload()` resets the prior runtime terminal latch and restores started state;
2. `_load_game()` still routes through `apply_save_payload()`;
3. `_load_game()` does not bypass the authoritative evaluator with direct `_show_ending()` / `death_reason()` calls;
4. post-load frame settlement still calls `_evaluate_terminal_state()`;
5. the evaluator retains the `game_over` idempotency guard;
6. the evaluator remains the owner of `rules_sys.death_reason(st)` and `_show_ending(reason, st)`.

Regression commit: `cda80b471955b5c3b30131c062a02788b41005a2` (`test: guard save/load terminal re-entry contract`).

## Validation
No Godot/Web/browser runtime was available in this worker execution. No runtime PASS is claimed.

Prepared focused QA/local command:
`godot --headless --path . --script res://tools/verify_save_terminal_reentry.gd`

Expected successful output:
`GAME-FIX-004 PASS: save/load re-entry preserves centralized terminal evaluation and idempotency`

The pre-existing GAME-FIX-003 focused regression should also be rerun on the exact candidate SHA:
`godot --headless --path . --script res://tools/verify_terminal_state_evaluation.gd`

## Files changed by this task after dependency alignment
- `tools/verify_save_terminal_reentry.gd` — added narrow regression.
- `agent-reports/gameplay.md` — this handoff.

The inherited `scripts/Game.gd` change is the already accepted GAME-FIX-003 implementation required by this task's stated dependency; GAME-FIX-004 itself adds no unrelated source semantics.

## Risk / integration note
GAME-FIX-001 and GAME-FIX-002 are still separate reviewed gameplay branches touching `scripts/Game.gd`. Integration QA must combine the accepted gameplay work onto one exact candidate SHA and rerun the narrow gameplay regressions there; this worker does not merge into `main` or coordination branches.

## Handoff
GAME-FIX-004 is ready for orchestrator review at repository level. Requested task status: `NEEDS_REVIEW`. Fresh Godot execution remains pending QA/local acceptance and must not be inferred from this report.
