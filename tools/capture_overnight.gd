extends SceneTree
## 过夜截图：深夜床位提示会变成"睡到明早"，以及睡醒后的跨天小结。
## 输出 build/qa/overnight_bed_hint.png 与 overnight_wakeup.png。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var phase: int = 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frame_count += 1
	match phase:
		0:
			if frame_count >= 8:
				_setup()
				phase = 1
				frame_count = 0
		1:
			if frame_count >= 12:
				_capture("res://build/qa/overnight_bed_hint.png")
				main.home_activities._activate("rest")
				phase = 2
				frame_count = 0
		2:
			# 活动本身有 1.2 秒的进度动画，等结算文案真的挂上去再截。
			if frame_count >= 6 and main.toast_label.visible and main.toast_label.text.contains("昨天"):
				_capture("res://build/qa/overnight_wakeup.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("overnight capture timed out: ", main.toast_label.text)
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	var home = main.home_activities
	location.current_location = "home"
	location._refresh()
	# 把时钟推到深夜，看床位提示会不会换成"睡到明早"。
	main.time_sys.advance_minutes((21 * 60 + 40) - main.time_sys.get_minute_of_day())
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.need_fraction = 0.0
	main.fullness = 78
	main.energy = 42
	main.money = 1280
	main.health = 74
	main.mood = 61
	main.daily_routine.complete("commute")
	main.daily_routine.complete("work")
	main.daily_routine.complete("meal")
	location.player_sprite.position = home.SPOTS.rest.position
	location.player_target = home.SPOTS.rest.position
	location._update_player_grounding()
	main._refresh_ui()


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
