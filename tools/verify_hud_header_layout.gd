extends SceneTree
## UI-FIX-003 narrow HUD/header layout contract check.
## This script is prepared for Godot 4.7.2 headless execution but is not run by the web worker.

const Data = preload("res://scripts/Data.gd")
const EXPECTED_HUD_HEIGHT := 112.0
const NARROW_VIEWPORT := Vector2i(1024, 720)

var main: Node
var frames := 0
var phase := 0
var failures: Array[String] = []


func _init() -> void:
	var packed: PackedScene = load("res://scenes/Main.tscn")
	main = packed.instantiate()
	get_root().add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if phase == 0:
		if frames < 5:
			return false
		_prepare_long_content()
		_run_layout_checks("default")
		# Exercise one narrower desktop/Web width in the same regression. Waiting a few
		# frames lets anchors and the HUD viewport-size callback settle before rechecking.
		get_root().size = NARROW_VIEWPORT
		phase = 1
		frames = 0
		return false

	if frames < 3:
		return false
	var hud = main.get("hud")
	hud._sync_viewport()
	_run_layout_checks("1024x720")
	_finish()
	return true


func _prepare_long_content() -> void:
	main._choose_origin(Data.ORIGINS[0])
	var dialog = main.get("dialog_ui")
	if dialog != null:
		dialog.close_dialog()
	var queue: Array = main.get("dialog_queue")
	queue.clear()

	var hud = main.get("hud")
	var state = main.get("game_state")
	# Use intentionally long common-content strings. They must stay inside the HUD envelope
	# instead of increasing its height and colliding with the independently owned header.
	hud.refresh(
		state,
		"职业发展与生活平衡阶段",
		"在连续工作、生活安排和城市探索之间找到自己的长期节奏，并完成这一阶段的多个目标",
		12,
		"完成一条足够长的任务说明，用来验证常见内容增长不会把 HUD 向下撑进地点标题"
	)
	hud.refresh_daily("通勤 ✓ · 工作 ✓ · 吃饭 ✓ · 休息 ✓ · 额外安排：处理一件今天必须完成但描述很长的事情")
	hud.refresh_skill(999, "资深岗位·长期成长测试")
	hud.refresh_time(999, "23:59", "深夜加班后的漫长时段")
	hud.refresh_weather("持续大雨并伴随强风")
	hud.refresh_bag(999)
	hud._sync_viewport()


func _run_layout_checks(label: String) -> void:
	var hud = main.get("hud")
	var location = main.get("location_sys")
	var header: Control = location.root.get_node("LocationHeader") as Control
	var hud_rect := hud.get_global_rect()
	var header_rect := header.get_global_rect()
	var viewport_width := get_root().size.x

	_expect(is_equal_approx(hud.size.y, EXPECTED_HUD_HEIGHT), "%s: HUD external height must remain the owned 112px reservation" % label)
	_expect(is_equal_approx(hud.get_reserved_height(), EXPECTED_HUD_HEIGHT), "%s: HUD must expose the same reserved-height contract" % label)
	_expect(hud.clip_contents, "%s: HUD must clip unexpected child overflow inside its own reservation" % label)
	_expect(hud_rect.end.y <= header_rect.position.y, "%s: HUD reservation must remain separated from LocationHeader" % label)
	_expect(hud_rect.position.x >= -0.5 and hud_rect.end.x <= float(viewport_width) + 0.5, "%s: HUD envelope must stay inside the viewport width" % label)

	var content: Control = hud.get_node("HUDContent") as Control
	var primary: Control = hud.get_node("HUDContent/PrimaryRow") as Control
	var status: Control = hud.get_node("HUDContent/StatusRow") as Control
	_expect(content.get_global_rect().end.y <= hud_rect.end.y + 0.5, "%s: HUD content must fit vertically inside the owned reservation" % label)
	_expect(primary.get_global_rect().end.x <= hud_rect.end.x + 0.5, "%s: primary row must not overflow the HUD horizontally" % label)
	_expect(status.get_global_rect().end.x <= hud_rect.end.x + 0.5, "%s: status row must not overflow the HUD horizontally" % label)

	var daily: Label = hud.get_node("HUDContent/DailyRow") as Label
	var goal: Label = hud.get_node("HUDContent/GoalRow") as Label
	_expect(daily.autowrap_mode == TextServer.AUTOWRAP_OFF, "%s: daily row must stay single-line" % label)
	_expect(goal.autowrap_mode == TextServer.AUTOWRAP_OFF, "%s: goal row must stay single-line" % label)
	_expect(daily.clip_text and goal.clip_text, "%s: long daily/goal copy must be clipped inside HUD instead of growing vertically" % label)
	_expect(daily.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "%s: daily row must use ellipsis overrun" % label)
	_expect(goal.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "%s: goal row must use ellipsis overrun" % label)
	_expect(daily.tooltip_text == daily.text, "%s: daily tooltip must preserve full clipped text" % label)
	_expect(goal.tooltip_text == goal.text, "%s: goal tooltip must preserve full clipped text" % label)

	for button_name in ["BackpackButton", "SaveButton", "LoadButton", "QuitButton"]:
		var button: Button = hud.get_node("HUDContent/PrimaryRow/%s" % button_name) as Button
		_expect(button != null, "%s: %s must remain reachable in the primary HUD row" % [label, button_name])
		if button != null:
			var button_rect := button.get_global_rect()
			var inside_hud := (
				button_rect.position.x >= hud_rect.position.x - 0.5
				and button_rect.end.x <= hud_rect.end.x + 0.5
				and button_rect.position.y >= hud_rect.position.y - 0.5
				and button_rect.end.y <= hud_rect.end.y + 0.5
			)
			_expect(inside_hud, "%s: %s must remain inside the HUD reservation" % [label, button_name])

	print("[%s] viewport=%s HUD=%s header=%s primary=%s status=%s" % [
		label,
		get_root().size,
		hud_rect,
		header_rect,
		primary.get_global_rect(),
		status.get_global_rect(),
	])


func _finish() -> void:
	if failures.is_empty():
		print("[PASS] HUD/header layout contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
