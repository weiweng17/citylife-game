extends Node2D
## 导航调试覆盖层：碰撞体、可行走网格、不可达贴边采样点、互动点。
## 只用于 tools/capture_home_navmap.gd 的 QA 截图，不进游戏运行时。

var collision_polygons: Array = []
var grid_points: Array = []
var unreachable: Array = []
var spots: Array = []
var bounds_rect: Rect2 = Rect2()

func _draw() -> void:
	for raw in collision_polygons:
		var shape := PackedVector2Array(raw)
		if shape.size() < 3:
			continue
		draw_polygon(shape, [Color(1.0, 0.18, 0.22, 0.28)])
		var closed := PackedVector2Array(shape)
		closed.append(shape[0])
		draw_polyline(closed, Color(1.0, 0.35, 0.35, 0.95), 2.0)
	draw_rect(bounds_rect, Color(0.35, 0.9, 1.0, 0.65), false, 2.0)
	for point in grid_points:
		draw_rect(Rect2(point - Vector2(1.5, 1.5), Vector2(3.0, 3.0)), Color(0.3, 1.0, 0.42, 0.5))
	for point in unreachable:
		draw_circle(point, 5.5, Color(1.0, 0.85, 0.1, 0.95))
	for point in spots:
		draw_circle(point, 7.5, Color(0.35, 0.7, 1.0, 0.95))
