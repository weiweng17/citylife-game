extends Node2D
## 快速上线版「卧室养小人」垂直切片。
##
## 目标不是在这里堆完整模拟人生，而是先验证核心循环：
## 看小人生活 -> 发现需求 -> 玩家干预 -> 得到反馈 -> 离线后继续变化。
## 场景和 UI 都由代码生成，后续替换成正式分层美术时不需要重写玩法状态机。

const SAVE_PATH := "user://bedroom_life.json"
const PLAYER_TEX := "res://assets/sprites/player_v5.png"
const VIEW_SIZE := Vector2(1280.0, 720.0)
const SIM_MINUTES_PER_REAL_SECOND := 1.0
const AUTOSAVE_INTERVAL := 8.0

const ANCHORS := {
	"center": Vector2(620, 430),
	"bed": Vector2(365, 425),
	"kitchen": Vector2(190, 400),
	"shower": Vector2(165, 565),
	"computer": Vector2(1010, 455),
	"sofa": Vector2(660, 555),
	"window": Vector2(860, 300),
}

const ACTION_DATA := {
	"sleep": {
		"name": "睡觉",
		"anchor": "bed",
		"duration": 6.5,
		"thought": "好困……让我躺一会儿。",
	},
	"eat": {
		"name": "吃东西",
		"anchor": "kitchen",
		"duration": 4.0,
		"thought": "先吃点热乎的。",
	},
	"shower": {
		"name": "洗澡",
		"anchor": "shower",
		"duration": 5.0,
		"thought": "洗完澡整个人都会轻松一点。",
	},
	"computer": {
		"name": "玩电脑",
		"anchor": "computer",
		"duration": 5.5,
		"thought": "就玩一小会儿……应该吧。",
	},
	"chat": {
		"name": "聊天",
		"anchor": "sofa",
		"duration": 4.5,
		"thought": "你今天过得怎么样？",
	},
	"gift": {
		"name": "收礼物",
		"anchor": "sofa",
		"duration": 3.5,
		"thought": "这是给我的？真的？",
	},
	"relax": {
		"name": "发呆",
		"anchor": "window",
		"duration": 4.0,
		"thought": "雨声还挺适合发呆的。",
	},
}

var state := {
	"name": "小满",
	"level": 1,
	"coins": 120,
	"day": 1,
	"minute": 22 * 60 + 30,
	"mood": 76.0,
	"fullness": 64.0,
	"energy": 72.0,
	"hygiene": 82.0,
	"fun": 47.0,
	"affection": 20.0,
}

var daily := {
	"eat": false,
	"chat": false,
	"sleep": false,
	"rewarded": false,
}

var resident_root: Node2D
var resident_sprite: Sprite2D
var sleep_blanket: Polygon2D
var thought_label: Label
var ui_layer: CanvasLayer
var clock_label: Label
var coin_label: Label
var status_label: Label
var toast_label: Label
var daily_label: Label
var stat_labels := {}
var stat_bars := {}

var current_action := "idle"
var action_phase := "idle"
var action_timer := 0.0
var action_was_player_requested := false
var resident_target := ANCHORS["center"] as Vector2
var brain_timer := 1.0
var sim_minute_accum := 0.0
var autosave_timer := AUTOSAVE_INTERVAL
var ui_refresh_timer := 0.0
var toast_timer := 0.0
var offline_note := ""


func _ready() -> void:
	randomize()
	_build_resident()
	_load_game()
	_build_ui()
	_build_sleep_foreground()
	_create_room_hotspots()
	_refresh_ui()
	queue_redraw()
	if offline_note != "":
		_show_toast(offline_note, 5.0)
	else:
		_show_toast("小满正在房间里生活。你可以照顾她，也可以什么都不做。", 4.0)


func _process(delta: float) -> void:
	_tick_simulation(delta)
	_tick_action(delta)
	_tick_brain(delta)
	_tick_autosave(delta)

	ui_refresh_timer -= delta
	if ui_refresh_timer <= 0.0:
		ui_refresh_timer = 0.2
		_refresh_ui()

	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0 and is_instance_valid(toast_label):
			toast_label.visible = false

	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()


