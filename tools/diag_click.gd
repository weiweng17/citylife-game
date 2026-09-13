extends SceneTree
## 诊断用（只读）：复现 verify_home_input 的第一处点击，找出是谁吃掉了那一下。
## 不改任何状态，只打印几何与命中结果。

func _init() -> void:
	call_deferred("run")


func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	main.set_process(false)
	var location = main.location_sys
	var home = main.home_activities
	location.set_process(false)
	home.set_process(false)
	home._process(0)
	await process_frame

	print("location.active=", location.active, " current=", location.current_location)
	print("home.layer.visible=", home.layer.visible, " home.blocked=", home.blocked)
	var btn: Button = home.buttons["rest"]
	var target: Vector2 = btn.get_global_rect().get_center()
	print("rest rect=", btn.get_global_rect(), " center=", target)
	print("rest visible_in_tree=", btn.is_visible_in_tree(), " disabled=", btn.disabled)

	var motion := InputEventMouseMotion.new()
	motion.position = target
	root.push_input(motion)
	await process_frame
	var hovered: Control = root.gui_get_hovered_control()
	if hovered == null:
		print("hovered=<none>")
	else:
		print("hovered=", hovered.get_path(), " class=", hovered.get_class(), " mf=", hovered.mouse_filter)

	print("--- controls covering the point (painter's order, top last) ---")
	var found: Array[String] = []
	_collect(main, target, found)
	for line in found:
		print(line)

	print("--- viewport size: ", root.get_visible_rect().size)

	# 真正点一下，看 _request 里走到哪一步。
	print("player=", location.player_sprite.position, " bed=", home.SPOTS["rest"].position,
		" dist=", location.player_sprite.position.distance_to(home.SPOTS["rest"].position))
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = target
	click.pressed = true
	root.push_input(click)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = target
	release.pressed = false
	root.push_input(release)
	await process_frame
	print("after click -> home.pending=", home.pending, " activity_running=", main.activity_running)
	print("player_target=", location.player_target, " walk_path=", location.walk_path.size())
	print("direct walk_to returns=", location.walk_to(home.SPOTS["rest"].position),
		" path=", location.walk_path.size())
	quit(0)


func _collect(node: Node, point: Vector2, out: Array[String]) -> void:
	for child in node.get_children():
		if child is Control:
			var c := child as Control
			if c.is_visible_in_tree() and c.get_global_rect().has_point(point):
				var mf: int = c.mouse_filter
				var tag := "IGNORE" if mf == Control.MOUSE_FILTER_IGNORE else ("STOP" if mf == Control.MOUSE_FILTER_STOP else "PASS")
				out.append("%-11s %-14s %s" % [tag, c.get_class(), str(c.get_global_rect())] + "  " + str(c.get_path()))
		_collect(child, point, out)
