extends SceneTree

var failures: Array[String] = []
var checks := 0

func _init() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	location.set_process(false)
	main.home_activities.set_process(false)
	location.input_blocked = false
	var random := RandomNumberGenerator.new()
	random.seed = 74192
	for id in location.NAVIGATION:
		location.current_location = id
		location._refresh()
		var nav = location.navigation
		check(nav.is_walkable(location.player_sprite.position), id + " spawn must be outside EVERY obstacle")
		for rectangle in location.NAVIGATION[id].blocked:
			var resolved: Vector2 = location._clamp_walk_position(rectangle.get_center())
			check(nav.is_walkable(resolved), id + " recovery must clear ALL overlapping obstacles")
		for polygon in nav.polygons:
			for vertex in polygon:
				check(nav.is_walkable(location._clamp_walk_position(vertex)), id + " polygon recovery failed")
		for step in range(350):
			var before: Vector2 = location.player_sprite.position
			var direction := Vector2.from_angle(random.randf_range(-PI, PI))
			location._move_player(direction, 0.2)
			var after: Vector2 = location.player_sprite.position
			check(nav.is_walkable(after), id + " movement outside safe floor")
			check(before.distance_to(after) <= location.PLAYER_SPEED * 0.033 + 0.01, id + " movement teleported")
		print("CHECKED spawn, overlapping recovery, 350 low-FPS movement steps: ", id)
	location.current_location = "home"
	location._refresh()
	var home = main.home_activities
	for id in home.SPOTS:
		location._refresh()
		check(location.walk_to(home.SPOTS[id].position), "home route missing: " + id)
		var previous: Vector2 = location.player_sprite.position
		for waypoint in location.walk_path:
			check(location.navigation.segment_clear(previous, waypoint), "home route crosses furniture: " + id)
			previous = waypoint
		for step in range(1800):
			location._advance_path(1.0 / 60.0)
			check(location.navigation.is_walkable(location.player_sprite.position), "home route left walkable floor: " + id)
			if location.walk_path.is_empty():
				break
		check(location.player_sprite.position.distance_to(home.SPOTS[id].position) < 3.0, "home route did not arrive: " + id)
		print("CHECKED routed walk to furniture: ", id)
	# Real input-state regression: releasing D must not return to the previous frame.
	location._refresh()
	var key := InputEventKey.new()
	key.keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key)
	location._process(1.0 / 60.0)
	var after_key: Vector2 = location.player_sprite.position
	key = InputEventKey.new()
	key.keycode = KEY_D
	key.pressed = false
	Input.parse_input_event(key)
	location._process(1.0 / 60.0)
	check(location.player_sprite.position.is_equal_approx(after_key), "keyboard release rolled position back")
	var original_button: Node = location.travel_box.get_child(0)
	for index in range(120):
		location.apply_story_unlocks({})
	check(location.travel_box.get_child(0) == original_button, "travel buttons recreated with unchanged state")
	# Disconnected map and a diagonal passing exactly through an obstacle corner.
	var isolated = load("res://scripts/systems/LocationNavigation.gd").new()
	isolated.configure({"bounds": Rect2(0, 0, 240, 200), "blocked": [Rect2(110, 0, 20, 200)]})
	check(isolated.find_path(Vector2(40, 100), Vector2(200, 100)).is_empty(), "unreachable target must not teleport across wall")
	check(not isolated.segment_clear(Vector2(40, 30), Vector2(200, 160)), "diagonal swept collision missed wall")
	isolated.configure({"bounds": Rect2(0, 0, 240, 200), "polygons": [[Vector2(100, 30), Vector2(150, 80), Vector2(100, 130), Vector2(50, 80)]]})
	check(not isolated.segment_clear(Vector2(30, 80), Vector2(200, 80)), "polygon swept collision missed rotated furniture")
	check(not isolated.is_walkable(Vector2(100, 80)), "polygon interior must be blocked")
	check(not isolated.find_path(Vector2(30, 150), Vector2(200, 30)).is_empty(), "rotated furniture should allow a detour")
	print("Navigation checks: ", checks, "; failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
