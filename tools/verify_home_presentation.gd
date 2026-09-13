extends SceneTree
## 出租屋表现层回归：锚点、姿态、床上被子与结束后的自由姿态。

const Data = preload("res://scripts/Data.gd")

var main: Node
var failures := 0
var frame_count := 0

func _init() -> void:
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count < 8:
		return false
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main._process(0.0)
	_check_anchors()
	_check_sleep_pose()
	_check_work_poses()
	quit(0 if failures == 0 else 1)
	return true

func _expect(value: bool, label: String) -> void:
	if value:
		print("PASS ", label)
	else:
		failures += 1
		push_error("FAIL " + label)

func _check_anchors() -> void:
	for id in ["rest", "study", "meal", "leave"]:
		var anchor: Dictionary = main.home_activities.SPOTS[id]
		_expect(anchor.has("position") and anchor.has("facing") and anchor.has("pose") and anchor.has("depth") and anchor.has("interactionType"), "anchor fields: " + id)

func _check_sleep_pose() -> void:
	var location = main.location_sys
	var anchor: Dictionary = main.home_activities.SPOTS["rest"]
	location.player_sprite.position = anchor["position"]
	location.set_activity_feedback("睡意渐浓", true, "rest", anchor)
	_expect(location.player_pose == "sleep", "bed enters sleep pose")
	_expect(location.home_interaction_visual.visible, "duvet visible during sleep")
	_expect(is_zero_approx(location.player_shadow.modulate.a), "sleep hides ground shadow")
	location.set_activity_feedback("", false)
	_expect(location.player_pose == "idle" and not location.home_interaction_visual.visible, "bed restores free pose")

func _check_work_poses() -> void:
	var location = main.location_sys
	for id in ["study", "meal", "leave"]:
		var anchor: Dictionary = main.home_activities.SPOTS[id]
		location.player_sprite.position = anchor["position"]
		location.set_activity_feedback("进行中", true, id, anchor)
		_expect(location.player_pose == str(anchor["pose"]), "interaction pose: " + id)
		_expect(location.player_sprite.z_index == int(anchor["depth"]), "interaction depth: " + id)
		location.set_activity_feedback("", false)
