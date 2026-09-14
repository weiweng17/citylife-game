extends "res://scripts/systems/SpotActivities.gd"
## 咖啡馆互动。第 4 阶段"扩展地图与内容"的第二块：咖啡馆写着"适合见人，
## 也适合一个人坐很久"，现在额外提供一天一次的临时帮工，让这里不仅是消费/休息点。
##
## 骨架在基类 SpotActivities；数值结算交给 Game。
##
## 站位按咖啡馆背景（左侧靠窗吧台、中景圆桌）粗略标定，尚未逐帧对照美术校正。

var context: Dictionary = {}


func sync_context(info: Dictionary) -> void:
	context = info


func _define_spots() -> Dictionary:
	return {
		"coffee": {"position": Vector2(640, 485), "facing": Vector2(0, -1), "label": "靠窗吧台 · 点杯咖啡", "detail": "15元 · 30分钟 · 精力+15 心情+6"},
		"idle": {"position": Vector2(480, 520), "facing": Vector2(0, -1), "label": "圆桌 · 发会儿呆", "detail": "免费 · 20分钟 · 心情+8"},
		"side_gig": {"position": Vector2(760, 520), "facing": Vector2(0, -1), "label": "吧台后 · 临时帮工", "detail": "90分钟 · +55元 健康−2 心情−4 · 每天一次"},
	}

func _location_id() -> String:
	return "cafe"

func _layer_name() -> String:
	return "CafeInteractionLayer"

func _idle_prompt() -> String:
	return "雨声混着磨豆声。走近吧台或圆桌，按 E 或点击标签"


## GAME-CONTENT-013：临时帮工不是 Day-1 onboarding 行动。
## Game 只喂一个展示布尔值；真正的结算/反刷仍由 Game.gd 保持权威。
func _spot_available(id: String) -> bool:
	if id == "side_gig":
		return bool(context.get("gig_available", true))
	return true


func _label_of(id: String) -> String:
	if id == "side_gig" and bool(context.get("gig_today", false)):
		return "吧台后 · 今天已经帮过忙"
	return str(SPOTS[id]["label"])


func _detail_of(id: String) -> String:
	if id == "side_gig":
		if bool(context.get("gig_today", false)):
			return "一天一次 · 明天再来"
		return "90分钟 · 工钱+%d 健康−2 心情−4 · 每天一次" % int(context.get("gig_pay", 55))
	return str(SPOTS[id]["detail"])


func _sync_display() -> void:
	for id in SPOTS:
		var button: Button = buttons[id]
		button.visible = _spot_available(str(id))
		if button.visible:
			button.text = _label_of(str(id))
			button.tooltip_text = _detail_of(str(id))