func _build_resident() -> void:
	resident_root = Node2D.new()
	resident_root.name = "Resident"
	resident_root.position = ANCHORS["center"]
	resident_root.z_index = 10
	add_child(resident_root)

	resident_sprite = Sprite2D.new()
	resident_sprite.name = "Sprite"
	resident_sprite.texture = load(PLAYER_TEX)
	resident_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	resident_sprite.centered = true
	if resident_sprite.texture != null:
		resident_sprite.offset = Vector2(0.0, -resident_sprite.texture.get_height() / 2.0)
	resident_sprite.scale = Vector2(2.25, 2.25)
	resident_root.add_child(resident_sprite)

	thought_label = Label.new()
	thought_label.text = "今晚下雨了。"
	thought_label.position = Vector2(-82, -168)
	thought_label.size = Vector2(164, 42)
	thought_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thought_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thought_label.add_theme_font_size_override("font_size", 16)
	thought_label.add_theme_color_override("font_color", Color("#3d3432"))
	thought_label.add_theme_stylebox_override("normal", _panel_style(Color(0.98, 0.95, 0.90, 0.94), 12, Color(0.35, 0.28, 0.25, 0.12)))
	resident_root.add_child(thought_label)


func _build_sleep_foreground() -> void:
	# 睡觉时把人物下半身压进被子层，而不是简单把一张横躺 PNG 贴在床上。
	sleep_blanket = Polygon2D.new()
	sleep_blanket.name = "SleepBlanketForeground"
	sleep_blanket.polygon = PackedVector2Array([
		Vector2(276, 389), Vector2(428, 376), Vector2(492, 430), Vector2(318, 456)
	])
	sleep_blanket.color = Color("#7f9b80")
	sleep_blanket.z_index = 20
	sleep_blanket.visible = false
	add_child(sleep_blanket)


