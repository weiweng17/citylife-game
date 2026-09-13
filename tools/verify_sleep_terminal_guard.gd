extends SceneTree
## GAME-FIX-007：过夜需求结算跨过终局阈值时，必须在睡眠恢复前走统一终止判定。

const GAME_PATH := "res://scripts/Game.gd"


func _init() -> void:
	call_deferred("run")


func run() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	assert(file != null, "must be able to read Game.gd")
	var source := file.get_as_text()
	file.close()

	# 结构契约：仍只有统一 evaluator 直接消费 death_reason。
	assert(source.count("rules_sys.death_reason(") == 1, "death_reason must remain centralized")
	var evaluator := _function_block(source, "func _evaluate_terminal_state() -> bool:")
	assert(not evaluator.is_empty(), "missing authoritative terminal evaluator")
	assert("if game_over:" in evaluator, "terminal evaluator must remain idempotent")

	# 睡眠调用顺序必须是：时间需求结算 -> 统一终止判定 -> 非终止才恢复属性。
	var sleep_block := _function_block(source, "func _sleep_through_night() -> String:")
	assert(not sleep_block.is_empty(), "missing overnight sleep helper")
	var sync_pos := sleep_block.find("_sync_needs_to_time()")
	var eval_pos := sleep_block.find("_evaluate_terminal_state()")
	var health_recover_pos := sleep_block.find("health = mini(100, health + 12)")
	var mood_recover_pos := sleep_block.find("mood = mini(100, mood + 8)")
	assert(sync_pos >= 0, "overnight sleep must settle elapsed needs")
	assert(eval_pos > sync_pos, "overnight terminal evaluation must follow need settlement")
	assert(health_recover_pos > eval_pos, "health recovery must happen only after terminal evaluation")
	assert(mood_recover_pos > eval_pos, "mood recovery must happen only after terminal evaluation")
	assert("if _evaluate_terminal_state():\n\t\treturn \"\"" in sleep_block, "terminal overnight sleep must stop before recovery")

	# 调用方必须先结束活动锁，再停止普通睡醒后的 toast/completion 流程。
	var home_block := _function_block(source, "func _on_home_activity(id: String) -> void:")
	assert(not home_block.is_empty(), "missing home activity handler")
	var sleep_call_pos := home_block.find("feedback = _sleep_through_night()")
	var terminal_guard_pos := home_block.find("if game_over:", sleep_call_pos)
	var end_activity_pos := home_block.find("_end_activity()", terminal_guard_pos)
	var terminal_return_pos := home_block.find("return", end_activity_pos)
	assert(sleep_call_pos >= 0 and terminal_guard_pos > sleep_call_pos, "home rest must inspect terminal result after overnight sleep")
	assert(end_activity_pos > terminal_guard_pos and terminal_return_pos > end_activity_pos, "terminal sleep must release activity lock and return")

	# FIX-002 的小时 cadence 必须仍在，因为本修复依赖它产生的真实终止状态。
	var needs_block := _function_block(source, "func _sync_needs_to_time() -> void:")
	var loop_pos := needs_block.find("while need_fraction >= 1.0:")
	var fullness_penalty_pos := needs_block.find("if fullness <= 0:")
	var energy_penalty_pos := needs_block.find("if energy <= 0:")
	assert(loop_pos >= 0 and fullness_penalty_pos > loop_pos and energy_penalty_pos > loop_pos, "zero-need penalties must remain inside completed-hour loop")

	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)

	# 健康终止：20:00 睡到 07:30，零饱食会按小时扣健康。到 0 后不能被 +12 睡眠恢复救回。
	_prepare_overnight_case(main)
	main.health = 2
	main.mood = 100
	main.fullness = 0
	main.energy = 100
	var health_feedback: String = main._sleep_through_night()
	assert(main.game_over, "zero health reached during overnight settlement must end the run")
	assert(main.health == 0, "terminal health must not be revived by sleep recovery")
	assert(main.ending_ui.visible, "health terminal settlement must use existing ending UI")
	assert(health_feedback.is_empty(), "terminal overnight sleep must not produce normal wake feedback")
	var first_title: String = main.ending_ui.title_label.text
	var first_desc: String = main.ending_ui.desc_label.text
	assert(main._evaluate_terminal_state(), "repeated terminal evaluation must remain terminal")
	assert(main.ending_ui.title_label.text == first_title and main.ending_ui.desc_label.text == first_desc, "terminal re-entry must remain idempotent")

	# 心情终止：零精力的小时惩罚到 0 后，同样不能先 +8 再逃过终止判定。
	_prepare_overnight_case(main)
	main.health = 100
	main.mood = 2
	main.fullness = 100
	main.energy = 0
	var mood_feedback: String = main._sleep_through_night()
	assert(main.game_over, "zero mood reached during overnight settlement must end the run")
	assert(main.mood == 0, "terminal mood must not be revived by sleep recovery")
	assert(main.ending_ui.visible, "mood terminal settlement must use existing ending UI")
	assert(mood_feedback.is_empty(), "terminal mood sleep must not produce normal wake feedback")

	# 非终止过夜仍保持原有恢复值和可玩状态。
	_prepare_overnight_case(main)
	main.health = 80
	main.mood = 80
	main.fullness = 100
	main.energy = 100
	var normal_feedback: String = main._sleep_through_night()
	assert(not main.game_over, "healthy overnight sleep must remain playable")
	assert(main.health == 92, "non-terminal sleep must preserve +12 health recovery, got %d" % main.health)
	assert(main.mood == 88, "non-terminal sleep must preserve +8 mood recovery, got %d" % main.mood)
	assert(main.energy == 100, "non-terminal sleep must still restore energy to 100")
	assert(not normal_feedback.is_empty(), "non-terminal sleep must keep normal wake feedback")

	print("GAME-FIX-007 PASS: overnight settlement observes terminal thresholds before sleep recovery")
	quit(0)


func _prepare_overnight_case(main) -> void:
	main.game_over = false
	main.game_started = true
	main.ending_ui.close()
	main.time_sys.apply_save_dict({"day": 1, "minute_of_day": 20 * 60, "speed": 2.0})
	main.need_fraction = 0.0
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.murmur_shown = {"fullness": 2, "energy": 2}
	if main.daily_routine:
		main.daily_routine.reset(1)


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
