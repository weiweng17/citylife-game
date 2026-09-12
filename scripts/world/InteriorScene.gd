extends Node2D
class_name InteriorScene

@export var interior_id := "office"
@export var player_spawn := Vector2(540, 900)
@export var world_exit_position := Vector2(935, 565)

func get_interaction_npcs() -> Array:
	var result: Array = []
	var holder := get_node_or_null("NPCs")
	if holder:
		for child in holder.get_children():
			if child is Area2D:
				result.append(child)
	return result

func get_exit_door() -> Area2D:
	return get_node_or_null("InteriorDoor") as Area2D