func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "BedroomUI"
	ui_layer.layer = 30
	add_child(ui_layer)

	# 左侧：角色与状态。
	var stat_panel := PanelContainer.new()
	stat_panel.position = Vector2(18, 18)
	stat_panel.size = Vector2(262, 292)
	stat_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.975, 0.95, 0.91, 0.96), 18, Color(0.12, 0.09, 0.08, 0.18)))
	ui_layer.add_child(stat_panel)

	var stat_margin := MarginContainer.new()
	stat_margin.add_theme_constant_override("margin_left", 16)
	stat_margin.add_theme_constant_override("margin_right", 16)
	stat_margin.add_theme_constant_override("margin_top", 14)
	stat_margin.add_theme_constant_override("margin_bottom", 14)
	stat_panel.add_child(stat_margin)

	var stat_box := VBoxContainer.new()
	stat_box.add_theme_constant_override("separation", 7)
	stat_margin.add_child(stat_box)

	var title := Label.new()
	title.text = "小满  ·  Lv.1  室友"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#372d2a"))
	stat_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "一个会自己生活的小人"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("#74645f"))
	stat_box.add_child(subtitle)

	for row in [
		["mood", "心情", Color("#e88583")],
		["fullness", "饱食", Color("#d99a59")],
		["energy", "精力", Color("#bd87c9")],
		["hygiene", "卫生", Color("#70bdd0")],
		["fun", "娱乐", Color("#8d7fc6")],
		["affection", "亲密", Color("#d76faf")],
	]:
		_add_stat_row(stat_box, str(row[0]), str(row[1]), row[2] as Color)

	# 顶部时钟和金币。
	var time_panel := PanelContainer.new()
	time_panel.position = Vector2(514, 18)
	time_panel.size = Vector2(252, 72)
	time_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.075, 0.085, 0.88), 20, Color(1, 1, 1, 0.08)))
	ui_layer.add_child(time_panel)
	clock_label = Label.new()
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 24)
	clock_label.add_theme_color_override("font_color", Color("#fff8ea"))
	time_panel.add_child(clock_label)

	var coin_panel := PanelContainer.new()
	coin_panel.position = Vector2(1018, 18)
	coin_panel.size = Vector2(128, 46)
	coin_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.075, 0.085, 0.88), 14, Color(1, 1, 1, 0.08)))
	ui_layer.add_child(coin_panel)
	coin_label = Label.new()
	coin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coin_label.add_theme_font_size_override("font_size", 18)
	coin_label.add_theme_color_override("font_color", Color("#ffd878"))
	coin_panel.add_child(coin_label)

	var city_btn := Button.new()
	city_btn.text = "旧版都市"
	city_btn.position = Vector2(1154, 18)
	city_btn.size = Vector2(106, 46)
	city_btn.add_theme_font_size_override("font_size", 15)
	city_btn.add_theme_stylebox_override("normal", _button_style(Color(0.10, 0.09, 0.10, 0.88)))
	city_btn.add_theme_stylebox_override("hover", _button_style(Color(0.18, 0.15, 0.16, 0.94)))
	city_btn.pressed.connect(_open_legacy_city)
	ui_layer.add_child(city_btn)

	# 右侧：当前行为与今日目标。
	var right_panel := PanelContainer.new()
	right_panel.position = Vector2(1000, 94)
	right_panel.size = Vector2(260, 206)
	right_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.07, 0.08, 0.86), 18, Color(1, 1, 1, 0.08)))
	ui_layer.add_child(right_panel)
	var right_margin := MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 16)
	right_margin.add_theme_constant_override("margin_right", 16)
	right_margin.add_theme_constant_override("margin_top", 14)
	right_margin.add_theme_constant_override("margin_bottom", 14)
	right_panel.add_child(right_margin)
	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 10)
	right_margin.add_child(right_box)
	var right_title := Label.new()
	right_title.text = "现在在做什么"
	right_title.add_theme_font_size_override("font_size", 17)
	right_title.add_theme_color_override("font_color", Color("#fff5e8"))
	right_box.add_child(right_title)
	status_label = Label.new()
	status_label.custom_minimum_size = Vector2(0, 44)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#e8dbd3"))
	right_box.add_child(status_label)
	var daily_title := Label.new()
	daily_title.text = "今日计划"
	daily_title.add_theme_font_size_override("font_size", 16)
	daily_title.add_theme_color_override("font_color", Color("#fff5e8"))
	right_box.add_child(daily_title)
	daily_label = Label.new()
	daily_label.add_theme_font_size_override("font_size", 14)
	daily_label.add_theme_color_override("font_color", Color("#d8cbc5"))
	right_box.add_child(daily_label)

	# 底部主操作条。
	var action_panel := PanelContainer.new()
	action_panel.position = Vector2(302, 640)
	action_panel.size = Vector2(676, 64)
	action_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.07, 0.08, 0.90), 18, Color(1, 1, 1, 0.08)))
	ui_layer.add_child(action_panel)
	var action_margin := MarginContainer.new()
	action_margin.add_theme_constant_override("margin_left", 10)
	action_margin.add_theme_constant_override("margin_right", 10)
	action_margin.add_theme_constant_override("margin_top", 8)
	action_margin.add_theme_constant_override("margin_bottom", 8)
	action_panel.add_child(action_margin)
	var action_box := HBoxContainer.new()
	action_box.add_theme_constant_override("separation", 7)
	action_margin.add_child(action_box)
	for action_id in ["eat", "shower", "computer", "chat", "gift", "sleep"]:
		var btn := Button.new()
		btn.text = str(ACTION_DATA[action_id]["name"])
		btn.custom_minimum_size = Vector2(102, 46)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color("#fff7ef"))
		btn.add_theme_stylebox_override("normal", _button_style(Color(0.17, 0.145, 0.15, 0.96)))
		btn.add_theme_stylebox_override("hover", _button_style(Color(0.30, 0.23, 0.23, 0.98)))
		btn.pressed.connect(_on_action_button_pressed.bind(action_id))
		action_box.add_child(btn)

	# 左下角反馈条。
	toast_label = Label.new()
	toast_label.position = Vector2(18, 586)
	toast_label.size = Vector2(420, 48)
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_font_size_override("font_size", 15)
	toast_label.add_theme_color_override("font_color", Color("#fff5ea"))
	toast_label.add_theme_stylebox_override("normal", _panel_style(Color(0.065, 0.06, 0.07, 0.88), 14, Color(1, 1, 1, 0.08)))
	ui_layer.add_child(toast_label)


