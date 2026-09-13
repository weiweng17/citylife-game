extends Node
## 便利店互动。结构与出租屋、公司保持一致：距离校验、防重复触发、
## 活动期间锁输入；买什么、花多少钱、什么时候吃掉，全部交给 Game 结算。
## 货架站位按当前便利店背景粗略标定（在碰撞体外侧、与出生点连通），
## 尚未逐帧对照美术校正。

signal activity_requested(id: String)

const SPOTS := {
	# 站位选在中央货架正下方的走道；朝上即面朝货架（遮挡深度 485 < 站位深度 515，人不会被货架盖住）。
	"shop": {"position": Vector2(455, 515), "facing": Vector2(0, -1), "label": "货架 · 选购", "detail": "买点吃的带着，饿的时候不用等"},
}
const LOCATION_ID := "store"

var location
var layer: Control
var prompt: Label
var buttons: Dictionary = {}
var nearest: String = ""
var blocked: bool = false
var pending: String = ""
var pending_target := Vector2.ZERO

func configure(manager) -> void:
	location = manager
	layer = Control.new()
	layer.name = "StoreInteractionLayer"
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 1950
	location.root.add_child(layer)
	for id in SPOTS:
		var spot: Dictionary = SPOTS[id]
		var button := Button.new()
		button.text = str(spot.label)
		button.position = spot.position + Vector2(-58, 16)
		button.size = Vector2(116, 30)
		button.tooltip_text = str(spot.detail)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_request.bind(str(id)))
		_style_button(button)
		layer.add_child(button)
		buttons[id] = button
	prompt = Label.new()
	# 底部面板从 y=608 起，提示行必须留在它上方，否则会被盖住。
	prompt.position = Vector2(280, 580)
	prompt.size = Vector2(720, 25)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(prompt)

func _process(_delta: float) -> void:
	if location == null:
		return
	layer.visible = location.active and location.current_location == LOCATION_ID
	if not layer.visible or blocked:
		pending = ""
		return
	if not pending.is_empty():
		if location.player_target.distance_to(pending_target) > 1.0:
			pending = ""
		elif location.walk_path.is_empty():
			var id := pending
			pending = ""
			_activate(id)
	nearest = ""
	var distance: float = 82.0
	for id in SPOTS:
		var current: float = location.player_sprite.position.distance_to(SPOTS[id].position)
		if current < distance:
			distance = current
			nearest = str(id)
		buttons[id].modulate = Color.WHITE if current < 82.0 else Color(0.65, 0.68, 0.72, 0.8)
	if not blocked:
		prompt.text = "走近货架，按 E 或点击标签选购" if nearest.is_empty() else "[E] %s  —  %s" % [SPOTS[nearest].label, SPOTS[nearest].detail]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if layer.visible and not nearest.is_empty() and not blocked:
			_activate(nearest)
			get_viewport().set_input_as_handled()

## 与出租屋、公司一致；不要 flat=true，否则 normal 状态的底色不会被绘制。
static func _style_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(0.96, 0.93, 0.84))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.04, 0.05, 0.09, 0.74)
	normal.set_corner_radius_all(7)
	normal.set_border_width_all(1)
	normal.border_color = Color(1.0, 0.93, 0.68, 0.32)
	normal.set_content_margin_all(5)
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.11, 0.13, 0.20, 0.92)
	hover.border_color = Color(1.0, 0.93, 0.68, 0.95)
	button.add_theme_stylebox_override("hover", hover)


func _activate(id: String) -> void:
	if blocked or not layer.visible or not SPOTS.has(id):
		return
	if location.player_sprite.position.distance_to(SPOTS[id].position) > 82.0:
		location.hint_label.text = "请走近%s再开始" % SPOTS[id].label
		return
	location.stop_walking()
	location.face_direction(SPOTS[id].facing)
	activity_requested.emit(id)

func _request(id: String) -> void:
	if blocked or not layer.visible or not SPOTS.has(id):
		return
	pending = ""
	if location.player_sprite.position.distance_to(SPOTS[id].position) <= 82.0:
		_activate(id)
	elif location.walk_to(SPOTS[id].position):
		pending = id
		pending_target = location.player_target
		location.hint_label.text = "正在走向%s；方向键或点击地面可取消。" % SPOTS[id].label
