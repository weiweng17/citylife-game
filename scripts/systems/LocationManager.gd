extends CanvasLayer
class_name LocationManager
## MAP-002：独立地点 + 地点内可移动原型。
## 每个地点使用独立背景；玩家可用 WASD/方向键/点击地面移动。

signal action_requested(location_id: String)
signal travel_requested(location_id: String)
signal npc_requested(npc_id: String)

const PLAYER_SHEET := "res://assets/characters/sprites/gameplay/protagonist_walk_4x4.png"
const ActivityPropScript := preload("res://scripts/world/ActivityProp.gd")
const MoveMarkerScript := preload("res://scripts/world/MoveMarker.gd")
const HomeInteractionVisualScript := preload("res://scripts/world/HomeInteractionVisual.gd")
const PLAYER_FRAME := 256
const PLAYER_SPEED := 260.0
const NPC_HIRES_SHEETS := {
	"xiaoyu": "res://assets/characters/sprites/prototype/xiaoyu_walk_candidate.png",
	"chenjie": "res://assets/characters/sprites/prototype/chenjie_walk_candidate.png",
}
const NPC_FALLBACK_SPRITES := {
	"laozhang": "res://assets/sprites/npc_laozhang.png",
	"laozhou": "res://assets/sprites/npc_laozhou.png",
	"azhe": "res://assets/sprites/npc_azhe.png",
	"daoshi": "res://assets/sprites/npc_daoshi.png",
}

const LOCATIONS := {
	"home": {
		"name": "居民区 · 出租屋",
		"subtitle": "故事从这里开始。雨落在窗外，你刚在这座城市安顿下来。",
		"background": "res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp",
		"spawn": Vector2(850, 460),
	},
	"subway": {
		"name": "城南地铁站",
		"subtitle": "每天通往更远地方的入口。人群来了又走。",
		"background": "res://assets/backgrounds/dialogue/transport/subway_platform_rain_night.webp",
		"spawn": Vector2(640, 465),
	},
	"office": {
		"name": "云海科技 · 公司",
		"subtitle": "写字楼的灯总亮得比夜晚更久。",
		"background": "res://assets/backgrounds/dialogue/company/company_entrance_rain_night.webp",
		"spawn": Vector2(620, 470),
	},
	"park": {
		"name": "中央公园",
		"subtitle": "城市中难得可以慢下来的地方。",
		"background": "res://assets/backgrounds/dialogue/life/park_pavilion_rain_night.webp",
		"spawn": Vector2(640, 470),
	},
	"store": {
		"name": "街角便利店",
		"subtitle": "二十四小时亮着灯，总有人比你更晚回家。",
		"background": "res://assets/backgrounds/dialogue/life/convenience_store_rain_night.webp",
		"spawn": Vector2(535, 525),
	},
	"cafe": {
		"name": "雨巷咖啡馆",
		"subtitle": "适合见人，也适合一个人坐很久。",
		"background": "res://assets/backgrounds/dialogue/life/cafe_rain_night.webp",
		"spawn": Vector2(610, 470),
	},
	"hospital": {
		"name": "仁心医院",
		"subtitle": "有些人生节点，会在这里突然变得具体。",
		"background": "res://assets/backgrounds/dialogue/hospital/clinic_room_rain_night.webp",
		"spawn": Vector2(625, 470),
	},
	"rooftop": {
		"name": "老楼天台",
		"subtitle": "站得高一点，城市会显得很远。",
		"background": "res://assets/backgrounds/dialogue/city/rooftop_rain_night.webp",
		"spawn": Vector2(625, 470),
	},
	"alley": {
		"name": "旧巷口",
		"subtitle": "有些地方，只有夜里才像真的存在。",
		"background": "res://assets/backgrounds/dialogue/city/old_alley_rain_night.webp",
		"spawn": Vector2(625, 470),
	},
}

const VISIT_UNLOCKS := {
	"home": ["subway"],
	"subway": ["office"],
	"office": ["park", "store"],
	"park": ["cafe"],
	"store": ["hospital"],
}

