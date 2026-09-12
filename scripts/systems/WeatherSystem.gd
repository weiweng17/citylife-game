extends Node
class_name WeatherSystem

## FEAT-006: 城市天气状态机。
## 管理晴、阴、小雨、暴雨、雾，以及天气持续时间；不直接创建视觉节点。

signal weather_changed(weather_id: String, weather_name: String)

const WEATHER_NAMES := {
	"clear": "晴",
	"cloudy": "阴",
	"rain": "小雨",
	"storm": "暴雨",
	"fog": "雾",
}

const WEATHER_WEIGHTS := {
	"clear": 30,
	"cloudy": 28,
	"rain": 24,
	"storm": 8,
	"fog": 10,
}

var current_weather: String = "rain"
var _next_change_absolute_minute: int = 0
var _last_absolute_minute: int = -1
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func reset(time_source) -> void:
	# 保留当前项目的雨城视觉开场，之后由天气状态机自然变化。
	current_weather = "rain"
	_last_absolute_minute = _absolute_minute(time_source)
	_schedule_next_change(_last_absolute_minute)
	weather_changed.emit(current_weather, get_weather_name())


func update(time_source) -> void:
	if time_source == null:
		return
	var now := _absolute_minute(time_source)
	if now == _last_absolute_minute:
		return
	_last_absolute_minute = now
	if _next_change_absolute_minute <= 0:
		_schedule_next_change(now)
	if now >= _next_change_absolute_minute:
		_change_weather()
		_schedule_next_change(now)


func force_weather(weather_id: String, time_source = null) -> void:
	if not WEATHER_NAMES.has(weather_id):
		return
	current_weather = weather_id
	var now := _absolute_minute(time_source) if time_source != null else _last_absolute_minute
	_schedule_next_change(maxi(now, 0))
	weather_changed.emit(current_weather, get_weather_name())


func get_weather_id() -> String:
	return current_weather


func get_weather_name() -> String:
	return str(WEATHER_NAMES.get(current_weather, "未知"))


func get_ambient_multiplier() -> Color:
	match current_weather:
		"cloudy":
			return Color(0.86, 0.89, 0.94, 1.0)
		"rain":
			return Color(0.78, 0.84, 0.94, 1.0)
		"storm":
			return Color(0.61, 0.68, 0.82, 1.0)
		"fog":
			return Color(0.90, 0.92, 0.92, 1.0)
		_:
			return Color.WHITE


func get_rain_alpha() -> float:
	match current_weather:
		"rain":
			return 0.48
		"storm":
			return 0.78
		_:
			return 0.0


func get_rain_speed_multiplier() -> float:
	return 1.85 if current_weather == "storm" else 1.0


func get_overlay_color() -> Color:
	match current_weather:
		"cloudy":
			return Color(0.50, 0.56, 0.65, 0.06)
		"rain":
			return Color(0.35, 0.47, 0.64, 0.08)
		"storm":
			return Color(0.22, 0.29, 0.44, 0.16)
		"fog":
			return Color(0.78, 0.82, 0.82, 0.24)
		_:
			return Color(1.0, 1.0, 1.0, 0.0)


func get_encounter_context() -> Dictionary:
	return {"weather": current_weather}


func to_save_dict() -> Dictionary:
	return {
		"weather": current_weather,
		"next_change_absolute_minute": _next_change_absolute_minute,
		"rng_state": _rng.state,
	}


func apply_save_dict(data: Dictionary, time_source = null) -> void:
	var weather_id := str(data.get("weather", "rain"))
	current_weather = weather_id if WEATHER_NAMES.has(weather_id) else "rain"
	_last_absolute_minute = _absolute_minute(time_source) if time_source != null else 0
	_next_change_absolute_minute = int(data.get("next_change_absolute_minute", 0))
	if data.has("rng_state"):
		_rng.state = int(data.get("rng_state", _rng.state))
	if _next_change_absolute_minute <= _last_absolute_minute:
		_schedule_next_change(_last_absolute_minute)
	weather_changed.emit(current_weather, get_weather_name())


func _change_weather() -> void:
	var candidates: Array[String] = []
	var total := 0
	for weather_id in WEATHER_WEIGHTS.keys():
		# 避免连续两个天气段完全一样，让变化更有感知。
		if str(weather_id) == current_weather:
			continue
		var weight := int(WEATHER_WEIGHTS[weather_id])
		total += weight
		for _i in range(weight):
			candidates.append(str(weather_id))
	if candidates.is_empty() or total <= 0:
		return
	current_weather = candidates[_rng.randi_range(0, candidates.size() - 1)]
	weather_changed.emit(current_weather, get_weather_name())


func _schedule_next_change(now_absolute_minute: int) -> void:
	# 一个天气段持续约 3～7 个游戏小时。
	_next_change_absolute_minute = now_absolute_minute + _rng.randi_range(180, 420)


func _absolute_minute(time_source) -> int:
	if time_source == null:
		return 0
	return (maxi(1, int(time_source.day)) - 1) * 1440 + int(time_source.get_minute_of_day())
