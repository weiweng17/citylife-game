extends Node
class_name WorldManager

const NPCScene = preload("res://scenes/world/NPC.tscn")
const POIScene = preload("res://scenes/world/POI.tscn")
const CompanyScene = preload("res://scenes/interiors/Company.tscn")

const MAP_W := 1080.0
const MAP_H := 1080.0

const BUILDINGS := [
	{"id": "home", "x": 150, "w": 320, "base": 360, "fh": 230},
	{"id": "hospital", "x": 790, "w": 280, "base": 240, "fh": 215},
	{"id": "office", "x": 790, "w": 280, "base": 500, "fh": 250},
	{"id": "store", "x": 260, "w": 250, "base": 940, "fh": 140},
	{"id": "old", "x": 30, "w": 170, "base": 960, "fh": 150},
]
const TREES := [
	Vector2(80, 640), Vector2(170, 640), Vector2(350, 640), Vector2(450, 640), Vector2(560, 650),
	Vector2(790, 640), Vector2(900, 640), Vector2(1010, 640),
	Vector2(80, 858), Vector2(150, 858), Vector2(560, 858), Vector2(650, 858), Vector2(880, 858), Vector2(980, 858),
	Vector2(110, 470), Vector2(190, 450), Vector2(350, 480), Vector2(390, 620), Vector2(120, 620), Vector2(60, 560),
]
const LAMPS := [
	Vector2(120, 672), Vector2(330, 672), Vector2(540, 672),
	Vector2(250, 828), Vector2(470, 828), Vector2(690, 828), Vector2(910, 828),
	Vector2(622, 300), Vector2(622, 520), Vector2(750, 200), Vector2(750, 420),
	Vector2(240, 505),
]

var world: Node2D
var interior: Node2D
var npc_nodes: Array = []
var poi_nodes: Dictionary = {}
var interior_npcs: Array = []
var inside := ""

var _ring_tex: ImageTexture
var _lm_img: Image
var _lm_w := 0
var _lm_h := 0
var _rain: Sprite2D
var _rain_off := 0.0
var _ambient: CanvasModulate
var _vignette: TextureRect
var _weather_overlay: ColorRect
var _rain_speed_multiplier := 1.0

func build(host: Node2D, player: CharacterBody2D, poi_data: Array, npc_data: Array) -> void:
	world = Node2D.new()
	world.name = "World"
	host.add_child(world)
	_build_ground()
	_build_buildings()
	_build_trees()
	_build_pois(poi_data)
	_build_npcs(npc_data)
	_build_interior(host)
	_setup_camera(player)
	_setup_atmosphere(host)

func _build_ground() -> void:
	var g := Sprite2D.new()
	g.name = "Ground"
	g.texture = load("res://assets/scene/ground.png")
	g.centered = false
	g.position = Vector2.ZERO
	g.z_index = -100
	g.light_mask = 0
	g.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	world.add_child(g)

func _build_buildings() -> void:
	for sp in BUILDINGS:
		var body := StaticBody2D.new()
		body.name = sp["id"]
		body.position = Vector2(sp["x"], sp["base"])
		var tex := Sprite2D.new()
		tex.texture = load("res://assets/sprites/building_%s.png" % sp["id"])
		tex.centered = false
		tex.position = Vector2(0, -sp["fh"])
		tex.light_mask = 0
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		body.add_child(tex)
		var cs := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(sp["w"], 36)
		cs.shape = rect
		cs.position = Vector2(sp["w"] / 2.0, -18)
		body.add_child(cs)
		world.add_child(body)

func _build_trees() -> void:
	for p in TREES:
		var t := Sprite2D.new()
		t.name = "Tree"
		t.texture = load("res://assets/sprites/tree.png")
		t.centered = false
		t.position = Vector2(p.x - 28, p.y - 62)
		t.z_index = 1
		t.light_mask = 0
		t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		world.add_child(t)
	for p in LAMPS:
		var l := Sprite2D.new()
		l.name = "Lamp"
		l.texture = load("res://assets/sprites/lamp.png")
		l.centered = false
		l.position = Vector2(p.x - 11, p.y - 34)
		l.z_index = 2
		l.light_mask = 0
		l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		world.add_child(l)

func _build_pois(poi_data: Array) -> void:
	poi_nodes.clear()
	for d in poi_data:
		var poi = POIScene.instantiate()
		world.add_child(poi)
		poi.configure(d)
		poi_nodes[str(d.get("id", ""))] = poi