# 每张美术背景对应的可行走地面与实体阻挡区。坐标均以 1280 × 720 视口计算，
# 角色的脚底（而非立绘中心）不会进入家具、柜台、墙面、站台设施或画面边缘。
const NAVIGATION := {
	"home": {"bounds": Rect2(70, 250, 1110, 335), "blocked": [], "polygons": [
		# 床、茶几、沙发按斜向轮廓标定，不再用横平竖直的大框截断走道。
		[Vector2(48, 323), Vector2(237, 283), Vector2(315, 356), Vector2(393, 477), Vector2(387, 522), Vector2(215, 570), Vector2(65, 415)],
		[Vector2(436, 389), Vector2(565, 350), Vector2(666, 401), Vector2(668, 444), Vector2(532, 505), Vector2(435, 450)],
		[Vector2(363, 523), Vector2(422, 487), Vector2(479, 536), Vector2(791, 480), Vector2(829, 491), Vector2(832, 607), Vector2(472, 719), Vector2(361, 636)],
		# 书桌及椅子；右侧厨房柜台、冰箱与门边鞋柜。
		[Vector2(680, 245), Vector2(797, 219), Vector2(798, 338), Vector2(747, 350), Vector2(684, 318)],
		[Vector2(568, 253), Vector2(626, 237), Vector2(674, 283), Vector2(651, 322), Vector2(588, 314)],
		[Vector2(950, 250), Vector2(1280, 250), Vector2(1280, 585), Vector2(1003, 585), Vector2(1003, 428), Vector2(1078, 394), Vector2(958, 325)],
		# 左侧床头柜和上方靠墙区域。
		[Vector2(239, 250), Vector2(324, 250), Vector2(342, 316), Vector2(280, 335)],
		# 死区封堵（verify_home_edges 实走复核发现）：床头上方墙根是美术里的床头与墙壁，
		# 床尾木架与沙发左缝是实体和窄缝；此前“站得住却走不进去”，一并并入碰撞体。
		[Vector2(70, 250), Vector2(245, 250), Vector2(245, 292), Vector2(85, 310)],
		[Vector2(70, 455), Vector2(350, 500), Vector2(350, 585), Vector2(70, 585)],
	]},
	"subway": {"bounds": Rect2(70, 325, 1140, 275), "blocked": [Rect2(175, 305, 135, 230), Rect2(910, 285, 105, 265), Rect2(0, 480, 235, 150), Rect2(1060, 420, 220, 230)]},
	"office": {"bounds": Rect2(95, 335, 1085, 245), "blocked": [Rect2(0, 280, 245, 185), Rect2(540, 245, 740, 175), Rect2(990, 330, 290, 230)]},
	"park": {"bounds": Rect2(85, 315, 1110, 270), "blocked": [Rect2(0, 285, 300, 200), Rect2(890, 260, 390, 225), Rect2(490, 330, 270, 110)]},
	"store": {"bounds": Rect2(60, 270, 1130, 310), "blocked": [Rect2(55, 385, 320, 245), Rect2(365, 300, 315, 175), Rect2(640, 455, 325, 180), Rect2(1005, 245, 275, 395)]},
	"cafe": {"bounds": Rect2(75, 295, 1125, 285), "blocked": [Rect2(0, 330, 355, 235), Rect2(390, 350, 170, 105), Rect2(730, 320, 250, 155), Rect2(1030, 250, 250, 345)]},
	"hospital": {"bounds": Rect2(95, 300, 1085, 275), "blocked": [Rect2(0, 250, 365, 245), Rect2(515, 325, 270, 135), Rect2(1000, 230, 280, 360)]},
	"rooftop": {"bounds": Rect2(85, 320, 1110, 250), "blocked": [Rect2(0, 280, 270, 205), Rect2(990, 260, 290, 225)]},
	"alley": {"bounds": Rect2(105, 305, 1055, 285), "blocked": [Rect2(0, 235, 340, 260), Rect2(1000, 220, 280, 285)]},
}

const LOCATION_LIGHTING := {
	"home": Color(1.0, 0.88, 0.73, 1.0),
	"subway": Color(0.79, 0.86, 1.0, 1.0),
	"office": Color(0.69, 0.76, 0.92, 1.0),
	"park": Color(0.72, 0.80, 0.89, 1.0),
	"store": Color(1.0, 0.90, 0.76, 1.0),
	"cafe": Color(1.0, 0.84, 0.67, 1.0),
	"hospital": Color(0.86, 0.91, 0.98, 1.0),
	"rooftop": Color(0.65, 0.73, 0.88, 1.0),
	"alley": Color(0.62, 0.70, 0.84, 1.0),
}

