extends PanelContainer
class_name StartUI

signal origin_selected(origin: Dictionary)
signal load_requested

var load_button: Button
var scroll_container: ScrollContainer
var content_box: VBoxContainer


func setup(origins: Array, money_formatter: Callable) -> void:
	name = "StartPanel"
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.08, 0.11, 0.985)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	add_theme_stylebox_override("panel", sb)

	# setup() is intentionally valid before this node enters the scene tree. Game.gd
	# builds StartUI in that order, so the complete presentation hierarchy belongs here
	# rather than in _ready(). The ScrollContainer bounds vertical growth while keeping
	# the existing full-screen panel/background contract intact.
	scroll_container = ScrollContainer.new()
	scroll_container.name = "StartScroll"
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.follow_focus = true
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll_container)

	content_box = VBoxContainer.new()
	content_box.name = "StartContent"
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 10)
	scroll_container.add_child(content_box)

	var title := Label.new()
	title.name = "StartTitle"
	title.text = "都市浮生"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	content_box.add_child(title)
	var sub := Label.new()
	sub.name = "StartSubtitle"
	sub.text = "选择你的出身，开始这一生"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	content_box.add_child(sub)
	for index in range(origins.size()):
		var origin: Dictionary = origins[index]
		content_box.add_child(_make_origin_card(origin, money_formatter, index))

	load_button = Button.new()
	load_button.name = "LoadButton"
	load_button.text = "读取上次存档"
	load_button.visible = false
	load_button.pressed.connect(func(): load_requested.emit())
	content_box.add_child(load_button)


func _ready() -> void:
	get_viewport().size_changed.connect(_sync_viewport)
	_sync_viewport()


func _sync_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport().get_visible_rect().size


func _make_origin_card(o: Dictionary, money_formatter: Callable, card_index: int) -> Control:
	var card := PanelContainer.new()
	card.name = "OriginCard%d" % card_index
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.15, 0.17, 0.22, 0.96)
	csb.set_corner_radius_all(6)
	csb.content_margin_left = 10
	csb.content_margin_right = 10
	csb.content_margin_top = 8
	csb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", csb)
	var body := VBoxContainer.new()
	body.name = "OriginBody"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 4)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(body)
	var nm := Label.new()
	nm.text = str(o.get("name", ""))
	nm.add_theme_font_size_override("font_size", 16)
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(nm)
	var ds := Label.new()
	ds.text = str(o.get("desc", ""))
	ds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ds.add_theme_font_size_override("font_size", 12)
	ds.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(ds)
	var ini: Dictionary = o.get("init", {})
	var stt := Label.new()
	stt.text = "初始 · 钱%s  技能%d  人脉%d  健康%d  心态%d    ｜ %s" % [
		money_formatter.call(int(ini.get("money", 0))), int(ini.get("skill", 0)), int(ini.get("network", 0)),
		int(ini.get("health", 0)), int(ini.get("mood", 0)), str(o.get("bonus", "")),
	]
	stt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stt.add_theme_font_size_override("font_size", 11)
	stt.add_theme_color_override("font_color", Color(0.74, 0.80, 0.88))
	stt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(stt)
	var hit := Button.new()
	hit.name = "OriginHit"
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.pressed.connect(func(): origin_selected.emit(o))
	card.add_child(hit)
	return card


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func set_load_available(value: bool) -> void:
	if load_button:
		load_button.visible = value
