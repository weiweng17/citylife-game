extends "res://scripts/systems/SpotActivities.gd"
## 咖啡馆互动。第 4 阶段"扩展地图与内容"的第二块：咖啡馆写着"适合见人，
## 也适合一个人坐很久"，但玩家到了以后除了一位 NPC 没有别的事可做。
##
## 骨架在基类 SpotActivities；数值结算交给 Game（咖啡要先看余额）。
##
## 站位按咖啡馆背景（左侧靠窗吧台、中景圆桌）粗略标定，尚未逐帧对照美术校正，
## 所以 `tools/verify_cafe.gd` 会专门断言两个点都真的走得到。

func _define_spots() -> Dictionary:
	return {
		"coffee": {"position": Vector2(640, 485), "facing": Vector2(0, -1), "label": "靠窗吧台 · 点杯咖啡", "detail": "15元 · 30分钟 · 精力+15 心情+6"},
		"idle": {"position": Vector2(480, 520), "facing": Vector2(0, -1), "label": "圆桌 · 发会儿呆", "detail": "免费 · 20分钟 · 心情+8"},
	}

func _location_id() -> String:
	return "cafe"

func _layer_name() -> String:
	return "CafeInteractionLayer"

func _idle_prompt() -> String:
	return "雨声混着磨豆声。走近吧台或圆桌，按 E 或点击标签"
