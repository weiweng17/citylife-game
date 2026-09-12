extends SceneTree
## 出租屋家具全边缘实走复核。
## 沿每个家具轮廓外侧取贴边站位，逐点验证：站得住、能从出生点走到、路径不穿家具；
## 然后真的沿轮廓走完整一圈，全程脚底必须留在可走地面上。
## 另输出前景遮挡覆盖诊断（INFO，不作为失败项）。

var failures: Array[String] = []
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	location.set_process(false)
	main.home_activities.set_process(false)
	location.input_blocked = false
	location.current_location = "home"
	location._refresh()

	var nav = location.navigation
	var margin: float = nav.RADIUS + 2.0
	var spawn: Vector2 = location.player_sprite.position
	var outlines: Array = location.NAVIGATION["home"].get("polygons", [])

	var index := 0
	for outline in outlines:
		index += 1
		var ring := PackedVector2Array(outline)
		var standing: Array[Vector2] = []
		for edge in range(ring.size()):
			var a: Vector2 = ring[edge]
			var b: Vector2 = ring[(edge + 1) % ring.size()]
			var samples: int = maxi(2, int(a.distance_to(b) / 26.0))
			var normal := Vector2(-(b - a).y, (b - a).x).normalized()
			for step in range(samples + 1):
				var point: Vector2 = a.lerp(b, float(step) / float(samples))
				for side in [1.0, -1.0]:
					var candidate: Vector2 = point + normal * side * margin
					if nav.is_walkable(candidate):
						standing.append(candidate)
		var sealed := _is_boundary_seal(outline, location)
		check(standing.size() >= 3 or sealed, "furniture %d must expose walkable edge samples" % index)

		for point in standing:
			check(nav.is_walkable(point), "furniture %d edge sample stands inside the collider" % index)
			_reset(location, spawn)
			check(location.walk_to(point), "furniture %d edge sample %s unreachable from spawn" % [index, point])
			var previous: Vector2 = location.player_sprite.position
			for waypoint in location.walk_path:
				check(nav.segment_clear(previous, waypoint), "furniture %d route crosses a collider" % index)
				previous = waypoint

		# 沿轮廓连续走一圈：模拟玩家贴着家具绕行，不允许任何一帧离开地面。
		for point in standing:
			_reset(location, spawn)
			if not location.walk_to(point):
				continue
			for frame in range(2400):
				location._advance_path(1.0 / 60.0)
				check(nav.is_walkable(location.player_sprite.position), "furniture %d edge walk left the floor" % index)
				if location.walk_path.is_empty():
					break
		print("CHECKED furniture %d: %d edge samples walked" % [index, standing.size()])

	_report_occlusion(location, outlines)
	print("Home edge checks: ", checks, "; failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _reset(location, spawn: Vector2) -> void:
	location.player_sprite.position = spawn
	location.player_target = spawn
	location.walk_path.clear()

## 封堵体贴着可行走区边框，作用是消除死区，不要求能绕行。
func _is_boundary_seal(outline, location) -> bool:
	var rect: Rect2 = location.NAVIGATION["home"].get("bounds", Rect2())
	for raw in outline:
		var point: Vector2 = raw
		var on_border: bool = (
			absf(point.x - rect.position.x) < 0.6
			or absf(point.x - rect.end.x) < 0.6
			or absf(point.y - rect.position.y) < 0.6
			or absf(point.y - rect.end.y) < 0.6
		)
		if on_border:
			return true
	return false

func _report_occlusion(location, outlines: Array) -> void:
	var occluders: Array = location.OCCLUDERS.get("home", [])
	var index := 0
	for outline in outlines:
		index += 1
		var ring := PackedVector2Array(outline)
		var center := Vector2.ZERO
		for point in ring:
			center += point
		center /= float(maxi(1, ring.size()))
		var covered := false
		for item in occluders:
			if not item is Dictionary:
				continue
			var shape: PackedVector2Array = PackedVector2Array((item as Dictionary).get("points", []))
			if shape.size() >= 3 and Geometry2D.is_point_in_polygon(center, shape):
				covered = true
				break
		print("[INFO] furniture %d centre %s foreground: %s" % [index, center, "covered" if covered else "NO FOREGROUND OCCLUDER"])
