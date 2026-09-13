extends "res://scripts/systems/SpotActivities.gd"
## Spatial household interactions. The game owns effects and time settlement.
## 骨架在基类 SpotActivities；本层只有两处定制：
##  - rest 的详情由 Game 按时刻写进 rest_detail（夜里"睡到明早"，白天两小时小睡）；
##  - 走近不够的措辞是"再互动"（其余场景是"再开始"）。

## 床位的提示语由 Game 按当前时刻写进来：夜里是"睡到明早"，白天是两小时小睡。
## 空着就退回 SPOTS 里的静态说明。
var rest_detail: String = ""


func _define_spots() -> Dictionary:
	return {
		"rest": {"position": Vector2(430, 330), "facing": Vector2(-1, 0), "label": "床 · 休息", "detail": "2小时 · 健康+12 心情+8"},
		"study": {"position": Vector2(690, 365), "facing": Vector2(0, -1), "label": "书桌 · 学习", "detail": "1小时 · 技能+3 心情−3"},
		"meal": {"position": Vector2(930, 440), "facing": Vector2(1, -0.35), "label": "厨房 · 做饭", "detail": "30分钟 · 20元 健康+5"},
		"leave": {"position": Vector2(920, 550), "facing": Vector2(1, 0), "label": "房门 · 出门", "detail": "前往城南地铁站"},
	}


func _location_id() -> String:
	return "home"

func _layer_name() -> String:
	return "HomeInteractionLayer"

func _idle_prompt() -> String:
	return "走近家具，按 E 或点击标签互动"

func _approach_word() -> String:
	return "再互动"


func _detail_of(id: String) -> String:
	if id == "rest" and not rest_detail.is_empty():
		return rest_detail
	return str(SPOTS[id]["detail"])
