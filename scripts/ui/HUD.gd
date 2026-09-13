extends PanelContainer
class_name GameHUD

signal save_requested
signal load_requested
signal quit_requested
signal backpack_requested

## 《都市浮生》顶部 HUD。
## 只负责展示玩家状态，不直接修改游戏数据。

var age_label: Label
var money_label: Label
var time_label: Label
var weather_label: Label
var goal_label: Label
var daily_label: Label
var health_bar: ProgressBar
var mood_bar: ProgressBar
var fullness_bar: ProgressBar
var energy_bar: ProgressBar
var health_fill: StyleBoxFlat
var mood_fill: StyleBoxFlat
var fullness_fill: StyleBoxFlat
var energy_fill: StyleBoxFlat
var bag_btn: Button


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	name = "HUD"
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	get_viewport().size_changed.connect(_sync_viewport)
	_sync_viewport()

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.10, 0.86)
	panel_style.set_content_margin_all(8)
	panel_style.set_corner_radius_all(10)
	add_theme_stylebox_override("panel", panel_style)

	var root := VBoxContainer.new()
	root.name = "HUDContent"
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	var row1 := HBoxContainer.new()
	row1.name = "PrimaryRow"
	row1.add_theme_constant_override("separation", 10)
	root.add_child(row1)

	age_label = Label.new()
	age_label.custom_minimum_size = Vector2(180, 0)
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

	bag_btn = Button.new()
	bag_btn.text = "背包"
	bag_btn.tooltip_text = "看看身上带着什么"
	bag_btn.custom_minimum_size = Vector2(70, 32)
	bag_btn.pressed.connect(func(): backpack_requested.emit())
	row1.add_child(bag_btn)

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
	row2.name = "StatusRow"
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

	row2.add_child(_bar_label("饱食"))
	fullness_bar = _make_bar(Color(0.16, 0.20, 0.30), Color(0.96, 0.72, 0.36))
	fullness_fill = fullness_bar.get_theme_stylebox("fill") as StyleBoxFlat
	row2.add_child(fullness_bar)

	row2.add_child(_bar_label("精力"))
	energy_bar = _make_bar(Color(0.16, 0.20, 0.30), Color(0.62, 0.86, 0.72))
	energy_fill = energy_bar.get_theme_stylebox("fill") as StyleBoxFlat
	row2.add_child(energy_bar)

	daily_label = Label.new()
	daily_label.name = "DailyRow"
	daily_label.add_theme_font_size_override("font_size", 12)
	daily_label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.56))
	root.add_child(daily_label)

	goal_label = Label.new()
	goal_label.add_theme_font_size_override("font_size", 12)
	goal_label.add_theme_color_override("font_color", Color(0.82, 0.85, 0.92))
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(goal_label)


func _sync_viewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = Vector2(14.0, 10.0)
	size = Vector2(maxf(320.0, viewport_size.x - 28.0), 112.0)


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

	fullness_bar.value = state.fullness
	if fullness_fill:
		fullness_fill.bg_color = _need_color(state.fullness)
	energy_bar.value = state.energy
	if energy_fill:
		energy_fill.bg_color = _need_color(state.energy)


## 每日循环目标：与上方的人生阶段目标是两套系统，分开显示避免混淆。
func refresh_daily(text: String) -> void:
	if daily_label:
		daily_label.text = "今日：%s" % text


## 背包按钮上带件数，让玩家不用打开就知道身上有没有吃的。
func refresh_bag(total: int) -> void:
	if bag_btn == null:
		return
	var count: int = maxi(0, total)
	bag_btn.text = "背包" if count <= 0 else "背包 %d" % count


func refresh_time(day: int, clock_text: String, period_name: String) -> void:
	if time_label:
		time_label.text = " · 第%d天 %s · %s" % [day, clock_text, period_name]


func refresh_weather(weather_name: String) -> void:
	if weather_label:
		weather_label.text = " · %s" % weather_name

func _bar_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	return label

func _make_bar(bg: Color, fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(92, 12)
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


## 需求条：低了转橙，告急转红，让玩家一眼看出该吃还是该睡。
func _need_color(value: int) -> Color:
	if value <= 15:
		return Color(0.92, 0.34, 0.32)
	if value <= 35:
		return Color(0.96, 0.68, 0.30)
	return Color(0.62, 0.86, 0.72)


func _fmt_money(value: int) -> String:
	if absi(value) >= 10000:
		return "%d 万" % int(value / 10000)
	return "%d 元" % value
