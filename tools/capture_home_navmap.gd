extends SceneTree
## 渲染出租屋导航调试图：红色为碰撞体、绿点为 A* 可行走网格、
## 黄点为“站得住但走不到”的死区、蓝点为家具互动站位。
## 输出 res://build/qa/home_navmap.png（被 Git 忽略）。

const OVERLAY := preload("res://tools/NavMapOverlay.gd")

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
		main._choose_origin(main.Data.ORIGINS[0])
		main.dialog_queue.clear()
		main.dialog_ui.close_dialog()
		main.set_process(false)
		var location = main.location_sys
		location.set_process(false)
		main.home_activities.set_process(false)
		location.current_location = "home"
		location._refresh()
		_build_overlay(location)
		phase = 1
		frame_count = 0
	elif phase == 1 and frame_count >= 6:
		var image: Image = root.get_texture().get_image()
		var result: Error = image.save_png("res://build/qa/home_navmap.png")
		print("[%s] res://build/qa/home_navmap.png" % ["OK" if result == OK else "FAIL"])
		quit(0)
		return true
	return false

func _build_overlay(location) -> void:
	var nav = location.navigation
	var overlay: Node2D = OVERLAY.new()
	overlay.name = "NavMapOverlay"
	overlay.collision_polygons = location.NAVIGATION["home"].get("polygons", [])
	overlay.bounds_rect = nav.bounds
	for id in nav.graph.get_point_ids():
		overlay.grid_points.append(nav.graph.get_point_position(id))
	for spot in main.home_activities.SPOTS.values():
		overlay.spots.append(spot.position)

	# 沿轮廓外侧取贴边点，复算一次哪些是 A* 到不了的死区。
	var margin: float = nav.RADIUS + 2.0
	var spawn: Vector2 = location.player_sprite.position
	for outline in overlay.collision_polygons:
		var ring := PackedVector2Array(outline)
		for edge in range(ring.size()):
			var a: Vector2 = ring[edge]
			var b: Vector2 = ring[(edge + 1) % ring.size()]
			var samples: int = maxi(2, int(a.distance_to(b) / 26.0))
			var normal := Vector2(-(b - a).y, (b - a).x).normalized()
			for step in range(samples + 1):
				var point: Vector2 = a.lerp(b, float(step) / float(samples))
				for side in [1.0, -1.0]:
					var candidate: Vector2 = point + normal * side * margin
					if not nav.is_walkable(candidate):
						continue
					location.player_sprite.position = spawn
					location.player_target = spawn
					location.walk_path.clear()
					if not location.walk_to(candidate):
						overlay.unreachable.append(candidate)
	location.player_sprite.position = spawn
	location.player_target = spawn
	location.walk_path.clear()
	location._update_player_grounding()
	location.root.add_child(overlay)
	print("[INFO] dead-zone samples: ", overlay.unreachable.size())
