extends "res://scripts/systems/SpotActivities.gd"
## 旧巷互动。第 4 阶段"扩展地图与内容"的第四块：旧巷此前只有夜里的道士，
## 玩家到了以后没事情可做。
##
## 骨架在基类 SpotActivities；数值结算交给 Game（香钱要先看余额）。
##
## 站位按旧巷背景（中央亮灯的木门、墙上的神龛）粗略标定，尚未逐帧对照美术校正，
## 所以 `tools/verify_alley.gd` 会专门断言两个点都真的走得到。

func _define_spots() -> Dictionary:
	return {
		"shrine": {"position": Vector2(640, 400), "facing": Vector2(0, -1), "label": "神龛 · 上柱香", "detail": "5元 · 15分钟 · 心情+8"},
		"door": {"position": Vector2(445, 400), "facing": Vector2(0, -1), "label": "木门前 · 歇歇脚", "detail": "免费 · 20分钟 · 心情+6"},
	}

func _location_id() -> String:
	return "alley"

func _layer_name() -> String:
	return "AlleyInteractionLayer"

func _idle_prompt() -> String:
	return "巷子里的雨声更近。走近神龛或木门，按 E 或点击标签"
