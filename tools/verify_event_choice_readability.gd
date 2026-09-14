extends SceneTree
## UI-CONTENT-008 narrow EventUI choice/readability contract check.
## Prepared for Godot 4.7.2 headless execution; not executed by the web worker.

const EventUIScript = preload("res://scripts/ui/EventUI.gd")
const DEFAULT_VIEWPORT := Vector2i(1280, 720)
const NARROW_VIEWPORT := Vector2i(960, 540)
const CHOICE_INDICES := [3, 7, 11]
const EXPECTED_OPTIONS := 3

var ui
var phase := 0
var frames := 0
var failures: Array[String] = []
var selected_indices: Array[int] = []
var continue_signal_count := 0
var result_continue_rect := Rect2()


func _init() -> void:
	_set_logical_viewport(DEFAULT_VIEWPORT)
	ui = EventUIScript.new()
	ui.option_selected.connect(_on_option_selected)
	ui.continue_requested.connect(_on_continue_requested)
	get_root().add_child(ui)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 4:
		return false

	match phase:
		0:
			_show_pack_a_stress_event()
			phase = 1
			frames = 0
			return false
		1:
			_check_choice_layout("1280x720 choices", DEFAULT_VIEWPORT)
			_set_logical_viewport(NARROW_VIEWPORT)
			ui._sync_viewport()
			phase = 2
			frames = 0
			return false
		2:
			_check_choice_layout("960x540 choices", NARROW_VIEWPORT)
			_scroll_to_bottom()
			phase = 3
			frames = 0
			return false
		3:
			_check_last_choice_reachable("960x540 bottom")
			_press_last_choice()
			phase = 4
			frames = 0
			return false
		4:
			_expect(selected_indices.size() == 1, "one choice activation must emit option_selected exactly once")
			if selected_indices.size() == 1:
				_expect(selected_indices[0] == CHOICE_INDICES[2], "option_selected must preserve the supplied option index")
			ui.show_result(_long_result())
			phase = 5
			frames = 0
			return false
		5:
			_check_result_layout("960x540 result", NARROW_VIEWPORT)
			_scroll_to_bottom()
			phase = 6
			frames = 0
			return false
		6:
			_check_result_bottom("960x540 result bottom")
			_press_continue()
			phase = 7
			frames = 0
			return false
		7:
			_expect(continue_signal_count == 1, "one Continue activation must emit continue_requested exactly once")
			ui.close_event()
			_expect(not ui.is_busy(), "close_event() must leave EventUI busy=false")
			_expect(selected_indices.size() == 1, "close_event() must not fabricate option_selected")
			_expect(continue_signal_count == 1, "close_event() must not fabricate continue_requested")
			_finish()
			return true

	return false


func _show_pack_a_stress_event() -> void:
	var options: Array = []
	for index in range(EXPECTED_OPTIONS):
		options.append({
			"index": CHOICE_INDICES[index],
			"enabled": true,
			"text": _long_choice(index),
		})
	ui.show_event(
		"雨夜里的一件小事",
		_long_body(),
		options,
		null
	)


func _long_body() -> String:
	return (
		"雨越下越密，屋檐下的人都往里挪了一点。你本来只想停两分钟，却听见旁边的人提起一个和今天有关的小麻烦。"
		+ "这段正文故意比旧事件更长，用来模拟 Pack A 普通城市事件在增加生活细节、人物反应和选择语境后的阅读压力。"
		+ "正文可以继续增长，但标题、三个选择和后续结果流程都不能因为内容变长而消失。"
	)


func _long_choice(index: int) -> String:
	var lead := [
		"先留下来帮他把眼前的事情处理完，再把自己原本的安排往后挪一点",
		"只帮最关键的那一步，把时间和精力留给今天还必须完成的其他事情",
		"说明自己现在也有难处，礼貌拒绝，但把附近能解决问题的人和地方告诉他",
	][index]
	return (
		lead
		+ "。这个选项故意继续补充一段生活化说明，验证 Pack A 选择文字变长后按钮会自然换行、保持完整点击区域，而且不会和上下选项重叠。"
	)


func _long_result() -> String:
	return (
		"事情最后没有一个特别戏剧性的结尾。你们把能做的做完，雨声还是一样大。"
		+ "结果文字继续增加，用来验证选择结算后的叙述可以在中间滚动，而底部唯一的继续按钮不会被长结果推走。"
		+ "再多写几句生活细节：手机亮了一次，远处有车压过积水，屋檐边又滴下一串水。"
		+ "玩家可以读完这些文字，也可以明确找到继续推进事件的动作。"
	)