# 从背景原图截取这些前景区域并按物体落地点排序，形成真正的前后遮挡。
# rect 是屏幕坐标，depth 是物体最前沿的脚底深度。
const OCCLUDERS := {
	"home": [
		{"points": [Vector2(35, 287), Vector2(163, 256), Vector2(255, 302), Vector2(387, 464), Vector2(373, 513), Vector2(212, 554), Vector2(70, 410)], "depth": 514},
		{"points": [Vector2(430, 382), Vector2(565, 340), Vector2(666, 397), Vector2(660, 437), Vector2(528, 480), Vector2(439, 415)], "depth": 480},
		{"points": [Vector2(365, 495), Vector2(424, 483), Vector2(477, 541), Vector2(791, 474), Vector2(826, 489), Vector2(826, 596), Vector2(461, 719), Vector2(361, 632)], "depth": 650},
		# 书桌与厨房柜体在互动时盖住角色腿部，建立前后空间关系。
		{"points": [Vector2(574, 166), Vector2(648, 154), Vector2(796, 216), Vector2(794, 326), Vector2(744, 341), Vector2(736, 253), Vector2(577, 194)], "depth": 430},
		{"points": [Vector2(950, 250), Vector2(1280, 250), Vector2(1280, 585), Vector2(1003, 585), Vector2(1003, 428), Vector2(1078, 394), Vector2(958, 325)], "depth": 505},
	],
	"subway": [
		{"rect": Rect2(165, 60, 150, 485), "depth": 535},
		{"rect": Rect2(895, 65, 135, 500), "depth": 555},
		{"rect": Rect2(0, 420, 250, 225), "depth": 610},
		{"rect": Rect2(1050, 380, 230, 275), "depth": 620},
	],
	"office": [
		{"rect": Rect2(0, 175, 270, 310), "depth": 470},
		{"rect": Rect2(505, 170, 775, 270), "depth": 425},
		{"rect": Rect2(970, 280, 310, 300), "depth": 560},
	],
	"park": [
		{"rect": Rect2(0, 220, 320, 300), "depth": 500},
		{"rect": Rect2(470, 250, 310, 210), "depth": 450},
		{"rect": Rect2(880, 190, 400, 340), "depth": 515},
	],
	"store": [
		{"rect": Rect2(35, 300, 355, 355), "depth": 620},
		{"rect": Rect2(350, 245, 355, 250), "depth": 485},
		{"rect": Rect2(615, 385, 370, 255), "depth": 615},
		{"rect": Rect2(990, 175, 290, 465), "depth": 610},
	],
	"cafe": [
		{"rect": Rect2(0, 275, 380, 330), "depth": 575},
		{"rect": Rect2(375, 300, 210, 185), "depth": 475},
		{"rect": Rect2(700, 260, 310, 240), "depth": 490},
		{"rect": Rect2(1010, 185, 270, 420), "depth": 580},
	],
	"hospital": [
		{"rect": Rect2(0, 215, 390, 310), "depth": 510},
		{"rect": Rect2(485, 265, 330, 230), "depth": 485},
		{"rect": Rect2(970, 170, 310, 430), "depth": 575},
	],
	"rooftop": [
		{"rect": Rect2(0, 235, 290, 290), "depth": 510},
		{"rect": Rect2(970, 220, 310, 310), "depth": 515},
	],
	"alley": [
		{"rect": Rect2(0, 185, 365, 350), "depth": 515},
		{"rect": Rect2(975, 170, 305, 365), "depth": 515},
	],
}

# NPC 按地点配置脚底位置，避免同一坐标在不同背景中落进家具或前景遮挡。
const NPC_LOCATION_POS := {
	"home": {"xiaoyu": Vector2(760, 420)},
	"store": {"chenjie": Vector2(845, 315)},
	"office": {"laozhang": Vector2(370, 455)},
	"park": {"laozhou": Vector2(420, 455)},
	# 咖啡馆：阿哲中午坐吧台前的高脚位（12:00-14:00，见 npc_schedules.json）。
	"cafe": {"azhe": Vector2(900, 545)},
	"subway": {"laozhang": Vector2(735, 430), "azhe": Vector2(510, 475)},
	"alley": {"daoshi": Vector2(845, 455)},
}

var current_location: String = "home"
var unlocked: Dictionary = {"home": true}
var visited: Dictionary = {}
var active: bool = false
var input_blocked: bool = false
var navigation = preload("res://scripts/systems/LocationNavigation.gd").new()
var navigation_location: String = ""
var walk_path := PackedVector2Array()
var travel_signature: String = ""

var root: Control
var background: TextureRect
var shade: ColorRect
var title_label: Label
var subtitle_label: Label
var travel_box: HBoxContainer
var action_button: Button
var hint_label: Label
var player_sprite: AnimatedSprite2D
var player_shadow: Sprite2D
var player_feedback: Label
var activity_prop: Node2D
var move_marker: Node2D
var home_interaction_visual: Node2D
var player_target: Vector2 = Vector2.ZERO
var npc_layer: Control
var foreground_layer: Control
var npc_signature: String = ""
var current_lighting: Color = Color.WHITE
var player_pose: String = "idle"
var interaction_anchor: Dictionary = {}
var _pose_time := 0.0

func _ready() -> void:
	layer = 0
	_build_ui()
	set_process(true)