func _add_stat_row(parent: VBoxContainer, key: String, label_text: String, fill_color: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(42, 22)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color("#544743"))
	row.add_child(name_label)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 50
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(132, 16)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.21, 0.17, 0.16, 0.14)
	bg.corner_radius_top_left = 8
	bg.corner_radius_top_right = 8
	bg.corner_radius_bottom_left = 8
	bg.corner_radius_bottom_right = 8
	bar.add_theme_stylebox_override("background", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 8
	fill.corner_radius_top_right = 8
	fill.corner_radius_bottom_left = 8
	fill.corner_radius_bottom_right = 8
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)
	var value_label := Label.new()
	value_label.text = "50"
	value_label.custom_minimum_size = Vector2(30, 22)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color("#544743"))
	row.add_child(value_label)
	stat_bars[key] = bar
	stat_labels[key] = value_label


func _create_room_hotspots() -> void:
	var hotspot_specs := [
		["sleep", Vector2(302, 322)],
		["eat", Vector2(102, 312)],
		["shower", Vector2(92, 506)],
		["computer", Vector2(932, 380)],
	]
	for spec in hotspot_specs:
		var action_id := str(spec[0])
		var btn := Button.new()
		btn.text = str(ACTION_DATA[action_id]["name"])
		btn.position = spec[1]
		btn.size = Vector2(84, 34)
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color("#4b3a35"))
		btn.add_theme_stylebox_override("normal", _button_style(Color(0.98, 0.95, 0.90, 0.94)))
		btn.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.88, 0.72, 0.98)))
		btn.pressed.connect(_on_action_button_pressed.bind(action_id))
		ui_layer.add_child(btn)


func _tick_simulation(delta: float) -> void:
	sim_minute_accum += delta * SIM_MINUTES_PER_REAL_SECOND
	while sim_minute_accum >= 1.0:
		sim_minute_accum -= 1.0
		_advance_one_game_minute()


func _advance_one_game_minute() -> void:
	state["minute"] = int(state["minute"]) + 1
	if int(state["minute"]) >= 24 * 60:
		state["minute"] = 0
		state["day"] = int(state["day"]) + 1
		daily = {"eat": false, "chat": false, "sleep": false, "rewarded": false}
		_show_toast("新的一天开始了。小满又有自己的小计划。", 3.5)

	if not (current_action == "eat" and action_phase == "acting"):
		state["fullness"] = _clamp_need(float(state["fullness"]) - 0.028)
	if not (current_action == "sleep" and action_phase == "acting"):
		state["energy"] = _clamp_need(float(state["energy"]) - 0.021)
	state["hygiene"] = _clamp_need(float(state["hygiene"]) - 0.012)
	state["fun"] = _clamp_need(float(state["fun"]) - 0.017)

	var need_average := (float(state["fullness"]) + float(state["energy"]) + float(state["hygiene"]) + float(state["fun"])) / 4.0
	var target_mood := need_average * 0.82 + float(state["affection"]) * 0.18
	state["mood"] = _clamp_need(lerpf(float(state["mood"]), target_mood, 0.025))


func _tick_action(delta: float) -> void:
	if action_phase == "moving":
		var distance := resident_root.position.distance_to(resident_target)
		if distance <= 4.0:
			resident_root.position = resident_target
			_begin_acting()
			return
		var dir := resident_root.position.direction_to(resident_target)
		resident_root.position += dir * minf(150.0 * delta, distance)
		if absf(dir.x) > 0.05:
			resident_sprite.flip_h = dir.x < 0.0
		resident_sprite.position.y = sin(Time.get_ticks_msec() / 90.0) * 1.6
	elif action_phase == "acting":
		action_timer -= delta
		if action_timer <= 0.0:
			_finish_action()
	else:
		resident_sprite.position.y = 0.0


func _tick_brain(delta: float) -> void:
	if action_phase != "idle":
		return
	brain_timer -= delta
	if brain_timer > 0.0:
		return
	brain_timer = randf_range(2.5, 4.5)
	_choose_autonomous_action()


