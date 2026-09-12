extends RefCounted
## Foot-space navigation shared by click routes, keyboard movement and spawn recovery.
## Obstacles are expanded by the player's radius; movement never ejects through a wall.
const RADIUS := 13.0
const CELL := 12.0
var bounds: Rect2
var obstacles: Array[Rect2] = []
var polygons: Array[PackedVector2Array] = []
var graph := AStar2D.new()

func configure(profile: Dictionary) -> void:
	bounds = (profile.get("bounds", Rect2(85, 205, 1110, 360)) as Rect2).grow(-RADIUS)
	obstacles.clear()
	polygons.clear()
	graph.clear()
	for rectangle in profile.get("blocked", []):
		obstacles.append((rectangle as Rect2).grow(RADIUS))
	for outline in profile.get("polygons", []):
		for expanded in Geometry2D.offset_polygon(PackedVector2Array(outline), RADIUS):
			polygons.append(expanded)
	var cells: Dictionary = {}
	for y in range(int(bounds.size.y / CELL) + 1):
		for x in range(int(bounds.size.x / CELL) + 1):
			var point := bounds.position + Vector2(x, y) * CELL
			if is_walkable(point):
				var id := graph.get_point_count()
				graph.add_point(id, point)
				cells[Vector2i(x, y)] = id
	for cell in cells:
		for offset in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1)]:
			if cells.has(cell + offset):
				var a: int = cells[cell]
				var b: int = cells[cell + offset]
				if segment_clear(graph.get_point_position(a), graph.get_point_position(b)):
					graph.connect_points(a, b)

func is_walkable(point: Vector2) -> bool:
	if not bounds.has_point(point):
		return false
	for obstacle in obstacles:
		if obstacle.has_point(point):
			return false
	for polygon in polygons:
		if Geometry2D.is_point_in_polygon(point, polygon):
			return false
	return true

func segment_clear(a: Vector2, b: Vector2) -> bool:
	if not is_walkable(a) or not is_walkable(b):
		return false
	for polygon in polygons:
		for index in range(polygon.size()):
			if Geometry2D.segment_intersects_segment(a, b, polygon[index], polygon[(index + 1) % polygon.size()]) != null:
				return false
	for obstacle in obstacles:
		# Slab intersection also rejects diagonal corner cutting between safe endpoints.
		var enter := 0.0
		var leave := 1.0
		var intersects := true
		for axis in range(2):
			var direction: float = b[axis] - a[axis]
			if absf(direction) < 0.00001:
				if a[axis] < obstacle.position[axis] or a[axis] > obstacle.end[axis]:
					intersects = false
					break
			else:
				var near_t: float = (obstacle.position[axis] - a[axis]) / direction
				var far_t: float = (obstacle.end[axis] - a[axis]) / direction
				enter = maxf(enter, minf(near_t, far_t))
				leave = minf(leave, maxf(near_t, far_t))
				if enter > leave:
					intersects = false
					break
		if intersects:
			return false
	return true

func nearest_valid(point: Vector2) -> Vector2:
	if is_walkable(point):
		return point
	var id := graph.get_closest_point(point)
	return graph.get_point_position(id) if id >= 0 else bounds.get_center()

func _visible_anchor(point: Vector2) -> int:
	var best := -1
	var distance := INF
	for id in graph.get_point_ids():
		var candidate := graph.get_point_position(id)
		var squared := candidate.distance_squared_to(point)
		if squared < distance and segment_clear(point, candidate):
			best = id
			distance = squared
	return best

func find_path(start: Vector2, requested: Vector2) -> PackedVector2Array:
	var target := nearest_valid(requested)
	if not is_walkable(start):
		return PackedVector2Array()
	if segment_clear(start, target):
		return PackedVector2Array([target])
	var first := _visible_anchor(start)
	var last := _visible_anchor(target)
	if first < 0 or last < 0:
		return PackedVector2Array()
	var raw := graph.get_point_path(first, last)
	if raw.is_empty():
		return raw
	raw.append(target)
	var result := PackedVector2Array()
	var previous := start
	var index := 0
	while index < raw.size():
		var farthest := index
		while farthest + 1 < raw.size() and segment_clear(previous, raw[farthest + 1]):
			farthest += 1
		result.append(raw[farthest])
		previous = raw[farthest]
		index = farthest + 1
	return result

func move_safely(start: Vector2, displacement: Vector2) -> Vector2:
	var result := start
	var steps := maxi(1, int(ceil(displacement.length() / 3.0)))
	var step := displacement / steps
	for index in range(steps):
		if segment_clear(result, result + step):
			result += step
		else:
			var horizontal := Vector2(step.x, 0)
			var vertical := Vector2(0, step.y)
			if segment_clear(result, result + horizontal):
				result += horizontal
			if segment_clear(result, result + vertical):
				result += vertical
	return result