func _build_ui() -> void:
	root = Control.new()
	root.name = "LocationView"
	root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.gui_input.connect(_on_root_gui_input)
	add_child(root)
	get_viewport().size_changed.connect(_sync_web_layout)

	background = TextureRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root.add_child(background)

	shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.015, 0.025, 0.08)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.z_index = 1900
	root.add_child(shade)

	player_shadow = _make_ground_shadow(27.0, 8.0, Color(0.0, 0.0, 0.0, 0.34))
	player_shadow.name = "PlayerShadow"
	player_shadow.z_index = 4
	root.add_child(player_shadow)

	player_sprite = AnimatedSprite2D.new()
	player_sprite.name = "LocationPlayer"
	player_sprite.sprite_frames = _make_player_frames()
	player_sprite.animation = "walk_down"
	player_sprite.frame = 0
	# 立绘以脚底为定位点；缩小至与背景中原有行人相同的透视尺度。
	player_sprite.centered = false
	player_sprite.offset = Vector2(-128.0, -248.0)
	player_sprite.scale = Vector2(0.32, 0.32)
	player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	player_sprite.modulate = Color(0.82, 0.87, 0.94, 1.0)
	player_sprite.z_index = 5
	root.add_child(player_sprite)

	player_feedback = Label.new()
	player_feedback.name = "PlayerFeedback"
	player_feedback.visible = false
	player_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_feedback.position = Vector2(-64.0, -102.0)
	player_feedback.size = Vector2(128.0, 28.0)
	player_feedback.add_theme_font_size_override("font_size", 16)
	player_feedback.add_theme_color_override("font_color", Color(1.0, 0.93, 0.68, 1.0))
	player_feedback.add_theme_color_override("font_shadow_color", Color(0.03, 0.02, 0.02, 0.95))
	player_feedback.add_theme_constant_override("shadow_offset_x", 1)
	player_feedback.add_theme_constant_override("shadow_offset_y", 2)
	player_feedback.z_index = 7
	root.add_child(player_feedback)

	activity_prop = ActivityPropScript.new()
	activity_prop.name = "ActivityProp"
	activity_prop.visible = false
	activity_prop.z_index = 8
	root.add_child(activity_prop)

	# 睡眠时使用独立睡姿和真正的被子前景纹理，不使用程序几何遮挡。
	home_interaction_visual = HomeInteractionVisualScript.new()
	home_interaction_visual.name = "HomeSleepVisual"
	home_interaction_visual.z_index = 515
	home_interaction_visual.visible = false
	root.add_child(home_interaction_visual)

	move_marker = MoveMarkerScript.new()
	move_marker.name = "MoveMarker"
	move_marker.visible = false
	# 落点提示是操作反馈不是场景物体，必须浮在前景遮挡层（最深 650）与环境染色之上。
	move_marker.z_index = 1905
	root.add_child(move_marker)

	npc_layer = Control.new()
	npc_layer.name = "NpcHotspots"
	npc_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	npc_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(npc_layer)

	foreground_layer = Control.new()
	foreground_layer.name = "ForegroundOcclusion"
	foreground_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	foreground_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(foreground_layer)

	var header: PanelContainer = PanelContainer.new()
	header.name = "LocationHeader"
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 24
	header.offset_right = -24
	# 标题整体下移，给 HUD 多出来的“今日目标”一行留位置，避免两者贴边重叠。
	header.offset_top = 132
	header.offset_bottom = 204
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.z_index = 2000
	root.add_child(header)
	var hv: VBoxContainer = VBoxContainer.new()
	header.add_child(hv)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 25)
	hv.add_child(title_label)
	subtitle_label = Label.new()
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hv.add_child(subtitle_label)

	var footer: PanelContainer = PanelContainer.new()
	footer.name = "LocationFooter"
	footer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 20
	footer.offset_right = -20
	footer.offset_top = -112
	footer.offset_bottom = -16
	footer.mouse_filter = Control.MOUSE_FILTER_STOP
	footer.z_index = 2000
	root.add_child(footer)
	var fv: VBoxContainer = VBoxContainer.new()
	footer.add_child(fv)
	hint_label = Label.new()
	hint_label.text = "点击地面 / WASD / 方向键移动 · 已解锁地点"
	fv.add_child(hint_label)
	travel_box = HBoxContainer.new()
	travel_box.alignment = BoxContainer.ALIGNMENT_CENTER
	fv.add_child(travel_box)
	action_button = Button.new()
	action_button.text = "在这里行动"
	action_button.custom_minimum_size = Vector2(180, 34)
	action_button.pressed.connect(_on_action_pressed)
	fv.add_child(action_button)
	_sync_web_layout()

func _sync_web_layout() -> void:
	if root != null:
		root.position = Vector2.ZERO
		root.size = get_viewport().get_visible_rect().size

