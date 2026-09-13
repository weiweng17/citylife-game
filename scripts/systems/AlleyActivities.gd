extends "res://scripts/systems/SpotActivities.gd"
## 旧巷互动。数值结算仍由 Game 负责，这里只定义空间锚点与演出类型。

func _define_spots() -> Dictionary:
	return {
		"shrine": {
			"position": Vector2(640, 400), "facing": Vector2(0, -1), "pose": "interact", "depth": 400,
			"interactionType": "shrine", "label": "神龛 · 上柱香", "detail": "5元 · 15分钟 · 心情+8",
		},
		"door": {
			"position": Vector2(445, 400), "facing": Vector2(0, -1), "pose": "sit", "depth": 400,
			"interactionType": "door", "label": "木门前 · 歇歇脚", "detail": "免费 · 20分钟 · 心情+6",
		},
	}

func _location_id() -> String:
	return "alley"

func _layer_name() -> String:
	return "AlleyInteractionLayer"

func _idle_prompt() -> String:
	return "巷子里的雨声更近。走近神龛或木门，按 E 或点击标签"
