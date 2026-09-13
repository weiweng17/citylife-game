extends SceneTree
## GAME-FIX-004: save/load re-entry must keep terminal evaluation centralized and idempotent.

const GAME_PATH := "res://scripts/Game.gd"

func _init() -> void:
	call_deferred("run")


func run() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	if file == null:
		push_error("GAME-FIX-004 FAIL: cannot read %s" % GAME_PATH)
		quit(1)
		return
	var source := file.get_as_text()
	file.close()
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
			errors.append("loaded payload does not restore started runtime state before settlement")
		if load_section.find("apply_save_payload(") < 0:
			errors.append("_load_game no longer routes through apply_save_payload")
		if load_section.find("_show_ending(") >= 0 or load_section.find("death_reason(") >= 0:
			errors.append("_load_game bypasses the authoritative terminal evaluator")
		if process_section.find("_evaluate_terminal_state()") < 0:
			errors.append("post-load settled frame no longer routes through _evaluate_terminal_state")
		if evaluator_section.find("if game_over:") < 0 or evaluator_section.find("return true") < 0:
			errors.append("authoritative evaluator lost its game_over idempotency guard")
		if evaluator_section.find("rules_sys.death_reason(st)") < 0:
			errors.append("authoritative evaluator no longer owns terminal reason evaluation")
		if evaluator_section.find("_show_ending(reason, st)") < 0:
			errors.append("authoritative evaluator no longer owns the ending transition")
		if source.count("rules_sys.death_reason(") != 1:
			errors.append("death_reason must still have exactly one authoritative Game.gd call site")

	if not errors.is_empty():
		for error in errors:
			push_error("GAME-FIX-004 FAIL: %s" % error)
		quit(1)
		return

	# Runtime package: exercise payload replacement plus the shared evaluator without touching user:// saves.
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	if main.dialog_ui:
		main.dialog_ui.close_dialog()
	main.set_process(false)

	var nonterminal_payload: Dictionary = main.build_save_payload().duplicate(true)
	var nonterminal_state: Dictionary = nonterminal_payload.get("game_state", {}).duplicate(true)
	nonterminal_state["health"] = 50
	nonterminal_state["mood"] = 50
	nonterminal_payload["game_state"] = nonterminal_state

	# Re-enter from a prior terminal runtime into a healthy save: the latch must clear and stay playable.
	main.game_over = true
	if main.ending_ui:
		main.ending_ui.show_ending("stale", "stale")
	main.apply_save_payload(nonterminal_payload)
	if main.ending_ui:
		main.ending_ui.close()
	assert(main.game_started, "non-terminal load must restore started state")
	assert(not main.game_over, "non-terminal load must clear prior terminal latch")
	assert(not main._evaluate_terminal_state(), "non-terminal loaded state must remain playable")
	assert(not main.game_over, "non-terminal evaluation must not set game_over")

	# Terminal payload: load clears the old latch, then the same authoritative evaluator settles it once.
	var terminal_payload: Dictionary = nonterminal_payload.duplicate(true)
	var terminal_state: Dictionary = terminal_payload.get("game_state", {}).duplicate(true)
	terminal_state["health"] = 0
	terminal_payload["game_state"] = terminal_state
	main.apply_save_payload(terminal_payload)
	if main.ending_ui:
		main.ending_ui.close()
	assert(not main.game_over, "payload replacement must clear stale game_over before re-evaluation")
	assert(main._evaluate_terminal_state(), "terminal loaded state must settle through shared evaluator")
	assert(main.game_over, "terminal settlement must set game_over")
	assert(main.ending_ui != null and main.ending_ui.visible, "terminal settlement must show existing ending UI")
	var first_title: String = main.ending_ui.title_label.text
	var first_desc: String = main.ending_ui.desc_label.text

	# Refresh/re-entry after settlement must be idempotent and preserve the first ending presentation.
	main._refresh_ui()
	assert(main._evaluate_terminal_state(), "already-settled terminal state must remain terminal")
	assert(main.ending_ui.title_label.text == first_title, "re-entry must not replace ending title")
	assert(main.ending_ui.desc_label.text == first_desc, "re-entry must not replace ending description")

	# Loading a healthy payload after a terminal runtime must recover playability without schema changes.
	main.apply_save_payload(nonterminal_payload)
	if main.ending_ui:
		main.ending_ui.close()
	assert(not main.game_over, "healthy reload must clear terminal latch")
	assert(not main._evaluate_terminal_state(), "healthy reload must not be terminal")
	assert(main.game_started, "healthy reload must remain playable")

	print("GAME-FIX-004 PASS: save/load re-entry preserves centralized terminal evaluation and idempotency")
	quit(0)
