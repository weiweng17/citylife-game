extends SceneTree
## 主线任务截图：开局的任务开场白、HUD 上的任务行、一步做完之后的追加提示。
## 输出 build/qa/quest_intro.png / quest_step.png
##
## 排版（任务行会不会把目标行顶爆、追加提示会不会溢出）只能靠眼睛看。

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
			# 开场白已经弹出来了（_process 每帧都会推进任务），等它和 HUD 一起稳定。
			if frame_count >= 20:
				_capture("res://build/qa/quest_intro.png")
				_travel_office()
				phase = 2
				frame_count = 0
		2:
			# 等交互层真的亮起来再激活（切图后 layer.visible 要等它自己的 _process）。
			if main.office_activities.layer.visible and not main.office_activities.blocked:
				main.office_activities._activate("work")
				phase = 3
				frame_count = 0
			elif frame_count > 600:
				printerr("quest capture: office layer never showed up")
				quit(1)
				return true
		3:
			# 班次要 1.2 秒。落下来的那一帧还不能截：任务提示是**下一帧**才追加的
			# （本截图脚本的 _process 跑在 Game._process 之前），进度文字也要等下一帧才清掉。
			if not main.activity_running:
				settle_frames += 1
			else:
				settle_frames = 0
			if settle_frames >= 4:
				_capture("res://build/qa/quest_step.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("quest capture timed out")
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	# 别动 set_process：任务推进靠 Game._process 每帧跑。


func _travel_office() -> void:
	main.location_sys.unlock("office")
	main.location_sys.travel_to("office")
	main.location_sys.player_sprite.position = main.office_activities.SPOTS.work.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.office_activities.blocked = false
	main.daily_routine.reset(main.time_sys.day)


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
