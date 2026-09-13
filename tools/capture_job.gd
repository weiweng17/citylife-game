extends SceneTree
## 工作技能成长截图：HUD 上的技能档位、技能够了才出现的谈薪点、谈成之后的那句反馈。
## 输出 build/qa/job_skill.png / job_locked.png / job_negotiate.png
##
## 排版与"技能不够时少了什么"只能靠眼睛看，自动测试只断言数值与显隐。

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
	match phase:
		0:
			if frame_count >= 8:
				_setup()
				phase = 1
				frame_count = 0
		1:
			# 技能 55 =「熟练」，两个热点都该在。
			if frame_count >= 12:
				_capture("res://build/qa/job_skill.png")
				main.skill = 48
				main._refresh_ui()
				phase = 2
				frame_count = 0
		2:
			# 技能 48 =「上手」，谈薪点应当消失。
			if frame_count >= 12:
				_capture("res://build/qa/job_locked.png")
				main.skill = 60
				main.network = 40
				main.game_state.raise_steps = 0
				main.game_state.raise_day = 0
				main.mood = 62
				main._refresh_ui()
				phase = 3
				frame_count = 0
		3:
			# 先让"谈薪"这个点真的出现在画面上（它的显隐在 OfficeActivities._process 里刷）。
			if frame_count >= 10:
				main._do_negotiate()
				phase = 4
				frame_count = 0
		4:
			# 谈薪要走 10 步进度，用固定帧数等会截在半路（开窗帧率不稳）。
			# 改成盯着 activity_running 落下来，落下的那一帧正好是提示还新的时候。
			if frame_count >= 6 and not main.activity_running:
				_capture("res://build/qa/job_negotiate.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("job capture timed out")
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.location_sys.unlock("office")
	main.location_sys.travel_to("office")
	# 站在谈薪点旁边，提示行才会显示这一项的价格与条件。
	main.location_sys.player_sprite.position = main.office_activities.SPOTS.negotiate.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.location_sys._update_player_grounding()
	main.skill = 55
	main.money = 1240
	main.mood = 62
	main.health = 78
	main.fullness = 64
	main.energy = 58
	# 让「今日」那行有内容可看，否则截图里是空目标，分不清是没做还是没画。
	main.daily_routine.complete("commute")
	main._refresh_ui()


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
