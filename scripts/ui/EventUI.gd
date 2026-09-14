extends Control
class_name GameEventUI

## 事件选择界面：全屏剧情背景 + 底部事件面板。
## 只负责展示；业务状态修改仍由 Game/EventSystem 负责。

signal option_selected(index: int)
signal continue_requested

const PANEL_SIDE_MARGIN := 12.0
const PANEL_BOTTOM_MARGIN := 10.0
const PANEL_TOP_SAFE_MARGIN := 12.0
const PANEL_MIN_HEIGHT := 220.0
const PANEL_MAX_HEIGHT := 340.0
const PANEL_HEIGHT_RATIO := 0.4722222
const OPTION_MIN_HEIGHT := 38.0

var background_rect: TextureRect
var shade_rect: ColorRect
var panel: PanelContainer
var head_label: Label
var scroll_container: ScrollContainer
var scroll_content: VBoxContainer
var body_label: Label
var options_box: VBoxContainer
var continue_button: Button


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	name = "EventUI"
	visible = false
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_viewport().size_changed.connect(_sync_viewport)

	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)

	shade_rect = ColorRect.new()
	shade_rect.name = "Shade"
	shade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade_rect.color = Color(0.02, 0.025, 0.04, 0.32)
	shade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade_rect)

	panel = PanelContainer.new()
	panel.name = "EventPanel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.clip_contents = true
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "EventContent"
	vbox.add_theme_constant_override("separation", 8)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	head_label = Label.new()
	head_label.name = "EventHeader"
	head_label.add_theme_font_size_override("font_size", 15)
	head_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(head_label)

	# Narrative copy and choices share one bounded overflow owner. The title remains
	# stable above it, while long Pack A copy can grow without clipping lower choices.
	scroll_container = ScrollContainer.new()
	scroll_container.name = "EventScroll"
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.follow_focus = true
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll_container)

	scroll_content = VBoxContainer.new()
	scroll_content.name = "EventScrollContent"
	scroll_content.add_theme_constant_override("separation", 8)
	scroll_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(scroll_content)

	body_label = Label.new()
	body_label.name = "EventBody"
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(0, 100)
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_content.add_child(body_label)

	options_box = VBoxContainer.new()
	options_box.name = "EventOptions"
	options_box.add_theme_constant_override("separation", 6)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_content.add_child(options_box)

	# Result continuation stays outside the scroll owner. Result prose may be long, but
	# the one primary action must remain visible/reachable at both declared viewports.
	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "继续"
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_button)

	_sync_viewport()


func _sync_viewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = Vector2.ZERO
	size = viewport_size
	if panel == null:
		return

	var desired_height := clampf(
		viewport_size.y * PANEL_HEIGHT_RATIO,
		PANEL_MIN_HEIGHT,
		PANEL_MAX_HEIGHT
	)
	var available_height := maxf(
		0.0,
		viewport_size.y - PANEL_TOP_SAFE_MARGIN - PANEL_BOTTOM_MARGIN
	)
	var panel_height := minf(desired_height, available_height)
	panel.offset_left = PANEL_SIDE_MARGIN
	panel.offset_right = -PANEL_SIDE_MARGIN
	panel.offset_bottom = -PANEL_BOTTOM_MARGIN
	panel.offset_top = -(PANEL_BOTTOM_MARGIN + panel_height)


func show_event(header: String, body: String, option_views: Array, background: Texture2D = null) -> void:
	head_label.text = header
	head_label.tooltip_text = header
	body_label.text = body
	background_rect.texture = background
	background_rect.visible = background != null
	shade_rect.visible = background != null
	_clear_options()
	for item in option_views:
		var btn := Button.new()
		var idx := int(item.get("index", 0))
		btn.name = "OptionButton%d" % idx
		btn.text = str(item.get("text", ""))
		btn.disabled = not bool(item.get("enabled", true))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, OPTION_MIN_HEIGHT)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.tooltip_text = btn.text
		btn.pressed.connect(_on_option_pressed.bind(idx))
		options_box.add_child(btn)
	continue_button.visible = false
	visible = true
	_reset_scroll()


func show_result(result_text: String) -> void:
	head_label.text = "结果"
	head_label.tooltip_text = "结果"
	body_label.text = result_text
	_clear_options()
	continue_button.visible = true
	visible = true
	_reset_scroll()


func close_event() -> void:
	visible = false
	background_rect.texture = null
	_clear_options()
	continue_button.visible = false
	_reset_scroll()


func is_busy() -> bool:
	return visible


func _on_option_pressed(index: int) -> void:
	option_selected.emit(index)


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _clear_options() -> void:
	# Remove immediately from layout before queue_free so result/reopen cannot inherit one
	# frame of stale choice height from the previous presentation.
	for child in options_box.get_children():
		options_box.remove_child(child)
		child.queue_free()


func _reset_scroll() -> void:
	if scroll_container == null:
		return
	scroll_container.scroll_vertical = 0
	scroll_container.set_deferred("scroll_vertical", 0)
