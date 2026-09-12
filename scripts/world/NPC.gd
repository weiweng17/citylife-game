extends Area2D
class_name WorldNPC

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var npc_data: Dictionary = {}

func configure(data: Dictionary, texture_path: String = "") -> void:
	npc_data = data.duplicate(true)
	name = "NPC_" + str(data.get("id", "unknown"))
	position = data.get("pos", Vector2.ZERO)
	set_meta("npc", npc_data)

	var path := texture_path
	if path.is_empty():
		path = "res://assets/sprites/npc_%s.png" % str(data.get("id", ""))
	var tex: Texture2D = load(path)
	var tw := 32.0
	var th := 48.0
	if tex != null:
		tw = float(tex.get_width())
		th = float(tex.get_height())
		sprite.texture = tex
	sprite.centered = false
	sprite.position = Vector2(-tw / 2.0, -th)
	sprite.light_mask = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	label.text = str(data.get("name", ""))
	label.position = Vector2(-50, -(th + 16))

func get_npc_data() -> Dictionary:
	return npc_data

func set_schedule_state(is_visible: bool, new_position: Vector2 = Vector2.ZERO, location_id: String = "") -> void:
	visible = is_visible
	monitoring = is_visible
	monitorable = is_visible
	if is_visible:
		position = new_position
	set_meta("schedule_location", location_id)


func is_available() -> bool:
	return visible and monitoring