func _tick_autosave(delta: float) -> void:
	autosave_timer -= delta
	if autosave_timer <= 0.0:
		autosave_timer = AUTOSAVE_INTERVAL
		_save_game()


func _choose_autonomous_action() -> void:
	if float(state["energy"]) < 28.0:
		_start_action("sleep", false)
	elif float(state["fullness"]) < 30.0:
		_start_action("eat", false)
	elif float(state["hygiene"]) < 32.0:
		_start_action("shower", false)
	elif float(state["fun"]) < 34.0:
		_start_action("computer", false)
	else:
		var choices := ["relax", "computer", "relax"]
		_start_action(str(choices[randi() % choices.size()]), false)


func _on_action_button_pressed(action_id: String) -> void:
	if action_id == "eat":
		if int(state["coins"]) < 6:
			_show_toast("零钱不够了。先让小满自己安排吧。", 3.0)
			return
		state["coins"] = int(state["coins"]) - 6
	elif action_id == "gift":
		if int(state["coins"]) < 20:
			_show_toast("送礼物需要 20 枚硬币。", 3.0)
			return
		state["coins"] = int(state["coins"]) - 20
	_start_action(action_id, true)


func _start_action(action_id: String, player_requested: bool) -> void:
	if not ACTION_DATA.has(action_id):
		return
	_reset_action_pose()
	current_action = action_id
	action_phase = "moving"
	action_was_player_requested = player_requested
	var anchor_name := str(ACTION_DATA[action_id]["anchor"])
	resident_target = ANCHORS.get(anchor_name, ANCHORS["center"])
	thought_label.text = str(ACTION_DATA[action_id]["thought"])
	if player_requested:
		_show_toast("你叫小满去%s。" % str(ACTION_DATA[action_id]["name"]), 2.2)


func _begin_acting() -> void:
	action_phase = "acting"
	action_timer = float(ACTION_DATA[current_action]["duration"])
	if current_action == "sleep":
		resident_root.rotation = -1.08
		resident_root.position += Vector2(20, -4)
		sleep_blanket.visible = true
	elif current_action == "shower":
		resident_sprite.modulate = Color(0.82, 0.93, 1.0, 0.65)
	elif current_action == "computer":
		resident_sprite.flip_h = true


func _finish_action() -> void:
	var was_player := action_was_player_requested
	match current_action:
		"sleep":
			state["energy"] = _clamp_need(float(state["energy"]) + 38.0)
			state["fullness"] = _clamp_need(float(state["fullness"]) - 4.0)
			daily["sleep"] = true
		"eat":
			state["fullness"] = _clamp_need(float(state["fullness"]) + 34.0)
			state["mood"] = _clamp_need(float(state["mood"]) + 3.0)
			daily["eat"] = true
		"shower":
			state["hygiene"] = _clamp_need(float(state["hygiene"]) + 45.0)
			state["mood"] = _clamp_need(float(state["mood"]) + 4.0)
		"computer":
			state["fun"] = _clamp_need(float(state["fun"]) + 32.0)
			state["energy"] = _clamp_need(float(state["energy"]) - 4.0)
		"chat":
			state["mood"] = _clamp_need(float(state["mood"]) + 9.0)
			state["fun"] = _clamp_need(float(state["fun"]) + 7.0)
			state["affection"] = _clamp_need(float(state["affection"]) + 5.0)
			daily["chat"] = true
		"gift":
			state["mood"] = _clamp_need(float(state["mood"]) + 10.0)
			state["affection"] = _clamp_need(float(state["affection"]) + 9.0)
		"relax":
			state["fun"] = _clamp_need(float(state["fun"]) + 6.0)
			state["mood"] = _clamp_need(float(state["mood"]) + 4.0)

	if was_player and current_action not in ["chat", "gift"]:
		state["affection"] = _clamp_need(float(state["affection"]) + 1.0)

	var finished_name := str(ACTION_DATA[current_action]["name"])
	_show_toast("%s完成了。小满看起来舒服了一点。" % finished_name, 2.8)
	_check_daily_reward()
	_reset_action_pose()
	current_action = "idle"
	action_phase = "idle"
	action_was_player_requested = false
	thought_label.text = _idle_thought()
	brain_timer = randf_range(2.2, 4.0)
	_save_game()


