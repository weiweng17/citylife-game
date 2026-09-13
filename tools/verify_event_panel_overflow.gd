extends SceneTree
## UI-FIX-004 narrow EventUI overflow/layout contract check.
## Prepared for Godot 4.7.2 headless execution; not executed by the web worker.

const EventUIScript = preload("res://scripts/ui/EventUI.gd")
const DEFAULT_VIEWPORT := Vector2i(1280, 720)
const NARROW_VIEWPORT := Vector2i(960, 540)
const EXPECTED_OPTIONS := 8

var ui
var phase := 0
var frames := 0
var failures: Array[String] = []


func _init() -> void:
	_set_logical_viewport(DEFAULT_VIEWPORT)
	ui = EventUIScript.new()
	get_root().add_child(ui)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 4:
		return false

	match phase:
		0:
			_show_long_event()
			phase = 1
			frames = 0
			return false
		1:
			_check_event_layout("1280x720", DEFAULT_VIEWPORT)
			_set_logical_viewport(NARROW_VIEWPORT)
			ui._sync_viewport()
			phase = 2
			frames = 0
			return false
		2:
			_check_event_layout("960x540", NARROW_VIEWPORT)
			ui.show_result(_long_result())
			phase = 3
			frames = 0
			return false
		3:
			_check_result_layout("960x540 result", NARROW_VIEWPORT)
			_finish()
			return true

	return false


func _show_long_event() -> void:
	var options: Array = []
	for index in range(EXPECTED_OPTIONS):
		options.append({
			"index": index,
			"enabled": true,
			"text": "选项 %d：这是一个故意写得很长的事件选择，用来验证按钮文字换行后仍由滚动区承接，而不是把面板底部裁掉。" % (index + 1),
		})

	ui.show_event(
		"响应式事件面板压力测试",
		_long_body(),
		options,
		null
	)


func _long_body() -> String:
	return (
		"这是一段故意拉长的事件正文，用来验证叙事内容增长时 EventUI 不会依赖外层裁剪隐藏后续操作。\n"
		+ "正文会重复多段，让 ScrollContainer 必须真正拥有垂直 overflow。玩家仍应能看到标题，并通过滚动访问所有选择。\n"
		+ "第二段继续增加内容高度，同时保持事件数据和结算逻辑完全不参与本测试。\n"
		+ "第三段用于覆盖较窄、较矮的桌面/Web 逻辑视口。布局应该缩短面板并保留滚动路径。\n"
		+ "第四段再次增加高度，确保测试不是仅靠 100px 的正文最小高度触发。\n"
		+ "第五段结束。下方还有八个长选项，它们都必须保留在 EventOptions 中。"
	)


func _long_result() -> String:
	return (
		"这是一个故意拉长的事件结果。结果正文可以超过可视区域，但继续按钮不能被正文推到面板之外。\n"
		+ "结果内容继续增长，以验证正文仍在滚动区内，而 ContinueButton 保持为 EventContent 的固定底部动作。\n"
		+ "再增加一段结果说明，让较矮逻辑视口下也需要滚动。\n"
		+ "第四段结果说明。\n第五段结果说明。\n第六段结果说明。\n第七段结果说明。\n第八段结果说明。"
	)


