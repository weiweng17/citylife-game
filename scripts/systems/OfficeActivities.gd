extends "res://scripts/systems/SpotActivities.gd"
## 公司工作互动。骨架在基类 SpotActivities；数值结算仍在 Game。
var context: Dictionary = {}

func sync_context(info: Dictionary) -> void:
	context = info

func _define_spots() -> Dictionary:
	return {
		"work": {
			"position": Vector2(700, 470), "facing": Vector2(0, -1), "pose": "sit", "depth": 470,
			"interactionType": "work", "label": "工位 · 上班", "detail": "4小时 · 健康−6 心情−4",
		},
		"negotiate": {
			"position": Vector2(920, 500), "facing": Vector2(0, -1), "pose": "interact", "depth": 500,
			"interactionType": "negotiate", "label": "大堂 · 谈薪", "detail": "30分钟 · 看手艺，也看人",
			"requires_skill": 55,
		},
	}

func _location_id() -> String:
	return "office"

func _layer_name() -> String:
	return "OfficeInteractionLayer"

func _idle_prompt() -> String:
	return "走近工位，按 E 或点击标签开始工作"

func _spot_available(id: String) -> bool:
	var spot: Dictionary = SPOTS[id]
	if not spot.has("requires_skill"):
		return true
	return int(context.get("skill", 0)) >= int(spot["requires_skill"])

func _label_of(id: String) -> String:
	if id == "negotiate" and bool(context.get("raised_today", false)):
		return "大堂 · 今天谈过了"
	return str(SPOTS[id]["label"])

func _detail_of(id: String) -> String:
	match id:
		"work":
			return "4小时 · 工资+%d 健康−6 心情−4" % int(context.get("wage", 0))
		"negotiate":
			if bool(context.get("raised_today", false)):
				return "一天一次 · 明天再来"
			if bool(context.get("friend", false)):
				return "30分钟 · 老张说替你提一句"
			return "30分钟 · 技能+人脉够了才谈得下来"
	return str(SPOTS[id]["detail"])

func _sync_display() -> void:
	for id in SPOTS:
		var button: Button = buttons[id]
		button.visible = _spot_available(str(id))
		if button.visible:
			button.text = _label_of(str(id))
			button.tooltip_text = _detail_of(str(id))
