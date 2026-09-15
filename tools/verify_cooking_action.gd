extends SceneTree
## COOK-ACTION-001 headless integration check.
## This is not the final visual acceptance. It proves the gameplay path is a real action lifecycle:
## approach/trigger -> active cooking motion -> one settlement -> exit motion -> controls restored.

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

	assert(main.activity_running, "Cooking must enter the shared activity lifecycle")
	assert(activities._cook_visual_active, "Cooking must start a dedicated visual lifecycle")
	assert(location.player_pose == "cook", "Cooking must use the cook pose instead of generic interact")
	assert(location.input_blocked, "Player movement must stay locked while cooking")

	if activities.has_cook_action_asset():
		assert(activities.cook_sprite.visible, "Dedicated cook sprite must be visible when the sheet exists")
		assert(not location.player_sprite.visible, "Walk sprite must be hidden while dedicated cooking art is active")
	else:
		assert(location.player_sprite.visible, "Runtime cook rig must keep the protagonist visible")
		assert(location.player_sprite.is_playing(), "Runtime cook rig must animate character frames")
		assert(location.activity_prop.visible, "Runtime cook rig must show the cooking prop")
		assert(location.activity_prop.kind == "pot", "Cooking prop must be the pot")
		var first_phase: float = location.activity_prop.phase
		await create_timer(0.22).timeout
		assert(location.activity_prop.phase > first_phase, "Pot/steam animation must advance over time")

	# _begin_activity is 1.2s; allow the additional ~0.18-0.25s cook exit animation to finish too.
	await create_timer(1.45).timeout
	assert(not main.activity_running, "Cooking settlement must finish")
	assert(not activities._cook_visual_active, "Cooking visual must finish its exit phase")
	assert(not location.input_blocked, "Controls must be restored after the exit phase")
	assert(location.player_sprite.visible, "Normal protagonist sprite must be restored")
	assert(not location.player_sprite.is_playing(), "Protagonist must return to an idle frame after cooking")
	assert(location.player_sprite.position.distance_to(meal_spot["position"]) < 0.5, "Cooking must end at the kitchen station")
	assert(main.money == before_money - 20, "Cooking must charge exactly once")
	assert(main.time_sys.get_minute_of_day() - before_minutes == 30, "Cooking must advance exactly 30 minutes")
	assert(main.health == 55, "Cooking must apply health exactly once")
	assert(main.fullness == 85, "Cooking must apply fullness exactly once")

	print("PASS COOK-ACTION-001: trigger -> motion -> settlement -> exit -> control restore")
	quit()
