extends Node
class_name EventSystem
## 正式事件系统：负责事件加载、候选池、条件判断、选择结算和事件去重。
## UI 展示由 EventUI 负责；Game.gd 只做流程协调。

const LOCATION_ALIASES := {
	"rent": ["home"],
	"cafe": ["street"],
	"office": [],
	"park": ["gym"],
	"subway": ["street"],
	"hospital": [],
	"rooftop": [],
	"alley": [],
}

# 以后需要真正全局事件时，在 events.json 中把 scene 写成 global。
const GLOBAL_SCENES := ["global"]

var events: Array = []
var used: Array[String] = []


func _ready() -> void:
	_load()


func _load() -> void:
	var f := FileAccess.open("res://data/events.json", FileAccess.READ)
	if f == null:
		push_error("[EventSystem] 读不到 res://data/events.json")
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) == OK and j.data is Array:
		events = j.data
	else:
		push_error("[EventSystem] events.json 解析失败")
	print("[EventSystem] 载入 %d 个事件" % events.size())


## 条件判定。cond 为 null/空视为通过。
static func cond_ok(cond, st: Dictionary) -> bool:
	if cond == null:
		return true
	if not cond is Dictionary:
		return true
	var c: Dictionary = cond
	if c.is_empty():
		return true

	if c.has("money_min") and int(st.get("money", 0)) < int(c["money_min"]):
		return false
	if c.has("money_max") and int(st.get("money", 0)) > int(c["money_max"]):
		return false
	if c.has("health_min") and int(st.get("health", 0)) < int(c["health_min"]):
		return false
	if c.has("health_max") and int(st.get("health", 0)) > int(c["health_max"]):
		return false
	if c.has("mood_min") and int(st.get("mood", 0)) < int(c["mood_min"]):
		return false
	if c.has("mood_max") and int(st.get("mood", 0)) > int(c["mood_max"]):
		return false
	if c.has("skill_min") and int(st.get("skill", 0)) < int(c["skill_min"]):
		return false
	if c.has("network_min") and int(st.get("network", 0)) < int(c["network_min"]):
		return false
	if c.has("age_min") and int(st.get("age", 0)) < int(c["age_min"]):
		return false
	if c.has("job") and str(st.get("job", "")) != str(c["job"]):
		return false

	var flags: Dictionary = st.get("flags", {})
	if c.has("flags"):
		for fl in c["flags"]:
			if not bool(flags.get(str(fl), false)):
				return false
	if c.has("flags_not"):
		for fl in c["flags_not"]:
			if bool(flags.get(str(fl), false)):
				return false

	if c.has("origins"):
		var origin_flag := ""
		for ofl in ["origin_town", "origin_local", "origin_returnee", "origin_switcher"]:
			if bool(flags.get(ofl, false)):
				origin_flag = ofl
				break
		if not c["origins"].has(origin_flag):
			return false

	return true


## 三层事件池：
## 1. 当前地点专属事件；2. 当前地点允许的通用别名事件；3. 真正 global 事件。
## 不再在本地点无事件时从所有地点乱抽。
func pick(scene_key: String, st: Dictionary):
	var exact_pool := _pool_for_scenes([scene_key], st)
	if not exact_pool.is_empty():
		return _weighted_pick(exact_pool)

	var aliases: Array = LOCATION_ALIASES.get(scene_key, [])
	if not aliases.is_empty():
		var common_pool := _pool_for_scenes(aliases, st)
		if not common_pool.is_empty():
			return _weighted_pick(common_pool)

	var global_pool := _pool_for_scenes(GLOBAL_SCENES, st)
	if not global_pool.is_empty():
		return _weighted_pick(global_pool)

	return null


func _pool_for_scenes(scenes: Array, st: Dictionary) -> Array:
	return events.filter(func(e: Dictionary) -> bool:
		return _match(e, scenes, st)
	)


func _match(e: Dictionary, scenes: Array, st: Dictionary) -> bool:
	var event_id := str(e.get("id", ""))
	if event_id != "" and used.has(event_id):
		return false

	var age: int = int(st.get("age", 22))
	var ag = e.get("age")
	if ag is Array and ag.size() >= 2:
		if age < int(ag[0]) or age > int(ag[1]):
			return false

	if not scenes.has(str(e.get("scene", ""))):
		return false

	return cond_ok(e.get("cond"), st)


func _weighted_pick(pool: Array):
	var total := 0
	for e in pool:
		total += maxi(1, int(e.get("weight", 1)))
	if total <= 0:
		return pool[0] if not pool.is_empty() else null

	var r := randf() * float(total)
	for e in pool:
		r -= float(maxi(1, int(e.get("weight", 1))))
		if r <= 0.0:
			return e
	return pool[-1]


## 给 EventUI 的纯展示数据。
func build_option_views(event_data: Dictionary, st: Dictionary) -> Array:
	var views: Array = []
	var options: Array = event_data.get("options", [])
	for i in options.size():
		var option: Dictionary = options[i]
		var enabled := cond_ok(option.get("cond"), st)
		views.append({
			"index": i,
			"text": str(option.get("text", "")) + ("" if enabled else "（条件不足）"),
			"enabled": enabled,
		})
	return views


## 执行一个事件选项。直接修改 st，并返回结果文本与事件 ID。
func apply_choice(event_data: Dictionary, option_index: int, st: Dictionary) -> Dictionary:
	var options: Array = event_data.get("options", [])
	if option_index < 0 or option_index >= options.size():
		return {"ok": false, "result": "", "event_id": ""}

	var option: Dictionary = options[option_index]
	if not cond_ok(option.get("cond"), st):
		return {"ok": false, "result": "条件不足。", "event_id": str(event_data.get("id", ""))}

	_apply_option(option, st)
	var event_id := str(event_data.get("id", ""))
	mark_used(event_id)
	return {
		"ok": true,
		"result": str(option.get("result", "")),
		"event_id": event_id,
	}


static func _apply_option(option: Dictionary, st: Dictionary) -> void:
	var effects = option.get("effects", {})
	if effects is Dictionary:
		if effects.has("money"):
			st["money"] = int(st.get("money", 0)) + int(effects["money"])
		if effects.has("health"):
			st["health"] = clampi(int(st.get("health", 0)) + int(effects["health"]), 0, 100)
		if effects.has("mood"):
			st["mood"] = clampi(int(st.get("mood", 0)) + int(effects["mood"]), 0, 100)
		if effects.has("skill"):
			st["skill"] = clampi(int(st.get("skill", 0)) + int(effects["skill"]), 0, 100)
		if effects.has("network"):
			st["network"] = clampi(int(st.get("network", 0)) + int(effects["network"]), 0, 100)

	var flags_value = option.get("flags")
	if flags_value is Dictionary:
		var flags: Dictionary = st.get("flags", {})
		for key in flags_value:
			flags[str(key)] = flags_value[key]
		st["flags"] = flags

	var job_value = option.get("job")
	if job_value != null and str(job_value) != "":
		st["job"] = str(job_value)


func mark_used(event_id: String) -> void:
	if event_id != "" and not used.has(event_id):
		used.append(event_id)


func reset_used() -> void:
	used.clear()


func to_save_dict() -> Dictionary:
	return {"used": used.duplicate()}


func apply_save_dict(data: Dictionary) -> void:
	used.clear()
	var saved_used = data.get("used", [])
	if saved_used is Array:
		for event_id in saved_used:
			var value := str(event_id)
			if value != "" and not used.has(value):
				used.append(value)
