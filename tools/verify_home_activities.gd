extends SceneTree

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
	main.health = 50
	main.mood = 50
	main.money = 100
	var activities = main.home_activities
	main.location_sys.player_sprite.position = Vector2(850, 460)
	await process_frame
	activities._activate("rest")
	assert(not main.activity_running, "Remote activation must be rejected")
	var expected_animations := {"rest": &"walk_left", "study": &"walk_up", "meal": &"walk_right"}
	for id in ["rest", "study", "meal"]:
		main.location_sys.player_sprite.position = activities.SPOTS[id].position
		main.location_sys.player_target = main.location_sys.player_sprite.position
		activities.blocked = false
		var before_minutes: int = main.time_sys.get_minute_of_day()
		activities._activate(id)
		assert(main.activity_running)
		assert(main.location_sys.player_sprite.animation == expected_animations[id], "Activity facing must match furniture: " + id)
		assert(main.location_sys.player_feedback.visible, "Activity feedback must be visible: " + id)
		activities._activate(id)
		await create_timer(1.5).timeout
		assert(not main.activity_running)
		assert(not main.location_sys.player_feedback.visible, "Activity feedback must clear: " + id)
		var elapsed: int = main.time_sys.get_minute_of_day() - before_minutes
		assert(elapsed == {"rest":120, "study":60, "meal":30}[id], "Activity must settle only once")
		print("PASS proximity and single settlement: ", id)
	assert(main.health == 67)
	assert(main.mood == 55)
	assert(main.money == 80)
	main.location_sys.player_sprite.position = activities.SPOTS.leave.position
	activities.blocked = false
	# 出门会立刻切图，切图时 _refresh() 会把动画复位成落地朝向 walk_down。
	# 先用“未开局”守卫拦住 _on_home_activity 的切图分支，单独验证房门朝向，再放开验证切图。
	main.game_started = false
	activities._activate("leave")
	assert(main.location_sys.player_sprite.animation == &"walk_right", "Door facing must point toward exit")
	main.game_started = true
	activities._activate("leave")
	assert(main.location_sys.current_location == "subway")
	print("PASS effects and door travel")
	quit()
