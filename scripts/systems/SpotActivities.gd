extends Node
class_name SpotActivities
## 分场景互动点的公共基类（第 4 阶段单元 5，还模板复制五遍的债）。
##
## 子类只回答五个问题：互动点在哪（_define_spots）、挂哪张图（_location_id）、
## 提示行说什么（_idle_prompt）、走近不够时的措辞（_approach_word）、
## 层叫什么（_layer_name）。展示上的差异走可选钩子：
##  - _label_of / _detail_of：动态标签与详情（公司用它把时薪写进按钮）
##  - _spot_available：互动点隐藏条件（公司谈薪：技能不到不显示）
##  - _sync_display：每帧附加的展示同步（公司用它刷按钮显隐）
##
## 结构约定（全部场景一致，改动前先读 docs/ARCHITECTURE.md）：
##  - 距离 82px 内才算"到了"；点了标签先自动走近，走近后自动激活。
##  - 数值结算一律在 Game 的 _on_*_activity，这里只负责触发、朝向与展示。
##  - 活动期间由 Game 的 _begin/_end_activity 统一锁 `blocked`。
##  - 提示行放 y=580：底部面板从 y=608 起，放 600 会被盖住。
##  - 按钮不要 flat=true：Godot 4 的 flat 不绘制 normal 底色。

signal activity_requested(id: String)

var location
var layer: Control
var prompt: Label
var buttons: Dictionary = {}
var nearest: String = ""
var blocked: bool = false
var pending: String = ""
var pending_target := Vector2.ZERO
## 由 _define_spots() 在 configure 时填入。外部（Game、测试工具）按
## `xxx_activities.SPOTS` 只读访问，所以保持大写实例属性而不是私有名。
var SPOTS: Dictionary = {}


# ---------------------------------------------------- 子类必须回答的五个问题

func _define_spots() -> Dictionary:
	return {}

func _location_id() -> String:
	return ""

func _layer_name() -> String:
	return "SpotInteractionLayer"

## 附近没有互动点时的整行提示。
func _idle_prompt() -> String:
	return "走近互动点，按 E 或点击标签"

## 距离不够时的提示尾巴（出租屋说"再互动"，其余场景说"再开始"）。
func _approach_word() -> String:
	return "再开始"


# ---------------------------------------------------- 子类可选覆盖的展示钩子

func _label_of(id: String) -> String:
	return str(SPOTS[id]["label"])

func _detail_of(id: String) -> String:
	return str(SPOTS[id]["detail"])

## 返回 false 的互动点直接不显示、不参与"最近点"判定；显示出来的都点得动。
func _spot_available(_id: String) -> bool:
	return true

## 每帧附加的展示同步（早退之后、pending 处理之前调用）。
func _sync_display() -> void:
	pass


# ---------------------------------------------------- 公共骨架

func configure(manager) -> void:
	location = manager
	SPOTS = _define_spots()
	layer = Control.new()
	layer.name = _layer_name()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 1950
	location.root.add_child(layer)
	for id in SPOTS:
		var spot: Dictionary = SPOTS[id]
		var button := Button.new()
		button.text = _label_of(str(id))
		# 标签落在站位下方，不压在角色的腿上。
		button.position = spot.position + Vector2(-58, 16)
		button.size = Vector2(116, 30)
		button.tooltip_text = _detail_of(str(id))
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
	layer.visible = location.active and location.current_location == _location_id()
	if not layer.visible or blocked:
		pending = ""
		return
	_sync_display()
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
		prompt.text = _idle_prompt() if nearest.is_empty() else "[E] %s  —  %s" % [_label_of(nearest), _detail_of(nearest)]


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
		location.hint_label.text = "请走近%s%s" % [SPOTS[id]["label"], _approach_word()]
		return
	location.stop_walking()
	location.face_direction(SPOTS[id]["facing"])
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
		location.hint_label.text = "正在走向%s；方向键或点击地面可取消。" % SPOTS[id]["label"]
