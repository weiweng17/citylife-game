extends "res://scripts/systems/SpotActivities.gd"
## 天台互动。数值结算仍由 Game 负责，这里只定义空间锚点与演出类型。

func _define_spots() -> Dictionary:
	return {
		"ledge": {
			"position": Vector2(640, 530), "facing": Vector2(0, -1), "pose": "interact", "depth": 530,
			"interactionType": "ledge", "label": "栏杆边 · 看夜景", "detail": "免费 · 25分钟 · 心情+10",
		},
		"bench": {
			"position": Vector2(330, 480), "facing": Vector2(-1, 0), "pose": "sit", "depth": 480,
			"interactionType": "bench", "label": "长椅 · 吹吹风", "detail": "免费 · 20分钟 · 心情+8 精力+5",
		},
	}

func _location_id() -> String:
	return "rooftop"

func _layer_name() -> String:
	return "RooftopInteractionLayer"

func _idle_prompt() -> String:
	return "风比楼下凉。走近栏杆或长椅，按 E 或点击标签"
