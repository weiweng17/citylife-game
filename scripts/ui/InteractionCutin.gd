extends CanvasLayer
## 通用复杂交互演出层。
## 地图负责移动/寻路/锚点；活动期间用独立 Cut-in 表现，业务结算仍由 Game.gd 负责。
## 完整 16:9 素材存在时优先使用；缺素材时自动回退到地点背景，保证批量接入不阻塞玩法。

const DEFAULT_HOLD_MS := 1250
const FADE_IN_SECONDS := 0.22
const FADE_OUT_SECONDS := 0.22

const HOME_BG := preload("res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp")
const OFFICE_BG := preload("res://assets/backgrounds/dialogue/company/company_entrance_rain_night.webp")
const STORE_BG := preload("res://assets/backgrounds/dialogue/life/convenience_store_rain_night.webp")
const CAFE_BG := preload("res://assets/backgrounds/dialogue/life/cafe_rain_night.webp")
const PARK_BG := preload("res://assets/backgrounds/dialogue/life/park_pavilion_rain_night.webp")
const HOSPITAL_BG := preload("res://assets/backgrounds/dialogue/hospital/clinic_room_rain_night.webp")
const HOME_SLEEP_SUBJECT := preload("res://assets/characters/sprites/interactions/protagonist_sleep_side_v6.png")

# key = "location_id:interactionType"。
# image_path 是可选正式演出图；不存在时使用 background（以及可选 subject）作为 fallback。
const PRESENTATIONS := {
	"home:bed": {
		"image_path": "res://assets/cutins/home_sleep_v1.webp",
		"background": HOME_BG, "subject": HOME_SLEEP_SUBJECT,
		"title": "雨夜 · 休息", "subtitle": "让时间慢下来。", "hold_ms": 1500,
	},
	"home:desk": {
		"image_path": "res://assets/cutins/home_study_v1.webp",
		"background": HOME_BG,
		"title": "灯下 · 学习", "subtitle": "把今天留下的一点时间，换成明天的可能。",
	},
	"home:kitchen": {
		"image_path": "res://assets/cutins/home_cook_v1.webp",
		"background": HOME_BG,
		"title": "厨房 · 做饭", "subtitle": "热气升起来，出租屋也像个家。",
	},
	"office:work": {
		"image_path": "res://assets/cutins/office_work_v1.webp",
		"background": OFFICE_BG,
		"title": "云海科技 · 上班", "subtitle": "屏幕亮着，城市的夜也还没结束。", "hold_ms": 1450,
	},
	"office:negotiate": {
		"background": OFFICE_BG,
		"title": "大堂 · 谈薪", "subtitle": "有些话，要在真正开口之后才有答案。",
	},
	"store:shop": {
		"image_path": "res://assets/cutins/store_shop_v1.webp",
		"background": STORE_BG,
		"title": "街角便利店 · 选购", "subtitle": "给接下来的生活，备一点余地。",
	},
	"cafe:coffee": {
		"background": CAFE_BG,
		"title": "靠窗吧台 · 咖啡", "subtitle": "雨声、磨豆声，还有短暂的安静。",
	},
	"cafe:idle": {
		"background": CAFE_BG,
		"title": "圆桌 · 发呆", "subtitle": "什么都不做，也可以是一种安排。",
	},
	"park:bench": {
		"background": PARK_BG,
		"title": "公园长椅 · 歇脚", "subtitle": "雨没有停，你可以先停一会儿。",
	},
	"park:pond": {
		"background": PARK_BG,
		"title": "池塘边 · 看雨", "subtitle": "水面把城市的灯揉成一片。",
	},
	"hospital:clinic": {
		"background": HOSPITAL_BG,
		"title": "仁心医院 · 就诊", "subtitle": "照顾好自己，才有力气继续往前。",
	},
	"hospital:bench": {
		"background": HOSPITAL_BG,
		"title": "候诊椅 · 缓一缓", "subtitle": "坐一会儿，让呼吸慢下来。",
	},
}

