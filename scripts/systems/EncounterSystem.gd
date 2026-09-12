extends Node
class_name EncounterSystem
## 奇遇系统：与普通年度事件分离。
## 奇遇由地点 + 时间 + 玩家状态 + 天气等条件共同触发；默认同一天最多触发一次。

const EventSystemScript = preload("res://scripts/systems/EventSystem.gd")

var encounters: Array = []
var used: Array[String] = []
var _last_trigger_day: int = -1


func _ready() -> void:
	_load()


func _load() -> void:
	var f := FileAccess.open("res://data/encounters.json", FileAccess.READ)
	if f == null:
		push_error("[EncounterSystem] 读不到 res://data/encounters.json")
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) == OK and j.data is Array:
		encounters = j.data
	else:
		push_error("[EncounterSystem] encounters.json 解析失败")
	print("[EncounterSystem] 载入 %d 个奇遇" % encounters.size())


func reset() -> void:
	used.clear()
	_last_trigger_day = -1


## 尝试触发奇遇。context 目前支持 weather；后续可扩展 reputation / weekday 等。
func pick(scene_key: String, st: Dictionary, time_source, context: Dictionary = {}):
	if time_source == null:
		return null
	if _last_trigger_day == int(time_source.day):
		return null

	var pool: Array = []
	for e in encounters:
		if not e is Dictionary:
			continue
		if _match(e, scene_key, st, time_source, context):
			pool.append(e)
	if pool.is_empty():
		return null

	var picked = _weighted_pick(pool)
	if picked == null:
		return null
	var chance := clampf(float(picked.get("chance", 0.18)), 0.0, 1.0)
	if randf() > chance:
		return null

	_last_trigger_day = int(time_source.day)
	return picked


func _match(e: Dictionary, scene_key: String, st: Dictionary, time_source, context: Dictionary) -> bool:
	var event_id := str(e.get("id", ""))
	if bool(e.get("once", true)) and event_id != "" and used.has(event_id):
		return false

	var scenes = e.get("scenes", [])
	if scenes is Array and not scenes.is_empty() and not scenes.has(scene_key):
		return false
	if e.has("scene") and str(e.get("scene", "")) != scene_key:
		return false

	var periods = e.get("periods", [])
	if periods is Array and not periods.is_empty() and not periods.has(time_source.get_period()):
		return false

	var h := float(time_source.get_hour_float())
	if e.has("hour_min") or e.has("hour_max"):
		var h_min := float(e.get("hour_min", 0.0))
		var h_max := float(e.get("hour_max", 24.0))
		if h_min <= h_max:
			if h < h_min or h >= h_max:
				return false
		else:
			# 跨午夜，例如 22:00 - 04:00。
			if h < h_min and h >= h_max:
				return false

	if int(time_source.day) < int(e.get("day_min", 1)):
		return false
	if e.has("day_max") and int(time_source.day) > int(e.get("day_max", 999999)):
		return false

	var weather_req = e.get("weather", [])
	if weather_req is Array and not weather_req.is_empty():
		if not weather_req.has(str(context.get("weather", "clear"))):
			return false

	if int(st.get("clues", []).size()) < int(e.get("clues_min", 0)):
		return false
	if e.has("clues_max") and int(st.get("clues", []).size()) > int(e.get("clues_max", 999)):
		return false

	return EventSystemScript.cond_ok(e.get("cond"), st)


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


func build_option_views(encounter_data: Dictionary, st: Dictionary) -> Array:
	var views: Array = []
	var options: Array = encounter_data.get("options", [])
	for i in options.size():
		var option: Dictionary = options[i]
		var enabled := EventSystemScript.cond_ok(option.get("cond"), st)
		views.append({
			"index": i,
			"text": str(option.get("text", "")) + ("" if enabled else "（条件不足）"),
			"enabled": enabled,
		})
	return views


func apply_choice(encounter_data: Dictionary, option_index: int, st: Dictionary) -> Dictionary:
	var options: Array = encounter_data.get("options", [])
	if option_index < 0 or option_index >= options.size():
		return {"ok": false, "result": "", "event_id": ""}
	var option: Dictionary = options[option_index]
	if not EventSystemScript.cond_ok(option.get("cond"), st):
		return {"ok": false, "result": "条件不足。", "event_id": str(encounter_data.get("id", ""))}

	_apply_option(option, st)
	var event_id := str(encounter_data.get("id", ""))
	if event_id != "" and bool(encounter_data.get("once", true)) and not used.has(event_id):
		used.append(event_id)
	return {
		"ok": true,
		"result": str(option.get("result", "")),
		"event_id": event_id,
		"time_cost": int(encounter_data.get("time_cost", 90)),
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


func to_save_dict() -> Dictionary:
	return {
		"used": used.duplicate(),
		"last_trigger_day": _last_trigger_day,
	}


func apply_save_dict(data: Dictionary) -> void:
	used.clear()
	var saved_used = data.get("used", [])
	if saved_used is Array:
		for encounter_id in saved_used:
			var value := str(encounter_id)
			if value != "" and not used.has(value):
				used.append(value)
	_last_trigger_day = int(data.get("last_trigger_day", -1))
