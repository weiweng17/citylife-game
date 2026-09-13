extends "res://scripts/systems/SpotActivities.gd"
## 咖啡馆互动。数值结算仍由 Game 负责，这里只定义空间锚点与演出类型。

func _define_spots() -> Dictionary:
	return {
		"coffee": {
			"position": Vector2(640, 485), "facing": Vector2(0, -1), "pose": "sit", "depth": 485,
			"interactionType": "coffee", "label": "靠窗吧台 · 点杯咖啡", "detail": "15元 · 30分钟 · 精力+15 心情+6",
		},
		"idle": {
			"position": Vector2(480, 520), "facing": Vector2(0, -1), "pose": "sit", "depth": 520,
			"interactionType": "idle", "label": "圆桌 · 发会儿呆", "detail": "免费 · 20分钟 · 心情+8",
		},
	}

func _location_id() -> String:
	return "cafe"

func _layer_name() -> String:
	return "CafeInteractionLayer"

func _idle_prompt() -> String:
	return "雨声混着磨豆声。走近吧台或圆桌，按 E 或点击标签"
