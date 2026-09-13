extends SceneTree
## 阶段 2 最后一项：睡整夜触发次日，以及"中途存档 → 读回"是否真能接着玩。
##
## 存档往返走的是 `Game.build_save_payload()` / `apply_save_payload()` 这一对，
## 全程在内存里做——**不碰玩家真正的存档文件**（user://savegame.json），
## 和 verify_home_input.gd 一样的顾虑。

const SAVE_KEYS := [
	"game_state", "time", "weather", "events", "encounters",
	"world", "locations", "daily", "inventory", "origin",
]


func _init() -> void:
	call_deferred("run")


func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	var home = main.home_activities
	var routine = main.daily_routine
	var time_sys = main.time_sys
	var inventory = main.inventory

	assert(location.current_location == "home", "the game must start at home")
	assert(time_sys.get_hour() == 7 and time_sys.get_minute() == 30, "the clock must start at 07:30")

	# ---------------------------------------------------------------- 白天只小睡
	assert(not main._is_sleep_hour(), "07:30 must not count as a sleep hour")
	assert(main._rest_detail_text().contains("2小时"), "the daytime bed hint must describe the nap")
	main.energy = 20
	main.fullness = 60
	var day_before: int = time_sys.day
	await _do_rest(home, location)
	assert(time_sys.day == day_before, "a daytime nap must not roll the day over")
	assert(time_sys.get_hour() == 9 and time_sys.get_minute() == 30, "the nap must end at 09:30")
	assert(main.energy == 70, "the nap must restore 50 energy, got %d" % main.energy)
	assert(routine.is_done("sleep"), "the nap must count as the daily rest goal")
	print("PASS daytime rest is only a two-hour nap")

	# ---------------------------------------------------------------- 夜里睡到次日
	# 直接跳时间是摆场景；把消耗基准对齐，别让这一跳被当成真实流过的 11 小时。
	time_sys.advance_minutes(11 * 60)  # 09:30 -> 20:30
	_rebaseline(main)
	assert(time_sys.get_hour() == 20, "setup: expected 20:30, got %02d" % time_sys.get_hour())
	assert(main._is_sleep_hour(), "20:30 must count as a sleep hour")
	assert(main._rest_detail_text().contains("明早"), "the night bed hint must promise the morning")
	routine.complete("commute")
	routine.complete("work")
	routine.complete("meal")
	main.health = 50
	main.mood = 40
	# 精力给足，免得触发"精力见底再掉心情"的另一条规则，好把睡眠本身的加成单独断言。
	main.energy = 80
	main.fullness = 80
	var day_night: int = time_sys.day
	await _do_rest(home, location)
	assert(time_sys.day == day_night + 1, "sleeping at night must roll the day over")
	assert(time_sys.get_hour() == 7 and time_sys.get_minute() == 30, "waking time must be 07:30")
	assert(main.energy == 100, "a full night must refill energy, got %d" % main.energy)
	assert(main.health == 62, "a full night must add 12 health, got %d" % main.health)
	assert(main.mood == 48, "a full night must add 8 mood, got %d" % main.mood)
	# 11 小时不动嘴：饱食按每小时 4 点掉到 36——醒来是"睡饱了但饿"。
	assert(main.fullness == 36, "11 hours asleep must cost 44 fullness, got %d" % main.fullness)
	assert(routine.day == time_sys.day, "the daily goals must belong to the new day")
	for task_id in routine.TASKS:
		assert(not routine.is_done(task_id), "the new day must start clean: " + task_id)
	assert(
		main.toast_label.text.contains("昨天") and main.toast_label.text.contains("√工作"),
		"the wake-up line must summarise yesterday, got: " + main.toast_label.text
	)
	print("PASS sleeping at night rolls over to the next morning")

	# ---------------------------------------------------------------- 过午夜后睡
	time_sys.advance_minutes(18 * 60 + 30)  # 07:30 -> 次日 02:00
	_rebaseline(main)
	assert(time_sys.get_hour() == 2, "setup: expected 02:00, got %02d" % time_sys.get_hour())
	var day_early: int = time_sys.day
	# 饿着肚子、精力见底才上床：这一觉会额外触发"精力归零再掉 2 点心情"，
	# 所以醒来是 40 − 2 + 8 = 46。这条规则属于需求系统，不是睡眠加成出了问题。
	main.energy = 10
	main.mood = 40
	main.fullness = 90
	await _do_rest(home, location)
	assert(time_sys.day == day_early, "sleeping after midnight must not add another day")
	assert(time_sys.get_hour() == 7 and time_sys.get_minute() == 30, "it must still end at 07:30")
	assert(main.energy == 100, "a short night must still refill energy, got %d" % main.energy)
	assert(main.mood == 46, "an exhausted night must cost 2 extra mood, got %d" % main.mood)
	print("PASS sleeping after midnight wakes the same morning")

	# ---------------------------------------------------------------- 中途存档 → 读回
	# 摆一个"一天过到一半"的现场：出了门、上了班、买了东西。
	location.unlock("store")
	location.travel_to("store")
	routine.reset(time_sys.day)
	routine.complete("commute")
	routine.complete("work")
	inventory.reset()
	inventory.add("instant_noodles", 2)
	inventory.add("canned_coffee", 1)
	main.money = 733
	main.health = 61
	main.mood = 44
	main.skill = 57
	main.fullness = 63
	main.energy = 28
	main.game_state.flags["tut_moved"] = true
	var saved_day: int = time_sys.day
	var saved_clock: String = time_sys.get_clock_text()
	var saved: Dictionary = main.build_save_payload()
	for key in SAVE_KEYS:
		assert(saved.has(key), "the save payload must carry: " + key)
	assert(not main.origin.is_empty(), "the save payload must carry the origin")

	# 把现场搅乱，再整份读回来。
	main.money = 1
	main.health = 1
	main.mood = 1
	main.skill = 1
	main.fullness = 1
	main.energy = 1
	inventory.reset()
	routine.reset(9)
	time_sys.reset()
	location.travel_to("home")
	assert(main.money == 1 and location.current_location == "home")

	main.apply_save_payload(saved)

	assert(main.money == 733, "money must come back, got %d" % main.money)
	assert(main.health == 61, "health must come back, got %d" % main.health)
	assert(main.mood == 44, "mood must come back, got %d" % main.mood)
	assert(main.skill == 57, "skill must come back, got %d" % main.skill)
	assert(main.fullness == 63, "fullness must come back, got %d" % main.fullness)
	assert(main.energy == 28, "energy must come back, got %d" % main.energy)
	assert(time_sys.day == saved_day, "the day must come back, got %d" % time_sys.day)
	assert(time_sys.get_clock_text() == saved_clock, "the clock must come back, got %s" % time_sys.get_clock_text())
	assert(location.current_location == "store", "the place must come back")
	assert(
		inventory.count("instant_noodles") == 2 and inventory.count("canned_coffee") == 1,
		"the bag must come back"
	)
	assert(routine.day == time_sys.day, "the daily routine must come back on the right day")
	assert(routine.is_done("commute") and routine.is_done("work"), "the daily progress must come back")
	assert(bool(main.flags.get("tut_moved", false)), "story flags must come back")
	assert(not main.origin.is_empty(), "the origin must come back")
	assert(main.game_started and not main.game_over, "loading must leave a playable game")

	# 读档会把时间整体跳到存档那一刻，这一跳不能被当成真实流逝的时间扣掉需求。
	var fullness_before: int = main.fullness
	var energy_before: int = main.energy
	main._sync_needs_to_time()
	assert(
		main.fullness == fullness_before and main.energy == energy_before,
		"loading must not drain needs (fullness %d->%d, energy %d->%d)" % [
			fullness_before, main.fullness, energy_before, main.energy,
		]
	)
	print("PASS a mid-run save restores state without draining needs")

	quit(0)


func _rebaseline(main) -> void:
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.need_fraction = 0.0


func _do_rest(home, location) -> void:
	location.player_sprite.position = home.SPOTS.rest.position
	location.player_target = location.player_sprite.position
	home.blocked = false
	home._activate("rest")
	await create_timer(1.5).timeout
