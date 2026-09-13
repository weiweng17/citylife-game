extends Node2D
class_name HomeInteractionVisual
## 出租屋特有的近景表现层：被子只在睡觉时显示，盖住角色的躯干而不盖住头部。
## 它是程序化临时表现，不依赖一套新的睡眠素材；以后替换成美术遮罩也不影响流程。

var sleeping := false
var breath := 0.0

func set_sleeping(value: bool) -> void:
	sleeping = value
	visible = value
	queue_redraw()

func _process(delta: float) -> void:
	if not sleeping:
		return
	breath += delta
	# 被子本身也有非常轻的呼吸起伏，避免一张完全静止的遮挡片。
	position.y = 442.0 + sin(breath * 1.6) * 0.7
	queue_redraw()

func _draw() -> void:
	if not sleeping:
		return
	# 床面朝右下，覆盖身体中下段；左上角留出头和肩膀。
	var duvet := PackedVector2Array([
		Vector2(-48, -20), Vector2(78, -4), Vector2(104, 30),
		Vector2(66, 51), Vector2(-70, 31), Vector2(-82, 2),
	])
	draw_colored_polygon(duvet, Color(0.17, 0.22, 0.31, 0.94))
	draw_polyline(duvet, Color(0.52, 0.57, 0.66, 0.72), 1.4, true)
	draw_line(Vector2(-46, 2), Vector2(70, 20), Color(0.68, 0.70, 0.74, 0.30), 1.2)
	draw_line(Vector2(-30, 20), Vector2(52, 37), Color(0.68, 0.70, 0.74, 0.24), 1.0)
