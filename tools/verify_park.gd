extends SceneTree
## 第 4 阶段单元 1：公园互动（长椅歇脚 / 池塘边看雨）。
##
## 覆盖：
## 1. 两个互动点从公园出生点**都真的走得到**（站位是照美术估的，容易压进阻挡区）
## 2. 长椅：耗时 30 分钟、精力+20、心情+5，且**只结算一次**
## 3. 池塘：耗时 20 分钟、心情+8
## 4. 公园活动**不算**每日目标里的"休息"（那仍然只属于回家睡觉）
## 5. 活动期间锁输入、结束后放行；切走图再回来，层会跟着开关
## 6. 活动公用的 _begin_activity/_end_activity 重构没有破坏原有三处结算
##    （此文件跑完后还会跑全员回归确认）
##
## 说明：与既有套件一致，用 `_activate()` 触发覆盖"信号接线 + 结算"；
## 真实鼠标命中由 verify_home_input.gd 用真实输入覆盖。

const Data = preload("res://scripts/Data.gd")

var failures: Array[String] = []
var main


func _init() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL ", message)


## 切图之后，交互层的 `layer.visible` 要等它自己的 `_process` 才会亮；
## 只等固定帧数会踩中"layer 还没亮就 _activate → 静默返回"的坑。
func _wait_for_layer(activities) -> void:
	var guard: int = 0
	while guard < 600:
		if activities.layer.visible and not activities.blocked:
			await process_frame
			return
		await process_frame
		guard += 1
	check(false, "the interaction layer never became visible for " + str(activities.name))


func run() -> void:
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	main._process(0.0)
	main.set_process(false)

	var park = main.park_activities
	var location = main.location_sys
	var time_sys = main.time_sys

	# ---------------------------------------------------- 1 可达性
	location.unlock("park")
	location.travel_to("park")
	check(location.current_location == "park", "the park should open")
	for id in park.SPOTS:
		check(location.walk_to(park.SPOTS[id].position),
			"the park spot must be reachable from the spawn: " + id)
	location.stop_walking()
	print("PASS both park spots are reachable from the spawn")

	# ---------------------------------------------------- 2 长椅
	location.player_sprite.position = park.SPOTS.bench.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(park)
	main.daily_routine.reset(time_sys.day)
	var before_minutes: int = time_sys.get_minute_of_day()
	var before_energy: int = main.energy
	var before_mood: int = main.mood
	park._activate("bench")
	check(main.activity_running, "the bench break should start")
	check(location.player_sprite.animation == &"walk_up", "sitting on the bench should face the bench")
	park._activate("bench")  # 活动期间重复触发必须被挡掉
	await create_timer(1.6).timeout
	check(not main.activity_running, "the bench break should end")
	check(time_sys.get_minute_of_day() - before_minutes == 30, "the bench break must cost 30 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.energy == mini(100, before_energy + 20), "the bench break should give back energy")
	check(main.mood == mini(100, before_mood + 5), "the bench break should give back mood")
	check(not main.daily_routine.is_done("sleep"), "a park break must NOT tick the daily sleep goal")
	check(main.toast_label.text.contains("长椅是湿的"), "the break should be narrated, got: " + main.toast_label.text)
	print("PASS the bench break settles once and gives back energy and mood")

	# ---------------------------------------------------- 3 池塘
	location.player_sprite.position = park.SPOTS.pond.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(park)
	before_minutes = time_sys.get_minute_of_day()
	var mood_before_pond: int = main.mood
	park._activate("pond")
	await create_timer(1.5).timeout
	check(not main.activity_running, "watching the rain should end")
	check(time_sys.get_minute_of_day() - before_minutes == 20, "watching the rain must cost 20 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, mood_before_pond + 8), "watching the rain should give back mood")
	check(main.toast_label.text.contains("石栏被雨洗得发亮"), "the pond should be narrated, got: " + main.toast_label.text)
	print("PASS watching the rain from the pond settles once and gives back mood")

	# ---------------------------------------------------- 4 层跟随地点开关
	location.travel_to("home")
	await process_frame
	await process_frame
	check(not park.layer.visible, "the park layer must hide away from the park")
	location.travel_to("park")
	await process_frame
	await process_frame
	check(park.layer.visible, "the park layer must come back in the park")
	print("PASS the park layer follows the current location")

	print("park failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