func _check_choice_layout(label: String, expected_viewport: Vector2i) -> void:
	_check_logical_viewport(label, expected_viewport)
	var panel: PanelContainer = ui.get_node("EventPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("EventContent") as VBoxContainer
	var header: Label = content.get_node("EventHeader") as Label
	var scroll: ScrollContainer = content.get_node("EventScroll") as ScrollContainer
	var scroll_content: VBoxContainer = scroll.get_node("EventScrollContent") as VBoxContainer
	var body: Label = scroll_content.get_node("EventBody") as Label
	var options: VBoxContainer = scroll_content.get_node("EventOptions") as VBoxContainer
	var continue_button: Button = content.get_node("ContinueButton") as Button
	var vbar := scroll.get_v_scroll_bar()

	_expect(ui.is_busy(), "%s: visible event must report busy=true" % label)
	_expect(_rect_inside_viewport(panel.get_global_rect(), expected_viewport), "%s: EventPanel must stay inside viewport" % label)
	_expect(panel.size.y <= 340.5, "%s: EventPanel must remain within bounded maximum height" % label)
	_expect(header.text == "雨夜里的一件小事", "%s: event title must be preserved" % label)
	_expect(header.get_global_rect().end.y <= scroll.get_global_rect().position.y + 0.5, "%s: title must remain outside/above EventScroll" % label)
	_expect(body.text == _long_body(), "%s: long body copy must be preserved exactly" % label)
	_expect(body.autowrap_mode != TextServer.AUTOWRAP_OFF, "%s: body copy must wrap" % label)
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "%s: long body/choices must have vertical overflow owner" % label)
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s: readability must not depend on horizontal scrolling" % label)
	_expect(scroll.follow_focus, "%s: focused choices should be scroll-reachable" % label)
	_expect(options.get_child_count() == EXPECTED_OPTIONS, "%s: all three Pack A choices must remain present" % label)
	_expect(not continue_button.visible, "%s: Continue must remain hidden during choice state" % label)
	_expect(scroll_content.get_combined_minimum_size().y > scroll.size.y + 0.5, "%s: stress content must exceed the bounded scroll viewport" % label)
	_expect(vbar.max_value > vbar.page + 0.5, "%s: stress content must expose a usable vertical scroll range" % label)
	_expect(scroll.scroll_vertical == 0, "%s: show/resize before reading must remain at top" % label)

	var scroll_rect := scroll.get_global_rect()
	var previous_bottom := -INF
	for option_index in range(EXPECTED_OPTIONS):
		var expected_index: int = CHOICE_INDICES[option_index]
		var button: Button = options.get_node("OptionButton%d" % expected_index) as Button
		_expect(button != null, "%s: option %d must remain a Button" % [label, option_index])
		if button == null:
			continue
		_expect(not button.disabled, "%s: stress option %d must remain operable" % [label, option_index])
		_expect(button.text == _long_choice(option_index), "%s: option %d must preserve full choice copy" % [label, option_index])
		_expect(button.autowrap_mode != TextServer.AUTOWRAP_OFF, "%s: option %d must wrap instead of clipping long copy" % [label, option_index])
		_expect(button.alignment == HORIZONTAL_ALIGNMENT_LEFT, "%s: option %d must remain left-aligned for multi-line scanning" % [label, option_index])
		_expect(button.tooltip_text == button.text, "%s: option %d tooltip must preserve full copy" % [label, option_index])
		_expect(button.size.y > 38.5, "%s: stress option %d must expand beyond one-line minimum height" % [label, option_index])
		var rect := button.get_global_rect()
		_expect(rect.position.x >= scroll_rect.position.x - 0.5 and rect.end.x <= scroll_rect.end.x + 0.5, "%s: option %d must stay horizontally inside EventScroll" % [label, option_index])
		var local_rect := Rect2(button.position, button.size)
		_expect(local_rect.position.y >= previous_bottom - 0.5, "%s: option %d must not overlap the previous wrapped choice" % [label, option_index])
		previous_bottom = local_rect.end.y

	print("[%s] panel=%s scroll=%s content_min=%s vbar(max=%s page=%s)" % [
		label,
		panel.get_global_rect(),
		scroll.get_global_rect(),
		scroll_content.get_combined_minimum_size(),
		vbar.max_value,
		vbar.page,
	])


func _scroll_to_bottom() -> void:
	var scroll: ScrollContainer = ui.get_node("EventPanel/EventContent/EventScroll") as ScrollContainer
	var vbar := scroll.get_v_scroll_bar()
	scroll.scroll_vertical = int(ceil(vbar.max_value))


func _check_last_choice_reachable(label: String) -> void:
	var scroll: ScrollContainer = ui.get_node("EventPanel/EventContent/EventScroll") as ScrollContainer
	var options: VBoxContainer = scroll.get_node("EventScrollContent/EventOptions") as VBoxContainer
	var button: Button = options.get_node("OptionButton%d" % CHOICE_INDICES[2]) as Button
	var vbar := scroll.get_v_scroll_bar()
	var usable_end := maxf(0.0, vbar.max_value - vbar.page)
	_expect(scroll.scroll_vertical > 0, "%s: overflow path must support non-zero scrolling" % label)
	_expect(absf(float(scroll.scroll_vertical) - usable_end) <= 2.0, "%s: choices must be scrollable to the usable bottom" % label)
	_expect(_rect_inside_rect(button.get_global_rect(), scroll.get_global_rect()), "%s: final wrapped choice must become fully visible/reachable" % label)


