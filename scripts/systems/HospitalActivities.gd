extends "res://scripts/systems/SpotActivities.gd"
## 医院互动。数值结算仍由 Game 负责，这里只定义空间锚点与演出类型。

func _define_spots() -> Dictionary:
	return {
		"clinic": {
			"position": Vector2(560, 520), "facing": Vector2(0, -1), "pose": "interact", "depth": 520,
			"interactionType": "clinic", "label": "诊桌前 · 看一次病", "detail": "50元 · 60分钟 · 健康+25",
		},
		"bench": {
			"position": Vector2(420, 530), "facing": Vector2(-1, 0), "pose": "sit", "depth": 530,
			"interactionType": "bench", "label": "候诊椅 · 缓一缓", "detail": "免费 · 15分钟 · 心情+5",
		},
	}

func _location_id() -> String:
	return "hospital"

func _layer_name() -> String:
	return "HospitalInteractionLayer"

func _idle_prompt() -> String:
	return "消毒水的味道。走近诊桌或候诊椅，按 E 或点击标签"