func set_poi_state(id: String, interactable: bool, display_label: String = "", lock_reason: String = "", highlighted: bool = false) -> void:
	var poi = poi_nodes.get(id)
	if poi != null and is_instance_valid(poi) and poi.has_method("set_world_state"):
		poi.set_world_state(interactable, display_label, lock_reason, highlighted)


func is_poi_interactable(id: String) -> bool:
	var poi = poi_nodes.get(id)
	if poi == null or not is_instance_valid(poi):
		return true
	return poi.is_interactable() if poi.has_method("is_interactable") else true


func get_poi_lock_reason(id: String) -> String:
	var poi = poi_nodes.get(id)
	if poi == null or not is_instance_valid(poi):
		return ""
	return str(poi.get_lock_reason()) if poi.has_method("get_lock_reason") else ""

func _build_npcs(npc_data: Array) -> void:
	for d in npc_data:
		var npc = NPCScene.instantiate()
		world.add_child(npc)
		npc.configure(d)
		npc_nodes.append(npc)

func _build_interior(host: Node2D) -> void:
	interior = CompanyScene.instantiate()
	interior.name = "Interior"
	host.add_child(interior)
	if interior.has_method("get_interaction_npcs"):
		interior_npcs = interior.get_interaction_npcs()

func _setup_camera(player: CharacterBody2D) -> void:
	var cam := player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = int(MAP_W)
		cam.limit_bottom = int(MAP_H)
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = 10.0
		# 横屏 16:9 下保持原 1080×1080 地图可玩范围，不让视野一次露出地图边界。
		cam.zoom = Vector2(1.25, 1.25)

func _setup_atmosphere(host: Node2D) -> void:
	_ambient = CanvasModulate.new()
	_ambient.name = "Ambient"
	_ambient.color = Color.WHITE
	host.add_child(_ambient)
	var lm_tex: Texture2D = load("res://assets/scene/lightmap.png")
	if lm_tex != null:
		_lm_img = lm_tex.get_image()
		if _lm_img != null:
			_lm_w = _lm_img.get_width()
			_lm_h = _lm_img.get_height()
	var vul := CanvasLayer.new()
	vul.name = "Vignette"
	vul.layer = 0
	_vignette = TextureRect.new()
	_vignette.texture = load("res://assets/sprites/vignette.png")
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vul.add_child(_vignette)
	host.add_child(vul)
	var weather_layer := CanvasLayer.new()
	weather_layer.name = "WeatherOverlay"
	weather_layer.layer = 1
	_weather_overlay = ColorRect.new()
	_weather_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_weather_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weather_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	weather_layer.add_child(_weather_overlay)
	host.add_child(weather_layer)
	_rain = Sprite2D.new()
	_rain.name = "Rain"
	_rain.texture = load("res://assets/sprites/rain.png")
	_rain.centered = false
	_rain.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_rain.region_enabled = true
	_rain.region_rect = Rect2(0, 0, MAP_W, MAP_H)
	_rain.z_index = 60
	_rain.light_mask = 0
	_rain.modulate = Color(0.85, 0.92, 1.0, 0.5)
	_rain.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	world.add_child(_rain)

func process_visuals(delta: float, player: CharacterBody2D, time_source = null, weather_source = null) -> void:
	_apply_time_visuals(time_source, weather_source)
	_apply_entity_light(player)
	_scroll_rain(delta)

func _apply_time_visuals(time_source, weather_source = null) -> void:
	if time_source == null:
		return
	var weather_mul := Color.WHITE
	var weather_overlay := Color(1.0, 1.0, 1.0, 0.0)
	var rain_alpha := 0.0
	_rain_speed_multiplier = 1.0
	if weather_source != null:
		weather_mul = weather_source.get_ambient_multiplier()
		weather_overlay = weather_source.get_overlay_color()
		rain_alpha = weather_source.get_rain_alpha()
		_rain_speed_multiplier = weather_source.get_rain_speed_multiplier()
	if _ambient:
		if inside != "":
			_ambient.color = Color(1.0, 0.98, 0.94, 1.0)
		else:
			var base: Color = time_source.get_ambient_color()
			_ambient.color = Color(base.r * weather_mul.r, base.g * weather_mul.g, base.b * weather_mul.b, 1.0)
	if _vignette:
		_vignette.modulate.a = 0.42 if inside != "" else time_source.get_vignette_alpha()
	if _weather_overlay:
		_weather_overlay.color = Color(weather_overlay.r, weather_overlay.g, weather_overlay.b, 0.0 if inside != "" else weather_overlay.a)
	if _rain:
		_rain.visible = rain_alpha > 0.01
		_rain.modulate = Color(0.85, 0.92, 1.0, 0.12 if inside != "" and rain_alpha > 0.0 else rain_alpha)