func _check_event_layout(label: String, expected_viewport: Vector2i) -> void:
	_check_logical_viewport(label, expected_viewport)

	var panel: PanelContainer = ui.get_node("EventPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("EventContent") as VBoxContainer
	var scroll: ScrollContainer = content.get_node("EventScroll") as ScrollContainer
	var scroll_content: VBoxContainer = scroll.get_node("EventScrollContent") as VBoxContainer
	var options: VBoxContainer = scroll_content.get_node("EventOptions") as VBoxContainer
	var continue_button: Button = content.get_node("ContinueButton") as Button

	_expect(_rect_inside_viewport(panel.get_global_rect(), expected_viewport), "%s: EventPanel must stay inside the logical viewport" % label)
	_expect(panel.size.y <= 340.5, "%s: EventPanel must stay within its bounded maximum height" % label)
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "%s: dynamic event content must own an automatic vertical scroll path" % label)
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s: event content must not depend on horizontal scrolling" % label)
	_expect(scroll.follow_focus, "%s: focused option buttons must be allowed to scroll into view" % label)
	_expect(options.get_child_count() == EXPECTED_OPTIONS, "%s: all event choices must remain present in the scroll content" % label)
	_expect(not continue_button.visible, "%s: continue action must remain hidden during choice presentation" % label)
	_expect(scroll_content.get_combined_minimum_size().y > scroll.size.y + 0.5, "%s: stress content must exceed the bounded scroll viewport" % label)
	var vbar := scroll.get_v_scroll_bar()
	_expect(vbar.max_value > vbar.page + 0.5, "%s: stress content must expose a usable vertical scroll range" % label)

	var scroll_rect := scroll.get_global_rect()
	for index in range(options.get_child_count()):
		var button: Button = options.get_child(index) as Button
		_expect(button != null, "%s: option %d must remain a Button" % [label, index])
		if button == null:
			continue
		_expect(not button.disabled, "%s: stress option %d must remain enabled" % [label, index])
		_expect(button.autowrap_mode != TextServer.AUTOWRAP_OFF, "%s: option %d must wrap rather than force panel width growth" % [label, index])
		_expect(button.tooltip_text == button.text, "%s: option %d must preserve its full text in the tooltip" % [label, index])
		var button_rect := button.get_global_rect()
		_expect(
			button_rect.position.x >= scroll_rect.position.x - 0.5
			and button_rect.end.x <= scroll_rect.end.x + 0.5,
			"%s: option %d must remain horizontally contained by EventScroll" % [label, index]
		)

	print("[%s] viewport=%s panel=%s scroll=%s content_min=%s vbar(max=%s page=%s)" % [
		label,
		ui.get_viewport().get_visible_rect().size,
		panel.get_global_rect(),
		scroll.get_global_rect(),
		scroll_content.get_combined_minimum_size(),
		vbar.max_value,
		vbar.page,
	])


func _check_result_layout(label: String, expected_viewport: Vector2i) -> void:
	_check_logical_viewport(label, expected_viewport)

	var panel: PanelContainer = ui.get_node("EventPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("EventContent") as VBoxContainer
	var scroll: ScrollContainer = content.get_node("EventScroll") as ScrollContainer
	var scroll_content: VBoxContainer = scroll.get_node("EventScrollContent") as VBoxContainer
	var options: VBoxContainer = scroll_content.get_node("EventOptions") as VBoxContainer
	var continue_button: Button = content.get_node("ContinueButton") as Button

	_expect(_rect_inside_viewport(panel.get_global_rect(), expected_viewport), "%s: result EventPanel must stay inside the logical viewport" % label)
	_expect(options.get_child_count() == 0, "%s: result view must remove choice buttons immediately from layout" % label)
	_expect(continue_button.visible, "%s: result continue action must be visible" % label)
	_expect(continue_button.get_parent() == content, "%s: ContinueButton must remain outside EventScroll" % label)
	_expect(_rect_inside_rect(continue_button.get_global_rect(), panel.get_global_rect()), "%s: ContinueButton must stay reachable inside EventPanel" % label)
	_expect(scroll_content.get_combined_minimum_size().y > scroll.size.y + 0.5, "%s: long result copy must overflow through EventScroll rather than push ContinueButton out" % label)

	print("[%s] panel=%s scroll=%s continue=%s" % [
		label,
		panel.get_global_rect(),
		scroll.get_global_rect(),
		continue_button.get_global_rect(),
	])


func _check_logical_viewport(label: String, expected: Vector2i) -> void:
	var actual := ui.get_viewport().get_visible_rect().size
	_expect(
		is_equal_approx(actual.x, float(expected.x)) and is_equal_approx(actual.y, float(expected.y)),
		"%s: logical viewport must actually be %dx%d, got %s" % [label, expected.x, expected.y, actual]
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


func _finish() -> void:
	if failures.is_empty():
		print("[PASS] EventUI overflow/layout contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
