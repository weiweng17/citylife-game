extends "res://scripts/systems/SpotActivities.gd"
## 天台互动。第 4 阶段"扩展地图与内容"的第五块：老楼天台写着"站得高一点，
## 城市会显得很远"，此前玩家到了以后只是一张空地图。
##
## 骨架在基类 SpotActivities；数值结算交给 Game。
##
## 站位按天台背景（前沿栏杆、左侧长椅）粗略标定，尚未逐帧对照美术校正，
## 所以 `tools/verify_rooftop.gd` 会专门断言两个点都真的走得到。

func _define_spots() -> Dictionary:
	return {
		"ledge": {"position": Vector2(640, 530), "facing": Vector2(0, -1), "label": "栏杆边 · 看夜景", "detail": "免费 · 25分钟 · 心情+10"},
		"bench": {"position": Vector2(330, 480), "facing": Vector2(-1, 0), "label": "长椅 · 吹吹风", "detail": "免费 · 20分钟 · 心情+8 精力+5"},
	}

func _location_id() -> String:
	return "rooftop"

func _layer_name() -> String:
	return "RooftopInteractionLayer"

func _idle_prompt() -> String:
	return "风比楼下凉。走近栏杆或长椅，按 E 或点击标签"
