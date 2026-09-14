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
	assert("get_onboarding_objective_state" in game_source, "Game must expose one onboarding objective state")
	assert("onboarding_complete" in game_source, "onboarding completion must use existing flags")
	assert("gig_available" in cafe_source, "cafe side gig must have onboarding visibility context")

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

	# 1) 新档明确进入 onboarding，且任何时刻只有一个 objective dict。
	assert(main._onboarding_active(), "new game must enter onboarding")
	_assert_objective(main, "meal")
	assert(not main.cafe_activities._spot_available("side_gig"), "cafe side gig must be hidden during onboarding")

	# 2) meal-before-leave：房门和已解锁旅行按钮两条路径都不能绕过。
	var before_reject := _total_minutes(main.time_sys)
	main._on_home_activity("leave")
	assert(main.location_sys.current_location == "home", "home leave must be blocked before the first meal")
	assert(_total_minutes(main.time_sys) == before_reject, "blocked home leave must not cost time")
	main.location_sys.travel_to("subway")
	assert(main.location_sys.current_location == "home", "travel button must be reverted before the first meal")
	assert(_total_minutes(main.time_sys) == before_reject, "blocked travel-button bypass must not cost time")

	# 为避免等待活动进度条，本 verifier 直接写入与完成一顿饭等价的已授权 onboarding 状态，
	# 后面的工作/购买仍通过真实 handler 验证 gate。
	main.flags[main.ONBOARDING_MEAL_FLAG] = true
	main.daily_routine.complete("meal")
	_assert_objective(main, "subway")

	# 3) 正常通勤：subway -> office；到 office 后必须先找老张。
	main.location_sys.unlock("subway")
	main.location_sys.travel_to("subway")
	assert(main.location_sys.current_location == "subway", "meal completion must release subway travel")
	_assert_objective(main, "office")
	main.location_sys.unlock("office")
	main.location_sys.travel_to("office")
	assert(main.location_sys.current_location == "office", "subway must lead to office")
	_assert_objective(main, "laozhang")

	# 08:55 左右老张按既有日程应可出现；无需改 NPC schedule。
	_set_clock(main, 8 * 60 + 55)
	var laozhang_state: Dictionary = main.npc_schedule_sys.get_state_for("laozhang", main.time_sys, main.weather_sys)
	assert(bool(laozhang_state.get("visible", false)), "Old Zhang must be available around 08:55")
	assert(str(laozhang_state.get("location", "")) == "office", "Old Zhang must be in office around 08:55")

	# 工作前若没完成老张有效对话，应无工资/时间结算。
	var money_before_work: int = main.money
	var minutes_before_work := _total_minutes(main.time_sys)
	await main._do_work_shift()
	assert(main.money == money_before_work, "ordinary work must be blocked before Old Zhang contact")
	assert(_total_minutes(main.time_sys) == minutes_before_work, "blocked work must not advance time")

	# 完成老张对话才进入 work objective。
	main.dialog_pending_npc = "laozhang"
	main._on_dialog_finished()
	_assert_objective(main, "work")

	# 直接置位“第一班已完成”用于验证后半段 objective；012 的工资/加班结算由其独立 verifier 覆盖。
	main.flags[main.ONBOARDING_WORK_FLAG] = true
	main.daily_routine.complete("work")
	_assert_objective(main, "store")
	# 可选 overtime 做/不做都不能改变 L1 store objective。
	main.flags[main.OVERTIME_DAY_FLAG] = main.time_sys.day
	_assert_objective(main, "store")

	# 4) onboarding 期间随机事件、encounter、暗线/quest 都必须退到后台。
	assert(main._try_encounter("office") == null, "encounters must be suppressed during onboarding")
	var age_before: int = main.age
	main._on_location_action("office")
	assert(main.cur_event == null, "ordinary/dark event takeover must be suppressed during onboarding")
	assert(main.age == age_before, "onboarding location actions must not advance a year")
	var quest_before: Dictionary = main.game_state.quest_progress.duplicate(true)
	main._notify_quest("work_shift")
	main._evaluate_quests()
	assert(main.game_state.quest_progress == quest_before, "q1-q3 progress/reward noise must be suppressed during onboarding")

	# 5) store 只认真正能顶一顿的食物；牛奶不能替代，面包可以。
	main.location_sys.unlock("store")
	main.location_sys.travel_to("store")
	main._on_shop_buy("milk")
	assert(not bool(main.flags.get(main.ONBOARDING_STORE_FOOD_FLAG, false)), "milk must not complete the first-day food purchase objective")
	main._on_shop_buy("bread")
	assert(bool(main.flags.get(main.ONBOARDING_STORE_FOOD_FLAG, false)), "bread must complete the first-day food purchase objective")
	_assert_objective(main, "home")

	# 6) 回家后尚未到夜间时仍是收尾目标；夜里切到 sleep 目标。
	main.location_sys.travel_to("home")
	assert(bool(main.flags.get(main.ONBOARDING_HOME_RETURN_FLAG, false)), "returning home after food purchase must be remembered")
	_assert_objective(main, "home")
	_set_clock(main, 20 * 60)
	_assert_objective(main, "sleep")

	# 单纯跨天不能完成 onboarding。
	var saved_flags: Dictionary = main.flags.duplicate(true)
	main.time_sys.advance_minutes(24 * 60)
	assert(main._onboarding_active(), "accidental day rollover must not complete onboarding")
	main.flags = saved_flags
	_set_clock(main, 20 * 60)

	# 7) 现有 game_state payload 要能完整保存 onboarding phase，不新增顶层 schema。
	var payload: Dictionary = main.build_save_payload().duplicate(true)
	assert(not payload.has("onboarding"), "onboarding must not add a new save-schema section")
	main.flags.erase(main.ONBOARDING_STORE_FOOD_FLAG)
	main.apply_save_payload(payload)
	assert(bool(main.flags.get(main.ONBOARDING_STORE_FOOD_FLAG, false)), "onboarding flags must survive existing save payload")
	_assert_objective(main, "sleep")

	# 8) 第一次成功整夜睡眠才真正完成；完成后 objective 为空，Day2 side gig 可见。
	main.dialog_ui.close_dialog()
	main.event_ui.close_event()
	main.ending_ui.close()
	main.set_process(false)
	var sleep_text: String = main._sleep_through_night()
	assert(not main.game_over, "healthy first-night sleep must not end the game")
	assert(bool(main.flags.get(main.ONBOARDING_COMPLETE_FLAG, false)), "successful first-night sleep must complete onboarding")
	assert(main.get_onboarding_objective_state().is_empty(), "completed onboarding must expose no onboarding objective")
	assert(not sleep_text.is_empty(), "successful first-night sleep must return normal feedback")
	main._refresh_ui()
	assert(main.cafe_activities._spot_available("side_gig"), "cafe side gig must become available after onboarding / Day2+")

	print("GAME-CONTENT-013 PASS: deterministic first-day gates/objective state preserve terminal and livelihood contracts")
	quit(0)


func _assert_objective(main, expected_id: String) -> void:
	var objective: Dictionary = main.get_onboarding_objective_state()
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
