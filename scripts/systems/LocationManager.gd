extends CanvasLayer
class_name LocationManager
## MAP-002：独立地点 + 地点内可移动原型。
## 每个地点使用独立背景；玩家可用 WASD/方向键/点击地面移动。

signal action_requested(location_id: String)
signal travel_requested(location_id: String)
signal npc_requested(npc_id: String)

const PLAYER_SHEET := "res://assets/characters/sprites/gameplay/protagonist_walk_4x4.png"
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
		"spawn": Vector2(640, 455),
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
		"spawn": Vector2(610, 475),
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
	"home": {"bounds": Rect2(70, 250, 1110, 335), "blocked": [Rect2(72, 360, 330, 210), Rect2(455, 448, 270, 118), Rect2(620, 228, 270, 170), Rect2(380, 535, 470, 120), Rect2(975, 210, 220, 375)]},
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

# NPC 在每个独立场景中的屏幕位置。
const NPC_SCREEN_POS := {
	"xiaoyu": Vector2(430, 410),
	"chenjie": Vector2(890, 400),
	"laozhang": Vector2(905, 430),
	"laozhou": Vector2(410, 415),
	"azhe": Vector2(900, 430),
	"daoshi": Vector2(930, 430),
}

var current_location: String = "home"
var unlocked: Dictionary = {"home": true}
var visited: Dictionary = {}
var active: bool = false

var root: Control
var background: TextureRect
var shade: ColorRect
var title_label: Label
var subtitle_label: Label
var travel_box: HBoxContainer
var action_button: Button
var hint_label: Label
var player_sprite: AnimatedSprite2D
var player_shadow: Polygon2D
var player_target: Vector2 = Vector2.ZERO
var npc_layer: Control
var npc_signature: String = ""
var current_lighting: Color = Color.WHITE

func _ready() -> void:
	layer = 0
	_build_ui()
	set_process(true)

func _build_ui() -> void:
	root = Control.new()
	root.name = "LocationView"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.gui_input.connect(_on_root_gui_input)
	add_child(root)

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

	npc_layer = Control.new()
	npc_layer.name = "NpcHotspots"
	npc_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	npc_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(npc_layer)

	var header: PanelContainer = PanelContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 24
	header.offset_right = -24
	header.offset_top = 74
	header.offset_bottom = 150
	header.mouse_filter = Control.MOUSE_FILTER_STOP
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
	footer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 20
	footer.offset_right = -20
	footer.offset_top = -112
	footer.offset_bottom = -16
	footer.mouse_filter = Control.MOUSE_FILTER_STOP
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
	# 这些节点都使用全屏锚点。这里只保证浏览器重绘后回到原点，避免手动改尺寸
	# 导致 Godot 覆盖锚点尺寸并产生布局警告。
	if root != null:
		root.position = Vector2.ZERO

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

func _make_ground_shadow(width: float, height: float, color: Color) -> Polygon2D:
	var shadow := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(20):
		var angle: float = TAU * float(i) / 20.0
		points.append(Vector2(cos(angle) * width, sin(angle) * height))
	shadow.polygon = points
	shadow.color = color
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
	action_button.text = "在%s行动" % str(info.get("name", current_location)).split(" · ")[0]
	var spawn: Vector2 = info.get("spawn", Vector2(640, 460))
	player_sprite.position = spawn
	player_sprite.modulate = current_lighting
	_update_player_grounding()
	player_target = spawn
	player_sprite.stop()
	player_sprite.animation = "walk_down"
	player_sprite.frame = 0
	npc_signature = ""
	_clear_npcs()
	_refresh_travel_buttons()

func _refresh_travel_buttons() -> void:
	if travel_box == null:
		return
	for child in travel_box.get_children():
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
	travel_to(id)

func _on_action_pressed() -> void:
	action_requested.emit(current_location)

func _on_root_gui_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			player_target = _clamp_walk_position(mouse_event.position)

