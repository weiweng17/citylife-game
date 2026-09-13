extends Node2D
## 点击落点标记：可达时金色涟漪扩散，不可达时红色静止提示。
## 纯视觉反馈，不参与任何碰撞或结算判断。

const DURATION := 0.55
const GOLD := Color(1.0, 0.93, 0.68, 1.0)
const RED := Color(1.0, 0.42, 0.40, 1.0)

var life: float = 0.0
var blocked_hint: bool = false

func ping(target: Vector2, unreachable: bool = false) -> void:
	position = target
	blocked_hint = unreachable
	life = DURATION
	visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if life <= 0.0:
		return
	life -= delta
	if life <= 0.0:
		life = 0.0
		visible = false
	queue_redraw()

func _draw() -> void:
	if life <= 0.0:
		return
	if blocked_hint:
		# 走不到的地方：静止红环加一道斜杠，和“可以走”明确区分。
		draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 24, Color(RED, 0.85), 2.0)
		draw_line(Vector2(-6.0, -6.0), Vector2(6.0, 6.0), Color(RED, 0.85), 2.0)
		return
	var t: float = 1.0 - life / DURATION
	var radius: float = 8.0 + t * 20.0
	var alpha: float = (1.0 - t) * 0.9
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 26, Color(GOLD, alpha), 2.5)
	draw_arc(Vector2.ZERO, radius * 0.45, 0.0, TAU, 20, Color(GOLD, alpha * 0.6), 1.5)
