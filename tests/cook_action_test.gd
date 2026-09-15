extends SceneTree
## COOK-ACTION-001 Godot Headless acceptance.
## Exercises the real home -> kitchen -> E-equivalent activation path and records CI artifacts.

var report_lines: PackedStringArray = []

func _init() -> void:
	call_deferred("run")

func _record(ok: bool, message: String) -> bool:
	report_lines.append(("%s %s" % ["PASS" if ok else "FAIL", message]))
	if ok:
		return true
	_write_report()
	push_error("COOK-ACTION-001 FAIL: " + message)
	quit(1)
	return false

func _write_report() -> void:
	var file := FileAccess.open("res://cook-test-report.md", FileAccess.WRITE)
	if file != null:
		file.store_string("# COOK-ACTION-001\n\n" + "\n".join(report_lines) + "\n")
	_capture_image()

func _capture_image() -> void:
	await process_frame
	var image := root.get_texture().get_image()
	if image != null:
		image.save_png("res://cook-test.png")

func run() -> void:
	var packed := load("res://scenes/Main.tscn")
	if not _record(packed != null, "game scene loads"):
		return
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)

	main.money = 100
	main.health = 50
	main.fullness = 40
	var activities = main.home_activities
	var location = main.location_sys
	var meal_spot: Dictionary = activities.SPOTS["meal"]

	# Headless equivalent of entering home, walking to the kitchen, and pressing E.
	if not _record(location.current_location == "home", "entered home"):
		return
	location.player_sprite.position = meal_spot["position"]
	location.player_target = meal_spot["position"]
	activities.blocked = false
	await process_frame
	var before_minutes: int = main.time_sys.get_minute_of_day()
	var before_money: int = main.money
	activities._activate("meal")
	await process_frame
	await process_frame

	if not _record(main.activity_running, "meal interaction succeeded"):
		return
	if not _record(location.activity_controller == "cook", "cook activity owns animation control"):
		return
	if not _record(location.player_state == "cook" and location.player_pose == "cook", "cook state is present"):
		return
	if not _record(location.input_blocked, "movement is locked during cooking"):
		return
	if not _record(activities._cook_visual_active, "cook visual lifecycle started"):
		return
	if activities.has_cook_action_asset():
		if not _record(activities.cook_sprite.visible and activities.cook_sprite.is_playing(), "dedicated cook animation keeps playing"):
			return
	else:
		if not _record(location.player_sprite.visible and location.player_sprite.is_playing(), "runtime cook animation keeps playing"):
			return
		if not _record(location.activity_prop.visible and location.activity_prop.kind == "pot", "cooking prop exists"):
			return
		var phase: float = float(location.activity_prop.phase)
		await create_timer(0.22).timeout
		if not _record(location.activity_prop.phase > phase, "cooking prop animation advances"):
			return

	await create_timer(1.45).timeout
	if not _record(not main.activity_running, "time settlement completed"):
		return
	if not _record(main.money == before_money - 20, "money changed by -20"):
		return
	if not _record(main.time_sys.get_minute_of_day() - before_minutes == 30, "time changed by 30 minutes"):
		return
	if not _record(main.health == 55 and main.fullness == 85, "cooking attributes changed once"):
		return
	if not _record(location.activity_controller.is_empty() and location.player_state == "idle", "control returns to idle"):
		return
	if not _record(not location.input_blocked and not location.player_sprite.is_playing(), "movement is restored"):
		return

	_write_report()
	print("COOK-ACTION-001 PASS")
	quit(0)
