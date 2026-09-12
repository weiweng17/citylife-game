extends Node
class_name NPCScheduleSystem

## FEAT-002: 核心 NPC 的城市作息。
## 只负责“何时出现、出现在哪里”，不负责对话内容、寻路或剧情条件。

const SCHEDULE_PATH := "res://data/npc_schedules.json"

var world_manager
var schedules: Dictionary = {}
var default_visible := false
var _last_minute_key := -1


func configure(p_world_manager) -> void:
	world_manager = p_world_manager
	_load_schedules()


func _load_schedules() -> void:
	schedules = {}
	if not FileAccess.file_exists(SCHEDULE_PATH):
		push_warning("[NPCSchedule] Missing schedule file: %s" % SCHEDULE_PATH)
		return
	var file := FileAccess.open(SCHEDULE_PATH, FileAccess.READ)
	if file == null:
		push_warning("[NPCSchedule] Could not open schedule file")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[NPCSchedule] Invalid JSON root")
		return
	var root: Dictionary = parsed
	default_visible = bool(root.get("defaults", {}).get("visible", false))
	schedules = root.get("npcs", {})


func reset(time_source, weather_source = null) -> void:
	_last_minute_key = -1
	apply(time_source, true, weather_source)


func apply(time_source, force: bool = false, weather_source = null) -> void:
	if world_manager == null or time_source == null:
		return
	var minute_key: int = int(time_source.get_minute_of_day())
	var weather_id := str(weather_source.get_weather_id()) if weather_source != null else ""
	var composite_key := minute_key * 16 + weather_id.hash() % 16
	if not force and composite_key == _last_minute_key:
		return
	_last_minute_key = composite_key

	for npc in world_manager.npc_nodes:
		if not is_instance_valid(npc):
			continue
		var data: Dictionary = npc.get_npc_data() if npc.has_method("get_npc_data") else npc.get_meta("npc", {})
		var npc_id := str(data.get("id", ""))
		var state := _state_for(npc_id, minute_key, weather_id)
		if npc.has_method("set_schedule_state"):
			npc.set_schedule_state(bool(state.get("visible", default_visible)), state.get("position", npc.position), str(state.get("location", "")))
		else:
			npc.visible = bool(state.get("visible", default_visible))
			if bool(state.get("visible", default_visible)):
				npc.position = state.get("position", npc.position)


func get_state_for(npc_id: String, time_source, weather_source = null) -> Dictionary:
	if time_source == null:
		return {"visible": false}
	var minute_of_day: int = int(time_source.get_minute_of_day())
	var weather_id: String = str(weather_source.get_weather_id()) if weather_source != null else ""
	return _state_for(npc_id, minute_of_day, weather_id)


func _state_for(npc_id: String, minute_of_day: int, weather_id: String = "") -> Dictionary:
	var entries: Array = schedules.get(npc_id, [])
	if entries.is_empty():
		return {"visible": true}
	for raw in entries:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = raw
		var start := _clock_to_minute(str(entry.get("start", "00:00")))
		var end := _clock_to_minute(str(entry.get("end", "24:00")))
		if _in_window(minute_of_day, start, end):
			var hide_weather = entry.get("hide_in_weather", [])
			if hide_weather is Array and hide_weather.has(weather_id):
				continue
			var pos_value = entry.get("pos", [])
			var pos := Vector2.ZERO
			if typeof(pos_value) == TYPE_ARRAY and pos_value.size() >= 2:
				pos = Vector2(float(pos_value[0]), float(pos_value[1]))
			return {
				"visible": true,
				"position": pos,
				"location": str(entry.get("location", "")),
			}
	return {"visible": default_visible}


func _clock_to_minute(value: String) -> int:
	if value == "24:00":
		return 24 * 60
	var parts := value.split(":")
	if parts.size() != 2:
		return 0
	return clampi(int(parts[0]), 0, 23) * 60 + clampi(int(parts[1]), 0, 59)


func _in_window(now: int, start: int, end: int) -> bool:
	if start <= end:
		return now >= start and now < end
	return now >= start or now < end
