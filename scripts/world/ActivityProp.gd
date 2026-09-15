extends Node2D
## 活动道具：休息/学习/做饭时在角色手部显示小物件。
## 只用程序化绘制，不引入外部美术；绘制原点为物件中心。
## 做饭阶段不是静态图标：锅体会轻微颠动，蒸汽持续上升，作为角色烹饪动作的一部分。

const PROP_FOR := {
	"rest": "pillow",
	"study": "book",
	"meal": "pot",
	"work": "laptop",
}

var kind: String = ""
var phase: float = 0.0


func setup(activity_id: String) -> void:
	kind = str(PROP_FOR.get(activity_id, ""))
	phase = 0.0
	rotation = 0.0
	scale = Vector2.ONE
	visible = not kind.is_empty()
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	phase += delta
	if kind == "pot":
		# 小幅颠锅：位移由 HomeActivities 控制，这里负责道具自身的角度和呼吸感。
		rotation = sin(phase * 7.5) * 0.055
		var pulse := 1.0 + sin(phase * 5.0) * 0.018
		scale = Vector2(pulse, pulse)
		queue_redraw()


func _draw() -> void:
	# 深色衬底把物件从暖色背景里托出来，再整体放大到与角色比例协调。
	draw_circle(Vector2.ZERO, 17.0, Color(0.03, 0.03, 0.06, 0.42))
	draw_arc(Vector2.ZERO, 17.0, 0.0, TAU, 24, Color(1.0, 0.93, 0.68, 0.55), 1.2)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.35, 1.35))
	match kind:
		"book":
			_draw_book()
		"pot":
			_draw_pot()
		"pillow":
			_draw_pillow()
		"laptop":
			_draw_laptop()


func _draw_laptop() -> void:
	draw_rect(Rect2(-11.0, -8.0, 22.0, 13.0), Color(0.28, 0.31, 0.38))
	draw_rect(Rect2(-9.0, -6.0, 18.0, 9.0), Color(0.52, 0.70, 0.86))
	draw_rect(Rect2(-9.0, -6.0, 18.0, 3.0), Color(0.68, 0.82, 0.94))
	draw_rect(Rect2(-13.0, 5.0, 26.0, 2.5), Color(0.38, 0.41, 0.48))


func _draw_book() -> void:
	draw_rect(Rect2(-13.0, -6.0, 12.0, 9.0), Color(0.55, 0.34, 0.22))
	draw_rect(Rect2(1.0, -6.0, 12.0, 9.0), Color(0.60, 0.38, 0.24))
	draw_rect(Rect2(-11.5, -4.5, 9.0, 6.0), Color(0.94, 0.92, 0.85))
	draw_rect(Rect2(2.5, -4.5, 9.0, 6.0), Color(0.90, 0.88, 0.81))
	draw_rect(Rect2(-1.5, -6.0, 3.0, 9.0), Color(0.30, 0.18, 0.12))


func _draw_pot() -> void:
	draw_rect(Rect2(-15.0, -3.0, 4.0, 3.0), Color(0.22, 0.24, 0.30))
	draw_rect(Rect2(11.0, -3.0, 4.0, 3.0), Color(0.22, 0.24, 0.30))
	draw_rect(Rect2(-11.0, -5.0, 22.0, 10.0), Color(0.50, 0.54, 0.62))
	draw_rect(Rect2(-11.0, -5.0, 22.0, 2.5), Color(0.78, 0.82, 0.90))
	# 三股蒸汽的高度和透明度错相变化，避免旧版“两颗静态白点”的贴纸感。
	for i in range(3):
		var local_phase := fmod(phase * 0.9 + float(i) * 0.31, 1.0)
		var rise := local_phase * 9.0
		var drift := sin(phase * 3.2 + float(i) * 1.7) * 1.8
		var alpha := (1.0 - local_phase) * 0.72
		draw_circle(Vector2(-4.0 + float(i) * 4.0 + drift, -8.0 - rise), 1.4 + local_phase, Color(0.98, 0.98, 0.98, alpha))


func _draw_pillow() -> void:
	draw_rect(Rect2(-12.0, -5.0, 24.0, 10.0), Color(0.72, 0.76, 0.88))
	draw_rect(Rect2(-12.0, -5.0, 24.0, 3.0), Color(0.94, 0.96, 1.0))
	draw_rect(Rect2(-6.0, -1.0, 12.0, 2.0), Color(0.55, 0.60, 0.75))
