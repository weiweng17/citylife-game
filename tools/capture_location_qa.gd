extends SceneTree
## 生成地点模式视觉回归截图：居民区、居民区行动事件、便利店。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var phase: int = 0


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
		print("[INFO] home texture=%s viewport=%s" % [main.get("location_sys").background.texture.get_size(), get_root().get_visible_rect().size])
		phase = 1
		frame_count = 0
	elif phase == 1 and frame_count >= 8:
		_capture("res://build/qa/home.png")
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
