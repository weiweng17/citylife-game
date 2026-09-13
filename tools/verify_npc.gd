extends SceneTree
## 第 3 阶段单元 1：NPC 关系反馈（好感度 / 熟悉度分档 / 每天只有第一次算数）。
##
## 覆盖：
## 1. NPC 按日程出现在对应地点，不在场的 NPC 没有热点
## 2. 点热点 → 开启带熟悉度的对话（走 button.pressed → npc_requested → Game 这条真实信号链）
## 3. 对话还没读完时什么都不结算；读到结束才 +好感
## 4. 同一天重复聊天不重复结算，而且对话里会说明
## 5. 跨天之后恢复结算
## 6. 跨过一档时补一句旁白，并按档位回一点心情
## 7. 悬停标签与提示气泡跟着档位变
## 8. 关系存在 game_state 里，随存档整份往返，且**不新增 payload 字段**
##
## 说明：这里用 `button.pressed.emit()` 触发，覆盖的是"信号接线 + 结算"；
## 真正的鼠标命中是通用 GUI 行为，家具与地点按钮已由 verify_home_input.gd 用真实输入覆盖。

const Data = preload("res://scripts/Data.gd")
const NpcRelationsScript = preload("res://scripts/systems/NpcRelations.gd")

const XIAOYU := "xiaoyu"
const CHENJIE := "chenjie"
const EVENING := 19 * 60  # 小雨 18:30-24:00 在家；陈姐这个点应当已在便利店

var failures: Array[String] = []
var main


func _init() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL ", message)


func _set_clock(minute_of_day: int) -> void:
	var want: int = main.time_sys.day * 1440 + minute_of_day
	var now: int = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	main.time_sys.advance_minutes(want - now)
	# 跳完把消耗基准对齐，否则这一跳会被 needs 当成真实流逝的时间（见 HANDOFF）。
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()


func _npc_button(npc_id: String) -> Button:
	# 按名字扫而不是 get_node：热点重建时旧节点可能还排在被释放的队列里，
	# 直接按名字取会拿到正要释放的那一个（见 LocationManager._clear_npcs 的注释）。
	var wanted := "Npc_%s" % npc_id
	for child in main.location_sys.npc_layer.get_children():
		if child is Button and str(child.name) == wanted and not child.is_queued_for_deletion():
			return child as Button
	return null


func _relation(npc_id: String) -> int:
	return int(main.game_state.relations.get(npc_id, 0))


func _open_talk(npc_id: String) -> void:
	var button := _npc_button(npc_id)
	if button != null:
		button.pressed.emit()


## 按对话的"继续/结束"把整段读完——读完才会 emit dialog_finished。
func _finish_dialog() -> String:
	var seen := ""
	var guard := 0
	while main.dialog_ui.visible and guard < 80:
		seen += main.dialog_ui.text_label.text
		main.dialog_ui.next_button.pressed.emit()
		guard += 1
	return seen


func _hover_label_text(npc_id: String) -> String:
	var button := _npc_button(npc_id)
	if button == null:
		return ""
	for child in button.get_children():
		if child is Label:
			return (child as Label).text
	return ""


