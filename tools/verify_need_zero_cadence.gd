extends SceneTree
## GAME-FIX-002：归零后的健康/心情惩罚必须跟随完整游戏小时，而不是任意分钟刷新。

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

	var time_sys = main.time_sys
	main.fullness = 0
	main.energy = 0
	main.health = 100
	main.mood = 100
	main.need_fraction = 0.0
	main.murmur_shown = {
		"fullness": time_sys.day,
		"energy": time_sys.day,
	}
	main._last_total_minutes = time_sys.day * 1440 + time_sys.get_minute_of_day()

	# 只有半小时：尚未形成一次需求消耗小时，不应因为“需求已经为 0”提前扣罚。
	time_sys.advance_minutes(30)
	main._sync_needs_to_time()
	assert(main.health == 100, "30 minutes at zero fullness must not damage health, got %d" % main.health)
	assert(main.mood == 100, "30 minutes at zero energy must not damage mood, got %d" % main.mood)
	assert(is_equal_approx(main.need_fraction, 0.5), "30 minutes must retain 0.5 need hour, got %s" % main.need_fraction)
	print("PASS zero needs do not penalize before a full hour")

	# 再过半小时：累计满一小时，只应结算一次 -2/-2。
	time_sys.advance_minutes(30)
	main._sync_needs_to_time()
	assert(main.health == 98, "one full zero-fullness hour must damage health once, got %d" % main.health)
	assert(main.mood == 98, "one full zero-energy hour must damage mood once, got %d" % main.mood)
	assert(is_equal_approx(main.need_fraction, 0.0), "one full hour must consume the accumulated fraction")
	print("PASS zero-need penalty fires once on the hourly cadence")

	# 没有新的时间推进：重复同步/刷新不能重复扣罚。
	main._sync_needs_to_time()
	main._sync_needs_to_time()
	assert(main.health == 98, "re-entry without elapsed time must not damage health again")
	assert(main.mood == 98, "re-entry without elapsed time must not damage mood again")
	print("PASS repeated sync without time advance is penalty-free")

	# 一次跨两小时应按两个完整小时结算，保持原有 -2/-2 数值，不丢时长也不按调用次数算。
	time_sys.advance_minutes(120)
	main._sync_needs_to_time()
	assert(main.health == 94, "two additional zero-fullness hours must apply two health penalties, got %d" % main.health)
	assert(main.mood == 94, "two additional zero-energy hours must apply two mood penalties, got %d" % main.mood)
	assert(main.fullness == 0, "fullness must remain clamped at zero")
	assert(main.energy == 0, "energy must remain clamped at zero")
	print("PASS multi-hour advance applies exactly one zero-need penalty per full hour")

	print("GAME-FIX-002 PASS: zero-need penalties are tied to the hourly need-drain cadence")
	quit(0)
