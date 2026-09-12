extends RefCounted
## 《都市浮生》唯一玩家运行状态容器。
## 目标：让事件、规则、剧情、UI 后续都围绕同一份状态工作，避免 Game.gd 内重复持有状态。

var age: int = 22
var money: int = 5000
var health: int = 80
var mood: int = 70
var skill: int = 35
var network: int = 20
var job: String = "unemployed"
var flags: Dictionary = {}
var clues: Array = []
var stage_idx: int = 0
var jobless_years: int = 0


func reset_default() -> void:
	age = 22
	money = 5000
	health = 80
	mood = 70
	skill = 35
	network = 20
	job = "unemployed"
	flags = {}
	clues.clear()
	stage_idx = 0
	jobless_years = 0


func reset_from_origin(origin_data: Dictionary, origin_flag: String = "") -> void:
	age = 22
	money = int(origin_data.get("money", 5000))
	health = int(origin_data.get("health", 80))
	mood = int(origin_data.get("mood", 70))
	skill = int(origin_data.get("skill", 35))
	network = int(origin_data.get("network", 20))
	job = "unemployed"
	flags = {}
	if origin_flag != "":
		flags[origin_flag] = true
	clues.clear()
	stage_idx = 0
	jobless_years = 0


func to_dict() -> Dictionary:
	return {
		"age": age,
		"money": money,
		"health": health,
		"mood": mood,
		"skill": skill,
		"network": network,
		"flags": flags,
		"job": job,
		"jobless_years": jobless_years,
		"clues": clues,
		"stage_idx": stage_idx,
	}


func apply_dict(data: Dictionary) -> void:
	age = int(data.get("age", age))
	money = int(data.get("money", money))
	health = int(data.get("health", health))
	mood = int(data.get("mood", mood))
	skill = int(data.get("skill", skill))
	network = int(data.get("network", network))
	job = str(data.get("job", job))
	jobless_years = int(data.get("jobless_years", jobless_years))
	flags = data.get("flags", flags)
	clues = data.get("clues", clues)
	stage_idx = int(data.get("stage_idx", stage_idx))
