extends SceneTree
## UI-FIX-007 narrow DialogUI overflow/lifecycle contract check.
## Prepared for Godot 4.7.2 headless execution; not executed by the web worker.

const DialogUIScript = preload("res://scripts/ui/DialogUI.gd")
const DEFAULT_VIEWPORT := Vector2i(1280, 720)
const NARROW_VIEWPORT := Vector2i(960, 540)

var ui
var phase := 0
var frames := 0
var failures: Array[String] = []
var finished_signal_count := 0
var speaker_rect_before_scroll := Rect2()
var next_rect_before_scroll := Rect2()


func _init() -> void:
	_set_logical_viewport(DEFAULT_VIEWPORT)
	ui = DialogUIScript.new()
	ui.dialog_finished.connect(_on_dialog_finished)
	get_root().add_child(ui)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 4:
		return false

	match phase:
		0:
			ui.show_dialog("旁白", ["这是一条普通长度的对话。", "第二条普通对话。"])
			phase = 1
			frames = 0
			return false
		1:
			_check_normal_layout()
			_press_next()
			phase = 2
			frames = 0
			return false
		2:
			_check_second_normal_line()
			_press_next()
			phase = 3
			frames = 0
			return false
		3:
			_expect(not ui.is_busy(), "completed normal dialogue must leave busy=false")
			_expect(finished_signal_count == 1, "one completed normal dialogue must emit dialog_finished exactly once")
			_set_logical_viewport(NARROW_VIEWPORT)
			ui._sync_viewport()
			ui.show_dialog("陈姐", [_stress_line(), "短收尾。"])
			phase = 4
			frames = 0
			return false
		4:
			_check_long_layout_before_scroll()
			_scroll_body_to_bottom()
			phase = 5
			frames = 0
			return false
		5:
			_check_long_layout_after_scroll()
			_press_next()
			phase = 6
			frames = 0
			return false
		6:
			_check_long_to_short_reset()
			# A programmatic close must preserve the public lifecycle contract: it hides
			# the dialog without pretending the queued dialogue completed.
			ui.close_dialog()
			_expect(not ui.is_busy(), "close_dialog() must leave busy=false")
			_expect(finished_signal_count == 1, "close_dialog() must not emit dialog_finished")
			ui.show_dialog("老张", [_stress_line()])
			phase = 7
			frames = 0
			return false
		7:
			_check_reopen_reset()
			_scroll_body_to_bottom()
			phase = 8
			frames = 0
			return false
		8:
			_expect(ui.is_busy(), "scrolling a long body must keep Game-facing busy semantics true")
			_press_next()
			phase = 9
			frames = 0
			return false
		9:
			_expect(not ui.is_busy(), "final activation must close the reopened dialogue")
			_expect(finished_signal_count == 2, "two completed dialogues must emit dialog_finished exactly once each")
			_finish()
			return true

	return false


func _check_normal_layout() -> void:
	_check_logical_viewport("1280x720 normal", DEFAULT_VIEWPORT)
	var content: VBoxContainer = ui.get_node("DialogContent") as VBoxContainer
	var speaker: Label = content.get_node("DialogSpeaker") as Label
	var scroll: ScrollContainer = content.get_node("DialogBodyScroll") as ScrollContainer
	var text: Label = scroll.get_node("DialogText") as Label
	var next_button: Button = content.get_node("DialogNext") as Button

	_expect(ui.is_busy(), "1280x720 normal: visible dialog must report busy=true")
	_expect(is_equal_approx(ui.size.y, 220.0), "1280x720 normal: existing 220px panel-height contract must remain")
	_expect(_rect_inside_viewport(ui.get_global_rect(), DEFAULT_VIEWPORT), "1280x720 normal: dialog panel must stay inside logical viewport")
	_expect(_rect_inside_rect(scroll.get_global_rect(), ui.get_global_rect()), "1280x720 normal: body scroll must stay inside dialog panel")
	_expect(_rect_inside_rect(next_button.get_global_rect(), ui.get_global_rect()), "1280x720 normal: continue action must stay inside dialog panel")
	_expect(speaker.text == "旁白", "1280x720 normal: speaker text must be preserved")
	_expect(text.text == "这是一条普通长度的对话。", "1280x720 normal: body text must be preserved")
	_expect(next_button.text == "继续", "1280x720 normal: non-final line button copy must remain 继续")
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "1280x720 normal: body must own automatic vertical overflow")
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "1280x720 normal: body must not depend on horizontal scrolling")
	_expect(scroll.follow_focus, "1280x720 normal: body scroll should keep focus-follow enabled")
	_expect(speaker.get_global_rect().end.y <= scroll.get_global_rect().position.y + 0.5, "1280x720 normal: speaker must remain above/outside body scroll")
	_expect(next_button.get_global_rect().position.y >= scroll.get_global_rect().end.y - 0.5, "1280x720 normal: continue action must remain below/outside body scroll")
	var vbar := scroll.get_v_scroll_bar()
	_expect(vbar.max_value <= vbar.page + 0.5, "1280x720 normal: ordinary short text should not expose needless vertical scrolling")
	_expect(finished_signal_count == 0, "intermediate normal line must not emit dialog_finished")


