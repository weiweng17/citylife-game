extends SceneTree
## 截图验证：休息/学习/做饭三个活动进行中的角色与手持道具。
## 输出 res://build/qa/home_prop_<id>.png（被 Git 忽略）。

const Data = preload("res://scripts/Data.gd")

const IDS := ["rest", "study", "meal"]

var main: Node
var frame_count: int = 0
var phase: int = 0
var index: int = 0
var use_candidate_bed_group := false
var use_background_blanket_v2 := false
var use_background_blanket_v3 := false

func _init() -> void:
	use_candidate_bed_group = OS.get_cmdline_user_args().has("--candidate-bed-group")
	use_background_blanket_v2 = OS.get_cmdline_user_args().has("--background-blanket-v2")
	use_background_blanket_v3 = OS.get_cmdline_user_args().has("--background-blanket-v3")
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
		location.home_interaction_visual.set_candidate_bed_group(use_candidate_bed_group)
		location.home_interaction_visual.set_background_blanket_v2(use_background_blanket_v2)
		location.home_interaction_visual.set_background_blanket_v3(use_background_blanket_v3)
		phase = 1
		frame_count = 0
	elif phase == 1 and frame_count >= 4:
		if index >= IDS.size():
			quit(0)
			return true
		var id: String = IDS[index]
		var location = main.location_sys
		location.player_sprite.position = main.home_activities.SPOTS[id].position
		location.player_target = location.player_sprite.position
		main.home_activities.blocked = false
		main.home_activities._activate(id)
		phase = 2
		frame_count = 0
	# 床有 SleepEnter 淡入：等睡姿和被子都进入稳定画面后再截，不截交叉淡入的中间帧。
	elif phase == 2 and frame_count >= (28 if IDS[index] == "rest" else 5):
		var suffix := "_candidate" if use_candidate_bed_group else ("_background_v3" if use_background_blanket_v3 else ("_background_v2" if use_background_blanket_v2 else "_legacy"))
		var path := "res://build/qa/home_prop_%s%s.png" % [IDS[index], suffix]
		var result: Error = root.get_texture().get_image().save_png(path)
		print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
		phase = 3
		frame_count = 0
	elif phase == 3 and frame_count >= 240:
		# 上一个活动必须真正结算（activity_running 复位）才能触发下一个，
		# 否则 _activate 会被活动锁拒掉，截到的是上一次的反馈。
		if main.activity_running:
			return false
		index += 1
		phase = 1
		frame_count = 0
	return false
