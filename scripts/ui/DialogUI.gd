extends PanelContainer
class_name GameDialogUI

## 通用对话面板。
## 只负责展示 speaker + 多行文本、处理“继续/结束”，不处理剧情/线索逻辑。

signal dialog_finished

var speaker_label: Label
var text_label: Label
var next_button: Button

var _lines: Array = []
var _index := 0


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	name = "Dialog"
	visible = false
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	get_viewport().size_changed.connect(_sync_viewport)
	_sync_viewport()

	var vbox := VBoxContainer.new()
	add_child(vbox)

	speaker_label = Label.new()
	vbox.add_child(speaker_label)

	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size = Vector2(0, 96)
	vbox.add_child(text_label)

	next_button = Button.new()
	next_button.text = "继续"
	next_button.pressed.connect(_on_next_pressed)
	vbox.add_child(next_button)


func _sync_viewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = Vector2(16.0, maxf(0.0, viewport_size.y - 230.0))
	size = Vector2(maxf(300.0, viewport_size.x - 32.0), 220.0)


func show_dialog(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines.duplicate()
	_index = 0
	speaker_label.text = speaker
	visible = true
	_render()


func close_dialog() -> void:
	visible = false
	_lines.clear()
	_index = 0


func is_busy() -> bool:
	return visible


func _render() -> void:
	if _lines.is_empty():
		return
	text_label.text = str(_lines[_index])
	next_button.text = "结束" if _index >= _lines.size() - 1 else "继续"


func _on_next_pressed() -> void:
	_index += 1
	if _index >= _lines.size():
		close_dialog()
		dialog_finished.emit()
	else:
		_render()