func _check_second_normal_line() -> void:
	var scroll: ScrollContainer = ui.get_node("DialogContent/DialogBodyScroll") as ScrollContainer
	var text: Label = scroll.get_node("DialogText") as Label
	var next_button: Button = ui.get_node("DialogContent/DialogNext") as Button
	_expect(ui.is_busy(), "second normal line must keep busy=true")
	_expect(text.text == "第二条普通对话。", "next activation must advance exactly one line")
	_expect(next_button.text == "结束", "final line button copy must remain 结束")
	_expect(scroll.scroll_vertical == 0, "advancing to a normal next line must start body at top")
	_expect(finished_signal_count == 0, "arriving at final line must not emit before final activation")


func _check_long_layout_before_scroll() -> void:
	_check_logical_viewport("960x540 long", NARROW_VIEWPORT)
	var content: VBoxContainer = ui.get_node("DialogContent") as VBoxContainer
	var speaker: Label = content.get_node("DialogSpeaker") as Label
	var scroll: ScrollContainer = content.get_node("DialogBodyScroll") as ScrollContainer
	var text: Label = scroll.get_node("DialogText") as Label
	var next_button: Button = content.get_node("DialogNext") as Button
	var vbar := scroll.get_v_scroll_bar()

	_expect(ui.is_busy(), "960x540 long: open dialogue must keep busy=true")
	_expect(is_equal_approx(ui.size.y, 220.0), "960x540 long: panel must keep the existing 220px height")
	_expect(_rect_inside_viewport(ui.get_global_rect(), NARROW_VIEWPORT), "960x540 long: dialog must stay inside logical viewport")
	_expect(_rect_inside_rect(scroll.get_global_rect(), ui.get_global_rect()), "960x540 long: body scroll must stay inside panel")
	_expect(_rect_inside_rect(next_button.get_global_rect(), ui.get_global_rect()), "960x540 long: continue action must stay reachable inside panel")
	_expect(speaker.text == "陈姐", "960x540 long: speaker must remain visible/preserved")
	_expect(text.text == _stress_line(), "960x540 long: long body text must be preserved without truncating source text")
	_expect(next_button.text == "继续", "960x540 long: first of two lines must still show 继续")
	_expect(text.get_combined_minimum_size().y > scroll.size.y + 0.5, "960x540 long: stress text must exceed bounded body viewport")
	_expect(vbar.max_value > vbar.page + 0.5, "960x540 long: stress text must expose a usable vertical scroll range")
	_expect(scroll.scroll_vertical == 0, "960x540 long: newly shown long line must start at top")
	_expect(speaker.get_global_rect().end.y <= scroll.get_global_rect().position.y + 0.5, "960x540 long: speaker must remain outside/above body scroll")
	_expect(next_button.get_global_rect().position.y >= scroll.get_global_rect().end.y - 0.5, "960x540 long: continue action must remain outside/below body scroll")
	_expect(finished_signal_count == 1, "opening another dialogue must not emit dialog_finished")

	speaker_rect_before_scroll = speaker.get_global_rect()
	next_rect_before_scroll = next_button.get_global_rect()
	print("[960x540 long] panel=%s scroll=%s text_min=%s vbar(max=%s page=%s)" % [
		ui.get_global_rect(),
		scroll.get_global_rect(),
		text.get_combined_minimum_size(),
		vbar.max_value,
		vbar.page,
	])


