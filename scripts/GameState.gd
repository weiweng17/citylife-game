extends RefCounted
## 《都市浮生》唯一玩家运行状态容器。
## 目标：让事件、规则、剧情、UI 后续都围绕同一份状态工作，避免 Game.gd 内重复持有状态。

var age: int = 22
var money: int = 5000
var health: int = 80
var mood: int = 70
var skill: int = 35
var network: int = 20
# 每日循环需求：饱食与精力。越高越好，随游戏时间自然消耗，靠吃饭和睡觉补回。
var fullness: int = 70
var energy: int = 80
var job: String = "unemployed"
var flags: Dictionary = {}
var clues: Array = []
var stage_idx: int = 0
var jobless_years: int = 0
# NPC 关系：`relations` 是 {npc_id: 好感度}，`talk_day` 记录"最后一次有效交谈发生在第几天"。
# 用"记下是哪一天"而不是"每天重置标记"，跨天就不需要额外清理，也不怕漏重置。
var relations: Dictionary = {}
var talk_day: Dictionary = {}


func reset_default() -> void:
	age = 22
	money = 5000
	health = 80
	mood = 70
	skill = 35
	network = 20
	fullness = 70
	energy = 80
	job = "unemployed"
	flags = {}
	clues.clear()
	stage_idx = 0
	jobless_years = 0
	relations = {}
	talk_day = {}


func reset_from_origin(origin_data: Dictionary, origin_flag: String = "") -> void:
	age = 22
	money = int(origin_data.get("money", 5000))
	health = int(origin_data.get("health", 80))
	mood = int(origin_data.get("mood", 70))
	skill = int(origin_data.get("skill", 35))
	network = int(origin_data.get("network", 20))
	fullness = int(origin_data.get("fullness", 70))
	energy = int(origin_data.get("energy", 80))
	job = "unemployed"
	flags = {}
	if origin_flag != "":
		flags[origin_flag] = true
	clues.clear()
	stage_idx = 0
	jobless_years = 0
	relations = {}
	talk_day = {}


func to_dict() -> Dictionary:
	return {
		"age": age,
		"money": money,
		"health": health,
		"mood": mood,
		"skill": skill,
		"network": network,
		"fullness": fullness,
		"energy": energy,
		"flags": flags,
		"job": job,
		"jobless_years": jobless_years,
		"clues": clues,
		"stage_idx": stage_idx,
		"relations": relations,
		"talk_day": talk_day,
	}


func apply_dict(data: Dictionary) -> void:
	age = int(data.get("age", age))
	money = int(data.get("money", money))
	health = int(data.get("health", health))
	mood = int(data.get("mood", mood))
	skill = int(data.get("skill", skill))
	network = int(data.get("network", network))
	fullness = int(data.get("fullness", fullness))
	energy = int(data.get("energy", energy))
	job = str(data.get("job", job))
	jobless_years = int(data.get("jobless_years", jobless_years))
	flags = data.get("flags", flags)
	clues = data.get("clues", clues)
	stage_idx = int(data.get("stage_idx", stage_idx))
	relations = data.get("relations", relations)
	talk_day = data.get("talk_day", talk_day)
