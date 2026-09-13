extends SceneTree

const GAME_PATH := "res://scripts/Game.gd"

func _init() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	if file == null:
		push_error("GAME-FIX-004 FAIL: cannot read %s" % GAME_PATH)
		quit(1)
		return
	var source := file.get_as_text()
	var errors: Array[String] = []

	var apply_start := source.find("func apply_save_payload(payload: Dictionary) -> void:")
	var load_start := source.find("func _load_game() -> void:")
	var process_start := source.find("func _process(delta: float) -> void:")
	var evaluator_start := source.find("func _evaluate_terminal_state() -> bool:")
	var fmt_start := source.find("func _fmt_money", evaluator_start)

	if apply_start < 0 or load_start < 0 or process_start < 0 or evaluator_start < 0 or fmt_start < 0:
		errors.append("required save/load/process/evaluator functions are missing")
	else:
		var apply_section := source.substr(apply_start, load_start - apply_start)
		var load_section := source.substr(load_start, process_start - load_start)
		var process_section := source.substr(process_start, evaluator_start - process_start)
		var evaluator_section := source.substr(evaluator_start, fmt_start - evaluator_start)

		if apply_section.find("game_over = false") < 0:
			errors.append("loaded payload does not clear the prior runtime terminal latch before re-evaluation")
		if apply_section.find("game_started = true") < 0:
			errors.append("loaded payload does not restore playable runtime state before settlement")
		if load_section.find("apply_save_payload(") < 0:
			errors.append("_load_game no longer routes through apply_save_payload")
		if load_section.find("_show_ending(") >= 0 or load_section.find("death_reason(") >= 0:
			errors.append("_load_game bypasses the authoritative terminal evaluator")
		if process_section.find("_evaluate_terminal_state()") < 0:
			errors.append("post-load frame settlement no longer routes through _evaluate_terminal_state")
		if evaluator_section.find("if game_over:") < 0 or evaluator_section.find("return true") < 0:
			errors.append("authoritative evaluator lost its game_over idempotency guard")
		if evaluator_section.find("rules_sys.death_reason(st)") < 0:
			errors.append("authoritative evaluator no longer owns terminal reason evaluation")
		if evaluator_section.find("_show_ending(reason, st)") < 0:
			errors.append("authoritative evaluator no longer owns the ending transition")

	if errors.is_empty():
		print("GAME-FIX-004 PASS: save/load re-entry preserves centralized terminal evaluation and idempotency")
		quit(0)
		return

	for error in errors:
		push_error("GAME-FIX-004 FAIL: %s" % error)
	quit(1)
