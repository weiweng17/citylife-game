extends "res://scripts/systems/SpotActivities.gd"
## 医院互动。第 4 阶段"扩展地图与内容"的第三块：健康目前只有睡觉 +12 和
## 感冒药能补，医院是第一个正经的健康恢复出口——花钱花时间，但补得多。
##
## 骨架在基类 SpotActivities；数值结算交给 Game（挂号费要先看余额）。
##
## 站位按医院背景（中景诊桌、左下候诊长椅）粗略标定，尚未逐帧对照美术校正，
## 所以 `tools/verify_hospital.gd` 会专门断言两个点都真的走得到。

func _define_spots() -> Dictionary:
	return {
		"clinic": {"position": Vector2(560, 520), "facing": Vector2(0, -1), "label": "诊桌前 · 看一次病", "detail": "50元 · 60分钟 · 健康+25"},
		"bench": {"position": Vector2(420, 530), "facing": Vector2(-1, 0), "label": "候诊椅 · 缓一缓", "detail": "免费 · 15分钟 · 心情+5"},
	}

func _location_id() -> String:
	return "hospital"

func _layer_name() -> String:
	return "HospitalInteractionLayer"

func _idle_prompt() -> String:
	return "消毒水的味道。走近诊桌或候诊椅，按 E 或点击标签"
