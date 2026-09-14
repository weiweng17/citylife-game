extends SceneTree
## GAME-CONTENT-012：办公室加班 + 咖啡馆临时帮工。
## Web worker 只准备该验证包；实际 Godot 执行归 QA-002 frozen integration SHA。

const GAME_PATH := "res://scripts/Game.gd"
const OFFICE_PATH := "res://scripts/systems/OfficeActivities.gd"
const CAFE_PATH := "res://scripts/systems/CafeActivities.gd"


func _init() -> void:
	call_deferred("run")


func _wait_for_layer(activities) -> void:
	var guard: int = 0
	while guard < 600:
		if activities.layer.visible and not activities.blocked:
			await process_frame
			return
		await process_frame
		guard += 1
	assert(false, "interaction layer never became ready: " + str(activities.name))


func run() -> void:
	var game_source := _read(GAME_PATH)
	var office_source := _read(OFFICE_PATH)
	var cafe_source := _read(CAFE_PATH)

	# 已验收 terminal semantics 不得被内容波次倒退。
	assert(game_source.count("rules_sys.death_reason(") == 1, "death_reason must remain centralized")
	var process_block := _function_block(game_source, "func _process(delta: float) -> void:")
	assert(process_block.find("_sync_needs_to_time()") < process_block.find("_evaluate_terminal_state()"), "need settlement must precede terminal observation")
	assert(process_block.find("_evaluate_terminal_state()") < process_block.find("_evaluate_quests()"), "terminal observation must precede quest rewards")
	var livelihood_settle := _function_block(game_source, "func _settle_livelihood_time(minutes: int) -> bool:")
	assert(livelihood_settle.find("time_sys.advance_minutes(minutes)") < livelihood_settle.find("_sync_needs_to_time()"), "livelihood time must advance before needs settle")
	assert(livelihood_settle.find("_sync_needs_to_time()") < livelihood_settle.find("_evaluate_terminal_state()"), "livelihood needs must settle before terminal observation")

	# 可见标签必须把时间、钱与主要代价说清楚。
	assert("\"overtime\"" in office_source, "office must define overtime spot")
	assert("2小时" in office_source and "健康−4" in office_source and "心情−8" in office_source and "每天一次" in office_source, "overtime label must expose time/stat/daily costs")
	assert("worked_today" in office_source, "overtime visibility must depend on ordinary work completion")
	assert("\"side_gig\"" in cafe_source, "cafe must define side-gig spot")
	assert("90分钟" in cafe_source and "55元" in cafe_source and "健康−2" in cafe_source and "心情−4" in cafe_source and "每天一次" in cafe_source, "side-gig label must expose reward/time/stat/daily costs")

	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	main._process(0.0)
	main.set_process(false)
	main.murmur_shown = {"fullness": main.time_sys.day, "energy": main.time_sys.day}
	main._refresh_ui()

	var location = main.location_sys
	var office = main.office_activities
	var cafe = main.cafe_activities
	var time_sys = main.time_sys

	# 1) 加班在普通班次之前不可见；新互动点从公司出生区域可正常寻路到达；普通班次后开放。
	assert(not office._spot_available("overtime"), "overtime must stay hidden before ordinary work")
	location.unlock("office")
	location.travel_to("office")
	await _wait_for_layer(office)
	assert(location.walk_to(office.SPOTS.overtime.position), "overtime spot must be reachable through normal office navigation")
	location.stop_walking()
	location.player_sprite.position = office.SPOTS.work.position
	location.player_target = location.player_sprite.position
	office.blocked = false
	var work_money_before: int = main.money
	office._activate("work")
	await create_timer(1.5).timeout
	assert(main.money == work_money_before + 120, "baseline ordinary work pay must remain unchanged")
	assert(main.daily_routine.is_done("work"), "ordinary shift must mark work done")
	main._refresh_ui()
	assert(office._spot_available("overtime"), "overtime must appear after ordinary work")

	# 2) 加班：当前 wage 的 60%，2 小时，健康−4，心情−8；同日第二次不结算。
	location.player_sprite.position = office.SPOTS.overtime.position
	location.player_target = location.player_sprite.position
	office.blocked = false
	var overtime_money_before: int = main.money
	var overtime_health_before: int = main.health
	var overtime_mood_before: int = main.mood
	var overtime_total_before := _total_minutes(time_sys)
	office._activate("overtime")
	await create_timer(1.5).timeout
	assert(main.money == overtime_money_before + 72, "skill-48 base wage 120 must yield 60% overtime pay = 72")
	assert(main.health == overtime_health_before - 4, "overtime health cost must be 4")
	assert(main.mood == overtime_mood_before - 8, "overtime mood cost must be 8")
	assert(_total_minutes(time_sys) - overtime_total_before == 120, "overtime must cost 120 minutes")
	assert(main._livelihood_done_today(main.OVERTIME_DAY_FLAG), "overtime daily flag must be recorded")
	var overtime_money_once: int = main.money
	var overtime_total_once := _total_minutes(time_sys)
	office._activate("overtime")
	await process_frame
	assert(main.money == overtime_money_once, "same-day overtime must not pay twice")
	assert(_total_minutes(time_sys) == overtime_total_once, "same-day overtime must not consume time twice")

	# 3) 日标记复用 GameState.flags，随现有 game_state payload 往返，不新增顶层 save 字段。
	# build_save_payload() 在内存里保留嵌套字典引用；测试必须深拷贝，才能模拟真正写盘/读回后的独立 payload。
	var payload: Dictionary = main.build_save_payload().duplicate(true)
	assert(not payload.has("livelihood"), "livelihood must not add a save-schema section")
	var overtime_day: int = int(main.flags.get(main.OVERTIME_DAY_FLAG, -1))
	main.flags.erase(main.OVERTIME_DAY_FLAG)
	main.apply_save_payload(payload)
	assert(int(main.flags.get(main.OVERTIME_DAY_FLAG, -1)) == overtime_day, "overtime day flag must survive existing save payload")
	main.dialog_ui.close_dialog()
	main.event_ui.close_event()
	main.ending_ui.close()
	main.set_process(false)

	# 4) 咖啡馆帮工点必须可正常寻路到达；55 元 < 最低普通班 90 元；90 分钟，健康−2，心情−4；同日一次。
	location.unlock("cafe")
	location.travel_to("cafe")
	await _wait_for_layer(cafe)
	assert(location.walk_to(cafe.SPOTS.side_gig.position), "cafe side-gig spot must be reachable through normal cafe navigation")
	location.stop_walking()
	location.player_sprite.position = cafe.SPOTS.side_gig.position
	location.player_target = location.player_sprite.position
	cafe.blocked = false
	var gig_money_before: int = main.money
	var gig_health_before: int = main.health
	var gig_mood_before: int = main.mood
	var gig_total_before := _total_minutes(time_sys)
	cafe._activate("side_gig")
	await create_timer(1.5).timeout
	assert(main.CAFE_GIG_PAY == 55 and main.CAFE_GIG_PAY < 90, "cafe gig must pay 55 and less than the minimum ordinary shift")
	assert(main.money == gig_money_before + 55, "cafe gig must pay 55")
	assert(main.health == gig_health_before - 2, "cafe gig health cost must be 2")
	assert(main.mood == gig_mood_before - 4, "cafe gig mood cost must be 4")
	assert(_total_minutes(time_sys) - gig_total_before == 90, "cafe gig must cost 90 minutes")
	assert(main._livelihood_done_today(main.CAFE_GIG_DAY_FLAG), "cafe gig daily flag must be recorded")
	var gig_money_once: int = main.money
	var gig_total_once := _total_minutes(time_sys)
	cafe._activate("side_gig")
	await process_frame
	assert(main.money == gig_money_once, "same-day cafe gig must not pay twice")
	assert(_total_minutes(time_sys) == gig_total_once, "same-day cafe gig must not consume time twice")

	# 5) 跨天后两个 daily flags 都自然重新开放，不需要清 save schema。
	var day_before: int = time_sys.day
	time_sys.advance_minutes(24 * 60)
	assert(time_sys.day == day_before + 1, "test must cross into a new day")
	assert(not main._livelihood_done_today(main.OVERTIME_DAY_FLAG), "overtime must reopen next day")
	assert(not main._livelihood_done_today(main.CAFE_GIG_DAY_FLAG), "cafe gig must reopen next day")
	location.player_sprite.position = cafe.SPOTS.side_gig.position
	location.player_target = location.player_sprite.position
	cafe.blocked = false
	var next_day_money: int = main.money
	cafe._activate("side_gig")
	await create_timer(1.5).timeout
	assert(main.money == next_day_money + 55, "cafe gig must be repeatable on a later day")

	print("GAME-CONTENT-012 PASS: overtime and cafe side gig are visible, reachable, costly and once-per-day")
	quit(0)


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
