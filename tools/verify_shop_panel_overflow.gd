extends SceneTree
## UI-FIX-006 narrow ShopUI overflow/rebuild contract check.
## Prepared for Godot 4.7.2 headless execution; not executed by the web worker.

const ShopUIScript = preload("res://scripts/ui/ShopUI.gd")
const InventoryScript = preload("res://scripts/systems/Inventory.gd")
const DEFAULT_VIEWPORT := Vector2i(1280, 720)
const NARROW_VIEWPORT := Vector2i(960, 540)


class InventoryStub:
	extends RefCounted

	var item_ids: Array = []
	var counts: Dictionary = {}

	func _init(ids: Array) -> void:
		item_ids = ids.duplicate()
		for raw_id in item_ids:
			counts[str(raw_id)] = 1

	func owned_items() -> Array:
		return item_ids.duplicate()

	func total_count() -> int:
		var total := 0
		for item_id in counts:
			total += int(counts[item_id])
		return total

	func count(item_id: String) -> int:
		return int(counts.get(item_id, 0))


var ui
var inventory
var empty_inventory
var phase := 0
var frames := 0
var failures: Array[String] = []
var buy_signal_count := 0
var buy_item_id := ""
var use_signal_count := 0
var use_item_id := ""
var closed_signal_count := 0
var narrow_overflow_seen := false


func _init() -> void:
	_set_logical_viewport(DEFAULT_VIEWPORT)
	inventory = InventoryStub.new(InventoryScript.DISPLAY_ORDER.duplicate())
	empty_inventory = InventoryStub.new([])
	ui = ShopUIScript.new()
	ui.buy_requested.connect(_on_buy_requested)
	ui.use_requested.connect(_on_use_requested)
	ui.closed.connect(_on_closed)
	get_root().add_child(ui)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 4:
		return false

	match phase:
		0:
			ui.open_buy(9999, inventory)
			phase = 1
			frames = 0
			return false
		1:
			_check_layout("1280x720 buy", DEFAULT_VIEWPORT, "buy")
			_set_logical_viewport(NARROW_VIEWPORT)
			ui._sync_viewport()
			phase = 2
			frames = 0
			return false
		2:
			_check_layout("960x540 buy", NARROW_VIEWPORT, "buy")
			_scroll_list_to_bottom()
			phase = 3
			frames = 0
			return false
		3:
			_check_last_row_reachable("960x540 buy")
			_trigger_last_action("buy")
			# Game refreshes the still-open ShopUI after a successful buy/use and only then
			# writes status text. Recreate that exact presentation call order.
			_scroll_list_to_bottom()
			ui.refresh(9998, inventory)
			ui.set_status("测试状态：refresh 后状态区仍应固定在列表滚动区之外。")
			phase = 4
			frames = 0
			return false
		4:
			_check_refresh_reset()
			_scroll_list_to_bottom()
			ui.open_bag(9998, inventory)
			phase = 5
			frames = 0
			return false
		5:
			_check_layout("960x540 bag", NARROW_VIEWPORT, "bag")
			_check_scroll_reset("buy -> full bag rebuild")
			_scroll_list_to_bottom()
			phase = 6
			frames = 0
			return false
		6:
			_check_last_row_reachable("960x540 bag")
			_trigger_last_action("bag")
			# Historical regression target: after a tall shelf/full bag, a sparse or empty bag
			# must not inherit the previous scroll range/height.
			_scroll_list_to_bottom()
			ui.open_bag(9998, empty_inventory)
			phase = 7
			frames = 0
			return false
		7:
			_check_empty_bag_layout()
			ui.open_buy(9998, inventory)
			phase = 8
			frames = 0
			return false
		8:
			_check_layout("960x540 buy reopen", NARROW_VIEWPORT, "buy")
			_check_scroll_reset("empty bag -> buy rebuild")
			_check_signal_contract()
			var close_button: Button = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopFooter/ShopClose") as Button
			close_button.pressed.emit()
			phase = 9
			frames = 0
			return false
		9:
			_expect(not ui.is_open(), "close button must keep closing ShopUI")
			_expect(closed_signal_count == 1, "closed must emit exactly once for one close activation")
			_expect(narrow_overflow_seen, "960x540 six-row catalog must exercise a real ShopList vertical overflow range")
			_finish()
			return true

	return false