func _make_player_frames() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	for default_name in frames.get_animation_names():
		frames.remove_animation(default_name)
	var texture: Texture2D = load(PLAYER_SHEET) as Texture2D
	var names: Array[String] = ["walk_down", "walk_left", "walk_right", "walk_up"]
	for row in range(4):
		var anim: String = names[row]
		frames.add_animation(anim)
		frames.set_animation_speed(anim, 8.0)
		frames.set_animation_loop(anim, true)
		for col in range(4):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(col * PLAYER_FRAME, row * PLAYER_FRAME, PLAYER_FRAME, PLAYER_FRAME)
			frames.add_frame(anim, atlas)
	return frames

func _make_ground_shadow(width: float, height: float, color: Color) -> Sprite2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([
		color,
		Color(color.r, color.g, color.b, color.a * 0.48),
		Color(color.r, color.g, color.b, 0.0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 96
	texture.height = 32
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	var shadow := Sprite2D.new()
	shadow.texture = texture
	shadow.scale = Vector2(width * 2.0 / 96.0, height * 2.0 / 32.0)
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return shadow

func reset_new_game() -> void:
	unlocked = {"home": true}
	visited = {}
	current_location = "home"
	set_active(true)
	_visit_and_unlock("home")
	_refresh()

func set_active(value: bool) -> void:
	active = value
	if root != null:
		root.visible = value
	if not value and player_sprite != null:
		player_sprite.stop()

func is_active() -> bool:
	return active

func unlock(id: String) -> void:
	if LOCATIONS.has(id):
		unlocked[id] = true
		_refresh_travel_buttons()

func is_unlocked(id: String) -> bool:
	return bool(unlocked.get(id, false))

func travel_to(id: String, unlock_on_arrival: bool = true) -> void:
	if not LOCATIONS.has(id) or not is_unlocked(id):
		return
	current_location = id
	if unlock_on_arrival:
		_visit_and_unlock(id)
	_refresh()
	travel_requested.emit(id)

func _visit_and_unlock(id: String) -> void:
	visited[id] = true
	var next_list: Array = VISIT_UNLOCKS.get(id, [])
	for next_id in next_list:
		unlocked[str(next_id)] = true

func _refresh() -> void:
	_sync_web_layout()
	if root != null and active:
		root.visible = true
	if not LOCATIONS.has(current_location):
		current_location = "home"
	var info: Dictionary = LOCATIONS[current_location]
	current_lighting = LOCATION_LIGHTING.get(current_location, Color.WHITE)
	title_label.text = str(info.get("name", current_location))
	subtitle_label.text = str(info.get("subtitle", ""))
	var path: String = str(info.get("background", ""))
	background.texture = load(path) as Texture2D if not path.is_empty() else null
	_rebuild_foreground()
	action_button.text = "在%s行动" % str(info.get("name", current_location)).split(" · ")[0]
	var spawn: Vector2 = _clamp_walk_position(info.get("spawn", Vector2(640, 460)))
	player_sprite.position = spawn
	player_sprite.modulate = _player_light_color()
	player_sprite.rotation = 0.0
	player_pose = "idle"
	interaction_anchor = {}
	if home_interaction_visual:
		home_interaction_visual.force_hidden()
	_update_player_grounding()
	player_target = spawn
	walk_path.clear()
	player_sprite.stop()
	player_sprite.animation = "walk_down"
	player_sprite.frame = 0
	npc_signature = ""
	_clear_npcs()
	_refresh_travel_buttons()

func _rebuild_foreground() -> void:
	if foreground_layer == null:
		return
	for child in foreground_layer.get_children():
		child.queue_free()
	var texture: Texture2D = background.texture
	if texture == null:
		return
	var viewport_size := Vector2(1280.0, 720.0)
	var source_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	# 与 TextureRect.STRETCH_KEEP_ASPECT_COVERED 使用同一套等比放大 + 居中裁切换算。
	var cover_scale: float = maxf(viewport_size.x / source_size.x, viewport_size.y / source_size.y)
	var crop_offset: Vector2 = (source_size * cover_scale - viewport_size) * 0.5
	for raw_item in OCCLUDERS.get(current_location, []):
		if not raw_item is Dictionary:
			continue
		var item: Dictionary = raw_item
		var rect: Rect2 = item.get("rect", Rect2())
		var points: PackedVector2Array = PackedVector2Array(item.get("points", []))
		if points.is_empty() and rect.size.x > 0.0 and rect.size.y > 0.0:
			points = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
		if points.size() < 3:
			continue
		var overlay := Polygon2D.new()
		overlay.texture = texture
		overlay.polygon = points
		var uv := PackedVector2Array()
		for point in points:
			uv.append((point + crop_offset) / cover_scale)
		overlay.uv = uv
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		overlay.z_index = int(item.get("depth", rect.end.y))
		foreground_layer.add_child(overlay)

func _refresh_travel_buttons() -> void:
	if travel_box == null:
		return
	var keys := unlocked.keys()
	keys.sort()
	var signature := str(keys) + current_location
	if signature == travel_signature:
		return
	travel_signature = signature
	for child in travel_box.get_children():
		travel_box.remove_child(child)
		child.queue_free()
	var order: Array[String] = ["home", "subway", "office", "park", "store", "cafe", "hospital", "rooftop", "alley"]
	for id in order:
		if not is_unlocked(id):
			continue
		var info: Dictionary = LOCATIONS[id]
		var btn: Button = Button.new()
		btn.text = str(info.get("name", id)).split(" · ")[0]
		btn.disabled = id == current_location
		btn.pressed.connect(_on_travel_pressed.bind(id))
		travel_box.add_child(btn)

func _on_travel_pressed(id: String) -> void:
	if not input_blocked:
		travel_to(id)

func _on_action_pressed() -> void:
	if not input_blocked:
		action_requested.emit(current_location)

func _on_root_gui_input(event: InputEvent) -> void:
	if not active or input_blocked:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# 点了哪里必须有回应：走得到是金色涟漪，走不到是红色提示。
			var reachable: bool = walk_to(mouse_event.position)
			if move_marker != null:
				move_marker.ping(mouse_event.position, not reachable)

func _ensure_navigation() -> void:
	if navigation_location != current_location:
		navigation.configure(NAVIGATION.get(current_location, {}))
		navigation_location = current_location

func walk_to(target: Vector2) -> bool:
	if input_blocked or not active:
		return false
	_ensure_navigation()
	walk_path = navigation.find_path(player_sprite.position, target)
	if walk_path.is_empty():
		player_target = player_sprite.position
		hint_label.text = "这里无法到达，请选择另一处地面。"
		return false
	player_target = walk_path[walk_path.size() - 1]
	return true

func stop_walking() -> void:
	walk_path.clear()
	player_target = player_sprite.position
	player_sprite.stop()
	player_sprite.frame = 0

func _animation_for_direction(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"walk_right" if direction.x > 0.0 else &"walk_left"
	return &"walk_down" if direction.y > 0.0 else &"walk_up"

func face_direction(direction: Vector2) -> void:
	if player_sprite == null or direction.length_squared() < 0.01:
		return
	player_sprite.stop()
	player_sprite.animation = _animation_for_direction(direction)
	player_sprite.frame = 0

func set_activity_feedback(text: String, active_feedback: bool, activity_id: String = "", anchor: Dictionary = {}) -> void:
	if player_feedback == null or player_sprite == null:
		return
	player_feedback.text = text
	player_feedback.visible = active_feedback
	if active_feedback:
		_apply_interaction_pose(anchor)
	else:
		_restore_free_pose()
	if player_shadow != null:
		player_shadow.modulate.a = 0.70 if active_feedback and player_pose != "sleep" else (0.0 if player_pose == "sleep" else 1.0)
	if activity_prop != null:
		activity_prop.setup(activity_id)
		# 床上姿态已有被子和露出的头部；把"手持枕头"留着反而像漂浮道具。
		if player_pose == "sleep":
			activity_prop.visible = false
	_update_player_grounding()


func _apply_interaction_pose(anchor: Dictionary) -> void:
	interaction_anchor = anchor.duplicate(true)
	player_pose = str(anchor.get("pose", "interact"))
	_pose_time = 0.0
	player_sprite.stop()
	face_direction(anchor.get("facing", Vector2.DOWN))
	player_sprite.rotation = 0.0
	if player_pose == "sleep":
		# position 是脚底中心；sleep_position 是同一 LocationView 下的睡姿中心。
		# 不混用 local/global，也不将普通站立帧旋转 90 度冒充睡姿。
		var approach_global := player_sprite.global_position
		player_sprite.z_index = int(anchor.get("depth", 518)) - 1
		if home_interaction_visual:
			home_interaction_visual.z_index = int(anchor.get("depth", 518))
			home_interaction_visual.begin_sleep(anchor, approach_global, _player_light_color())
		var fade_out := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		fade_out.tween_property(player_sprite, "modulate:a", 0.0, 0.16)
		fade_out.tween_callback(func(): player_sprite.visible = false)
	elif player_pose == "sit":
		player_sprite.scale = _depth_scale(player_sprite.position.y) * 0.91
		player_sprite.position += Vector2(0.0, 5.0)
		player_sprite.z_index = int(anchor.get("depth", player_sprite.position.y))
	else:
		player_sprite.scale = _depth_scale(player_sprite.position.y) * Vector2(1.0, 0.96)
		player_sprite.z_index = int(anchor.get("depth", player_sprite.position.y))


func _restore_free_pose() -> void:
	if player_pose == "sleep" and interaction_anchor.has("position"):
		# 起床回到床边，而不是在床中央直接站起。
		player_sprite.position = interaction_anchor["position"]
		player_target = player_sprite.position
		player_sprite.visible = true
		var lit_color := _player_light_color()
		player_sprite.modulate = Color(lit_color.r, lit_color.g, lit_color.b, 0.0)
		var fade_in := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		fade_in.tween_property(player_sprite, "modulate:a", 1.0, 0.20)
	player_pose = "idle"
	interaction_anchor = {}
	_pose_time = 0.0
	player_sprite.rotation = 0.0
	player_sprite.scale = _depth_scale(player_sprite.position.y)
	if home_interaction_visual:
		home_interaction_visual.end_sleep()


func _depth_scale(y: float) -> Vector2:
	# 以后景到前景的可行走地带，人物高度从约 75px 平滑变到 88px。
	var t := clampf((y - 280.0) / 350.0, 0.0, 1.0)
	var value := lerpf(0.292, 0.342, t)
	return Vector2(value, value)


func _player_light_color() -> Color:
	# 室内暖光 + 少量中性灰，弱化立绘的纯白和过强边缘反差。
	return current_lighting.lerp(Color(0.92, 0.90, 0.86, 1.0), 0.22)

func _process(delta: float) -> void:
	_sync_web_layout()
	if not active or player_sprite == null:
		return
	if input_blocked:
		stop_walking()
		_animate_pose(delta)
		return
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	if Input.is_key_pressed(KEY_W): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S): direction.y += 1.0
	if direction.length() > 0.05:
		direction = direction.normalized()
		walk_path.clear()
		_move_player(direction, delta)
		player_target = player_sprite.position
		return
	_advance_path(delta)
	if player_pose != "walk":
		player_pose = "idle"
	_animate_pose(delta)

func _advance_path(delta: float) -> void:
	var remaining := PLAYER_SPEED * minf(delta, 0.033)
	while not walk_path.is_empty() and remaining > 0.001:
		var offset: Vector2 = walk_path[0] - player_sprite.position
		if offset.length() < 0.01:
			walk_path.remove_at(0)
			continue
		var distance := minf(remaining, offset.length())
		var before := player_sprite.position
		_move_player(offset.normalized(), distance / PLAYER_SPEED)
		remaining -= distance
		if before.distance_to(player_sprite.position) < 0.001:
			stop_walking()
			break
	if walk_path.is_empty():
		stop_walking()

func _move_player(direction: Vector2, delta: float) -> void:
	_ensure_navigation()
	var before := player_sprite.position
	var displacement := direction * PLAYER_SPEED * minf(delta, 0.033)
	player_sprite.position = navigation.move_safely(before, displacement)
	_update_player_grounding()
	if before.distance_to(player_sprite.position) < 0.001:
		player_sprite.stop()
		player_sprite.frame = 0
		return
	var anim: StringName = _animation_for_direction(direction)
	if player_sprite.animation != anim:
		player_sprite.animation = anim
	if not player_sprite.is_playing():
		player_sprite.play()
	player_pose = "walk"


func _animate_pose(delta: float) -> void:
	if player_sprite == null or player_pose == "walk":
		return
	_pose_time += delta
	if player_pose == "interact":
		player_sprite.scale = _depth_scale(player_sprite.position.y) * Vector2(1.0, 0.96 + sin(_pose_time * 3.0) * 0.012)

func _update_player_grounding() -> void:
	if player_sprite == null:
		return
	if player_pose == "idle" or player_pose == "walk":
		player_sprite.scale = _depth_scale(player_sprite.position.y)
		player_sprite.z_index = maxi(5, int(player_sprite.position.y))
		player_sprite.modulate = _player_light_color()
	if player_shadow != null:
		player_shadow.position = player_sprite.position + Vector2(0.0, 4.0)
		player_shadow.z_index = maxi(4, player_sprite.z_index - 1)
		player_shadow.visible = player_pose != "sleep"
	if player_feedback != null:
		player_feedback.position = player_sprite.position + Vector2(-64.0, -102.0)
		player_feedback.z_index = player_sprite.z_index + 2
	if activity_prop != null:
		# 道具挂在角色手部高度，随脚底坐标走，避免随角色缩放变小。
		activity_prop.position = player_sprite.position + Vector2(16.0, -50.0)
		activity_prop.z_index = player_sprite.z_index + 3

func _clamp_walk_position(pos: Vector2) -> Vector2:
	_ensure_navigation()
	return navigation.nearest_valid(pos)

func set_visible_npcs(items: Array) -> void:
	# signature 必须带上 note（关系档位）：档位变了也得重建，否则悬停标签会一直显示旧档位。
	var parts: Array[String] = []
	for item in items:
		if typeof(item) == TYPE_DICTIONARY:
			parts.append("%s:%s:%s" % [str(item.get("id", "")), str(item.get("name", "")), str(item.get("note", ""))])
	parts.sort()
	var signature: String = "|".join(parts)
	if signature == npc_signature:
		return
	npc_signature = signature
	_clear_npcs()
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var npc_id: String = str(item.get("id", ""))
		var location_positions: Dictionary = NPC_LOCATION_POS.get(current_location, {})
		var pos: Vector2 = location_positions.get(npc_id, Vector2(900, 420))
		_add_npc_entity(npc_id, str(item.get("name", npc_id)), pos, str(item.get("note", "")))


func _add_npc_entity(npc_id: String, display_name: String, pos: Vector2, note: String = "") -> void:
	# 阴影、角色、标签拆开，避免 NPC 像悬在背景上的文字按钮。
	var shadow := _make_ground_shadow(24.0, 7.0, Color(0.0, 0.0, 0.0, 0.30))
	shadow.position = pos + Vector2(0.0, 32.0)
	shadow.z_index = maxi(1, int(pos.y) - 1)
	npc_layer.add_child(shadow)

	var button := Button.new()
	button.name = "Npc_%s" % npc_id
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "与%s交谈" % display_name if note.is_empty() else "与%s交谈（%s）" % [display_name, note]
	button.position = pos - Vector2(42.0, 76.0)
	button.size = Vector2(84.0, 110.0)
	button.z_index = maxi(2, int(pos.y))
	button.pressed.connect(_on_npc_pressed.bind(npc_id))
	npc_layer.add_child(button)

	var avatar := TextureRect.new()
	avatar.texture = _npc_texture(npc_id)
	avatar.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	avatar.modulate = current_lighting
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(avatar)

	var label := Label.new()
	label.text = display_name if note.is_empty() else "%s（%s）" % [display_name, note]
	label.visible = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-6.0, -19.0)
	label.size = Vector2(96.0, 20.0)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0, 0.96))
	label.add_theme_color_override("font_shadow_color", Color(0.01, 0.015, 0.03, 0.96))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	button.mouse_entered.connect(func(): label.visible = true)
	button.mouse_exited.connect(func(): label.visible = false)