func _reset_action_pose() -> void:
	if not is_instance_valid(resident_root):
		return
	resident_root.rotation = 0.0
	if is_instance_valid(resident_sprite):
		resident_sprite.position = Vector2.ZERO
		resident_sprite.modulate = Color.WHITE
	if is_instance_valid(sleep_blanket):
		sleep_blanket.visible = false


func _check_daily_reward() -> void:
	if bool(daily["rewarded"]):
		return
	if bool(daily["eat"]) and bool(daily["chat"]) and bool(daily["sleep"]):
		daily["rewarded"] = true
		state["coins"] = int(state["coins"]) + 25
		state["affection"] = _clamp_need(float(state["affection"]) + 4.0)
		_show_toast("今日计划全部完成：+25 硬币，亲密度也提高了。", 4.2)


func _idle_thought() -> String:
	var thoughts := [
		"外面还在下雨。",
		"今天要不要早点睡呢？",
		"房间好像又有一点乱了。",
		"你在的话，屋里会热闹一点。",
		"猫已经睡着了，我还没有。",
	]
	return str(thoughts[randi() % thoughts.size()])


func _refresh_ui() -> void:
	if not is_instance_valid(clock_label):
		return
	var minute := int(state["minute"])
	var hour := minute / 60
	var minute_part := minute % 60
	clock_label.text = "第 %d 天   %02d:%02d   ·   下雨" % [int(state["day"]), hour, minute_part]
	coin_label.text = "硬币 %d" % int(state["coins"])

	for key in stat_bars.keys():
		var value := float(state.get(key, 0.0))
		(stat_bars[key] as ProgressBar).value = value
		(stat_labels[key] as Label).text = str(int(round(value)))

	if current_action == "idle":
		status_label.text = "小满在自己安排时间。\n需求低了，她会主动照顾自己。"
	else:
		var who := "你安排的" if action_was_player_requested else "她自己决定"
		status_label.text = "%s：%s\n%s" % [who, str(ACTION_DATA[current_action]["name"]), str(ACTION_DATA[current_action]["thought"])]

	daily_label.text = "%s 吃一顿饭\n%s 和小满聊聊天\n%s 好好休息一次" % [
		"[完成]" if bool(daily["eat"]) else "[  ]",
		"[完成]" if bool(daily["chat"]) else "[  ]",
		"[完成]" if bool(daily["sleep"]) else "[  ]",
	]


func _save_game() -> void:
	var document := {
		"version": 1,
		"saved_unix": int(Time.get_unix_time_from_system()),
		"state": state,
		"daily": daily,
		"resident_position": [resident_root.position.x, resident_root.position.y] if is_instance_valid(resident_root) else [620, 430],
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(document))
	file.close()


func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var document: Dictionary = parsed
	var saved_state = document.get("state", {})
	if typeof(saved_state) == TYPE_DICTIONARY:
		state.merge(saved_state, true)
	var saved_daily = document.get("daily", {})
	if typeof(saved_daily) == TYPE_DICTIONARY:
		daily.merge(saved_daily, true)
	var saved_pos = document.get("resident_position", [])
	if typeof(saved_pos) == TYPE_ARRAY and saved_pos.size() >= 2:
		resident_root.position = Vector2(float(saved_pos[0]), float(saved_pos[1]))

	var last_saved := int(document.get("saved_unix", int(Time.get_unix_time_from_system())))
	var elapsed := maxi(0, int(Time.get_unix_time_from_system()) - last_saved)
	_apply_offline_progress(elapsed)


