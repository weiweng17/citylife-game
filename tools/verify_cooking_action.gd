extends SceneTree
## COOK-ACTION-001 headless integration check.
## This is not the final visual acceptance. It proves the gameplay path is a real action lifecycle:
## approach/trigger -> active cooking motion -> one settlement -> exit motion -> controls restored.
## Never use bare assert() here: a failed assert can abort the coroutine while leaving SceneTree alive,
## which makes CI appear to hang instead of reporting a useful failure.

func _init() -> void:
	call_deferred("run")


func _must(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("COOK-ACTION-001 FAIL: " + message)
	quit(1)
	return false


func run() -> void:
	var watchdog := create_timer(12.0)
	watchdog.timeout.connect(func():
		push_error("COOK-ACTION-001 FAIL: watchdog timeout")
		quit(2)
	)

	var packed = load("res://scenes/Main.tscn")
	if not _must(packed != null, "Main.tscn must load"):
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
	location.player_sprite.position = meal_spot["position"]
	location.player_target = location.player_sprite.position
	activities.blocked = false
	await process_frame

	var before_minutes: int = main.time_sys.get_minute_of_day()
	var before_money: int = main.money
	activities._activate("meal")
	await process_frame
	await process_frame

	if not _must(main.activity_running, "Cooking must enter the shared activity lifecycle"):
		return
	if not _must(activities._cook_visual_active, "Cooking must start a dedicated visual lifecycle"):
		return
	if not _must(location.player_pose == "cook", "Cooking must use the cook pose instead of generic interact"):
		return
	if not _must(location.input_blocked, "Player movement must stay locked while cooking"):
		return

	if activities.has_cook_action_asset():
		if not _must(activities.cook_sprite.visible, "Dedicated cook sprite must be visible when the sheet exists"):
			return
		if not _must(not location.player_sprite.visible, "Walk sprite must be hidden while dedicated cooking art is active"):
			return
	else:
		if not _must(location.player_sprite.visible, "Runtime cook rig must keep the protagonist visible"):
			return
		if not _must(location.player_sprite.is_playing(), "Runtime cook rig must animate character frames"):
			return
		if not _must(location.activity_prop.visible, "Runtime cook rig must show the cooking prop"):
			return
		if not _must(location.activity_prop.kind == "pot", "Cooking prop must be the pot"):
			return
		var first_phase: float = location.activity_prop.phase
		await create_timer(0.22).timeout
		if not _must(location.activity_prop.phase > first_phase, "Pot/steam animation must advance over time"):
			return

	# _begin_activity is 1.2s; allow the additional ~0.18-0.25s cook exit animation to finish too.
	await create_timer(1.45).timeout
	if not _must(not main.activity_running, "Cooking settlement must finish"):
		return
	if not _must(not activities._cook_visual_active, "Cooking visual must finish its exit phase"):
		return
	if not _must(not location.input_blocked, "Controls must be restored after the exit phase"):
		return
	if not _must(location.player_sprite.visible, "Normal protagonist sprite must be restored"):
		return
	if not _must(not location.player_sprite.is_playing(), "Protagonist must return to an idle frame after cooking"):
		return
	if not _must(location.player_sprite.position.distance_to(meal_spot["position"]) < 0.5, "Cooking must end at the kitchen station"):
		return
	if not _must(main.money == before_money - 20, "Cooking must charge exactly once"):
		return
	if not _must(main.time_sys.get_minute_of_day() - before_minutes == 30, "Cooking must advance exactly 30 minutes"):
		return
	if not _must(main.health == 55, "Cooking must apply health exactly once"):
		return
	if not _must(main.fullness == 85, "Cooking must apply fullness exactly once"):
		return

	print("PASS COOK-ACTION-001: trigger -> motion -> settlement -> exit -> control restore")
	quit(0)
