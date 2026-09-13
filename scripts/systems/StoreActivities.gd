extends "res://scripts/systems/SpotActivities.gd"
## 便利店互动。结构与出租屋、公司保持一致；数值与商品逻辑仍由 Game 结算。

func _define_spots() -> Dictionary:
	return {
		"shop": {
			"position": Vector2(455, 515), "facing": Vector2(0, -1), "pose": "interact", "depth": 515,
			"interactionType": "shop", "label": "货架 · 选购", "detail": "买点吃的带着，饿的时候不用等",
		},
	}

func _location_id() -> String:
	return "store"

func _layer_name() -> String:
	return "StoreInteractionLayer"

func _idle_prompt() -> String:
	return "走近货架，按 E 或点击标签选购"
