extends SceneTree
## UI-FIX-005 narrow StartUI overflow/lifecycle contract check.
## Prepared for Godot 4.7.2 headless execution; not executed by the web worker.

const StartUIScript = preload("res://scripts/ui/StartUI.gd")
const DEFAULT_VIEWPORT := Vector2i(1280, 720)
const NARROW_VIEWPORT := Vector2i(960, 540)
const EXPECTED_ORIGINS := 4

var ui
var origins: Array = []
var phase := 0
var frames := 0
var failures: Array[String] = []
var pre_tree_setup_ok := false
var origin_signal_count := 0
var emitted_origin: Dictionary = {}
var load_signal_count := 0


func _init() -> void:
	_set_logical_viewport(DEFAULT_VIEWPORT)
	origins = _stress_origins()
	ui = StartUIScript.new()

	# Match the real Game.gd lifecycle: setup() happens before add_child().
	ui.setup(origins, Callable(self, "_format_money"))
	pre_tree_setup_ok = (
		ui.get_node_or_null("StartScroll/StartContent/OriginCard0") != null
		and ui.get_node_or_null("StartScroll/StartContent/LoadButton") != null
	)
	# Mutate after setup so the signal check also catches an implementation that copied
	# the dictionary instead of forwarding the supplied origin object.
	var last_origin: Dictionary = origins[EXPECTED_ORIGINS - 1]
	last_origin["post_setup_marker"] = "same supplied origin"
	ui.origin_selected.connect(_on_origin_selected)
	ui.load_requested.connect(_on_load_requested)
	get_root().add_child(ui)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 4:
		return false

	match phase:
		0:
			_expect(pre_tree_setup_ok, "setup() must build the StartUI hierarchy before add_child()")
			ui.open()
			ui.set_load_available(false)
			phase = 1
			frames = 0
			return false
		1:
			_check_default_layout()
			ui.close()
			_expect(not ui.visible, "close() must keep hiding StartUI")
			ui.open()
			_expect(ui.visible, "open() must keep showing StartUI")
			ui.set_load_available(true)
			_set_logical_viewport(NARROW_VIEWPORT)
			ui._sync_viewport()
			phase = 2
			frames = 0
			return false
		2:
			_check_narrow_layout()
			_scroll_to_bottom()
			phase = 3
			frames = 0
			return false
		3:
			_check_bottom_reachability()
			_trigger_signals()
			phase = 4
			frames = 0
			return false
		4:
			_check_signal_contract()
			ui.close()
			ui.open()
			phase = 5
			frames = 0
			return false
		5:
			_check_reopen_reset()
			_finish()
			return true

	return false


func _stress_origins() -> Array:
	var result: Array = []
	for index in range(EXPECTED_ORIGINS):
		result.append({
			"id": "stress_%d" % index,
			"name": "压力测试出身 %d" % (index + 1),
			"desc": (
				"这是一段故意拉长的出身说明，用来验证较窄逻辑视口下文字换行后，卡片高度增长仍由 StartScroll 承接。"
				+ "内容继续增加，确保四张卡叠加后会形成真实的纵向 overflow，而不是依赖外层面板把后续内容裁掉。"
				+ "第三段继续增加高度，同时不改变出身字典的结构。"
				+ "第四段用于覆盖中文字体换行产生的额外高度。"
				+ "第五段确保测试内容足够超过 960×540 可视区域。"
			),
			"init": {
				"money": 2000 + index * 1000,
				"health": 80 - index,
				"mood": 60 + index,
				"skill": 40 + index,
				"network": 10 + index,
			},
			"bonus": (
				"这是故意写长的 bonus 文案，用来让初始属性行在窄宽度下换行，并验证卡片不会通过横向增长逃出滚动区域。"
				+ "附加说明继续增加换行压力。"
			),
		})
	return result


func _format_money(value: int) -> String:
	return "%d 元" % value


func _check_default_layout() -> void:
	_check_logical_viewport("1280x720", DEFAULT_VIEWPORT)
	var scroll: ScrollContainer = ui.get_node("StartScroll") as ScrollContainer
	var content: VBoxContainer = scroll.get_node("StartContent") as VBoxContainer
	var load_button: Button = content.get_node("LoadButton") as Button

	_expect(_rect_inside_viewport(ui.get_global_rect(), DEFAULT_VIEWPORT), "1280x720: StartUI must stay inside the logical viewport")
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "1280x720: StartScroll must own automatic vertical overflow")
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "1280x720: StartUI must not depend on horizontal scrolling")
	_expect(scroll.follow_focus, "1280x720: focused reachable controls should be allowed to scroll into view")
	_expect(_origin_card_count(content) == EXPECTED_ORIGINS, "1280x720: all four supplied origin cards must remain present")
	_expect(not load_button.visible, "1280x720: post-ready set_load_available(false) must hide the load button")
	_check_horizontal_containment("1280x720", scroll, content)


