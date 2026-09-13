extends Node
## Spatial household interactions. The game owns effects and time settlement.
signal activity_requested(id: String)

const SPOTS := {
	"rest": {"position": Vector2(430, 330), "facing": Vector2(-1, 0), "label": "床 · 休息", "detail": "2小时 · 健康+12 心情+8"},
	"study": {"position": Vector2(690, 365), "facing": Vector2(0, -1), "label": "书桌 · 学习", "detail": "1小时 · 技能+3 心情−3"},
	"meal": {"position": Vector2(930, 440), "facing": Vector2(1, -0.35), "label": "厨房 · 做饭", "detail": "30分钟 · 20元 健康+5"},
	"leave": {"position": Vector2(920, 550), "facing": Vector2(1, 0), "label": "房门 · 出门", "detail": "前往城南地铁站"},
}
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
	layer.name = "HomeInteractionLayer"
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 1950
	location.root.add_child(layer)
	for id in SPOTS:
		var spot: Dictionary = SPOTS[id]
		var button := Button.new()
		button.text = str(spot.label)
		# Labels sit below the standing point, not across the character's legs.
		button.position = spot.position + Vector2(-58, 16)
		button.size = Vector2(116, 30)
		button.tooltip_text = str(spot.detail)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_request.bind(str(id)))
		_style_button(button)
		layer.add_child(button)
		buttons[id] = button
	prompt = Label.new()
	prompt.position = Vector2(280, 580)
	prompt.size = Vector2(720, 25)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(prompt)

func _process(_delta: float) -> void:
	if location == null:
		return
	layer.visible = location.active and location.current_location == "home"
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
		prompt.text = "走近家具，按 E 或点击标签互动" if nearest.is_empty() else "[E] %s  —  %s" % [SPOTS[nearest].label, SPOTS[nearest].detail]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if layer.visible and not nearest.is_empty() and not blocked:
			_activate(nearest)
			get_viewport().set_input_as_handled()

## 压在场景上的暗色胶囊；不要 flat=true，否则 normal 状态的底色不会被绘制。
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
		location.hint_label.text = "请走近%s再互动" % SPOTS[id].label
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