func _check_layout(label: String, expected_viewport: Vector2i, expected_mode: String) -> void:
	_check_logical_viewport(label, expected_viewport)
	var panel: PanelContainer = ui.get_node("ShopCenter/ShopPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("ShopContent") as VBoxContainer
	var title: Label = content.get_node("ShopTitle") as Label
	var subtitle: Label = content.get_node("ShopSubtitle") as Label
	var scroll: ScrollContainer = content.get_node("ShopListScroll") as ScrollContainer
	var list: VBoxContainer = scroll.get_node("ShopList") as VBoxContainer
	var status: Label = content.get_node("ShopStatus") as Label
	var footer: HBoxContainer = content.get_node("ShopFooter") as HBoxContainer
	var close_button: Button = footer.get_node("ShopClose") as Button

	_expect(ui.is_open(), "%s: ShopUI must be open" % label)
	_expect(ui.mode == expected_mode, "%s: mode must remain %s" % [label, expected_mode])
	_expect(_rect_inside_viewport(ui.get_global_rect(), expected_viewport), "%s: ShopUI root must stay inside logical viewport" % label)
	_expect(_rect_inside_viewport(panel.get_global_rect(), expected_viewport), "%s: ShopPanel must stay vertically/horizontally inside logical viewport" % label)
	_expect(_rect_inside_rect(scroll.get_global_rect(), panel.get_global_rect()), "%s: ShopListScroll must stay inside ShopPanel" % label)
	_expect(_rect_inside_rect(status.get_global_rect(), panel.get_global_rect()), "%s: status must stay inside ShopPanel" % label)
	_expect(_rect_inside_rect(close_button.get_global_rect(), panel.get_global_rect()), "%s: close action must stay inside ShopPanel" % label)
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "%s: ShopListScroll must own automatic vertical overflow" % label)
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s: ShopListScroll must not depend on horizontal scrolling" % label)
	_expect(scroll.follow_focus, "%s: list scroll owner should support focus-follow reachability" % label)
	_expect(_row_count(list) == InventoryScript.DISPLAY_ORDER.size(), "%s: all six catalog rows must remain present" % label)

	# The list alone sits between the fixed header and fixed status/footer region.
	var scroll_rect := scroll.get_global_rect()
	_expect(title.get_global_rect().end.y <= scroll_rect.position.y + 0.5, "%s: title must remain above the scrolling list" % label)
	_expect(subtitle.get_global_rect().end.y <= scroll_rect.position.y + 0.5, "%s: subtitle must remain above the scrolling list" % label)
	_expect(status.get_global_rect().position.y >= scroll_rect.end.y - 0.5, "%s: status must remain below/outside the scrolling list" % label)
	_expect(footer.get_global_rect().position.y >= status.get_global_rect().end.y - 0.5, "%s: footer must remain below status and outside list scrolling" % label)
	_check_row_horizontal_containment(label, scroll, list)

	var vbar := scroll.get_v_scroll_bar()
	var overflows := list.get_combined_minimum_size().y > scroll.size.y + 0.5
	if expected_viewport == NARROW_VIEWPORT and overflows:
		narrow_overflow_seen = true
		_expect(vbar.max_value > vbar.page + 0.5, "%s: overflowing six-row list must expose a usable vertical scroll range" % label)

	print("[%s] panel=%s scroll=%s list_min=%s vbar(max=%s page=%s)" % [
		label,
		panel.get_global_rect(),
		scroll.get_global_rect(),
		list.get_combined_minimum_size(),
		vbar.max_value,
		vbar.page,
	])


func _check_empty_bag_layout() -> void:
	_check_logical_viewport("960x540 empty bag", NARROW_VIEWPORT)
	var panel: PanelContainer = ui.get_node("ShopCenter/ShopPanel") as PanelContainer
	var content: VBoxContainer = panel.get_node("ShopContent") as VBoxContainer
	var scroll: ScrollContainer = content.get_node("ShopListScroll") as ScrollContainer
	var list: VBoxContainer = scroll.get_node("ShopList") as VBoxContainer
	var status: Label = content.get_node("ShopStatus") as Label
	var close_button: Button = content.get_node("ShopFooter/ShopClose") as Button
	var empty_note: Label = list.get_node("ShopEmptyNote") as Label
	var vbar := scroll.get_v_scroll_bar()

	_expect(ui.is_open() and ui.mode == "bag", "960x540 empty bag: bag mode must stay open")
	_expect(_rect_inside_viewport(panel.get_global_rect(), NARROW_VIEWPORT), "960x540 empty bag: panel must stay inside viewport")
	_expect(list.get_child_count() == 1, "960x540 empty bag: rebuilt list must contain only the empty-state note")
	_expect(empty_note.text.begins_with("背包是空的"), "960x540 empty bag: empty-state copy must remain present")
	_expect(scroll.scroll_vertical == 0, "full bag -> empty bag must reset previous scroll offset")
	_expect(vbar.max_value <= vbar.page + 0.5, "full bag -> empty bag must not retain a stale overflow range")
	_expect(_rect_inside_rect(empty_note.get_global_rect(), scroll.get_global_rect()), "960x540 empty bag: empty-state note must fit inside list viewport")
	_expect(_rect_inside_rect(status.get_global_rect(), panel.get_global_rect()), "960x540 empty bag: fixed status region must stay inside panel")
	_expect(_rect_inside_rect(close_button.get_global_rect(), panel.get_global_rect()), "960x540 empty bag: close action must stay reachable")


