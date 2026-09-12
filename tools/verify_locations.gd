extends SceneTree
## 地点模式回归：UI 分层、行动按钮、出生点、边界和障碍碰撞。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frames: int = 0


func _init() -> void:
	var packed: PackedScene = load("res://scenes/Main.tscn")
	main = packed.instantiate()
	get_root().add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 5:
		return false
	var ok: bool = _run_checks()
	quit(0 if ok else 1)
	return true


func _run_checks() -> bool:
	var ok: bool = true
	print("=== 地点模式自动回归 ===")

	main._choose_origin(Data.ORIGINS[0])
	var dialog = main.get("dialog_ui")
	if dialog != null:
		dialog.close_dialog()
	var queue: Array = main.get("dialog_queue")
	queue.clear()
	var state = main.get("game_state")
	state.flags = {}

	var location = main.get("location_sys")
	var hud = main.get("hud")
	var header: Control = location.root.get_node("LocationHeader") as Control
	var primary_row: Control = hud.get_node("HUDContent/PrimaryRow") as Control
	var status_row: Control = hud.get_node("HUDContent/StatusRow") as Control
	var ui_separated: bool = hud.get_global_rect().end.y <= header.get_global_rect().position.y
	var hud_rows_separated: bool = primary_row.get_global_rect().end.y <= status_row.get_global_rect().position.y
	print("[%s] HUD 与地点标题分离" % ("OK" if ui_separated else "FAIL"))
	print("[%s] 保存按钮行与状态栏分离" % ("OK" if hud_rows_separated else "FAIL"))
	ok = ok and ui_separated and hud_rows_separated

	main.get("events_sys").reset_used()
	location.current_location = "home"
	location._refresh()
	location.action_button.pressed.emit()
	var event_ui: Control = main.get("event_ui") as Control
	var action_visible: bool = event_ui != null and event_ui.is_visible_in_tree() and event_ui.size.x > 1000.0 and event_ui.size.y > 600.0
	print("[INFO] EventUI rect=%s panel=%s layer=%s" % [event_ui.get_rect(), event_ui.panel.get_rect(), main.get_node("UI").layer])
	print("[%s] 点击居民区行动后事件面板可见且铺满画面" % ("OK" if action_visible else "FAIL"))
	ok = ok and action_visible
	main.get("event_ui").close_event()
	main.set("cur_event", null)

	for location_id in location.NAVIGATION:
		location.current_location = location_id
		var profile: Dictionary = location.NAVIGATION[location_id]
		var bounds: Rect2 = profile["bounds"]
		var safe_bounds: Rect2 = bounds.grow(-13.0)
		var extreme_a: Vector2 = location._clamp_walk_position(Vector2(-9999, -9999))
		var extreme_b: Vector2 = location._clamp_walk_position(Vector2(9999, 9999))
		var bounds_ok: bool = safe_bounds.grow(0.6).has_point(extreme_a) and safe_bounds.grow(0.6).has_point(extreme_b)

		var spawn: Vector2 = location._clamp_walk_position(location.LOCATIONS[location_id]["spawn"])
		var spawn_ok: bool = safe_bounds.grow(0.6).has_point(spawn)
		var obstacles_ok: bool = true
		var continuous_ok: bool = true
		for raw_obstacle in profile["blocked"]:
			var obstacle: Rect2 = (raw_obstacle as Rect2).grow(13.0).intersection(safe_bounds)
			if obstacle.size.x <= 0.0 or obstacle.size.y <= 0.0:
				continue
			var resolved: Vector2 = location._clamp_walk_position(obstacle.get_center())
			if obstacle.has_point(resolved) or not safe_bounds.grow(0.6).has_point(resolved):
				obstacles_ok = false
				break
			var start := Vector2(obstacle.position.x - 1.0, obstacle.get_center().y)
			var direction := Vector2.RIGHT
			if not safe_bounds.grow(0.6).has_point(start):
				start = Vector2(obstacle.end.x + 1.0, obstacle.get_center().y)
				direction = Vector2.LEFT
			location.player_sprite.position = location._clamp_walk_position(start)
			for step in range(45):
				location._move_player(direction, 0.05)
				if obstacle.has_point(location.player_sprite.position):
					continuous_ok = false
					break
			if not continuous_ok:
				break
		var location_ok: bool = bounds_ok and spawn_ok and obstacles_ok and continuous_ok
		print("[%s] %s：边界 / 出生点 / 静态障碍 / 连续移动" % ["OK" if location_ok else "FAIL", location_id])
		ok = ok and location_ok

	print("=== %s ===" % ("全部通过" if ok else "存在失败"))
	return ok
