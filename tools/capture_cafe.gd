extends SceneTree
## 咖啡馆互动截图：靠窗吧台冲泡进行中、圆桌发呆结算反馈。
## 输出 build/qa/cafe_coffee.png / cafe_idle.png
##
## 两个站位是不是压在美术的吧台/圆桌上、阿哲中午的站位对不对，
## 只能靠眼睛看。时钟拨到 12:30，让阿哲的午间日程也在画面里。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var settle_frames: int = 0
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
			if main.cafe_activities.layer.visible and not main.cafe_activities.blocked:
				main.cafe_activities._activate("coffee")
				phase = 2
				frame_count = 0
			elif frame_count > 600:
				printerr("cafe capture: cafe layer never showed up")
				quit(1)
				return true
		2:
			# 截一张"进行中"：头顶反馈 + 进度文字。
			if frame_count >= 20:
				_capture("res://build/qa/cafe_coffee.png")
				phase = 3
				frame_count = 0
		3:
			# 等咖啡结算落下来，再走到圆桌。
			if not main.activity_running and settle_frames >= 4:
				main.location_sys.player_sprite.position = main.cafe_activities.SPOTS.idle.position
				main.location_sys.player_target = main.location_sys.player_sprite.position
				phase = 4
				frame_count = 0
				settle_frames = 0
			elif main.activity_running:
				settle_frames = 0
			else:
				settle_frames += 1
		4:
			if not main.cafe_activities.blocked:
				main.cafe_activities._activate("idle")
				phase = 5
				frame_count = 0
			elif frame_count > 600:
				printerr("cafe capture: cafe layer blocked")
				quit(1)
				return true
		5:
			# 发呆结算完再等几帧，让提示完全落上去。
			if not main.activity_running:
				settle_frames += 1
			else:
				settle_frames = 0
			if settle_frames >= 4:
				_capture("res://build/qa/cafe_idle.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("cafe capture timed out")
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.location_sys.unlock("cafe")
	main.location_sys.travel_to("cafe")
	main.location_sys.player_sprite.position = main.cafe_activities.SPOTS.coffee.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	# 拨到中午 12:30：阿哲的咖啡馆日程（12:00-14:00）会出现在画面里。
	var want: int = main.time_sys.day * 1440 + 12 * 60 + 30
	var now: int = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.time_sys.advance_minutes(want - now)
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.money = 100
	main.energy = 55
	main.mood = 52
	main.fullness = 66


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
