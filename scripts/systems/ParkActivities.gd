extends "res://scripts/systems/SpotActivities.gd"
## 公园互动。第 4 阶段"扩展地图与内容"的第一块：公园此前只有地图和一位 NPC，
## 玩家到了以后没事情可做。
##
## 骨架在基类 SpotActivities：距离校验、防重复结算、活动期锁输入；
## 数值结算交给 Game，这里只回答"点位在哪、提示说什么"。
##
## 站位按当前公园背景（雨夜凉亭与长椅）粗略标定，尚未逐帧对照美术校正，
## 所以 `tools/verify_park.gd` 会专门断言两个点都真的走得到。

func _define_spots() -> Dictionary:
	return {
		"bench": {"position": Vector2(1020, 520), "facing": Vector2(0, -1), "label": "长椅 · 歇脚", "detail": "30分钟 · 精力+20 心情+5"},
		"pond": {"position": Vector2(300, 545), "facing": Vector2(0, 1), "label": "池塘边 · 看雨", "detail": "20分钟 · 心情+8"},
	}

func _location_id() -> String:
	return "park"

func _layer_name() -> String:
	return "ParkInteractionLayer"

func _idle_prompt() -> String:
	return "雨还没停。走近长椅或池塘，按 E 或点击标签"
