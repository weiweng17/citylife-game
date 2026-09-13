extends SceneTree
## 阶段 2 的整条链：家 → 地铁 → 公司上班 → 便利店买吃的 → 回家做饭 → 睡到次日。
##
## 与 verify_day_cycle 的分工：那个测各个规则本身，这个测"接口有没有接错"——
## 全程走真实交互（点家具/地点、走工位、按面板按钮），**不直接改状态**，
## 唯一的取巧是把时钟快进到夜里（白天到晚上要真的等 6 分钟现实时间）。
## 这样能抓到"便利店要先进过公司才解锁""路上花的时间有没有算"这类接线问题。

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
	var office = main.office_activities
	var store = main.store_activities
	var routine = main.daily_routine
	var time_sys = main.time_sys
	var inventory = main.inventory
	var start_money: int = main.money

	assert(location.current_location == "home", "the day must start at home")
	assert(not location.is_unlocked("office"), "the office must not be unlocked yet")
	assert(not location.is_unlocked("store"), "the store must not be unlocked yet")

	# ---- 出门 ----
	_at_home(home, location, "leave")
	await process_frame
	assert(location.current_location == "subway", "leaving home must reach the subway")
	assert(time_sys.get_minute_of_day() == 7 * 60 + 50, "the ride to the subway must cost 20 minutes")
	assert(location.is_unlocked("office"), "arriving at the subway must unlock the office")
	print("PASS leaving home reaches the subway and unlocks the office")

	# ---- 通勤到公司 ----
	location._on_travel_pressed("office")
	await process_frame
	await _wait_for_layer(office)
	assert(location.current_location == "office", "the subway must lead to the office")
	assert(routine.is_done("commute"), "arriving at the office must complete the daily commute")
	print("PASS commuting to the office marks the daily goal")

	# ---- 上班 ----
	await _work(main, office, location)
	var money_after_work: int = main.money
	assert(money_after_work == start_money + 120, "a shift must pay 120, got %d" % money_after_work)
	assert(routine.is_done("work"), "the shift must complete the daily work goal")
	print("PASS a shift at the office pays and marks the goal")

	# ---- 便利店 ----
	assert(location.is_unlocked("store"), "the store must be unlocked after visiting the office")
	location._on_travel_pressed("store")
	await process_frame
	assert(location.current_location == "store", "the map must lead to the store")
	store.blocked = false
	await _wait_for_layer(store)
	assert(store.layer.visible, "the store interaction layer must show up in the store")
	store._activate("shop")
	assert(main.shop_ui.is_open(), "the shelf must open the buy panel")
	assert(main.money == money_after_work, "opening the shelf must not charge anything")
	main.shop_ui.buy_requested.emit("instant_noodles")
	assert(main.money == money_after_work - 6, "noodles must cost 6")
	assert(inventory.count("instant_noodles") == 1, "the noodles must land in the bag")
	main.shop_ui.close()
	print("PASS buying at the store costs money and fills the bag")

	# ---- 回家做饭 ----
	location._on_travel_pressed("home")
	await process_frame
	assert(location.current_location == "home", "the map must lead back home")
	_at_home(home, location, "meal")
	await create_timer(1.5).timeout
	assert(routine.is_done("meal"), "cooking must complete the daily meal goal")
	assert(main.money == money_after_work - 6 - 20, "cooking must cost 20, got %d" % main.money)
	print("PASS getting home and cooking completes the daily meal goal")

	# ---- 睡到次日 ----
	# 唯一取巧的一步：白天到夜里要真等 6 分钟现实时间（游戏内 1 秒＝2 分钟），
	# 这里直接把时钟快进到夜里；后面走的仍是真实交互。
	while not main._is_sleep_hour():
		time_sys.advance_minutes(30)
	main._last_total_minutes = time_sys.day * 1440 + time_sys.get_minute_of_day()
	main.need_fraction = 0.0
	assert(main._rest_detail_text().contains("明早"), "the bed hint must switch to the overnight wording")
	var day_before: int = time_sys.day
	_at_home(home, location, "rest")
	await create_timer(1.5).timeout
	assert(time_sys.day == day_before + 1, "the night sleep must roll the day over")
	assert(time_sys.get_hour() == 7 and time_sys.get_minute() == 30, "waking must be at 07:30")
	assert(main.energy == 100, "a full night must refill energy")
	for task_id in routine.TASKS:
		assert(not routine.is_done(task_id), "the new day must start clean: " + task_id)
	var wake_line: String = main.toast_label.text
	assert(wake_line.contains("昨天"), "the wake-up line must summarise yesterday")
	for label in ["通勤", "工作", "吃饭"]:
		assert(wake_line.contains("√" + label), "yesterday's summary must tick " + label)
	assert(location.current_location == "home", "the player must still be home after waking")
	print("PASS sleeping at night closes the day and starts a clean new one")

	print("day flow total money: %d -> %d" % [start_money, main.money])
	quit(0)


## 家具互动：站到互动点旁边，再按真实的"激活"路径触发。
func _at_home(home, location, id: String) -> void:
	var spot: Vector2 = home.SPOTS[id].position
	location.player_sprite.position = spot
	location.player_target = spot
	home.blocked = false
	home._activate(id)


## 活动层是在它自己的 _process 里按"当前地点"开关的，切完图要等它真的亮起来再互动，
## 否则 _activate 会因为 layer.visible 还是 false 而直接返回（静默失败）。
func _wait_for_layer(activities) -> void:
	for _i in range(10):
		await process_frame
		if activities.layer.visible:
			return


func _work(main, office, location) -> void:
	location.player_sprite.position = office.SPOTS.work.position
	location.player_target = office.SPOTS.work.position
	office.blocked = false
	office._activate("work")
	await create_timer(1.5).timeout
