extends "res://scripts/systems/SpotActivities.gd"
## 便利店互动。结构与出租屋、公司保持一致：距离校验、防重复触发、
## 活动期间锁输入；买什么、花多少钱、什么时候吃掉，全部交给 Game 结算。
## 货架站位按当前便利店背景粗略标定（在碰撞体外侧、与出生点连通），
## 尚未逐帧对照美术校正。

func _define_spots() -> Dictionary:
	return {
		# 站位选在中央货架正下方的走道；朝上即面朝货架（遮挡深度 485 < 站位深度 515，人不会被货架盖住）。
		"shop": {"position": Vector2(455, 515), "facing": Vector2(0, -1), "label": "货架 · 选购", "detail": "买点吃的带着，饿的时候不用等"},
	}

func _location_id() -> String:
	return "store"

func _layer_name() -> String:
	return "StoreInteractionLayer"

func _idle_prompt() -> String:
	return "走近货架，按 E 或点击标签选购"
