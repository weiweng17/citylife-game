extends PanelContainer
class_name EndingUI

signal restart_requested

var title_label: Label
var desc_label: Label

func _ready() -> void:
	name = "EndingPanel"
	visible = false
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	get_viewport().size_changed.connect(_sync_viewport)
	_sync_viewport()
	var vbox := VBoxContainer.new()
	add_child(vbox)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(0, 220)
	vbox.add_child(desc_label)
	var again := Button.new()
	again.text = "再活一次"
	again.pressed.connect(func(): restart_requested.emit())
	vbox.add_child(again)

func _sync_viewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = Vector2(28.0, 90.0)
	size = Vector2(maxf(300.0, viewport_size.x - 56.0), maxf(260.0, viewport_size.y - 180.0))

func show_ending(title_text: String, description: String) -> void:
	title_label.text = title_text
	desc_label.text = description
	visible = true

func close() -> void:
	visible = false
