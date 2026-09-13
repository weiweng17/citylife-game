extends Node
## 公司工作互动。结构与出租屋活动保持一致：距离校验、防重复结算、
## 活动期间锁输入；具体数值结算交给 Game，这里只负责触发、朝向与**展示**。
##
## 第 3 阶段起有两处互动：
##  - `work`：工位上班。时薪随技能档位走，所以标签上的数字由 Game 每帧喂进来。
##  - `negotiate`：大堂找主管谈薪。技能不到「熟练」不显示，避免玩家点了个必然被拒的按钮。
## 门槛的**判定**仍然在 Game（数值结算只在 Game），这里只管好不好看。
##
## 站位按当前公司背景（写字楼入口雨夜）粗略标定，尚未逐帧对照美术校正。

signal activity_requested(id: String)

const SPOTS := {
	"work": {"position": Vector2(700, 470), "facing": Vector2(0, -1), "label": "工位 · 上班", "detail": "4小时 · 健康−6 心情−4"},
	"negotiate": {
		"position": Vector2(920, 500), "facing": Vector2(0, -1),
		"label": "大堂 · 谈薪", "detail": "30分钟 · 看手艺，也看人",
		"requires_skill": 55,
	},
}
const LOCATION_ID := "office"

var location
var layer: Control
var prompt: Label
var buttons: Dictionary = {}
var nearest: String = ""
var blocked: bool = false
var pending: String = ""
var pending_target := Vector2.ZERO
## 由 Game 每帧喂进来的展示上下文：技能、时薪、档位名、能不能谈薪、今天谈过没、有没有人帮腔。
var context: Dictionary = {}

func configure(manager) -> void:
	location = manager
	layer = Control.new()
	layer.name = "OfficeInteractionLayer"
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
	# 底部面板从 y=608 起；原来放在 600 会被它盖住，工作提示看不见。
	prompt.position = Vector2(280, 580)
	prompt.size = Vector2(720, 25)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(prompt)


## Game 每个 `_refresh_ui()` 喂一次。缺字段时按"最保守"取值，宁可显示旧数字也不崩。
func sync_context(info: Dictionary) -> void:
	context = info


## 技能不够的互动点直接不显示；显示出来的都点得动。
func _spot_available(id: String) -> bool:
	var spot: Dictionary = SPOTS[id]
	if not spot.has("requires_skill"):
		return true
	return int(context.get("skill", 0)) >= int(spot["requires_skill"])


func _label_of(id: String) -> String:
	if id == "negotiate" and bool(context.get("raised_today", false)):
		return "大堂 · 今天谈过了"
	return str(SPOTS[id]["label"])


## 标签上写清"这一趟能拿多少"，玩家不用去猜自己现在值多少钱。
func _detail_of(id: String) -> String:
	match id:
		"work":
			return "4小时 · 工资+%d 健康−6 心情−4" % int(context.get("wage", 0))
		"negotiate":
			if bool(context.get("raised_today", false)):
				return "一天一次 · 明天再来"
			if bool(context.get("friend", false)):
				return "30分钟 · 老张说替你提一句"
			return "30分钟 · 技能+人脉够了才谈得下来"
	return str(SPOTS[id]["detail"])


func _process(_delta: float) -> void:
	if location == null:
		return
	layer.visible = location.active and location.current_location == LOCATION_ID
	if not layer.visible or blocked:
		pending = ""
		return
	for id in SPOTS:
		var button: Button = buttons[id]
		button.visible = _spot_available(str(id))
		if button.visible:
			button.text = _label_of(str(id))
			button.tooltip_text = _detail_of(str(id))
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
		if not _spot_available(str(id)):
			continue
		var current: float = location.player_sprite.position.distance_to(SPOTS[id].position)
		if current < distance:
			distance = current
			nearest = str(id)
		buttons[id].modulate = Color.WHITE if current < 82.0 else Color(0.65, 0.68, 0.72, 0.8)
	if not blocked:
		prompt.text = "走近工位，按 E 或点击标签开始工作" if nearest.is_empty() else "[E] %s  —  %s" % [_label_of(nearest), _detail_of(nearest)]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if layer.visible and not nearest.is_empty() and not blocked:
			_activate(nearest)
			get_viewport().set_input_as_handled()

## 与出租屋一致；不要 flat=true，否则 normal 底色不会被绘制。
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