func _apply_offline_progress(elapsed_seconds: int) -> void:
	if elapsed_seconds < 90:
		return
	var capped := mini(elapsed_seconds, 12 * 60 * 60)
	var hours := float(capped) / 3600.0
	state["fullness"] = _clamp_need(float(state["fullness"]) - 3.5 * hours)
	state["energy"] = _clamp_need(float(state["energy"]) - 2.5 * hours)
	state["hygiene"] = _clamp_need(float(state["hygiene"]) - 1.8 * hours)
	state["fun"] = _clamp_need(float(state["fun"]) - 2.0 * hours)
	var notes: Array[String] = []
	if float(state["energy"]) < 24.0:
		state["energy"] = _clamp_need(float(state["energy"]) + 40.0)
		notes.append("睡了一觉")
	if float(state["fullness"]) < 24.0:
		state["fullness"] = _clamp_need(float(state["fullness"]) + 32.0)
		state["coins"] = maxi(0, int(state["coins"]) - 8)
		notes.append("自己买了点吃的")
	if notes.is_empty():
		notes.append("在房间里安静地待了一阵")
	var shown_hours := maxf(0.1, hours)
	offline_note = "你离开了 %.1f 小时。小满%s。" % [shown_hours, "，还".join(notes)]


func _open_legacy_city() -> void:
	_save_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _show_toast(text: String, duration: float = 3.0) -> void:
	if not is_instance_valid(toast_label):
		offline_note = text
		return
	toast_label.text = "  " + text
	toast_label.visible = true
	toast_timer = duration


func _clamp_need(value: float) -> float:
	return clampf(value, 0.0, 100.0)