func _npc_texture(npc_id: String) -> Texture2D:
	if NPC_HIRES_SHEETS.has(npc_id):
		var sheet: Texture2D = load(str(NPC_HIRES_SHEETS[npc_id])) as Texture2D
		if sheet != null:
			var frame_size: int = int(sheet.get_width() / 4.0)
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(0, 0, frame_size, frame_size)
			return atlas
	var fallback_path: String = str(NPC_FALLBACK_SPRITES.get(npc_id, ""))
	return load(fallback_path) as Texture2D if not fallback_path.is_empty() else null

func _clear_npcs() -> void:
	if npc_layer == null:
		return
	for child in npc_layer.get_children():
		# 先摘下来再 queue_free：queue_free 要等到帧末才生效，只调它的话同一帧里
		# 新旧 NPC 节点会同名并存，get_node 可能拿到那个正要释放的旧节点
		# （悬停标签看起来"没更新"就是这么来的），中间还会多绘制一帧。
		npc_layer.remove_child(child)
		child.queue_free()

func _on_npc_pressed(npc_id: String) -> void:
	if not input_blocked:
		npc_requested.emit(npc_id)

func apply_story_unlocks(state: Dictionary, time_source = null) -> void:
	if int(state.get("age", 22)) >= 40 or bool(state.get("flags", {}).get("dark_pursued", false)):
		unlocked["rooftop"] = true
	var flags: Dictionary = state.get("flags", {})
	var clues: Array = state.get("clues", [])
	var night_ok: bool = true
	if time_source != null:
		var minute: int = int(time_source.get_minute_of_day())
		night_ok = minute >= 18 * 60 + 30 or minute < 4 * 60 + 30
	if clues.size() >= 6 or bool(flags.get("dark_alley_revealed", false)):
		if night_ok:
			unlocked["alley"] = true
	_refresh_travel_buttons()

func to_save_dict() -> Dictionary:
	return {
		"current_location": current_location,
		"unlocked": unlocked.duplicate(true),
		"visited": visited.duplicate(true),
	}

func apply_save_dict(data: Dictionary) -> void:
	var u = data.get("unlocked", {"home": true})
	var v = data.get("visited", {})
	unlocked = u if typeof(u) == TYPE_DICTIONARY else {"home": true}
	visited = v if typeof(v) == TYPE_DICTIONARY else {}
	unlocked["home"] = true
	current_location = str(data.get("current_location", "home"))
	if not LOCATIONS.has(current_location) or not is_unlocked(current_location):
		current_location = "home"
	set_active(true)
	_refresh()
