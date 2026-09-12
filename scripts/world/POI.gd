extends Area2D
class_name WorldPOI

@onready var icon: Sprite2D = $Icon
@onready var label: Label = $Label

var poi_data: Dictionary = {}
var _pulse_started := false
var _interactable := true
var _lock_reason := ""
var _base_label := ""

func configure(data: Dictionary) -> void:
	poi_data = data.duplicate(true)
	name = "POI_" + str(data.get("id", "unknown"))
	position = data.get("pos", Vector2.ZERO)
	set_meta("poi", poi_data)
	label.text = str(data.get("name", ""))
	_base_label = label.text
	_start_pulse()

func get_poi_data() -> Dictionary:
	return poi_data

func _start_pulse() -> void:
	if _pulse_started or not is_inside_tree():
		return
	_pulse_started = true
	var tw := create_tween()
	tw.set_loops(0)
	tw.tween_property(icon, "scale", Vector2(1.12, 1.12), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func set_world_state(interactable: bool, display_label: String = "", lock_reason: String = "", highlighted: bool = false) -> void:
	_interactable = interactable
	_lock_reason = lock_reason
	label.text = display_label if not display_label.is_empty() else _base_label
	if highlighted:
		icon.modulate = Color(1.0, 0.78, 0.42, 1.0)
		label.modulate = Color(1.0, 0.86, 0.60, 1.0)
	elif interactable:
		icon.modulate = Color.WHITE
		label.modulate = Color.WHITE
	else:
		icon.modulate = Color(0.45, 0.48, 0.58, 0.72)
		label.modulate = Color(0.62, 0.65, 0.72, 0.82)


func is_interactable() -> bool:
	return _interactable


func get_lock_reason() -> String:
	return _lock_reason
