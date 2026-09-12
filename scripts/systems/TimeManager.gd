extends Node
class_name TimeManager

## 《都市浮生》统一城市时间系统。
## 负责游戏内分钟/小时/天数与昼夜阶段，不负责 NPC 作息（FEAT-002）。

signal minute_changed(day: int, hour: int, minute: int)
signal hour_changed(day: int, hour: int)
signal day_changed(day: int)
signal period_changed(period: String)

const MINUTES_PER_DAY := 24 * 60
const PERIOD_NAMES := {
	"dawn": "清晨",
	"day": "白天",
	"dusk": "黄昏",
	"night": "夜晚",
}

## 1 秒现实时间推进 2 分钟游戏时间；完整 24 小时约 12 分钟。
var game_minutes_per_real_second: float = 2.0
var day: int = 1
var paused: bool = false

var _minutes_of_day: float = 7.0 * 60.0 + 30.0
var _last_minute: int = 450
var _last_hour: int = 7
var _period: String = "day"


func _ready() -> void:
	_period = get_period()


func reset(start_hour: int = 7, start_minute: int = 30) -> void:
	day = 1
	_minutes_of_day = float(clampi(start_hour, 0, 23) * 60 + clampi(start_minute, 0, 59))
	_last_minute = get_minute_of_day()
	_last_hour = get_hour()
	_period = get_period()
	paused = false
	minute_changed.emit(day, get_hour(), get_minute())
	hour_changed.emit(day, get_hour())
	period_changed.emit(_period)


func tick(delta: float) -> void:
	if paused or delta <= 0.0:
		return

	var previous_day := day
	_minutes_of_day += delta * game_minutes_per_real_second
	while _minutes_of_day >= float(MINUTES_PER_DAY):
		_minutes_of_day -= float(MINUTES_PER_DAY)
		day += 1
	while _minutes_of_day < 0.0:
		_minutes_of_day += float(MINUTES_PER_DAY)
		day = maxi(1, day - 1)

	if day != previous_day:
		day_changed.emit(day)

	var current_minute := get_minute_of_day()
	if current_minute != _last_minute:
		_last_minute = current_minute
		minute_changed.emit(day, get_hour(), get_minute())

	var current_hour := get_hour()
	if current_hour != _last_hour:
		_last_hour = current_hour
		hour_changed.emit(day, current_hour)

	var new_period := get_period()
	if new_period != _period:
		_period = new_period
		period_changed.emit(_period)


func set_paused(value: bool) -> void:
	paused = value


## 用于奇遇、旅行等一次性推进游戏内时间；不会推进年龄/年度结算。
func advance_minutes(minutes: int) -> void:
	if minutes == 0:
		return
	var previous_day := day
	_minutes_of_day += float(minutes)
	while _minutes_of_day >= float(MINUTES_PER_DAY):
		_minutes_of_day -= float(MINUTES_PER_DAY)
		day += 1
	while _minutes_of_day < 0.0:
		_minutes_of_day += float(MINUTES_PER_DAY)
		day = maxi(1, day - 1)

	if day != previous_day:
		day_changed.emit(day)
	_last_minute = get_minute_of_day()
	_last_hour = get_hour()
	_period = get_period()
	minute_changed.emit(day, get_hour(), get_minute())
	hour_changed.emit(day, get_hour())
	period_changed.emit(_period)


func get_minute_of_day() -> int:
	return clampi(int(floor(_minutes_of_day)), 0, MINUTES_PER_DAY - 1)


func get_hour() -> int:
	return get_minute_of_day() / 60


func get_minute() -> int:
	return get_minute_of_day() % 60


func get_hour_float() -> float:
	return _minutes_of_day / 60.0


func get_clock_text() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]


func get_period() -> String:
	var h := get_hour_float()
	if h >= 5.0 and h < 7.0:
		return "dawn"
	if h >= 7.0 and h < 17.0:
		return "day"
	if h >= 17.0 and h < 19.0:
		return "dusk"
	return "night"


func get_period_name() -> String:
	return str(PERIOD_NAMES.get(get_period(), "白天"))


func get_ambient_color() -> Color:
	## 平滑环境色。这里仅做视觉表现，不改变玩法数值。
	var h := get_hour_float()
	var night := Color(0.38, 0.43, 0.60, 1.0)
	var dawn := Color(0.78, 0.76, 0.78, 1.0)
	var day_color := Color(0.96, 0.97, 1.0, 1.0)
	var dusk := Color(0.72, 0.59, 0.61, 1.0)

	if h < 5.0:
		return night
	if h < 7.0:
		return night.lerp(dawn, (h - 5.0) / 2.0)
	if h < 8.0:
		return dawn.lerp(day_color, h - 7.0)
	if h < 17.0:
		return day_color
	if h < 19.0:
		return day_color.lerp(dusk, (h - 17.0) / 2.0)
	if h < 20.0:
		return dusk.lerp(night, h - 19.0)
	return night


func get_vignette_alpha() -> float:
	match get_period():
		"night":
			return 0.92
		"dawn", "dusk":
			return 0.72
		_:
			return 0.52


func get_rain_alpha() -> float:
	match get_period():
		"night":
			return 0.58
		"dawn", "dusk":
			return 0.48
		_:
			return 0.36


func to_save_dict() -> Dictionary:
	return {
		"day": day,
		"minute_of_day": get_minute_of_day(),
		"speed": game_minutes_per_real_second,
	}


func apply_save_dict(data: Dictionary) -> void:
	day = maxi(1, int(data.get("day", 1)))
	_minutes_of_day = float(clampi(int(data.get("minute_of_day", 450)), 0, MINUTES_PER_DAY - 1))
	game_minutes_per_real_second = maxf(0.1, float(data.get("speed", game_minutes_per_real_second)))
	_last_minute = get_minute_of_day()
	_last_hour = get_hour()
	_period = get_period()
	paused = false
	minute_changed.emit(day, get_hour(), get_minute())
	hour_changed.emit(day, get_hour())
	period_changed.emit(_period)
