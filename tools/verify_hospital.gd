extends SceneTree
## 第 4 阶段单元 3：医院互动（诊桌看病 / 候诊椅缓一缓）。
##
## 覆盖：
## 1. 两个互动点从医院出生点**都真的走得到**（站位照美术估的，容易压进阻挡区）
## 2. 看病：花 50 元、耗时 60 分钟、健康+25，且**只结算一次**
## 3. 余额不足时不挂号、不扣钱、不推进时间
## 4. 候诊椅：免费、耗时 15 分钟、心情+5
## 5. 活动层随地点开关
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

	var hospital = main.hospital_activities
	var location = main.location_sys
	var time_sys = main.time_sys

	# ---------------------------------------------------- 1 可达性
	location.unlock("hospital")
	location.travel_to("hospital")
	check(location.current_location == "hospital", "the hospital should open")
	for id in hospital.SPOTS:
		check(location.walk_to(hospital.SPOTS[id].position),
			"the hospital spot must be reachable from the spawn: " + id)
	location.stop_walking()
	print("PASS both hospital spots are reachable from the spawn")

	# ---------------------------------------------------- 2 看病
	location.player_sprite.position = hospital.SPOTS.clinic.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(hospital)
	main.money = 200
	main.health = 40
	var before_minutes: int = time_sys.get_minute_of_day()
	hospital._activate("clinic")
	check(main.activity_running, "the clinic visit should start")
	check(location.player_sprite.animation == &"walk_up", "seeing the doctor should face the desk")
	hospital._activate("clinic")  # 活动期间重复触发必须被挡掉
	await create_timer(1.6).timeout
	check(not main.activity_running, "the clinic visit should end")
	check(time_sys.get_minute_of_day() - before_minutes == 60, "the clinic visit must cost 60 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.money == 150, "the clinic visit must cost 50 yuan, money is now %d" % main.money)
	check(main.health == 65, "the clinic visit should heal to 65, got %d" % main.health)
	check(main.toast_label.text.contains("能嫌医院冷"), "the clinic should be narrated, got: " + main.toast_label.text)
	print("PASS the clinic visit settles once and heals 25 health for 50 yuan")

	# ---------------------------------------------------- 3 余额不足
	main.money = 20
	before_minutes = time_sys.get_minute_of_day()
	hospital._activate("clinic")
	check(not main.activity_running, "no clinic visit when broke")
	await create_timer(0.3).timeout
	check(time_sys.get_minute_of_day() == before_minutes, "a declined visit must not advance time")
	check(main.money == 20, "a declined visit must not charge")
	check(main.toast_label.text.contains("余额不足"), "the player should be told the balance is short, got: " + main.toast_label.text)
	print("PASS a declined clinic visit leaves state untouched")

	# ---------------------------------------------------- 4 候诊椅
	location.player_sprite.position = hospital.SPOTS.bench.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(hospital)
	before_minutes = time_sys.get_minute_of_day()
	var mood_before: int = main.mood
	hospital._activate("bench")
	await create_timer(1.5).timeout
	check(not main.activity_running, "resting on the bench should end")
	check(time_sys.get_minute_of_day() - before_minutes == 15, "the bench must cost 15 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, mood_before + 5), "the bench should give back mood")
	check(main.toast_label.text.contains("喊到的名字都不是你的"), "the bench should be narrated, got: " + main.toast_label.text)
	print("PASS resting on the waiting bench settles once and gives back mood")

	# ---------------------------------------------------- 5 层跟随地点开关
	location.travel_to("home")
	await process_frame
	await process_frame
	check(not hospital.layer.visible, "the hospital layer must hide away from the hospital")
	location.travel_to("hospital")
	await process_frame
	await process_frame
	check(hospital.layer.visible, "the hospital layer must come back in the hospital")
	print("PASS the hospital layer follows the current location")

	print("hospital failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