func _panel_style(bg: Color, radius: int, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border_color
	style.shadow_color = Color(0, 0, 0, 0.14)
	style.shadow_size = 8
	return style


func _button_style(bg: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.10)
	return style


func _draw() -> void:
	# 夜雨出租屋：先用清爽的程序化 2.5D 房间作为可玩底座，正式美术随后按相同锚点替换。
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("#171923"))
	# 后墙
	draw_rect(Rect2(54, 36, 1172, 330), Color("#463e46"))
	draw_rect(Rect2(54, 280, 1172, 92), Color("#6d554a"))
	# 木地板透视面
	draw_colored_polygon(PackedVector2Array([
		Vector2(54, 340), Vector2(1226, 340), Vector2(1180, 660), Vector2(98, 660)
	]), Color("#9a6a4e"))
	for y in range(372, 650, 36):
		draw_line(Vector2(84, y), Vector2(1196, y), Color(0.22, 0.13, 0.10, 0.18), 1.0)
	for x in range(120, 1180, 92):
		draw_line(Vector2(x, 346), Vector2(x - 24, 654), Color(0.22, 0.13, 0.10, 0.12), 1.0)

	# 雨夜窗户
	draw_rect(Rect2(742, 62, 366, 212), Color("#101827"))
	draw_rect(Rect2(750, 70, 350, 196), Color("#17243b"))
	for bx in range(770, 1090, 52):
		var h := 54 + ((bx / 13) % 4) * 17
		draw_rect(Rect2(bx, 258 - h, 36, h), Color("#20283a"))
		for wy in range(int(264 - h), 250, 18):
			if ((bx + wy) / 9) as int % 3 != 0:
				draw_rect(Rect2(bx + 8, wy, 5, 8), Color("#d9ad63"))
	for rx in range(760, 1096, 22):
		var ry := 82 + (rx * 7) % 150
		draw_line(Vector2(rx, ry), Vector2(rx - 7, ry + 20), Color(0.55, 0.72, 0.94, 0.34), 1.0)
	draw_line(Vector2(925, 70), Vector2(925, 266), Color("#403a43"), 6.0)

	# 衣柜和收纳
	draw_rect(Rect2(430, 116, 170, 214), Color("#8a6a55"))
	draw_rect(Rect2(440, 126, 72, 194), Color("#aa8063"))
	draw_rect(Rect2(518, 126, 72, 194), Color("#9b735b"))
	draw_circle(Vector2(507, 222), 3.0, Color("#d8bd8a"))
	draw_circle(Vector2(523, 222), 3.0, Color("#d8bd8a"))

	# 厨房 / 冰箱
	draw_rect(Rect2(104, 258, 118, 212), Color("#718071"))
	draw_rect(Rect2(112, 270, 102, 90), Color("#84927f"))
	draw_line(Vector2(112, 365), Vector2(214, 365), Color(0.2, 0.2, 0.18, 0.3), 2.0)
	draw_circle(Vector2(203, 338), 3, Color("#d9d1b4"))
	draw_rect(Rect2(56, 392, 188, 56), Color("#684b3f"))
	draw_colored_polygon(PackedVector2Array([Vector2(56, 392), Vector2(232, 380), Vector2(266, 402), Vector2(86, 416)]), Color("#b58663"))
	draw_circle(Vector2(170, 386), 20, Color("#3d3430"))
	draw_circle(Vector2(170, 386), 15, Color("#c77b4d"))

	# 床：底座、床垫、被子、枕头。前景被子在独立 Polygon2D 中。
	draw_colored_polygon(PackedVector2Array([Vector2(264, 374), Vector2(430, 352), Vector2(514, 417), Vector2(326, 450)]), Color("#775343"))
	draw_colored_polygon(PackedVector2Array([Vector2(276, 350), Vector2(432, 332), Vector2(502, 390), Vector2(316, 420)]), Color("#e7d9c7"))
	draw_colored_polygon(PackedVector2Array([Vector2(320, 361), Vector2(430, 348), Vector2(493, 395), Vector2(365, 416)]), Color("#78947b"))
	draw_colored_polygon(PackedVector2Array([Vector2(286, 347), Vector2(335, 341), Vector2(356, 357), Vector2(304, 366)]), Color("#f5eee1"))

	# 电脑桌
	draw_colored_polygon(PackedVector2Array([Vector2(900, 394), Vector2(1078, 376), Vector2(1132, 414), Vector2(938, 438)]), Color("#b78662"))
	draw_rect(Rect2(936, 430, 10, 116), Color("#6d4d41"))
	draw_rect(Rect2(1108, 416, 10, 118), Color("#6d4d41"))
	draw_rect(Rect2(978, 330, 116, 68), Color("#27282e"))
	draw_rect(Rect2(986, 338, 100, 52), Color("#86b8c2"))
	draw_rect(Rect2(1030, 398, 10, 18), Color("#323238"))
	draw_rect(Rect2(974, 420, 90, 12), Color("#4a3d39"))

	# 浴室玻璃角落
	draw_rect(Rect2(62, 474, 188, 156), Color(0.55, 0.77, 0.84, 0.13))
	draw_line(Vector2(62, 474), Vector2(62, 630), Color(0.67, 0.86, 0.92, 0.58), 3)
	draw_line(Vector2(250, 474), Vector2(250, 630), Color(0.67, 0.86, 0.92, 0.58), 3)
	draw_line(Vector2(62, 474), Vector2(250, 474), Color(0.67, 0.86, 0.92, 0.58), 3)
	draw_rect(Rect2(120, 560, 74, 44), Color("#ece8dc"))
	draw_rect(Rect2(136, 548, 42, 15), Color("#f5f2ea"))

	# 沙发 / 豆袋和茶几
	_draw_ellipse(Vector2(650, 542), 94, 56, Color("#a46652"))
	_draw_ellipse(Vector2(654, 528), 72, 34, Color("#bf7c61"))
	draw_colored_polygon(PackedVector2Array([Vector2(744, 526), Vector2(866, 512), Vector2(902, 538), Vector2(775, 554)]), Color("#8b6048"))
	draw_rect(Rect2(784, 548, 8, 54), Color("#674637"))
	draw_rect(Rect2(875, 538, 8, 56), Color("#674637"))

	# 植物和暖灯，增加生活密度。
	for p in [Vector2(394, 288), Vector2(630, 305), Vector2(1118, 302), Vector2(744, 594)]:
		draw_rect(Rect2(p.x - 9, p.y, 18, 20), Color("#765044"))
		draw_circle(p + Vector2(-7, -4), 12, Color("#445f42"))
		draw_circle(p + Vector2(8, -7), 13, Color("#52734e"))
		draw_circle(p + Vector2(0, -16), 12, Color("#62845a"))
	draw_circle(Vector2(625, 286), 22, Color(1.0, 0.72, 0.38, 0.08))
	draw_circle(Vector2(625, 286), 9, Color("#f1be78"))

	# 人物脚下阴影，随位置移动，增强“站在房间里”的嵌入感。
	if is_instance_valid(resident_root):
		_draw_ellipse(resident_root.position + Vector2(0, 4), 25, 8, Color(0.06, 0.04, 0.05, 0.24))


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)
