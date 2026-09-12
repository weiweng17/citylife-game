extends Control
class_name GameEventUI

## 事件选择界面：全屏剧情背景 + 底部事件面板。
## 只负责展示；业务状态修改仍由 Game/EventSystem 负责。

signal option_selected(index: int)
signal continue_requested

var background_rect: TextureRect
var shade_rect: ColorRect
var panel: PanelContainer
var head_label: Label
var body_label: Label
var options_box: VBoxContainer
var continue_button: Button


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	name = "EventUI"
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

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
	panel.offset_top = -350
	panel.offset_bottom = -10
	panel.offset_left = 12
	panel.offset_right = -12
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	head_label = Label.new()
	head_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(head_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(0, 120)
	vbox.add_child(body_label)

	options_box = VBoxContainer.new()
	vbox.add_child(options_box)

	continue_button = Button.new()
	continue_button.text = "继续"
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_button)


func show_event(header: String, body: String, option_views: Array, background: Texture2D = null) -> void:
	head_label.text = header
	body_label.text = body
	background_rect.texture = background
	background_rect.visible = background != null
	shade_rect.visible = background != null
	_clear_options()
	for item in option_views:
		var btn := Button.new()
		btn.text = str(item.get("text", ""))
		btn.disabled = not bool(item.get("enabled", true))
		var idx := int(item.get("index", 0))
		btn.pressed.connect(_on_option_pressed.bind(idx))
		options_box.add_child(btn)
	continue_button.visible = false
	visible = true


func show_result(result_text: String) -> void:
	head_label.text = "结果"
	body_label.text = result_text
	_clear_options()
	continue_button.visible = true


func close_event() -> void:
	visible = false
	background_rect.texture = null
	_clear_options()
	continue_button.visible = false


func is_busy() -> bool:
	return visible


func _on_option_pressed(index: int) -> void:
	option_selected.emit(index)


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _clear_options() -> void:
	for child in options_box.get_children():
		child.queue_free()
