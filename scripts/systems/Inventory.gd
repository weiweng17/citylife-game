extends Node
class_name Inventory
## 背包：便利店买到的东西放在这里，随时可以取用。
## 物品目录、价钱与食用效果只写在这份定义里——商店面板、背包面板和结算
## 都读同一份数据，避免出现"货架上 6 块、结算扣 8 块"这类对不上的情况。
## 这里只管数量，具体数值结算仍由 Game 完成。

const ITEMS := {
	"instant_noodles": {
		"name": "桶装泡面",
		"price": 6,
		"minutes": 15,
		"effects": {"fullness": 32},
		"desc": "热水一冲就好。凌晨的厨房里，只有它不嫌你慢。",
		"use": "热水冲下去，香气从塑料盖缝里冒出来。你蹲在窗边把汤也喝干净了。",
	},
	"rice_ball": {
		"name": "三角饭团",
		"price": 7,
		"minutes": 10,
		"effects": {"fullness": 26},
		"desc": "便利店最守时的东西，包装上的海苔总是潮的。",
		"use": "海苔有点潮，米饭还是温的。三口就没了。",
	},
	"bread": {
		"name": "袋装面包",
		"price": 5,
		"minutes": 8,
		"effects": {"fullness": 20},
		"desc": "保质期长得可疑，味道淡得像没睡醒。",
		"use": "撕开袋子，面包屑掉在桌上。你没去擦。",
	},
	"canned_coffee": {
		"name": "罐装咖啡",
		"price": 8,
		"minutes": 5,
		"effects": {"energy": 28},
		"desc": "苦味从舌根顶到眉心，够撑完下半天。",
		"use": "拉开拉环的声音很脆。苦味停在舌根，人清醒了些。",
	},
	"milk": {
		"name": "盒装牛奶",
		"price": 6,
		"minutes": 6,
		"effects": {"fullness": 12, "health": 4},
		"desc": "睡前温一盒，胃里会安静下来。",
		"use": "牛奶一口一口下去，屋子里安静得能听见冰箱的嗡嗡声。",
	},
	"cold_medicine": {
		"name": "感冒药",
		"price": 18,
		"minutes": 10,
		"effects": {"health": 18, "mood": -3},
		"desc": "说明书看不进去，但总比硬扛着强。",
		"use": "就着凉水咽下去，苦味在喉咙里停了一会儿。",
	},
}

## 面板里的固定顺序：顶饱的在前，提神的和养身体的在后。
const DISPLAY_ORDER := ["instant_noodles", "rice_ball", "bread", "canned_coffee", "milk", "cold_medicine"]

const EFFECT_LABELS := {
	"fullness": "饱食",
	"energy": "精力",
	"health": "健康",
	"mood": "心情",
	"skill": "技能",
}

var counts: Dictionary = {}


func reset() -> void:
	counts = {}


func add(item_id: String, amount: int = 1) -> bool:
	if not ITEMS.has(item_id) or amount <= 0:
		return false
	counts[item_id] = count(item_id) + amount
	return true


func remove(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or count(item_id) < amount:
		return false
	var left: int = count(item_id) - amount
	if left <= 0:
		counts.erase(item_id)
	else:
		counts[item_id] = left
	return true


func count(item_id: String) -> int:
	return int(counts.get(item_id, 0))


func has(item_id: String) -> bool:
	return count(item_id) > 0


func total_count() -> int:
	var total: int = 0
	for item_id in counts:
		total += int(counts[item_id])
	return total


## 背包里真正有货的物品，按 DISPLAY_ORDER 排列，供背包面板显示。
func owned_items() -> Array:
	var out: Array = []
	for item_id in DISPLAY_ORDER:
		if has(item_id):
			out.append(item_id)
	return out


static func item_name(item_id: String) -> String:
	if not ITEMS.has(item_id):
		return item_id
	return str(ITEMS[item_id].get("name", item_id))


static func price_of(item_id: String) -> int:
	if not ITEMS.has(item_id):
		return 0
	return int(ITEMS[item_id].get("price", 0))


## "饱食+32" / "健康+18 心情−3" 这类一行效果摘要，数值一律放符号后面。
static func effect_text(item_id: String) -> String:
	if not ITEMS.has(item_id):
		return ""
	var effects: Dictionary = ITEMS[item_id].get("effects", {})
	var parts: Array[String] = []
	for key in effects:
		var value: int = int(effects[key])
		parts.append("%s%s%d" % [
			str(EFFECT_LABELS.get(key, key)),
			"+" if value >= 0 else "−",
			absi(value),
		])
	return " ".join(parts)


static func use_text(item_id: String) -> String:
	if not ITEMS.has(item_id):
		return ""
	return str(ITEMS[item_id].get("use", ""))


static func desc_text(item_id: String) -> String:
	if not ITEMS.has(item_id):
		return ""
	return str(ITEMS[item_id].get("desc", ""))


static func minutes_of(item_id: String) -> int:
	if not ITEMS.has(item_id):
		return 0
	return int(ITEMS[item_id].get("minutes", 0))


func to_save_dict() -> Dictionary:
	return {"counts": counts.duplicate()}


func apply_save_dict(data: Dictionary) -> void:
	counts = {}
	var saved = data.get("counts", {}) if typeof(data) == TYPE_DICTIONARY else {}
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for raw_id in saved:
		var item_id: String = str(raw_id)
		# 目录里已经删掉的旧物品直接丢掉，不让存档把无效条目带进来。
		if not ITEMS.has(item_id):
			continue
		var amount: int = int(saved[raw_id])
		if amount > 0:
			counts[item_id] = amount
