extends SceneTree
## 生成地点模式视觉回归截图：居民区、居民区行动事件、便利店。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var phase: int = 0
var capture_spot: String = ""


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	var packed: PackedScene = load("res://scenes/Main.tscn")
	main = packed.instantiate()
	get_root().add_child(main)


func _process(_delta: float) -> bool:
	frame_count += 1
	if phase == 0 and frame_count >= 8:
		main._choose_origin(Data.ORIGINS[0])
		main.get("dialog_ui").close_dialog()
		var queue: Array = main.get("dialog_queue")
		queue.clear()
		main.get("game_state").flags = {}
		main.get("location_sys").current_location = "home"
		main.get("location_sys")._refresh()
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--spot="):
				capture_spot = argument.trim_prefix("--spot=")
				if main.home_activities.SPOTS.has(capture_spot):
					var location = main.location_sys
					location.player_sprite.position = location._clamp_walk_position(main.home_activities.SPOTS[capture_spot].position)
					location.stop_walking()
					location._update_player_grounding()
		if OS.get_cmdline_user_args().has("--desk-edge"):
			var location = main.get("location_sys")
			location.player_sprite.position = Vector2(700, 360)
			location.player_target = location.player_sprite.position
			location._update_player_grounding()
		print("[INFO] home texture=%s viewport=%s" % [main.get("location_sys").background.texture.get_size(), get_root().get_visible_rect().size])
		phase = 1
		frame_count = 0
	elif phase == 1 and frame_count >= 8:
		_capture("res://build/qa/home%s.png" % ("_" + capture_spot if not capture_spot.is_empty() else ""))
		if not capture_spot.is_empty():
			quit(0)
			return true
		main.get("events_sys").reset_used()
		main.get("location_sys").action_button.pressed.emit()
		phase = 2
		frame_count = 0
	elif phase == 2 and frame_count >= 8:
		_capture("res://build/qa/home_action.png")
		main.get("event_ui").close_event()
		main.set("cur_event", null)
		var location = main.get("location_sys")
		location.unlock("store")
		location.travel_to("store", false)
		phase = 3
		frame_count = 0
	elif phase == 3 and frame_count >= 8:
		_capture("res://build/qa/store.png")
		quit(0)
		return true
	return false


func _capture(path: String) -> void:
	var image: Image = get_root().get_texture().get_image()
	var result: Error = image.save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
