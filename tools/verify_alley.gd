extends SceneTree
## 第 4 阶段单元 4：旧巷互动（神龛上香 / 木门歇脚）。
##
## 覆盖：
## 1. 两个互动点从旧巷出生点**都真的走得到**
## 2. 上香：花 5 元、耗时 15 分钟、心情+8，且**只结算一次**
## 3. 余额不足时不上香、不扣钱、不推进时间
## 4. 歇脚：免费、耗时 20 分钟、心情+6
## 5. 活动层随地点开关
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

	var alley = main.alley_activities
	var location = main.location_sys
	var time_sys = main.time_sys

	# ---------------------------------------------------- 1 可达性
	location.unlock("alley")
	location.travel_to("alley")
	check(location.current_location == "alley", "the alley should open")
	for id in alley.SPOTS:
		check(location.walk_to(alley.SPOTS[id].position),
			"the alley spot must be reachable from the spawn: " + id)
	location.stop_walking()
	print("PASS both alley spots are reachable from the spawn")

	# ---------------------------------------------------- 2 上香
	location.player_sprite.position = alley.SPOTS.shrine.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(alley)
	main.money = 50
	var before_minutes: int = time_sys.get_minute_of_day()
	var before_mood: int = main.mood
	alley._activate("shrine")
	check(main.activity_running, "lighting incense should start")
	check(location.player_sprite.animation == &"walk_up", "lighting incense should face the shrine")
	alley._activate("shrine")  # 活动期间重复触发必须被挡掉
	await create_timer(1.5).timeout
	check(not main.activity_running, "lighting incense should end")
	check(time_sys.get_minute_of_day() - before_minutes == 15, "incense must cost 15 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.money == 45, "incense must cost 5 yuan, money is now %d" % main.money)
	check(main.mood == mini(100, before_mood + 8), "incense should give back mood")
	check(main.toast_label.text.contains("没许愿"), "the incense should be narrated, got: " + main.toast_label.text)
	print("PASS lighting incense settles once and costs 5 yuan")

	# ---------------------------------------------------- 3 余额不足
	main.money = 2
	before_minutes = time_sys.get_minute_of_day()
	alley._activate("shrine")
	check(not main.activity_running, "no incense when broke")
	await create_timer(0.3).timeout
	check(time_sys.get_minute_of_day() == before_minutes, "a declined offering must not advance time")
	check(main.money == 2, "a declined offering must not charge")
	check(main.toast_label.text.contains("余额不足"), "the player should be told the balance is short, got: " + main.toast_label.text)
	print("PASS a declined offering leaves state untouched")

	# ---------------------------------------------------- 4 木门歇脚
	location.player_sprite.position = alley.SPOTS.door.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(alley)
	before_minutes = time_sys.get_minute_of_day()
	before_mood = main.mood
	alley._activate("door")
	await create_timer(1.5).timeout
	check(not main.activity_running, "resting by the door should end")
	check(time_sys.get_minute_of_day() - before_minutes == 20, "resting must cost 20 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, before_mood + 6), "resting should give back mood")
	check(main.toast_label.text.contains("总亮着灯"), "the door should be narrated, got: " + main.toast_label.text)
	print("PASS resting by the door settles once and gives back mood")

	# ---------------------------------------------------- 5 层跟随地点开关
	location.travel_to("home")
	await process_frame
	await process_frame
	check(not alley.layer.visible, "the alley layer must hide away from the alley")
	location.travel_to("alley")
	await process_frame
	await process_frame
	check(alley.layer.visible, "the alley layer must come back in the alley")
	print("PASS the alley layer follows the current location")

	print("alley failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