func _process(delta: float) -> void:
	_sync_web_layout()
	if not active or player_sprite == null:
		return
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	if Input.is_key_pressed(KEY_W): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S): direction.y += 1.0
	if direction.length() > 0.05:
		direction = direction.normalized()
		player_target = player_sprite.position
		_move_player(direction, delta)
		return
	var offset: Vector2 = player_target - player_sprite.position
	if offset.length() > 5.0:
		_move_player(offset.normalized(), delta)
	else:
		player_sprite.position = player_target
		_update_player_grounding()
		player_sprite.stop()
		player_sprite.frame = 0

func _move_player(direction: Vector2, delta: float) -> void:
	var next_pos: Vector2 = player_sprite.position + direction * PLAYER_SPEED * delta
	player_sprite.position = _clamp_walk_position(next_pos)
	_update_player_grounding()
	var anim: String = "walk_down"
	if abs(direction.x) > abs(direction.y):
		anim = "walk_right" if direction.x > 0.0 else "walk_left"
	else:
		anim = "walk_down" if direction.y > 0.0 else "walk_up"
	if player_sprite.animation != anim:
		player_sprite.animation = anim
	if not player_sprite.is_playing():
		player_sprite.play()

func _update_player_grounding() -> void:
	if player_sprite == null:
		return
	player_sprite.z_index = maxi(5, int(player_sprite.position.y))
	if player_shadow != null:
		player_shadow.position = player_sprite.position + Vector2(0.0, 4.0)
		player_shadow.z_index = maxi(4, player_sprite.z_index - 1)

func _clamp_walk_position(pos: Vector2) -> Vector2:
	var profile: Dictionary = NAVIGATION.get(current_location, {})
	var bounds: Rect2 = profile.get("bounds", Rect2(85, 205, 1110, 360))
	var radius: float = 13.0
	var result := Vector2(
		clampf(pos.x, bounds.position.x + radius, bounds.end.x - radius),
		clampf(pos.y, bounds.position.y + radius, bounds.end.y - radius)
	)
	for raw_obstacle in profile.get("blocked", []):
		if raw_obstacle is Rect2:
			result = _push_out_of_obstacle(result, (raw_obstacle as Rect2).grow(radius))
	return result

func _push_out_of_obstacle(pos: Vector2, obstacle: Rect2) -> Vector2:
	if not obstacle.has_point(pos):
		return pos
	var distances := {
		"left": absf(pos.x - obstacle.position.x),
		"right": absf(obstacle.end.x - pos.x),
		"top": absf(pos.y - obstacle.position.y),
		"bottom": absf(obstacle.end.y - pos.y),
	}
	var side: String = "left"
	for candidate in distances:
		if float(distances[candidate]) < float(distances[side]):
			side = candidate
	match side:
		"left": return Vector2(obstacle.position.x - 0.5, pos.y)
		"right": return Vector2(obstacle.end.x + 0.5, pos.y)
		"top": return Vector2(pos.x, obstacle.position.y - 0.5)
		_: return Vector2(pos.x, obstacle.end.y + 0.5)

func set_visible_npcs(items: Array) -> void:
	var parts: Array[String] = []
	for item in items:
		if typeof(item) == TYPE_DICTIONARY:
			parts.append("%s:%s" % [str(item.get("id", "")), str(item.get("name", ""))])
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
		var pos: Vector2 = NPC_SCREEN_POS.get(npc_id, Vector2(900, 420))
		_add_npc_entity(npc_id, str(item.get("name", npc_id)), pos)


func _add_npc_entity(npc_id: String, display_name: String, pos: Vector2) -> void:
	# 阴影、角色、标签拆开，避免 NPC 像悬在背景上的文字按钮。
	var shadow := _make_ground_shadow(24.0, 7.0, Color(0.0, 0.0, 0.0, 0.30))
	shadow.position = pos + Vector2(0.0, 32.0)
	shadow.z_index = maxi(1, int(pos.y) - 1)
	npc_layer.add_child(shadow)

	var button := Button.new()
	button.name = "Npc_%s" % npc_id
	button.flat = true
	button.tooltip_text = "与%s交谈" % display_name
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
	label.text = display_name
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
		child.queue_free()

func _on_npc_pressed(npc_id: String) -> void:
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
