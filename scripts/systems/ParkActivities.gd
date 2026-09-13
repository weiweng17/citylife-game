extends "res://scripts/systems/SpotActivities.gd"
## 公园互动。数值结算仍由 Game 负责，这里只定义空间锚点与演出类型。

func _define_spots() -> Dictionary:
	return {
		"bench": {
			"position": Vector2(1020, 520), "facing": Vector2(0, -1), "pose": "sit", "depth": 520,
			"interactionType": "bench", "label": "长椅 · 歇脚", "detail": "30分钟 · 精力+20 心情+5",
		},
		"pond": {
			"position": Vector2(300, 545), "facing": Vector2(0, 1), "pose": "interact", "depth": 545,
			"interactionType": "pond", "label": "池塘边 · 看雨", "detail": "20分钟 · 心情+8",
		},
	}

func _location_id() -> String:
	return "park"

func _layer_name() -> String:
	return "ParkInteractionLayer"

func _idle_prompt() -> String:
	return "雨还没停。走近长椅或池塘，按 E 或点击标签"
