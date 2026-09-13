extends SceneTree
## 每日需求：饱食与精力随时间消耗、吃饭睡觉补回、告急独白、存档往返。

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
	var home = main.home_activities
	var location = main.location_sys
	var routine = main.daily_routine

	assert(main.fullness == 70, "fullness must start at 70")
	assert(main.energy == 80, "energy must start at 80")

	# 需求按真实流经的分钟数扣：4 小时应扣 16 饱食、12 精力，而不是按信号只扣一次。
	main.fullness = 60
	main.energy = 70
	time_sys.advance_minutes(240)
	main._sync_needs_to_time()
	assert(main.fullness == 44, "4 hours must cost 16 fullness, got %d" % main.fullness)
	assert(main.energy == 58, "4 hours must cost 12 energy, got %d" % main.energy)
	print("PASS needs drain with real elapsed minutes")

	# 吃饭补饱食并标记今日目标
	main.fullness = 30
	main.money = 100
	routine.reset(time_sys.day)
	location.current_location = "home"
	location._refresh()
	location.player_sprite.position = home.SPOTS.meal.position
	location.player_target = location.player_sprite.position
	home.blocked = false
	home._activate("meal")
	await create_timer(1.5).timeout
	assert(main.fullness == 75, "cooking must restore 45 fullness, got %d" % main.fullness)
	assert(routine.is_done("meal"), "cooking must complete the daily meal task")
	print("PASS meal restores fullness")

	# 睡觉补精力并标记今日目标
	main.energy = 20
	location.player_sprite.position = home.SPOTS.rest.position
	location.player_target = location.player_sprite.position
	home.blocked = false
	home._activate("rest")
	await create_timer(1.5).timeout
	assert(main.energy == 70, "sleeping must restore energy, got %d" % main.energy)
	assert(routine.is_done("sleep"), "sleeping must complete the daily sleep task")
	print("PASS rest restores energy")

	# 告急独白：低值触发一次，同一天不再重复
	main.murmur_shown = {}
	main.fullness = 20
	main._sync_needs_to_time()
	assert(main.murmur_shown.has("fullness"), "low fullness must warn once")
	var first_text: String = main.toast_label.text
	main.murmur_shown["fullness"] = time_sys.day
	main.toast_label.text = ""
	main.fullness = 10
	main._sync_needs_to_time()
	assert(main.toast_label.text.is_empty(), "warning must not repeat on the same day")
	assert(not first_text.is_empty())
	print("PASS low need murmur fires once per day")

	# 需求进存档
	main.fullness = 42
	main.energy = 51
	var saved: Dictionary = main.game_state.to_dict()
	assert(int(saved.get("fullness", -1)) == 42)
	assert(int(saved.get("energy", -1)) == 51)
	main.game_state.apply_dict({"fullness": 11, "energy": 22})
	assert(main.fullness == 11)
	assert(main.energy == 22)
	print("PASS needs survive save round-trip")
	quit(0)
