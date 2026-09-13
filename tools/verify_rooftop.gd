extends SceneTree
## 第 4 阶段单元 4：天台互动（栏杆看夜景 / 长椅吹风）。
##
## 覆盖：
## 1. 两个互动点从天台出生点**都真的走得到**
## 2. 看夜景：耗时 25 分钟、心情+10，且**只结算一次**
## 3. 长椅：耗时 20 分钟、心情+8 精力+5
## 4. 活动层随地点开关
##
## 说明：与既有套件一致，用 `_activate()` 触发覆盖"信号接线 + 结算"。

const Data = preload("res://scripts/Data.gd")

var failures: Array[String] = []
var main


func _init() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL ", message)


## 切图之后，交互层的 `layer.visible` 要等它自己的 `_process` 才会亮。
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

	var rooftop = main.rooftop_activities
	var location = main.location_sys
	var time_sys = main.time_sys

	# ---------------------------------------------------- 1 可达性
	location.unlock("rooftop")
	location.travel_to("rooftop")
	check(location.current_location == "rooftop", "the rooftop should open")
	for id in rooftop.SPOTS:
		check(location.walk_to(rooftop.SPOTS[id].position),
			"the rooftop spot must be reachable from the spawn: " + id)
	location.stop_walking()
	print("PASS both rooftop spots are reachable from the spawn")

	# ---------------------------------------------------- 2 看夜景
	location.player_sprite.position = rooftop.SPOTS.ledge.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(rooftop)
	var before_minutes: int = time_sys.get_minute_of_day()
	var before_mood: int = main.mood
	rooftop._activate("ledge")
	check(main.activity_running, "watching the skyline should start")
	check(location.player_sprite.animation == &"walk_up", "watching the skyline should face the city")
	rooftop._activate("ledge")  # 活动期间重复触发必须被挡掉
	await create_timer(1.5).timeout
	check(not main.activity_running, "watching the skyline should end")
	check(time_sys.get_minute_of_day() - before_minutes == 25, "the skyline must cost 25 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, before_mood + 10), "the skyline should give back mood")
	check(main.toast_label.text.contains("烦恼都显得小了一圈"), "the skyline should be narrated, got: " + main.toast_label.text)
	print("PASS watching the skyline settles once and gives back mood")

	# ---------------------------------------------------- 3 长椅吹风
	location.player_sprite.position = rooftop.SPOTS.bench.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(rooftop)
	before_minutes = time_sys.get_minute_of_day()
	before_mood = main.mood
	var before_energy: int = main.energy
	rooftop._activate("bench")
	await create_timer(1.5).timeout
	check(not main.activity_running, "the bench should end")
	check(time_sys.get_minute_of_day() - before_minutes == 20, "the bench must cost 20 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, before_mood + 8), "the bench should give back mood")
	check(main.energy == mini(100, before_energy + 5), "the bench should give back energy")
	check(main.toast_label.text.contains("肩膀自己松了下来"), "the bench should be narrated, got: " + main.toast_label.text)
	print("PASS the rooftop bench settles once and gives back mood and energy")

	# ---------------------------------------------------- 4 层跟随地点开关
	location.travel_to("home")
	await process_frame
	await process_frame
	check(not rooftop.layer.visible, "the rooftop layer must hide away from the rooftop")
	location.travel_to("rooftop")
	await process_frame
	await process_frame
	check(rooftop.layer.visible, "the rooftop layer must come back in the rooftop")
	print("PASS the rooftop layer follows the current location")

	print("rooftop failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
