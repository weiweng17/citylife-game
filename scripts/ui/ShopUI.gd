extends Control
class_name ShopUI
## 便利店的货架面板，同时兼任随身背包。
## 一块面板两种用法：mode = "buy" 看货架，mode = "bag" 看背包。
## 这里只负责显示与转发点击——钱、物品数量、需求变化仍由 Game 结算，
## 面板永远只是同一份数据的另一个视图。

signal buy_requested(item_id: String)
signal use_requested(item_id: String)
signal closed

const InventoryScript = preload("res://scripts/systems/Inventory.gd")

const GOLD := Color(1.0, 0.93, 0.68)
const TEXT := Color(0.94, 0.93, 0.88)
const DIM := Color(0.68, 0.72, 0.80)

var mode: String = ""
var dim: ColorRect
var center: CenterContainer
var panel: PanelContainer
var title_label: Label
var subtitle_label: Label
var status_label: Label
var list_box: VBoxContainer
var close_btn: Button

var _money: int = 0
var _inventory = null


func _ready() -> void:
	# 不要依赖 FULL_RECT 锚点：本面板挂在 CanvasLayer 上，根 Control 不会被自动撑开，
	# 结果就是遮罩不铺开、面板贴在左上角。与 LocationManager.root 一样手动同步视口尺寸。
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build_ui()
	get_viewport().size_changed.connect(_sync_viewport)
	_sync_viewport()


func _sync_viewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = Vector2.ZERO
	size = viewport_size
	if dim != null:
		dim.position = Vector2.ZERO
		dim.size = viewport_size
	if center != null:
		center.position = Vector2.ZERO
		center.size = viewport_size