func _apply_entity_light(player: CharacterBody2D) -> void:
	if player and player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").modulate = light_at(player.position)
	for n in npc_nodes:
		if not is_instance_valid(n) or not n.visible:
			continue
		var sp: Sprite2D = n.get_node_or_null("Sprite2D")
		if sp != null:
			sp.modulate = light_at(n.position)

func _scroll_rain(delta: float) -> void:
	if _rain == null:
		return
	_rain_off += delta * 70.0 * _rain_speed_multiplier
	_rain.region_rect.position = Vector2(_rain_off, _rain_off * 1.7)

func light_at(pos: Vector2) -> Color:
	if inside != "":
		return Color(1.0, 0.98, 0.94, 1.0)
	if _lm_img == null or _lm_w == 0:
		return Color.WHITE
	var px := clampi(int(pos.x / 4.0), 0, _lm_w - 1)
	var py := clampi(int(pos.y / 4.0), 0, _lm_h - 1)
	var c: Color = _lm_img.get_pixel(px, py)
	return Color(c.r * 1.3, c.g * 1.3, c.b * 1.3, 1.0)

func spawn_move_marker(pos: Vector2) -> void:
	if world == null or not world.visible:
		return
	var m := Sprite2D.new()
	m.name = "MoveMarker"
	m.texture = _get_ring_tex()
	m.position = pos
	m.z_index = 200
	world.add_child(m)
	var tw := create_tween()
	tw.tween_property(m, "scale", Vector2(0.5, 0.5), 0.45).from(Vector2(1.25, 1.25)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(m, "modulate:a", 0.0, 0.45)
	tw.tween_callback(m.queue_free)

func _get_ring_tex() -> ImageTexture:
	if _ring_tex != null:
		return _ring_tex
	var s := 48
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := float(s) / 2.0
	for y in s:
		for x in s:
			var dx := float(x) - c + 0.5
			var dy := float(y) - c + 0.5
			var r := sqrt(dx * dx + dy * dy)
			if r >= 17.0 and r <= 22.0:
				img.set_pixel(x, y, Color(1, 1, 1, 0.95))
			elif r <= 4.5:
				img.set_pixel(x, y, Color(1, 1, 1, 0.90))
	_ring_tex = ImageTexture.create_from_image(img)
	return _ring_tex

func enter_interior(id: String, player: CharacterBody2D) -> void:
	if interior == null:
		return
	inside = id
	world.visible = false
	interior.visible = true
	var spawn_pos: Vector2 = interior.get("player_spawn") if interior.get("player_spawn") != null else Vector2(540, 900)
	player.position = spawn_pos
	player.set_target(player.position)

func exit_interior(player: CharacterBody2D) -> void:
	inside = ""
	if interior:
		interior.visible = false
	world.visible = true
	var exit_pos := Vector2(935, 565)
	if interior and interior.get("world_exit_position") != null:
		exit_pos = interior.get("world_exit_position")
	player.position = exit_pos
	player.set_target(player.position)

func get_exit_door():
	if interior == null:
		return null
	if interior.has_method("get_exit_door"):
		return interior.get_exit_door()
	return interior.get_node_or_null("InteriorDoor")


func to_save_dict(player: CharacterBody2D) -> Dictionary:
	var pos := Vector2.ZERO
	if player != null:
		pos = player.position
	return {
		"inside": inside,
		"player_position": [pos.x, pos.y],
	}


func apply_save_dict(data: Dictionary, player: CharacterBody2D) -> void:
	var saved_inside := str(data.get("inside", ""))
	inside = saved_inside
	if world:
		world.visible = saved_inside == ""
	if interior:
		interior.visible = saved_inside != ""
	var pos_data = data.get("player_position", [])
	if player != null and pos_data is Array and pos_data.size() >= 2:
		player.position = Vector2(float(pos_data[0]), float(pos_data[1]))
		player.set_target(player.position)

func set_legacy_world_visible(value: bool) -> void:
	if world:
		world.visible = value
	if interior:
		interior.visible = false
	if _rain:
		_rain.visible = value and _rain.visible
