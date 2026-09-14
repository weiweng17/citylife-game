extends "res://scripts/systems/SpotActivities.gd"
## 公司工作互动。骨架在基类 SpotActivities；本层的定制是**展示**：
##  - `work`：工位上班。时薪随技能档位走，标签上的数字由 Game 每帧喂进来。
##  - `overtime`：当天完成普通班次后开放；一天一次，收益更高但状态代价更重。
##  - `negotiate`：大堂找主管谈薪。技能不到「熟练」直接不显示，避免玩家点了个
##    必然被拒的按钮。门槛的**判定**仍然在 Game（数值结算只在 Game）。
##
## 站位按当前公司背景（写字楼入口雨夜）粗略标定，尚未逐帧对照美术校正。

## 由 Game 每帧喂进来的展示上下文：技能、时薪、档位名、谈薪状态、普通班次/加班状态。
var context: Dictionary = {}


## Game 每个 `_refresh_ui()` 喂一次。缺字段时按"最保守"取值，宁可少显示也不误导。
func sync_context(info: Dictionary) -> void:
	context = info


func _define_spots() -> Dictionary:
	return {
		"work": {"position": Vector2(700, 470), "facing": Vector2(0, -1), "label": "工位 · 上班", "detail": "4小时 · 健康−6 心情−4"},
		"overtime": {
			"position": Vector2(820, 470), "facing": Vector2(0, -1),
			"label": "工位 · 再加会儿班", "detail": "2小时 · 额外工资 健康−4 心情−8 · 每天一次",
		},
		"negotiate": {
			"position": Vector2(920, 500), "facing": Vector2(0, -1),
			"label": "大堂 · 谈薪", "detail": "30分钟 · 看手艺，也看人",
			"requires_skill": 55,
		},
	}

func _location_id() -> String:
	return "office"

func _layer_name() -> String:
	return "OfficeInteractionLayer"

func _idle_prompt() -> String:
	return "走近工位，按 E 或点击标签开始工作"


## 技能不够的谈薪不显示；加班必须先完成当天普通班次才显示。
func _spot_available(id: String) -> bool:
	if id == "overtime":
		return bool(context.get("worked_today", false))
	var spot: Dictionary = SPOTS[id]
	if not spot.has("requires_skill"):
		return true
	return int(context.get("skill", 0)) >= int(spot["requires_skill"])


func _label_of(id: String) -> String:
	if id == "overtime" and bool(context.get("overtime_today", false)):
		return "工位 · 今天已经加过班"
	if id == "negotiate" and bool(context.get("raised_today", false)):
		return "大堂 · 今天谈过了"
	return str(SPOTS[id]["label"])


## 标签上写清"这一趟能拿多少"，玩家不用去猜自己现在值多少钱。
func _detail_of(id: String) -> String:
	match id:
		"work":
			return "4小时 · 工资+%d 健康−6 心情−4" % int(context.get("wage", 0))
		"overtime":
			if bool(context.get("overtime_today", false)):
				return "一天一次 · 明天再来"
			return "2小时 · 加班费+%d 健康−4 心情−8 · 每天一次" % int(context.get("overtime_pay", 0))
		"negotiate":
			if bool(context.get("raised_today", false)):
				return "一天一次 · 明天再来"
			if bool(context.get("friend", false)):
				return "30分钟 · 老张说替你提一句"
			return "30分钟 · 技能+人脉够了才谈得下来"
	return str(SPOTS[id]["detail"])


## 每帧刷按钮显隐与文案（基类在早退之后调用）。
func _sync_display() -> void:
	for id in SPOTS:
		var button: Button = buttons[id]
		button.visible = _spot_available(str(id))
		if button.visible:
			button.text = _label_of(str(id))
			button.tooltip_text = _detail_of(str(id))
