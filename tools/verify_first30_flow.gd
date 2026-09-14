extends SceneTree
## GAME-CONTENT-013：首日 onboarding gate / objective state 验证包。
## Web worker 只准备该脚本；实际 Godot 执行归 QA-002 frozen integration SHA。

const GAME_PATH := "res://scripts/Game.gd"
const CAFE_PATH := "res://scripts/systems/CafeActivities.gd"


func _init() -> void:
	call_deferred("run")


func run() -> void:
	var game_source := _read(GAME_PATH)
	var cafe_source := _read(CAFE_PATH)

	# 已验收 terminal authority / GAME-CONTENT-012 数值不得被 onboarding 倒退。
	assert(game_source.count("rules_sys.death_reason(") == 1, "death_reason must remain centralized")
	assert("const OVERTIME_MINUTES := 120" in game_source, "overtime minutes must remain 120")
	assert("const OVERTIME_HEALTH_COST := 4" in game_source, "overtime health cost must remain 4")
	assert("const OVERTIME_MOOD_COST := 8" in game_source, "overtime mood cost must remain 8")
	assert("const CAFE_GIG_PAY := 55" in game_source, "cafe gig pay must remain 55")
	assert("const CAFE_GIG_MINUTES := 90" in game_source, "cafe gig minutes must remain 90")
	var process_block := _function_block(game_source, "func _process(delta: float) -> void:")
	assert(process_block.find("_sync_needs_to_time()") < process_block.find("_evaluate_terminal_state()"), "needs settlement must still precede terminal observation")
	assert("func current_onboarding_objective() -> Dictionary:" in game_source, "Game must expose exactly one onboarding objective state")
	assert("ONBOARDING_COMPLETE_FLAG := \"onboarding_complete\"" in game_source, "onboarding completion must use existing flags")
	assert("gig_visible" in cafe_source, "cafe side gig must consume onboarding visibility context")

	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.event_ui.close_event()
	main.set_process(false)
	main.murmur_shown = {"fullness": main.time_sys.day, "energy": main.time_sys.day}
	main._refresh_ui()

	# 1) 新档进入 onboarding，首屏只有一个 L1 objective；Cafe side gig 退到 Day2+。
	assert(main._onboarding_active(), "new game must enter onboarding")
	_assert_objective(main, main.ONBOARDING_MEAL)
	assert(not main.cafe_activities._spot_available("side_gig"), "cafe side gig must be hidden during onboarding")

	# 2) meal-before-leave：房门和已解锁旅行按钮两条路径都不能绕过，也不应扣旅行时间或留下后续解锁。
	var before_reject := _total_minutes(main.time_sys)
	main._on_home_activity("leave")
	assert(main.location_sys.current_location == "home", "home leave must be blocked before the first meal")
	assert(_total_minutes(main.time_sys) == before_reject, "blocked home leave must not cost time")
	main.location_sys.travel_to("subway")
	assert(main.location_sys.current_location == "home", "travel button must be reverted before the first meal")
	assert(_total_minutes(main.time_sys) == before_reject, "blocked travel-button bypass must not cost time")
	assert(not main.location_sys.is_unlocked("office"), "blocked pre-meal subway travel must not leak the office unlock")

	# 正常做饭必须把唯一目标推进到 subway。
	main.money = maxi(main.money, 100)
	await main._on_home_activity("meal")
	_assert_objective(main, main.ONBOARDING_SUBWAY)

	# 3) 通勤 spine：subway -> office -> 老张 -> 普通工作。
	main.location_sys.unlock("subway")
	main.location_sys.travel_to("subway")
	assert(main.location_sys.current_location == "subway", "meal completion must release subway travel")
	_assert_objective(main, main.ONBOARDING_OFFICE)
	main.location_sys.travel_to("office")
	assert(main.location_sys.current_location == "office", "subway must lead to office")
	_assert_objective(main, main.ONBOARDING_LAOZHANG)

	_set_clock(main, 8 * 60 + 55)
	var laozhang_state: Dictionary = main.npc_schedule_sys.get_state_for("laozhang", main.time_sys, main.weather_sys)
	assert(bool(laozhang_state.get("visible", false)), "Old Zhang must be available around 08:55")
	assert(str(laozhang_state.get("location", "")) == "office", "Old Zhang must be in office around 08:55")

	var money_before_work: int = main.money
	var minutes_before_work := _total_minutes(main.time_sys)
	await main._on_office_activity("work")
	assert(main.money == money_before_work, "ordinary work must be blocked before Old Zhang contact")
	assert(_total_minutes(main.time_sys) == minutes_before_work, "blocked work must not advance time")

	# 完成老张有效对话后才进入 work。
	main.dialog_pending_npc = "laozhang"
	main._on_dialog_finished()
	_assert_objective(main, main.ONBOARDING_WORK)
	await main._on_office_activity("work")
	_assert_objective(main, main.ONBOARDING_STORE)

	# 可选 overtime 做/不做都不能改变“去便利店”L1 目标。
	main.flags[main.OVERTIME_DAY_FLAG] = main.time_sys.day
	_assert_objective(main, main.ONBOARDING_STORE)

	# 4) onboarding 期间随机事件、encounter、暗线/quest/annual 都退到后台。
	assert(main._try_encounter("office") == null, "encounters must be suppressed during onboarding")
	var age_before: int = main.age
	main._on_location_action("office")
	assert(main.cur_event == null, "ordinary/dark event takeover must be suppressed during onboarding")
	assert(main.age == age_before, "onboarding location actions must not advance a year")
	var quest_before: Dictionary = main.game_state.quests.duplicate(true)
	main._notify_quest("work_shift")
	main._evaluate_quests()
	assert(main.game_state.quests == quest_before, "q1-q3 progress/reward noise must be suppressed during onboarding")
	main._year_pass()
	assert(main.age == age_before, "direct legacy annual progression must be suppressed during onboarding")

	# 5) 到 store 本身不能算完成；只有买到真正能顶一顿的食物才进入 home。
	main.location_sys.travel_to("store")
	_assert_objective(main, main.ONBOARDING_STORE)
	main.money = maxi(main.money, 100)
	main._on_shop_buy("milk")
	_assert_objective(main, main.ONBOARDING_STORE)
	main._on_shop_buy("bread")
	_assert_objective(main, main.ONBOARDING_HOME)

	# 6) 回家才进入第一晚 sleep 目标；单纯跨天不能替代完整睡眠。
	_set_clock(main, 20 * 60)
	main.location_sys.travel_to("home")
	_assert_objective(main, main.ONBOARDING_SLEEP)
	var payload: Dictionary = main.build_save_payload().duplicate(true)
	assert(not payload.has("onboarding"), "onboarding must not add a new save-schema section")
	var saved_objective: String = str(main.flags.get(main.ONBOARDING_OBJECTIVE_FLAG, ""))
	main.flags[main.ONBOARDING_OBJECTIVE_FLAG] = main.ONBOARDING_MEAL
	main.apply_save_payload(payload)
	assert(str(main.flags.get(main.ONBOARDING_OBJECTIVE_FLAG, "")) == saved_objective, "current onboarding objective must survive existing save payload")
	_assert_objective(main, main.ONBOARDING_SLEEP)

	var sleep_day: int = main.time_sys.day
	main.time_sys.advance_minutes(24 * 60)
	assert(main.time_sys.day == sleep_day + 1, "test must cross a day without sleeping")
	assert(main._onboarding_active(), "accidental day rollover must not complete onboarding")
	main.apply_save_payload(payload)
	main.dialog_ui.close_dialog()
	main.event_ui.close_event()
	main.ending_ui.close()
	main.set_process(false)

	# 7) 第一次成功整夜睡眠才完成；完成后 objective 为空，Day2 side gig 恢复。
	var sleep_text: String = main._sleep_through_night()
	assert(not main.game_over, "healthy first-night sleep must not end the game")
	assert(bool(main.flags.get(main.ONBOARDING_COMPLETE_FLAG, false)), "successful first-night sleep must complete onboarding")
	assert(main.current_onboarding_objective().is_empty(), "completed onboarding must expose no onboarding objective")
	assert(not sleep_text.is_empty(), "successful first-night sleep must return normal feedback")
	main._refresh_ui()
	assert(main.cafe_activities._spot_available("side_gig"), "cafe side gig must become available after onboarding / Day2+")

	print("GAME-CONTENT-013 PASS: deterministic first-day gates/objective state preserve terminal and livelihood contracts")
	quit(0)


func _assert_objective(main, expected_id: String) -> void:
	var objective: Dictionary = main.current_onboarding_objective()
	assert(not objective.is_empty(), "onboarding must expose exactly one current objective")
	assert(str(objective.get("id", "")) == expected_id, "expected objective %s, got %s" % [expected_id, str(objective.get("id", ""))])
	assert(not str(objective.get("text", "")).is_empty(), "objective text must be non-empty")


func _set_clock(main, minute_of_day: int) -> void:
	var want: int = main.time_sys.day * 1440 + minute_of_day
	var now: int = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.time_sys.advance_minutes(want - now)
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()


func _total_minutes(time_sys) -> int:
	return time_sys.day * 1440 + time_sys.get_minute_of_day()


func _read(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "must read " + path)
	var text := file.get_as_text()
	file.close()
	return text


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
