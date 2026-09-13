extends SceneTree
## 交互质感抽查截图：可走落点的金色涟漪，与不可走落点的红色提示。
## 输出 res://build/qa/home_marker_ok.png 与 home_marker_blocked.png。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var phase: int = 0

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)

func _process(_delta: float) -> bool:
	frame_count += 1
	if phase == 0 and frame_count >= 8:
		main._choose_origin(Data.ORIGINS[0])
		main.dialog_queue.clear()
		main.dialog_ui.close_dialog()
		main.set_process(false)
		var location = main.location_sys
		location.current_location = "home"
		location._refresh()
		location.player_sprite.position = Vector2(700, 460)
		location.player_target = location.player_sprite.position
		location._update_player_grounding()
		location.move_marker.ping(Vector2(770, 505))
		phase = 1
		frame_count = 0
	elif phase == 1 and frame_count >= 14:
		_capture("res://build/qa/home_marker_ok.png")
		# 床体内部：走不到的地方应该给出红色落点提示。
		main.location_sys.move_marker.ping(Vector2(237, 420), true)
		phase = 2
		frame_count = 0
	elif phase == 2 and frame_count >= 8:
		_capture("res://build/qa/home_marker_blocked.png")
		quit(0)
		return true
	return false

func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
