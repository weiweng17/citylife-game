extends SceneTree
## 旧巷与天台互动截图。
## 输出 build/qa/alley_shrine.png / alley_door.png / rooftop_ledge.png / rooftop_bench.png
##
## 站位是否压在美术的神龛/木门/栏杆/长椅上、提示行会不会被盖住，只能靠眼睛看。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var settle_frames: int = 0
var phase: int = 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frame_count += 1
	match phase:
		0:
			if frame_count >= 8:
				_setup_alley()
				phase = 1
				frame_count = 0
		1:
			if main.alley_activities.layer.visible and not main.alley_activities.blocked:
				main.alley_activities._activate("shrine")
				phase = 2
				frame_count = 0
			elif frame_count > 600:
				printerr("alley capture: layer never showed up")
				quit(1)
				return true
		2:
			if frame_count >= 20:
				_capture("res://build/qa/alley_shrine.png")
				phase = 3
				frame_count = 0
		3:
			if not main.activity_running and settle_frames >= 4:
				main.location_sys.player_sprite.position = main.alley_activities.SPOTS.door.position
				main.location_sys.player_target = main.location_sys.player_sprite.position
				phase = 4
				frame_count = 0
				settle_frames = 0
			elif main.activity_running:
				settle_frames = 0
			else:
				settle_frames += 1
		4:
			if not main.alley_activities.blocked:
				main.alley_activities._activate("door")
				phase = 5
				frame_count = 0
			elif frame_count > 600:
				printerr("alley capture: layer blocked")
				quit(1)
				return true
		5:
			if not main.activity_running:
				settle_frames += 1
			else:
				settle_frames = 0
			if settle_frames >= 4:
				_capture("res://build/qa/alley_door.png")
				phase = 6
				frame_count = 0
				settle_frames = 0
			elif frame_count > 900:
				printerr("alley capture timed out")
				quit(1)
				return true
		6:
			main.location_sys.travel_to("rooftop")
			main.location_sys.player_sprite.position = main.rooftop_activities.SPOTS.ledge.position
			main.location_sys.player_target = main.location_sys.player_sprite.position
			phase = 7
			frame_count = 0
		7:
			if main.rooftop_activities.layer.visible and not main.rooftop_activities.blocked:
				main.rooftop_activities._activate("ledge")
				phase = 8
				frame_count = 0
			elif frame_count > 600:
				printerr("rooftop capture: layer never showed up")
				quit(1)
				return true
		8:
			if frame_count >= 20:
				_capture("res://build/qa/rooftop_ledge.png")
				phase = 9
				frame_count = 0
		9:
			if not main.activity_running and settle_frames >= 4:
				main.location_sys.player_sprite.position = main.rooftop_activities.SPOTS.bench.position
				main.location_sys.player_target = main.location_sys.player_sprite.position
				phase = 10
				frame_count = 0
				settle_frames = 0
			elif main.activity_running:
				settle_frames = 0
			else:
				settle_frames += 1
		10:
			if not main.rooftop_activities.blocked:
				main.rooftop_activities._activate("bench")
				phase = 11
				frame_count = 0
			elif frame_count > 600:
				printerr("rooftop capture: layer blocked")
				quit(1)
				return true
		11:
			if not main.activity_running:
				settle_frames += 1
			else:
				settle_frames = 0
			if settle_frames >= 4:
				_capture("res://build/qa/rooftop_bench.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("rooftop capture timed out")
				quit(1)
				return true
	return false


func _setup_alley() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.location_sys.unlock("alley")
	main.location_sys.unlock("rooftop")
	main.location_sys.travel_to("alley")
	main.location_sys.player_sprite.position = main.alley_activities.SPOTS.shrine.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.money = 50
	main.energy = 60
	main.mood = 50
	main.fullness = 70


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
