extends SceneTree
## UI input regression without touching a user's save file.
var failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func click_at(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = position
		event.pressed = pressed
		root.push_input(event)
		await process_frame

func run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("This test requires a rendered window for GUI hit-testing. Run without --headless.")
		quit(2)
		return
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	main.set_process(false)
	var location = main.location_sys
	var home = main.home_activities
	location.set_process(false)
	home.set_process(false)
	main.health = 50
	main.mood = 50
	main.money = 100
	home._process(0)
	await process_frame
	# Click actual furniture Button, then execute its route without waiting for real travel time.
	await click_at(home.buttons.rest.get_global_rect().get_center())
	check(home.pending == "rest", "real click did not queue furniture approach")
	if not failures.is_empty():
		quit(1)
		return
	for step in range(1800):
		location._process(1.0 / 60.0)
		home._process(1.0 / 60.0)
		if main.activity_running:
			break
	check(main.activity_running, "arrival did not start rest")
	var before_location: String = location.current_location
	location._on_travel_pressed("subway")
	check(location.current_location == before_location, "travel allowed during rest")
	main._on_location_action("home")
	check(not main.event_ui.is_busy(), "event allowed during rest")
	main._restart()
	check(main.game_started and main.activity_running, "restart allowed during rest")
	await create_timer(1.5).timeout
	check(main.health == 62 and main.mood == 58, "clicked rest settlement wrong")
	check(not home.blocked and not location.input_blocked, "movement stayed blocked after activity")
	print("CHECKED real furniture button -> route -> rest -> input unlock")
	# E passes through the Viewport input pipeline, not a direct signal call.
	location.player_sprite.position = home.SPOTS.meal.position
	location.stop_walking()
	home._process(0)
	var before_age: int = main.age
	var before_minute: int = main.time_sys.get_minute_of_day()
	for pressed in [true, false]:
		var key := InputEventKey.new()
		key.keycode = KEY_E
		key.pressed = pressed
		root.push_input(key)
		await process_frame
	check(main.activity_running, "E did not activate kitchen")
	await create_timer(1.5).timeout
	check(main.money == 80 and main.health == 67, "E cooking settlement wrong")
	check(main.age == before_age and main.time_sys.get_minute_of_day() - before_minute == 30, "daily action changed year or wrong minutes")
	# Insufficient funds must not consume time or lock movement.
	main.money = 0
	before_minute = main.time_sys.get_minute_of_day()
	home._activate("meal")
	check(not main.activity_running and main.money == 0 and main.time_sys.get_minute_of_day() == before_minute, "failed purchase charged time or money")
	print("CHECKED E cooking, minutes not years, insufficient funds")
	# A new ground-click cancels queued furniture approach.
	location._refresh()
	home._request("rest")
	check(home.pending == "rest", "second approach not queued")
	location.walk_to(Vector2(920, 530))
	home._process(0)
	check(home.pending.is_empty(), "new ground target failed to cancel activity")
	# Test actual travel button remains clickable after many unchanged refreshes.
	location.stop_walking()
	for step in range(120):
		location.apply_story_unlocks({})
	await click_at(location.travel_box.get_child(1).get_global_rect().get_center())
	check(location.current_location == "subway", "real travel button click did not change scene")
	print("CHECKED cancel pending activity and real travel click")
	print("Home input failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