func _scroll_list_to_bottom() -> void:
	var scroll: ScrollContainer = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopListScroll") as ScrollContainer
	var vbar := scroll.get_v_scroll_bar()
	scroll.scroll_vertical = int(ceil(vbar.max_value))


func _check_last_row_reachable(label: String) -> void:
	var scroll: ScrollContainer = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopListScroll") as ScrollContainer
	var list: VBoxContainer = scroll.get_node("ShopList") as VBoxContainer
	var last_item_id := str(InventoryScript.DISPLAY_ORDER[InventoryScript.DISPLAY_ORDER.size() - 1])
	var last_row: Control = list.get_node("ShopRow_%s" % last_item_id) as Control
	var scroll_rect := scroll.get_global_rect()
	var vbar := scroll.get_v_scroll_bar()

	if vbar.max_value > vbar.page + 0.5:
		_expect(scroll.scroll_vertical > 0, "%s: overflow path must support a non-zero scroll offset" % label)
	_expect(_rect_inside_rect(last_row.get_global_rect(), scroll_rect), "%s: final catalog row must become fully visible" % label)


func _trigger_last_action(row_mode: String) -> void:
	var list: VBoxContainer = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopListScroll/ShopList") as VBoxContainer
	var last_item_id := str(InventoryScript.DISPLAY_ORDER[InventoryScript.DISPLAY_ORDER.size() - 1])
	var row: Control = list.get_node("ShopRow_%s" % last_item_id) as Control
	var action := row.find_child("ShopAction_%s" % last_item_id, true, false) as Button
	_expect(action != null, "%s row must retain an action button" % row_mode)
	if action != null:
		action.pressed.emit()


func _check_refresh_reset() -> void:
	_check_layout("960x540 buy refresh", NARROW_VIEWPORT, "buy")
	_check_scroll_reset("same-mode refresh")
	var status: Label = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopStatus") as Label
	_expect(status.text.begins_with("测试状态"), "refresh + set_status must keep status text in the fixed status region")


func _check_scroll_reset(label: String) -> void:
	var scroll: ScrollContainer = ui.get_node("ShopCenter/ShopPanel/ShopContent/ShopListScroll") as ScrollContainer
	_expect(scroll.scroll_vertical == 0, "%s must reset rebuilt ShopList scroll position to the top" % label)


func _check_signal_contract() -> void:
	var last_item_id := str(InventoryScript.DISPLAY_ORDER[InventoryScript.DISPLAY_ORDER.size() - 1])
	_expect(buy_signal_count == 1, "buy_requested must emit exactly once for one buy action")
	_expect(buy_item_id == last_item_id, "buy_requested must forward the selected item id")
	_expect(use_signal_count == 1, "use_requested must emit exactly once for one bag action")
	_expect(use_item_id == last_item_id, "use_requested must forward the selected item id")


func _check_row_horizontal_containment(label: String, scroll: ScrollContainer, list: VBoxContainer) -> void:
	var scroll_rect := scroll.get_global_rect()
	for raw_id in InventoryScript.DISPLAY_ORDER:
		var item_id := str(raw_id)
		var row: Control = list.get_node("ShopRow_%s" % item_id) as Control
		var row_rect := row.get_global_rect()
		_expect(
			row_rect.position.x >= scroll_rect.position.x - 0.5
			and row_rect.end.x <= scroll_rect.end.x + 0.5,
			"%s: row %s must remain horizontally contained by ShopListScroll" % [label, item_id]
		)


func _row_count(list: VBoxContainer) -> int:
	var count := 0
	for raw_id in InventoryScript.DISPLAY_ORDER:
		if list.get_node_or_null("ShopRow_%s" % str(raw_id)) != null:
			count += 1
	return count


func _on_buy_requested(item_id: String) -> void:
	buy_signal_count += 1
	buy_item_id = item_id


func _on_use_requested(item_id: String) -> void:
	use_signal_count += 1
	use_item_id = item_id


func _on_closed() -> void:
	closed_signal_count += 1


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
		print("[PASS] ShopUI list overflow/rebuild contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