func _build_ui() -> void:
	dim = ColorRect.new()
	dim.name = "ShopDim"
	dim.set_anchors_preset(Control.PRESET_TOP_LEFT)
	dim.color = Color(0.02, 0.03, 0.05, 0.62)
	# 盖住整屏并吃掉点击，避免面板打开时还能点到下面的地面和地点按钮。
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	center = CenterContainer.new()
	center.name = "ShopCenter"
	center.set_anchors_preset(Control.PRESET_TOP_LEFT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	panel = PanelContainer.new()
	panel.name = "ShopPanel"
	panel.custom_minimum_size = Vector2(660, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "ShopContent"
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", GOLD)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.add_theme_font_size_override("font_size", 12)
	subtitle_label.add_theme_color_override("font_color", DIM)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(subtitle_label)

	box.add_child(HSeparator.new())

	# 不再套 ScrollContainer：面板直接按内容撑高——货架六件刚好看完，背包里只有一件
	# 时就只有一件的高度。容器的最小尺寸要等布局刷新，包一层滚动区反而量不准
	# （先开货架再开空背包会量到上一次的高度，撑出一大片空白）。
	# 注意：货品目录如果涨到十几件，这个面板会高过屏幕，那时再换成固定高度的滚动区。
	list_box = VBoxContainer.new()
	list_box.name = "ShopList"
	list_box.add_theme_constant_override("separation", 6)
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(list_box)

	box.add_child(HSeparator.new())

	status_label = Label.new()
	status_label.name = "ShopStatus"
	status_label.custom_minimum_size = Vector2(0, 34)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color(0.96, 0.82, 0.58))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(status_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(footer)

	close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(140, 34)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close)
	_style_action(close_btn, false)
	footer.add_child(close_btn)


# ---------------------------------------------------------------- 开关

func open_buy(money_value: int, inventory) -> void:
	mode = "buy"
	_money = money_value
	_inventory = inventory
	status_label.text = ""
	visible = true
	_rebuild()


func open_bag(money_value: int, inventory) -> void:
	mode = "bag"
	_money = money_value
	_inventory = inventory
	status_label.text = ""
	visible = true
	_rebuild()


func is_open() -> bool:
	return visible


func refresh(money_value: int, inventory) -> void:
	_money = money_value
	if inventory != null:
		_inventory = inventory
	if visible:
		_rebuild()


func set_status(text: String) -> void:
	if status_label != null:
		status_label.text = text


func close() -> void:
	if not visible:
		return
	visible = false
	mode = ""
	closed.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- 内容

func _rebuild() -> void:
	if list_box == null:
		return
	for child in list_box.get_children():
		list_box.remove_child(child)
		child.queue_free()
	if mode == "buy":
		title_label.text = "街角便利店 · 货架"
		subtitle_label.text = "收银台的灯管有点闪。你口袋里还有 %d 元。" % _money
		close_btn.text = "离开货架"
		for item_id in InventoryScript.DISPLAY_ORDER:
			_add_row(str(item_id), "buy")
	else:
		title_label.text = "背包 · 随身带着的东西"
		var owned: Array = _inventory.owned_items()
		subtitle_label.text = "你身上带着 %d 件东西。" % _inventory.total_count()
		close_btn.text = "收起来"
		if owned.is_empty():
			_add_empty_note("背包是空的。\n先去街角便利店买点什么吧——饿的时候，等不了外卖。")
		else:
			for item_id in owned:
				_add_row(str(item_id), "bag")


func _add_empty_note(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(0, 120)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", DIM)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list_box.add_child(label)


func _add_row(item_id: String, row_mode: String) -> void:
	var holder := PanelContainer.new()
	holder.add_theme_stylebox_override("panel", _row_style())
	list_box.add_child(holder)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	holder.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = InventoryScript.item_name(item_id)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", TEXT)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = InventoryScript.desc_text(item_id)
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", DIM)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(desc_label)

	var effect_label := Label.new()
	effect_label.text = InventoryScript.effect_text(item_id)
	effect_label.custom_minimum_size = Vector2(128, 0)
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.add_theme_font_size_override("font_size", 12)
	effect_label.add_theme_color_override("font_color", Color(0.70, 0.90, 0.78))
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(effect_label)

	var button := Button.new()
	button.custom_minimum_size = Vector2(78, 32)
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if row_mode == "buy":
		var price: int = InventoryScript.price_of(item_id)
		var meta := Label.new()
		meta.text = "¥%d" % price
		meta.custom_minimum_size = Vector2(56, 0)
		meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		meta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		meta.add_theme_font_size_override("font_size", 14)
		meta.add_theme_color_override("font_color", GOLD if _money >= price else Color(0.72, 0.48, 0.44))
		meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(meta)
		button.text = "买下"
		# 买不起就把按钮按下去：让玩家一眼看出差多少钱，而不是点了才被拒。
		button.disabled = _money < price
		button.pressed.connect(func(): buy_requested.emit(item_id))
	else:
		var hold := Label.new()
		hold.text = "×%d" % _inventory.count(item_id)
		hold.custom_minimum_size = Vector2(56, 0)
		hold.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hold.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hold.add_theme_font_size_override("font_size", 14)
		hold.add_theme_color_override("font_color", GOLD)
		hold.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(hold)
		button.text = "用掉"
		button.pressed.connect(func(): use_requested.emit(item_id))
	_style_action(button, not button.disabled)
	row.add_child(button)


# ---------------------------------------------------------------- 样式

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.10, 0.96)
	style.set_corner_radius_all(12)
	style.set_border_width_all(1)
	style.border_color = Color(1.0, 0.93, 0.68, 0.42)
	style.set_content_margin_all(18)
	return style


func _row_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.10, 0.15, 0.86)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(9)
	return style


## 与场景内标签同一套暗色胶囊；不要 flat=true，否则 normal 底色不会被绘制。
func _style_action(button: Button, highlighted: bool) -> void:
	button.add_theme_font_size_override("font_size", 13)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.06, 0.07, 0.12, 0.90)
	normal.set_corner_radius_all(7)
	normal.set_border_width_all(1)
	normal.border_color = Color(1.0, 0.93, 0.68, 0.34 if highlighted else 0.18)
	normal.set_content_margin_all(5)
	button.add_theme_stylebox_override("normal", normal)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.15, 0.17, 0.25, 0.95)
	hover.border_color = Color(1.0, 0.93, 0.68, 0.95)
	button.add_theme_stylebox_override("hover", hover)

	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.20, 0.22, 0.30, 0.98)
	button.add_theme_stylebox_override("pressed", pressed)

	var disabled: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.05, 0.05, 0.08, 0.72)
	disabled.border_color = Color(1.0, 0.93, 0.68, 0.10)
	button.add_theme_stylebox_override("disabled", disabled)

	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.86))
	button.add_theme_color_override("font_disabled_color", Color(0.52, 0.52, 0.58))
