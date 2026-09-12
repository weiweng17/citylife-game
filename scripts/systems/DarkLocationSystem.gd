extends Node
class_name DarkLocationSystem

## FEAT-003：暗线地点的世界状态。
## 负责旧巷口夜间开放、线索揭示表现，以及追查后天台的视觉提示。
## 不负责剧情选项与结算；那些仍由 StorySystem / EventSystem 负责。

const Data = preload("res://scripts/Data.gd")

const ALLEY_OPEN_START := 18 * 60 + 30
const ALLEY_OPEN_END := 4 * 60 + 30

var world_manager
var _last_key := ""


func configure(p_world_manager) -> void:
	world_manager = p_world_manager


func reset(time_source, st: Dictionary) -> void:
	_last_key = ""
	apply(time_source, st, true)


func apply(time_source, st: Dictionary, force: bool = false) -> void:
	if world_manager == null or time_source == null:
		return
	var minute := int(time_source.get_minute_of_day())
	var clues: Array = st.get("clues", [])
	var flags: Dictionary = st.get("flags", {})
	var age := int(st.get("age", 22))
	var key := "%d:%d:%s:%s:%d" % [minute, clues.size(), str(flags.get("dark_alley_done", false)), str(flags.get("dark_pursued", false)), age]
	if not force and key == _last_key:
		return
	_last_key = key

	var alley_open := _in_window(minute, ALLEY_OPEN_START, ALLEY_OPEN_END)
	var alley_done := bool(flags.get("dark_alley_done", false))
	var clue_ready := clues.size() >= Data.DARK_CLUE_TOTAL
	if not alley_open:
		world_manager.set_poi_state(
			"alley", false, "旧巷口 · 夜间开放",
			"白天的旧巷口被铁门和杂物封着。也许入夜后再来。", false
		)
	elif clue_ready and not alley_done:
		world_manager.set_poi_state(
			"alley", true, "旧巷口 · 记号浮现", "", true
		)
	else:
		world_manager.set_poi_state("alley", true, "旧巷口", "", false)

	# 追查旧巷后，40 岁起天台会出现暗线视觉提示；未追查时仍可作为普通地点使用。
	var rooftop_ready := bool(flags.get("dark_pursued", false)) and age >= 40 and not bool(flags.get("dark_rooftop_done", false))
	world_manager.set_poi_state(
		"rooftop", true, "老楼天台 · 记号回应" if rooftop_ready else "老楼天台", "", rooftop_ready
	)


func _in_window(now: int, start: int, end: int) -> bool:
	if start <= end:
		return now >= start and now < end
	return now >= start or now < end