func _press_last_choice() -> void:
	var button: Button = ui.get_node("EventPanel/EventContent/EventScroll/EventScrollContent/EventOptions/OptionButton%d" % CHOICE_INDICES[2]) as Button
	if button != null:
		button.pressed.emit()


func _check_result_layout(label: String, expected_viewport: Vector2i) -> void:
	_check_logical_viewport(label, expected_viewport)
	var panel: PanelContainer = ui.get_node("EventPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("EventContent") as VBoxContainer
	var scroll: ScrollContainer = content.get_node("EventScroll") as ScrollContainer
	var scroll_content: VBoxContainer = scroll.get_node("EventScrollContent") as VBoxContainer
	var body: Label = scroll_content.get_node("EventBody") as Label
	var options: VBoxContainer = scroll_content.get_node("EventOptions") as VBoxContainer
	var continue_button: Button = content.get_node("ContinueButton") as Button
	var vbar := scroll.get_v_scroll_bar()

	_expect(ui.is_busy(), "%s: result presentation must keep EventUI busy=true" % label)
	_expect(_rect_inside_viewport(panel.get_global_rect(), expected_viewport), "%s: result panel must stay inside viewport" % label)
	_expect(options.get_child_count() == 0, "%s: old choices must leave layout immediately in result state" % label)
	_expect(body.text == _long_result(), "%s: result copy must be preserved" % label)
	_expect(continue_button.visible, "%s: Continue must be visible in result state" % label)
	_expect(continue_button.get_parent() == content, "%s: Continue must remain outside EventScroll" % label)
	_expect(_rect_inside_rect(continue_button.get_global_rect(), panel.get_global_rect()), "%s: Continue must remain reachable inside EventPanel" % label)
	_expect(scroll.scroll_vertical == 0, "%s: choice -> result rebuild must reset scroll to top" % label)
	_expect(scroll_content.get_combined_minimum_size().y > scroll.size.y + 0.5, "%s: long result must overflow through EventScroll" % label)
	_expect(vbar.max_value > vbar.page + 0.5, "%s: long result must expose a usable scroll range" % label)
	result_continue_rect = continue_button.get_global_rect()


func _check_result_bottom(label: String) -> void:
	var scroll: ScrollContainer = ui.get_node("EventPanel/EventContent/EventScroll") as ScrollContainer
	var continue_button: Button = ui.get_node("EventPanel/EventContent/ContinueButton") as Button
	_expect(scroll.scroll_vertical > 0, "%s: long result must support non-zero scrolling" % label)
	_expect(_rect_equal_approx(continue_button.get_global_rect(), result_continue_rect), "%s: scrolling result text must not move Continue" % label)
	_expect(ui.is_busy(), "%s: scrolling result must not change busy semantics" % label)


func _press_continue() -> void:
	var button: Button = ui.get_node("EventPanel/EventContent/ContinueButton") as Button
	if button != null and button.visible:
		button.pressed.emit()


func _on_option_selected(index: int) -> void:
	selected_indices.append(index)


func _on_continue_requested() -> void:
	continue_signal_count += 1


func _check_logical_viewport(label: String, expected: Vector2i) -> void:
	var actual := ui.get_viewport().get_visible_rect().size
	_expect(
		is_equal_approx(actual.x, float(expected.x)) and is_equal_approx(actual.y, float(expected.y)),
		"%s: logical viewport must be %dx%d, got %s" % [label, expected.x, expected.y, actual]
	)


func _set_logical_viewport(viewport_size: Vector2i) -> void:
	get_root().content_scale_size = viewport_size
	get_root().size = viewport_size


func _rect_inside_viewport(rect: Rect2, viewport_size: Vector2i) -> bool:
	return (
		rect.position.x >= -0.5
		and rect.position.y >= -0.5
		and rect.end.x <= float(viewport_size.x) + 0.5
		and rect.end.y <= float(viewport_size.y) + 0.5
	)


func _rect_inside_rect(inner: Rect2, outer: Rect2) -> bool:
	return (
		inner.position.x >= outer.position.x - 0.5
		and inner.position.y >= outer.position.y - 0.5
		and inner.end.x <= outer.end.x + 0.5
		and inner.end.y <= outer.end.y + 0.5
	)


func _rect_equal_approx(a: Rect2, b: Rect2) -> bool:
	return a.position.distance_to(b.position) <= 0.5 and a.size.distance_to(b.size) <= 0.5


func _finish() -> void:
	if failures.is_empty():
		print("[PASS] EventUI Pack A choice readability contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
