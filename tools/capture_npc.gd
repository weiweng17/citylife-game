extends SceneTree
## NPC 关系截图：场景里的 NPC 热点（悬停标签带熟悉度）、点开的对话标题、跨档后的标签。
## 输出 build/qa/npc_hotspot.png / npc_dialog.png / npc_tier.png

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
			if frame_count >= 10:
				_set_hover_visible()
				phase = 2
				frame_count = 0
		2:
			if frame_count >= 6:
				_capture("res://build/qa/npc_hotspot.png")
				var button := _button("xiaoyu")
				if button != null:
					button.pressed.emit()
				phase = 3
				frame_count = 0
		3:
			if frame_count >= 10:
				_capture("res://build/qa/npc_dialog.png")
				main.dialog_ui.close_dialog()
				# 关系升到"熟络"，看悬停标签会不会跟着变。
				main.game_state.relations["xiaoyu"] = 45
				main._sync_location_npcs()
				phase = 4
				frame_count = 0
		4:
			if frame_count >= 6:
				_set_hover_visible()
				phase = 5
				frame_count = 0
		5:
			if frame_count >= 6:
				_capture("res://build/qa/npc_tier.png")
				quit(0)
				return true
			if frame_count > 900:
				printerr("npc capture timed out")
				quit(1)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	location.current_location = "home"
	location._refresh()
	# 推到傍晚：小雨 18:30-24:00 在居民区。
	var want: int = main.time_sys.day * 1440 + 19 * 60
	var now: int = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.time_sys.advance_minutes(want - now)
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.fullness = 72
	main.energy = 66
	main.money = 860
	main.health = 78
	main.mood = 64
	main.daily_routine.complete("commute")
	main._sync_location_npcs()
	main._refresh_ui()


func _button(npc_id: String) -> Button:
	var wanted := "Npc_%s" % npc_id
	for child in main.location_sys.npc_layer.get_children():
		if child is Button and str(child.name) == wanted and not child.is_queued_for_deletion():
			return child as Button
	return null


## 名字标签平时只在鼠标悬停时出现；截图里直接打开，免得玩家看不到证据。
func _set_hover_visible() -> void:
	var button := _button("xiaoyu")
	if button == null:
		return
	for child in button.get_children():
		if child is Label:
			(child as Label).visible = true


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
