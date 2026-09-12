extends Node
class_name InteractionSystem

var player: CharacterBody2D
var world_manager
var poi_data: Array = []

func configure(p_player: CharacterBody2D, p_world_manager, p_poi_data: Array) -> void:
	player = p_player
	world_manager = p_world_manager
	poi_data = p_poi_data

func detect_near(flags: Dictionary) -> Dictionary:
	var result := {"target": {}, "tutorial": ""}
	if player == null or world_manager == null:
		return result
	if world_manager.inside != "":
		for a in world_manager.interior_npcs:
			if is_instance_valid(a) and player.position.distance_to(a.position) < 60.0:
				result["target"] = {"type": "interior_npc", "data": a.get_meta("interior_npc")}
				return result
		var door = world_manager.get_exit_door()
		if door and player.position.distance_to(door.position) < 60.0:
			result["target"] = {"type": "exit"}
		return result
	for n in world_manager.npc_nodes:
		if not is_instance_valid(n):
			continue
		var available: bool = bool(n.visible)
		if n.has_method("is_available"):
			available = bool(n.call("is_available"))
		if available and player.position.distance_to(n.position) < 52.0:
			var npc: Dictionary = n.get_meta("npc")
			result["target"] = {"type": "npc", "data": npc}
			if not bool(flags.get("tut_npc", false)):
				flags["tut_npc"] = true
				result["tutorial"] = "点「和%s说话」，听听 TA 的故事，也许能拿到线索。" % npc["name"]
			return result
	for d in poi_data:
		if player.position.distance_to(d["pos"]) < 46.0:
			var poi_id := str(d.get("id", ""))
			var interactable: bool = true
			if world_manager.has_method("is_poi_interactable"):
				interactable = bool(world_manager.call("is_poi_interactable", poi_id))
			if not interactable:
				var reason: String = "这里现在无法进入。"
				if world_manager.has_method("get_poi_lock_reason"):
					reason = str(world_manager.call("get_poi_lock_reason", poi_id))
				result["target"] = {
					"type": "locked_place",
					"data": d,
					"reason": reason
				}
				return result
			result["target"] = {"type": "place", "data": d}
			if not bool(flags.get("tut_poi", false)):
				flags["tut_poi"] = true
				result["tutorial"] = "点「进入%s」，看看这里今年发生了什么。" % d["name"]
			return result
	return result