func run() -> void:
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	# 先让 Game 把输入闸门算清楚再冻结；否则 location.input_blocked 会停在 true（见 docs/QA_2026-09-13.md）。
	main._process(0.0)
	main.set_process(false)

	_set_clock(EVENING)
	main.location_sys.travel_to("home")
	main._sync_location_npcs()

	# ---------------------------------------------------------- 1 按日程出现
	check(_npc_button(XIAOYU) != null, "xiaoyu should be home at 19:00")
	check(_npc_button(CHENJIE) == null, "chenjie works at the store at 19:00, should not be home")
	print("PASS npc hotspots follow the schedule")

	# ---------------------------------------------------------- 2 点热点开对话
	_open_talk(XIAOYU)
	check(main.dialog_ui.visible, "clicking the npc hotspot should open a dialog")
	check(main.dialog_pending_npc == XIAOYU, "the dialog should remember who is being talked to")
	var speaker: String = main.dialog_ui.speaker_label.text
	check(speaker.contains("小雨"), "the dialog title should name the npc, got: " + speaker)
	check(speaker.contains("陌生人"), "the dialog title should carry the relation tier, got: " + speaker)
	print("PASS hotspot click opens a dialog titled with the relation tier")

	# ---------------------------------------------------------- 3 读完才结算
	check(_relation(XIAOYU) == 0, "nothing may be granted while the dialog is still open")
	_finish_dialog()
	check(not main.dialog_ui.visible, "the dialog should be closed after reading it through")
	check(_relation(XIAOYU) == NpcRelationsScript.DAILY_GAIN,
		"the first talk of the day should grant %d, got %d" % [NpcRelationsScript.DAILY_GAIN, _relation(XIAOYU)])
	check(int(main.game_state.talk_day.get(XIAOYU, -1)) == main.time_sys.day,
		"the talk day should be recorded for the daily limit")
	check(main.toast_label.text.contains("好感+4"), "a toast should spell out the gain, got: " + main.toast_label.text)
	print("PASS relation is settled only after the dialog is read through")

	# ---------------------------------------------------------- 4 同一天不重复
	_open_talk(XIAOYU)
	var repeat_text := _finish_dialog()
	check(repeat_text.contains("今天已经聊过了"), "a same-day repeat should say so in the dialog")
	check(_relation(XIAOYU) == NpcRelationsScript.DAILY_GAIN,
		"a same-day repeat must not add anything, got %d" % _relation(XIAOYU))
	print("PASS the same-day repeat says so and grants nothing")

	# ---------------------------------------------------------- 5 跨天恢复
	main.time_sys.advance_minutes(24 * 60)
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	_set_clock(EVENING)
	main._sync_location_npcs()
	check(_npc_button(XIAOYU) != null, "xiaoyu should be home again the next evening")
	_open_talk(XIAOYU)
	_finish_dialog()
	check(_relation(XIAOYU) == NpcRelationsScript.DAILY_GAIN * 2,
		"a new day should grant again, got %d" % _relation(XIAOYU))
	print("PASS a new day grants again")

	# ---------------------------------------------------------- 6 跨档：旁白 + 心情
	var mood_before: int = main.mood
	main.game_state.relations[XIAOYU] = 16  # 再聊一次正好跨过"认识"
	main.game_state.talk_day.erase(XIAOYU)
	_open_talk(XIAOYU)
	_finish_dialog()
	check(_relation(XIAOYU) == 20, "16 + 4 should land exactly on the tier edge, got %d" % _relation(XIAOYU))
	check(NpcRelationsScript.label_of(20) == "认识", "20 should be the '认识' tier")
	check(main.toast_label.text.contains("认识"), "a tier-up should name the new tier, got: " + main.toast_label.text)
	check(main.toast_label.text.contains("他记住了你的脸"), "a tier-up should add its milestone line")
	check(main.mood == mood_before + 1, "the '认识' tier should give back 1 mood, got %d" % main.mood)
	print("PASS a tier-up adds narration and gives back mood")

	# ---------------------------------------------------------- 7 标签跟着档位变
	# 不手动清 npc_signature：档位写进 signature 才会自动重建，这里正是一起验证。
	main.game_state.relations[XIAOYU] = 45
	main._sync_location_npcs()
	var hover: String = _hover_label_text(XIAOYU)
	check(hover.contains("熟络"), "the hover label should follow the tier, got: " + hover)
	var button := _npc_button(XIAOYU)
	check(button != null and button.tooltip_text.contains("熟络"),
		"the tooltip should follow the tier too")
	check(NpcRelationsScript.label_of(70) == "朋友", "70 should be the '朋友' tier")
	print("PASS the hotspot label and tooltip follow the tier")

	# ---------------------------------------------------------- 8 存档往返
	var saved: Dictionary = main.build_save_payload()
	for key in ["game_state", "time", "weather", "events", "encounters", "world", "locations", "daily", "inventory", "origin"]:
		check(saved.has(key), "the save payload must still carry: " + key)
	var saved_state: Dictionary = saved.get("game_state", {})
	check(saved_state.has("relations"), "relations should ride inside game_state, not as a new payload field")
	check(saved_state.has("talk_day"), "talk_day should ride inside game_state too")

	# 用一份真正的深拷贝模拟落盘再读回（直接引用同一本字典等于没测序列化）。
	var copied_relations: Dictionary = (main.game_state.relations as Dictionary).duplicate(true)
	var copied_days: Dictionary = (main.game_state.talk_day as Dictionary).duplicate(true)
	main.game_state.relations = {}
	main.game_state.talk_day = {}
	main.apply_save_payload({"game_state": {"relations": copied_relations, "talk_day": copied_days}})
	check(_relation(XIAOYU) == 45, "relations must come back from a save, got %d" % _relation(XIAOYU))
	check(NpcRelationsScript.label_of(_relation(XIAOYU)) == "熟络", "the tier must come back too")
	print("PASS relations survive a save round-trip inside game_state")

	print("NPC relation failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