func _check_narrow_layout() -> void:
	_check_logical_viewport("960x540", NARROW_VIEWPORT)
	var scroll: ScrollContainer = ui.get_node("StartScroll") as ScrollContainer
	var content: VBoxContainer = scroll.get_node("StartContent") as VBoxContainer
	var load_button: Button = content.get_node("LoadButton") as Button

	_expect(_rect_inside_viewport(ui.get_global_rect(), NARROW_VIEWPORT), "960x540: StartUI must stay inside the logical viewport")
	_expect(_rect_inside_rect(scroll.get_global_rect(), ui.get_global_rect()), "960x540: StartScroll must stay inside StartUI")
	_expect(_origin_card_count(content) == EXPECTED_ORIGINS, "960x540: all four origin cards must remain present")
	_expect(load_button.visible, "960x540: post-ready set_load_available(true) must reveal the load button")
	_expect(content.get_combined_minimum_size().y > scroll.size.y + 0.5, "960x540: stress content must exceed the bounded scroll viewport")
	var vbar := scroll.get_v_scroll_bar()
	_expect(vbar.max_value > vbar.page + 0.5, "960x540: stress content must expose a usable vertical scroll range")
	_check_horizontal_containment("960x540", scroll, content)

	print("[960x540] root=%s scroll=%s content_min=%s vbar(max=%s page=%s)" % [
		ui.get_global_rect(),
		scroll.get_global_rect(),
		content.get_combined_minimum_size(),
		vbar.max_value,
		vbar.page,
	])


func _scroll_to_bottom() -> void:
	var scroll: ScrollContainer = ui.get_node("StartScroll") as ScrollContainer
	var vbar := scroll.get_v_scroll_bar()
	# Values beyond the legal end are clamped by ScrollContainer to its usable maximum.
	scroll.scroll_vertical = int(ceil(vbar.max_value))


func _check_bottom_reachability() -> void:
	var scroll: ScrollContainer = ui.get_node("StartScroll") as ScrollContainer
	var content: VBoxContainer = scroll.get_node("StartContent") as VBoxContainer
	var last_card: Control = content.get_node("OriginCard%d" % (EXPECTED_ORIGINS - 1)) as Control
	var load_button: Button = content.get_node("LoadButton") as Button
	var scroll_rect := scroll.get_global_rect()

	_expect(scroll.scroll_vertical > 0, "960x540 bottom: StartScroll must support a non-zero scroll offset")
	_expect(_rect_inside_rect(last_card.get_global_rect(), scroll_rect), "960x540 bottom: the fourth origin card must become fully visible")
	_expect(_rect_inside_rect(load_button.get_global_rect(), scroll_rect), "960x540 bottom: the enabled load button must become fully visible")
	print("[960x540 bottom] scroll_vertical=%s scroll=%s card=%s load=%s" % [
		scroll.scroll_vertical,
		scroll_rect,
		last_card.get_global_rect(),
		load_button.get_global_rect(),
	])


func _trigger_signals() -> void:
	var content: VBoxContainer = ui.get_node("StartScroll/StartContent") as VBoxContainer
	var last_card: Control = content.get_node("OriginCard%d" % (EXPECTED_ORIGINS - 1)) as Control
	var hit: Button = last_card.get_node("OriginHit") as Button
	var load_button: Button = content.get_node("LoadButton") as Button
	hit.pressed.emit()
	load_button.pressed.emit()


func _check_signal_contract() -> void:
	_expect(origin_signal_count == 1, "origin_selected must emit exactly once for one origin activation")
	_expect(emitted_origin == origins[EXPECTED_ORIGINS - 1], "origin_selected must forward the supplied origin dictionary")
	_expect(str(emitted_origin.get("post_setup_marker", "")) == "same supplied origin", "origin_selected must preserve post-setup mutations on the supplied origin dictionary")
	_expect(load_signal_count == 1, "load_requested must emit exactly once for one load activation")


func _check_reopen_reset() -> void:
	var scroll: ScrollContainer = ui.get_node("StartScroll") as ScrollContainer
	_expect(ui.visible, "reopened StartUI must remain visible")
	_expect(scroll.scroll_vertical == 0, "reopening StartUI must reset the previous run's scroll position to the top")


func _check_horizontal_containment(label: String, scroll: ScrollContainer, content: VBoxContainer) -> void:
	var scroll_rect := scroll.get_global_rect()
	for index in range(EXPECTED_ORIGINS):
		var card: Control = content.get_node("OriginCard%d" % index) as Control
		var card_rect := card.get_global_rect()
		_expect(
			card_rect.position.x >= scroll_rect.position.x - 0.5
			and card_rect.end.x <= scroll_rect.end.x + 0.5,
			"%s: origin card %d must remain horizontally contained by StartScroll" % [label, index]
		)


func _origin_card_count(content: VBoxContainer) -> int:
	var count := 0
	for index in range(EXPECTED_ORIGINS):
		if content.get_node_or_null("OriginCard%d" % index) != null:
			count += 1
	return count


func _on_origin_selected(origin: Dictionary) -> void:
	origin_signal_count += 1
	emitted_origin = origin


func _on_load_requested() -> void:
	load_signal_count += 1


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
		print("[PASS] StartUI overflow/lifecycle contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
