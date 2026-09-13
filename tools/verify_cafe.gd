extends SceneTree
## 第 4 阶段单元 2：咖啡馆互动（靠窗吧台点咖啡 / 圆桌发呆）+ 阿哲的午间日程。
##
## 覆盖：
## 1. 两个互动点从咖啡馆出生点**都真的走得到**（站位照美术估的，容易压进阻挡区）
## 2. 咖啡：花 15 元、耗时 30 分钟、精力+15 心情+6，且**只结算一次**
## 3. 余额不足时咖啡不下单、不扣钱、不推进时间
## 4. 发呆：免费、耗时 20 分钟、心情+8
## 5. 阿哲 12:00-14:00 会出现在咖啡馆（新加的午间日程）
## 6. 活动层随地点开关
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


func _set_clock(minute_of_day: int) -> void:
	var want: int = main.time_sys.day * 1440 + minute_of_day
	var now: int = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.time_sys.advance_minutes(want - now)
	# 跳完把消耗基准对齐，否则这一跳会被 needs 当成真实流逝的时间（见 HANDOFF）。
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()


func _npc_button(npc_id: String) -> Button:
	# 按名字扫而不是 get_node：热点重建时旧节点可能还在待释放队列里（见 verify_npc）。
	var wanted := "Npc_%s" % npc_id
	for child in main.location_sys.npc_layer.get_children():
		if child is Button and str(child.name) == wanted and not child.is_queued_for_deletion():
			return child as Button
	return null


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

	var cafe = main.cafe_activities
	var location = main.location_sys
	var time_sys = main.time_sys

	# ---------------------------------------------------- 1 可达性
	location.unlock("cafe")
	location.travel_to("cafe")
	check(location.current_location == "cafe", "the cafe should open")
	for id in cafe.SPOTS:
		check(location.walk_to(cafe.SPOTS[id].position),
			"the cafe spot must be reachable from the spawn: " + id)
	location.stop_walking()
	print("PASS both cafe spots are reachable from the spawn")

	# ---------------------------------------------------- 2 点杯咖啡
	location.player_sprite.position = cafe.SPOTS.coffee.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(cafe)
	main.money = 100
	var before_minutes: int = time_sys.get_minute_of_day()
	var before_energy: int = main.energy
	var before_mood: int = main.mood
	cafe._activate("coffee")
	check(main.activity_running, "ordering a coffee should start")
	check(location.player_sprite.animation == &"walk_up", "drinking coffee should face the window bar")
	cafe._activate("coffee")  # 活动期间重复触发必须被挡掉
	await create_timer(1.6).timeout
	check(not main.activity_running, "the coffee should finish")
	check(time_sys.get_minute_of_day() - before_minutes == 30, "a coffee must cost 30 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.money == 85, "a coffee must cost 15 yuan, money is now %d" % main.money)
	check(main.energy == mini(100, before_energy + 15), "the coffee should give back energy")
	check(main.mood == mini(100, before_mood + 6), "the coffee should give back mood")
	check(main.toast_label.text.contains("咖啡是烫的"), "the coffee should be narrated, got: " + main.toast_label.text)
	print("PASS ordering a coffee settles once and charges 15 yuan")

	# ---------------------------------------------------- 3 余额不足
	main.money = 5
	before_minutes = time_sys.get_minute_of_day()
	cafe._activate("coffee")
	check(not main.activity_running, "no coffee when broke")
	await create_timer(0.3).timeout
	check(time_sys.get_minute_of_day() == before_minutes, "a declined order must not advance time")
	check(main.money == 5, "a declined order must not charge")
	check(main.toast_label.text.contains("余额不足"), "the player should be told the balance is short, got: " + main.toast_label.text)
	print("PASS a declined coffee order leaves state untouched")

	# ---------------------------------------------------- 4 发会儿呆
	location.player_sprite.position = cafe.SPOTS.idle.position
	location.player_target = location.player_sprite.position
	await _wait_for_layer(cafe)
	before_minutes = time_sys.get_minute_of_day()
	var mood_before: int = main.mood
	cafe._activate("idle")
	await create_timer(1.5).timeout
	check(not main.activity_running, "idling should end")
	check(time_sys.get_minute_of_day() - before_minutes == 20, "idling must cost 20 minutes, got %d" % (time_sys.get_minute_of_day() - before_minutes))
	check(main.mood == mini(100, mood_before + 8), "idling should give back mood")
	check(main.toast_label.text.contains("谁的消息也没回"), "the idle should be narrated, got: " + main.toast_label.text)
	print("PASS idling at the round table settles once and gives back mood")

	# ---------------------------------------------------- 5 阿哲的午间日程
	_set_clock(12 * 60 + 30)
	main._sync_location_npcs()
	await process_frame
	await process_frame
	check(_npc_button("azhe") != null, "azhe should be at the cafe at 12:30")
	_set_clock(15 * 60)
	main._sync_location_npcs()
	await process_frame
	await process_frame
	check(_npc_button("azhe") == null, "azhe should have left the cafe by 15:00")
	print("PASS azhe keeps his noon cafe schedule")

	# ---------------------------------------------------- 6 层跟随地点开关
	location.travel_to("home")
	await process_frame
	await process_frame
	check(not cafe.layer.visible, "the cafe layer must hide away from the cafe")
	location.travel_to("cafe")
	await process_frame
	await process_frame
	check(cafe.layer.visible, "the cafe layer must come back in the cafe")
	print("PASS the cafe layer follows the current location")

	print("cafe failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