var _root: Control
var _background: TextureRect
var _subject: TextureRect
var _dim: ColorRect
var _title: Label
var _subtitle: Label
var _visible_key := ""
var _hold_until_ms: int = 0
var _hiding := false
var _fade: Tween

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_root.visible = false

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "InteractionCutinRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_background = TextureRect.new()
	_background.name = "Background"
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_background)

	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.color = Color(0.025, 0.02, 0.035, 0.22)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_dim)

	_subject = TextureRect.new()
	_subject.name = "FallbackSubject"
	_subject.anchor_left = 0.02
	_subject.anchor_top = 0.12
	_subject.anchor_right = 0.70
	_subject.anchor_bottom = 0.94
	_subject.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_subject.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_subject.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_subject)

	var caption_back := ColorRect.new()
	caption_back.name = "CaptionBackdrop"
	caption_back.anchor_left = 0.0
	caption_back.anchor_top = 0.76
	caption_back.anchor_right = 1.0
	caption_back.anchor_bottom = 1.0
	caption_back.color = Color(0.015, 0.018, 0.028, 0.52)
	caption_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(caption_back)

	_title = Label.new()
	_title.name = "Title"
	_title.anchor_left = 0.065
	_title.anchor_top = 0.80
	_title.anchor_right = 0.78
	_title.anchor_bottom = 0.88
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 1.0))
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_title)

	_subtitle = Label.new()
	_subtitle.name = "Subtitle"
	_subtitle.anchor_left = 0.066
	_subtitle.anchor_top = 0.89
	_subtitle.anchor_right = 0.82
	_subtitle.anchor_bottom = 0.96
	_subtitle.add_theme_font_size_override("font_size", 17)
	_subtitle.add_theme_color_override("font_color", Color(0.86, 0.87, 0.91, 0.92))
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_subtitle)

func _process(_delta: float) -> void:
	var key := _resolve_current_presentation()
	if not key.is_empty():
		if key != _visible_key or not _root.visible:
			_show_presentation(key)
		return
	if _root.visible and not _hiding and Time.get_ticks_msec() >= _hold_until_ms:
		_hide_presentation()

func _resolve_current_presentation() -> String:
	var game := get_tree().current_scene
	if game == null or game.get("activity_running") != true:
		return ""
	var location := game.get_node_or_null("LocationSys")
	if location == null or location.get("active") != true:
		return ""
	var anchor = location.get("interaction_anchor")
	if typeof(anchor) != TYPE_DICTIONARY or anchor.is_empty():
		return ""
	var interaction_type := str(anchor.get("interactionType", ""))
	if interaction_type.is_empty():
		return ""
	var key := "%s:%s" % [str(location.get("current_location")), interaction_type]
	return key if PRESENTATIONS.has(key) else ""

func _show_presentation(key: String) -> void:
	var cfg: Dictionary = PRESENTATIONS[key]
	_visible_key = key
	_hiding = false
	_hold_until_ms = Time.get_ticks_msec() + int(cfg.get("hold_ms", DEFAULT_HOLD_MS))

	var image_path := str(cfg.get("image_path", ""))
	var has_full_cutin := not image_path.is_empty() and ResourceLoader.exists(image_path)
	var subject_texture = cfg.get("subject", null)
	if has_full_cutin:
		_background.texture = load(image_path) as Texture2D
		_subject.visible = false
		_dim.color = Color(0.025, 0.02, 0.035, 0.08)
	else:
		_background.texture = cfg.get("background") as Texture2D
		_subject.texture = subject_texture as Texture2D
		_subject.visible = subject_texture != null
		_dim.color = Color(0.025, 0.02, 0.035, 0.22 if _subject.visible else 0.32)

	_title.text = str(cfg.get("title", ""))
	_subtitle.text = str(cfg.get("subtitle", ""))
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_root.visible = true
	_root.modulate.a = 0.0
	_subject.modulate = Color(1.0, 0.90, 0.80, 0.0 if _subject.visible else 1.0)
	_fade = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_fade.tween_property(_root, "modulate:a", 1.0, FADE_IN_SECONDS)
	if _subject.visible:
		_fade.tween_property(_subject, "modulate:a", 1.0, FADE_IN_SECONDS + 0.08)

func _hide_presentation() -> void:
	_hiding = true
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_fade.tween_property(_root, "modulate:a", 0.0, FADE_OUT_SECONDS)
	_fade.tween_callback(_finish_hide)

func _finish_hide() -> void:
	_root.visible = false
	_root.modulate.a = 1.0
	_visible_key = ""
	_hiding = false

func _input(_event: InputEvent) -> void:
	if _root != null and _root.visible:
		get_viewport().set_input_as_handled()
