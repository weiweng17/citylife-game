extends SceneTree
## GAME-FIX-003：所有终止状态通过 Game._evaluate_terminal_state() 统一判定。

const GAME_PATH := "res://scripts/Game.gd"

func _init() -> void:
	call_deferred("run")


func run() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	assert(file != null, "must be able to read Game.gd")
	var source := file.get_as_text()
	file.close()

	# 结构契约：death_reason 只允许出现在统一判定入口，年度结算不能再维护第二份判断。
	assert(source.count("rules_sys.death_reason(") == 1, "death_reason must have one authoritative call site")
	var evaluator := _function_block(source, "func _evaluate_terminal_state() -> bool:")
	assert(not evaluator.is_empty(), "missing _evaluate_terminal_state")
	assert("rules_sys.death_reason(" in evaluator, "terminal evaluator must own death_reason")
	assert("game_over" in evaluator, "terminal evaluator must guard repeated transitions")
	var year_pass := _function_block(source, "func _year_pass() -> void:")
	assert("_evaluate_terminal_state()" in year_pass, "annual settlement must use the shared evaluator")
	assert("rules_sys.death_reason(" not in year_pass, "annual settlement must not duplicate death_reason")
	var process_block := _function_block(source, "func _process(delta: float) -> void:")
	assert("_evaluate_terminal_state()" in process_block, "daily gameplay loop must use the shared evaluator")

	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)

	# 非终止状态继续游戏。
	main.health = 1
	main.mood = 1
	assert(not main._evaluate_terminal_state(), "positive health/mood must remain non-terminal")
	assert(not main.game_over, "non-terminal evaluation must not set game_over")

	# 日常状态触底可直接进入已有结局路径。
	main.health = 0
	assert(main._evaluate_terminal_state(), "zero health must be terminal")
	assert(main.game_over, "terminal evaluation must set game_over through _show_ending")
	assert(main.ending_ui.visible, "terminal evaluation must show the existing ending UI")
	var first_title: String = main.ending_ui.title_label.text
	var first_desc: String = main.ending_ui.desc_label.text

	# 重入必须幂等：已结束后再次判定不能重新计算/替换结局。
	assert(main._evaluate_terminal_state(), "already-ended state should report terminal")
	assert(main.ending_ui.title_label.text == first_title, "re-entry must not replace ending title")
	assert(main.ending_ui.desc_label.text == first_desc, "re-entry must not replace ending description")

	# 心情阈值沿用 Rules.death_reason 的原值，不在 Game 里复制阈值。
	main.game_over = false
	main.ending_ui.close()
	main.health = 100
	main.mood = 0
	assert(main._evaluate_terminal_state(), "zero mood must remain terminal under existing Rules thresholds")
	assert(main.game_over and main.ending_ui.visible, "mood terminal state must use the same ending path")

	print("GAME-FIX-003 PASS: terminal-state evaluation is centralized and idempotent")
	quit(0)


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
