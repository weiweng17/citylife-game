extends SceneTree
## 医院互动截图：诊桌问诊进行中、候诊椅结算反馈。
## 输出 build/qa/hospital_clinic.png / hospital_bench.png
##
## 两个站位是不是压在美术的诊桌/候诊椅上、提示行会不会被底部面板盖住，
## 只能靠眼睛看。

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
				_setup()
				phase = 1
				frame_count = 0
		1:
			if main.hospital_activities.layer.visible and not main.hospital_activities.blocked:
				main.hospital_activities._activate("clinic")
				phase = 2
				frame_count = 0
			elif frame_count > 600:
				printerr("hospital capture: hospital layer never showed up")
				quit(1)
				return true
		2:
			# 截一张"进行中"：头顶反馈 + 进度文字。
			if frame_count >= 20:
				_capture("res://build/qa/hospital_clinic.png")
				phase = 3
				frame_count = 0
		3:
			# 等问诊结算落下来，再走到候诊椅。
			if not main.activity_running and settle_frames >= 4:
				main.location_sys.player_sprite.position = main.hospital_activities.SPOTS.bench.position
				main.location_sys.player_target = main.location_sys.player_sprite.position
				phase = 4
				frame_count = 0
				settle_frames = 0
			elif main.activity_running:
				settle_frames = 0
			else:
				settle_frames += 1
		4:
			if not main.hospital_activities.blocked:
				main.hospital_activities._activate("bench")
				phase = 5
				frame_count = 0
			elif frame_count > 600:
				printerr("hospital capture: hospital layer blocked")
				quit(1)
				return true
		5:
			# 候诊结算完再等几帧，让提示完全落上去。
			if not main.activity_running:
				settle_frames += 1
			else:
				settle_frames = 0
			if settle_frames >= 4:
				_capture("res://build/qa/hospital_bench.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("hospital capture timed out")
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.location_sys.unlock("hospital")
	main.location_sys.travel_to("hospital")
	main.location_sys.player_sprite.position = main.hospital_activities.SPOTS.clinic.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.money = 200
	main.health = 40
	main.energy = 60
	main.mood = 50
	main.fullness = 70


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
