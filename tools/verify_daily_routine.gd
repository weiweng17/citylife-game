extends SceneTree
## 阶段 2 每日循环：每日目标状态、跨天重置、存档往返、公司工作结算。

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
	var routine = main.daily_routine
	var location = main.location_sys
	var time_sys = main.time_sys
	var office = main.office_activities

	assert(routine != null, "daily routine must exist")
	assert(routine.day == 1)
	for task_id in routine.TASKS:
		assert(not routine.is_done(task_id), "task must start unfinished: " + task_id)

	assert(routine.complete("work"))
	assert(routine.is_done("work"))
	assert(not routine.complete("work"), "repeat complete must be rejected")
	assert(not routine.all_done())
	routine.reset(2)
	assert(routine.day == 2)
	assert(not routine.is_done("work"), "new day must clear tasks")

	routine.complete("meal")
	var saved: Dictionary = routine.to_save_dict()
	routine.reset(1)
	routine.apply_save_dict(saved)
	assert(routine.day == 2)
	assert(routine.is_done("meal"))
	assert(not routine.is_done("work"))
	print("PASS daily routine state and save round-trip")

	location.unlock("office")
	location.travel_to("office")
	assert(location.current_location == "office")
	assert(routine.is_done("commute"), "arriving at office counts as commute")
	assert(location.walk_to(office.SPOTS.work.position), "office desk must be reachable")
	print("PASS commute marks the daily task")

	routine.reset(time_sys.day)
	location.player_sprite.position = office.SPOTS.work.position
	location.player_target = location.player_sprite.position
	office.blocked = false
	var before_money: int = main.money
	var before_health: int = main.health
	var before_mood: int = main.mood
	var before_minutes: int = time_sys.get_minute_of_day()
	office._activate("work")
	assert(main.activity_running)
	assert(location.player_sprite.animation == &"walk_up", "work must face the desk")
	assert(location.activity_prop.visible, "work prop must be visible")
	office._activate("work")
	await create_timer(1.5).timeout
	assert(not main.activity_running)
	assert(main.money == before_money + 120, "work must pay once")
	assert(main.health == before_health - 6)
	assert(main.mood == before_mood - 4)
	assert(time_sys.get_minute_of_day() - before_minutes == 240, "work must cost 4 hours")
	assert(routine.is_done("work"))
	assert(not location.activity_prop.visible, "work prop must clear")
	print("PASS office work settlement")

	var day_before: int = time_sys.day
	time_sys.advance_minutes(24 * 60)
	assert(time_sys.day == day_before + 1)
	assert(not routine.is_done("work"), "crossing midnight must reset daily tasks")
	print("PASS midnight resets daily tasks")
	quit(0)