func _check_long_layout_after_scroll() -> void:
	var speaker: Label = ui.get_node("DialogContent/DialogSpeaker") as Label
	var scroll: ScrollContainer = ui.get_node("DialogContent/DialogBodyScroll") as ScrollContainer
	var next_button: Button = ui.get_node("DialogContent/DialogNext") as Button
	_expect(scroll.scroll_vertical > 0, "960x540 long bottom: body must support non-zero vertical scrolling")
	_expect(_rect_equal_approx(speaker.get_global_rect(), speaker_rect_before_scroll), "960x540 long bottom: scrolling body must not move speaker")
	_expect(_rect_equal_approx(next_button.get_global_rect(), next_rect_before_scroll), "960x540 long bottom: scrolling body must not move continue action")
	_expect(ui.is_busy(), "960x540 long bottom: scrolling must not alter busy=true")
	_expect(finished_signal_count == 1, "scrolling must not emit dialog_finished")


func _check_long_to_short_reset() -> void:
	var scroll: ScrollContainer = ui.get_node("DialogContent/DialogBodyScroll") as ScrollContainer
	var text: Label = scroll.get_node("DialogText") as Label
	var next_button: Button = ui.get_node("DialogContent/DialogNext") as Button
	_expect(ui.is_busy(), "long -> short next line must keep busy=true")
	_expect(text.text == "短收尾。", "long -> short must advance to the supplied second line")
	_expect(next_button.text == "结束", "long -> short final line must show 结束")
	_expect(scroll.scroll_vertical == 0, "long -> short line transition must reset body scroll to top")
	_expect(finished_signal_count == 1, "intermediate next activation must not emit dialog_finished")


func _check_reopen_reset() -> void:
	var scroll: ScrollContainer = ui.get_node("DialogContent/DialogBodyScroll") as ScrollContainer
	var text: Label = scroll.get_node("DialogText") as Label
	var next_button: Button = ui.get_node("DialogContent/DialogNext") as Button
	var vbar := scroll.get_v_scroll_bar()
	_expect(ui.is_busy(), "reopened dialogue must report busy=true")
	_expect(text.text == _stress_line(), "reopened dialogue must render supplied long body")
	_expect(next_button.text == "结束", "single-line reopened dialogue must show 结束")
	_expect(scroll.scroll_vertical == 0, "close/reopen must reset body scroll to top")
	_expect(vbar.max_value > vbar.page + 0.5, "reopened stress line must still have a real scroll range")
	_expect(finished_signal_count == 1, "reopen must not emit dialog_finished")


func _scroll_body_to_bottom() -> void:
	var scroll: ScrollContainer = ui.get_node("DialogContent/DialogBodyScroll") as ScrollContainer
	var vbar := scroll.get_v_scroll_bar()
	scroll.scroll_vertical = int(ceil(vbar.max_value))


func _press_next() -> void:
	var next_button: Button = ui.get_node("DialogContent/DialogNext") as Button
	next_button.pressed.emit()


func _stress_line() -> String:
	return (
		"这是一段故意拉长的对话正文，用来验证固定高度的底部对话框不会因为正文增长而把说话人或继续按钮顶出画面。"
		+ "内容继续延长，模拟未来城市事件、关系剧情、本地化文本或更大字体带来的换行压力。"
		+ "玩家应该只滚动中间正文，而不是滚动整个对话框；说话人仍然固定在上方，继续或结束按钮仍然固定在下方。"
		+ "这一段继续增加高度，确保在九百六十乘五百四十逻辑视口下能够形成真实的纵向 overflow。"
		+ "再补一段文字，防止测试只因为当前字体偶然较窄而没有产生滚动范围。"
		+ "最后继续重复阅读压力：城市生活事件会逐渐变长，但推进按钮必须始终可达，切换下一句时也必须回到正文顶部。"
	)


func _on_dialog_finished() -> void:
	finished_signal_count += 1


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


func _rect_equal_approx(a: Rect2, b: Rect2) -> bool:
	return (
		a.position.distance_to(b.position) <= 0.5
		and a.size.distance_to(b.size) <= 0.5
	)


func _finish() -> void:
	if failures.is_empty():
		print("[PASS] DialogUI body overflow/lifecycle contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
