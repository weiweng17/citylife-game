extends PanelContainer
class_name GameHUD

signal save_requested
signal load_requested
signal quit_requested

## 《都市浮生》顶部 HUD。
## 只负责展示玩家状态，不直接修改游戏数据。

var age_label: Label
var money_label: Label
var time_label: Label
var weather_label: Label
var goal_label: Label
var health_bar: ProgressBar
var mood_bar: ProgressBar
var health_fill: StyleBoxFlat
var mood_fill: StyleBoxFlat


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	name = "HUD"
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_bottom = 96

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.10, 0.86)
	panel_style.set_content_margin_all(8)
	panel_style.set_corner_radius_all(10)
	add_theme_stylebox_override("panel", panel_style)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	var row1 := HBoxContainer.new()
	root.add_child(row1)

	age_label = Label.new()
	age_label.add_theme_font_size_override("font_size", 16)
	row1.add_child(age_label)

	time_label = Label.new()
	time_label.add_theme_font_size_override("font_size", 14)
	time_label.add_theme_color_override("font_color", Color(0.72, 0.82, 1.0))
	row1.add_child(time_label)

	weather_label = Label.new()
	weather_label.add_theme_font_size_override("font_size", 14)
	weather_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.92))
	row1.add_child(weather_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.add_child(spacer)

	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 16)
	money_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.36))
	row1.add_child(money_label)

	var save_btn := Button.new()
	save_btn.text = "保存"
	save_btn.tooltip_text = "保存进度"
	save_btn.custom_minimum_size = Vector2(70, 32)
	save_btn.pressed.connect(func(): save_requested.emit())
	row1.add_child(save_btn)

	var load_btn := Button.new()
	load_btn.text = "读取"
	load_btn.tooltip_text = "读取最近存档"
	load_btn.custom_minimum_size = Vector2(70, 32)
	load_btn.pressed.connect(func(): load_requested.emit())
	row1.add_child(load_btn)

	var quit_btn := Button.new()
	quit_btn.text = "退出"
	quit_btn.tooltip_text = "退出游戏"
	quit_btn.custom_minimum_size = Vector2(70, 32)
	quit_btn.pressed.connect(func(): quit_requested.emit())
	row1.add_child(quit_btn)

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	root.add_child(row2)

	var health_text := Label.new()
	health_text.text = "健康"
	health_text.add_theme_font_size_override("font_size", 12)
	row2.add_child(health_text)

	health_bar = _make_bar(Color(0.16, 0.20, 0.30), Color(0.40, 0.88, 0.50))
	health_fill = health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	row2.add_child(health_bar)

	var mood_text := Label.new()
	mood_text.text = "心情"
	mood_text.add_theme_font_size_override("font_size", 12)
	row2.add_child(mood_text)

	mood_bar = _make_bar(Color(0.16, 0.20, 0.30), Color(0.44, 0.70, 1.0))
	mood_fill = mood_bar.get_theme_stylebox("fill") as StyleBoxFlat
	row2.add_child(mood_bar)

	goal_label = Label.new()
	goal_label.add_theme_font_size_override("font_size", 12)
	goal_label.add_theme_color_override("font_color", Color(0.82, 0.85, 0.92))
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(goal_label)


func refresh(state, stage_name: String, stage_goal: String, dark_clue_total: int) -> void:
	if state == null:
		return

	var clue_txt := ""
	if state.clues.size() > 0:
		clue_txt = " · 碎片 %d/%d" % [state.clues.size(), dark_clue_total]

	var dark_txt := ""
	if bool(state.flags.get("dark_path_lucid", false)):
		dark_txt = " · 暗线·清醒"
	elif bool(state.flags.get("dark_path_mad", false)):
		dark_txt = " · 暗线·疯狂"
	elif bool(state.flags.get("dark_path_awakened", false)):
		dark_txt = " · 暗线·觉醒"
	elif bool(state.flags.get("dark_pursued", false)):
		dark_txt = " · 追查中"
	elif bool(state.flags.get("dark_letgo", false)):
		dark_txt = " · 已放下"

	age_label.text = "第 %d 岁 · %s" % [state.age, stage_name]
	money_label.text = _fmt_money(state.money)
	goal_label.text = "目标：%s%s%s" % [stage_goal, clue_txt, dark_txt]

	health_bar.value = state.health
	if health_fill:
		health_fill.bg_color = _health_color(state.health)

	mood_bar.value = state.mood
	if mood_fill:
		mood_fill.bg_color = _mood_color(state.mood)


func refresh_time(day: int, clock_text: String, period_name: String) -> void:
	if time_label:
		time_label.text = " · 第%d天 %s · %s" % [day, clock_text, period_name]


func refresh_weather(weather_name: String) -> void:
	if weather_label:
		weather_label.text = " · %s" % weather_name

func _make_bar(bg: Color, fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(120, 12)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = bg
	background_style.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill
	fill_style.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill_style)
	return bar


func _health_color(value: int) -> Color:
	if value <= 25:
		return Color(0.92, 0.32, 0.32)
	if value <= 55:
		return Color(0.96, 0.72, 0.30)
	return Color(0.40, 0.88, 0.50)


func _mood_color(value: int) -> Color:
	if value <= 25:
		return Color(0.58, 0.58, 0.68)
	if value <= 55:
		return Color(0.62, 0.74, 0.96)
	return Color(0.44, 0.70, 1.0)


func _fmt_money(value: int) -> String:
	if absi(value) >= 10000:
		return "%d 万" % int(value / 10000)
	return "%d 元" % value
