extends SceneTree
## GAME-FIX-009：终止状态必须在任务奖励或下一次背包恢复操作前被 authoritative evaluator 观察到。

const GAME_PATH := "res://scripts/Game.gd"


func _init() -> void:
	call_deferred("run")


func run() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	assert(file != null, "must be able to read Game.gd")
	var source := file.get_as_text()
	file.close()

	# 仍然只有统一 evaluator 直接消费 death_reason。
	assert(source.count("rules_sys.death_reason(") == 1, "death_reason must remain centralized")
	var evaluator := _function_block(source, "func _evaluate_terminal_state() -> bool:")
	assert(not evaluator.is_empty(), "missing authoritative terminal evaluator")
	assert("if game_over:" in evaluator, "terminal evaluator must remain idempotent")

	# Settled non-busy frame：need settlement -> terminal observation -> reward-bearing quest mutation。
	var process_block := _function_block(source, "func _process(delta: float) -> void:")
	var sync_pos := process_block.find("_sync_needs_to_time()")
	var eval_pos := process_block.find("_evaluate_terminal_state()")
	var quest_pos := process_block.find("_evaluate_quests()")
	assert(sync_pos >= 0 and eval_pos > sync_pos, "process must settle needs before terminal evaluation")
	assert(quest_pos > eval_pos, "quest mutation must occur only after terminal observation")
	assert(process_block.find("_evaluate_quests()", 0) == quest_pos, "process must not retain a pre-terminal quest evaluation")

	# 背包耗时：拒绝 game_over mutation；item time -> settle -> evaluator -> only then normal completion。
	var shop_block := _function_block(source, "func _on_shop_use(item_id: String) -> void:")
	var game_over_guard := shop_block.find("if game_over")
	var remove_pos := shop_block.find("inventory.remove")
	var advance_pos := shop_block.find("time_sys.advance_minutes(minutes)")
	var shop_sync_pos := shop_block.find("_sync_needs_to_time()")
	var shop_eval_pos := shop_block.find("_evaluate_terminal_state()")
	var close_pos := shop_block.find("shop_ui.close()")
	var normal_refresh_pos := shop_block.find("shop_ui.refresh(money, inventory)")
	assert(game_over_guard >= 0 and game_over_guard < remove_pos, "game_over must reject item mutation before inventory removal")
	assert(advance_pos >= 0 and shop_sync_pos > advance_pos, "item elapsed time must settle synchronously")
	assert(shop_eval_pos > shop_sync_pos, "shop terminal evaluation must follow need settlement")
	assert(close_pos > shop_eval_pos, "terminal shop path must close the persistent panel")
	assert(normal_refresh_pos > shop_eval_pos, "normal shop completion must happen only after terminal evaluation")

	# GAME-FIX-007 仍然保持：overnight settlement evaluator precedes recovery。
	var sleep_block := _function_block(source, "func _sleep_through_night() -> String:")
	var sleep_sync_pos := sleep_block.find("_sync_needs_to_time()")
	var sleep_eval_pos := sleep_block.find("_evaluate_terminal_state()")
	var sleep_recover_pos := sleep_block.find("health = mini(100, health + 12)")
	assert(sleep_sync_pos >= 0 and sleep_eval_pos > sleep_sync_pos and sleep_recover_pos > sleep_eval_pos, "GAME-FIX-007 sleep ordering must remain intact")

	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.set_process(false)
	_reset_case(main)

	# 1) 已经 terminal 的 q1-ready 状态：q1 的 mood+8 不能先把 mood=0 救回来。
	_prime_q1(main)
	main.mood = 0
	main._process(0.0)
	assert(main.game_over, "terminal mood must be observed before quest reward")
	assert(main.mood == 0, "q1 reward must not revive terminal mood")
	assert(not main.quest_sys.is_done(main._state(), "q1_stand_firm"), "terminal frame must return before completing q1")

	# 2) pending need settlement 先把 mood 2 扣到 0，也必须在 q1 奖励之前结束。
	_reset_case(main)
	_prime_q1(main)
	main.mood = 2
	main.energy = 0
	main.fullness = 100
	main.health = 100
	main.need_fraction = 55.0 / 60.0
	_set_time_baseline(main)
	main.time_sys.advance_minutes(5)
	main._process(0.0)
	assert(main.game_over, "pending need settlement must be terminal before quest reward")
	assert(main.mood == 0, "settled terminal mood must not be revived by q1")
	assert(not main.quest_sys.is_done(main._state(), "q1_stand_firm"), "q1 must remain uncompleted on the terminal frame")

	# 3) 非 terminal q1 仍按原奖励正常结算。
	_reset_case(main)
	_prime_q1(main)
	main.mood = 50
	main._process(0.0)
	assert(not main.game_over, "healthy q1 completion must remain playable")
	assert(main.quest_sys.is_done(main._state(), "q1_stand_firm"), "healthy q1 must still complete")
	assert(main.mood == 58, "q1 must preserve its +8 mood reward, got %d" % main.mood)

	# 4) 背包耗时使 health 触底：同一次 use 内立即终止并收起背包；第二件药不能复活。
	_reset_case(main)
	main.health = 2
	main.mood = 100
	main.fullness = 0
	main.energy = 100
	main.need_fraction = 55.0 / 60.0
	_set_time_baseline(main)
	main.inventory.add("canned_coffee", 1)
	main.inventory.add("cold_medicine", 1)
	main.shop_ui.open_bag(main.money, main.inventory)
	main._on_shop_use("canned_coffee")
	assert(main.game_over, "item elapsed-time settlement must observe terminal health synchronously")
	assert(main.health == 0, "terminal health must remain zero after first item")
	assert(not main.shop_ui.is_open(), "terminal shop-use path must close the backpack")
	assert(main.ending_ui.visible, "terminal shop settlement must use existing ending UI")
	var medicine_before: int = main.inventory.count("cold_medicine")
	main._on_shop_use("cold_medicine")
	assert(main.health == 0, "game_over must reject later health-restoring item use")
	assert(main.inventory.count("cold_medicine") == medicine_before, "game_over item use must not consume inventory")

	# 5) 普通非 terminal 物品使用仍保持效果、耗时和背包连续操作语义。
	_reset_case(main)
	main.health = 50
	main.mood = 100
	main.fullness = 80
	main.energy = 100
	_set_time_baseline(main)
	var before_minute: int = main.time_sys.get_minute_of_day()
	main.inventory.add("milk", 1)
	main.shop_ui.open_bag(main.money, main.inventory)
	main._on_shop_use("milk")
	assert(not main.game_over, "healthy item use must remain playable")
	assert(main.health == 54, "milk must preserve +4 health effect, got %d" % main.health)
	assert(main.inventory.count("milk") == 0, "normal item use must still consume the item")
	assert(main.shop_ui.is_open(), "non-terminal item use must keep backpack open")
	assert(main.time_sys.get_minute_of_day() == before_minute + 6, "milk must preserve its 6-minute time cost")

	print("GAME-FIX-009 PASS: settled terminal states precede quest rewards and repeated backpack recovery")
	quit(0)


func _reset_case(main) -> void:
	var origin: Dictionary = main.Data.ORIGINS[0]
	main.game_state.reset_from_origin(origin.get("init", {}), str(origin.get("flag", "")))
	main.origin = origin
	main.game_started = true
	main.game_over = false
	main.activity_running = false
	main.dialog_queue.clear()
	main.dialog_pending_clue = ""
	main.dialog_pending_npc = ""
	main.cur_event = null
	main.cur_event_kind = "event"
	main.cur_event_time_cost = 0
	main.dialog_ui.close_dialog()
	main.event_ui.close_event()
	main.ending_ui.close()
	if main.shop_ui.is_open():
		main.shop_ui.close()
	main.time_sys.reset()
	if main.daily_routine:
		main.daily_routine.reset(main.time_sys.day)
	if main.inventory:
		main.inventory.reset()
	main.need_fraction = 0.0
	main.murmur_shown = {"fullness": main.time_sys.day, "energy": main.time_sys.day}
	_set_time_baseline(main)


func _prime_q1(main) -> void:
	main.skill = 55
	main.money = 3000
	main.quest_sys.notify(main._state(), "work_shift")
	main.quest_sys.notify(main._state(), "meal_cooked")


func _set_time_baseline(main) -> void:
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
