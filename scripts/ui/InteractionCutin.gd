extends CanvasLayer
## 通用复杂交互演出层。
##
## 地图仍负责移动、寻路和交互锚点；复杂动作改用独立动漫 Cut-in 表现，
## 避免继续把角色硬塞进已经烘焙好的背景透视。
## 当前只接：出租屋 -> 床 -> 休息。业务结算仍完全由 Game.gd 负责。

const MIN_HOLD_MS := 1250
const FADE_IN_SECONDS := 0.22
const FADE_OUT_SECONDS := 0.22

const HOME_BG := preload("res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp")
const HOME_SLEEP_SUBJECT := preload("res://assets/characters/sprites/interactions/protagonist_sleep_side_v6.png")
const HOME_SLEEP_CUTIN_PATH := "res://assets/cutins/home_sleep_v1.webp"

# key = "location_id:interactionType"
# `image_path` 是正式完整 16:9 Cut-in；如果本地尚未放入该文件，会自动回退到
# background + subject 原型，确保代码可以先被拉取和测试，不破坏旧逻辑。
const PRESENTATIONS := {
	"home:bed": {
		"image_path": HOME_SLEEP_CUTIN_PATH,
		"background": HOME_BG,
		"subject": HOME_SLEEP_SUBJECT,
		"title": "雨夜 · 休息",
		"subtitle": "让时间慢下来。",
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
	_dim.color = Color(0.025, 0.02, 0.035, 0.24)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_dim)

	# 只有缺少完整 Cut-in 素材时才显示这个 fallback 主体。
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
	caption_back.color = Color(0.015, 0.018, 0.028, 0.50)
	caption_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(caption_back)

	_title = Label.new()
	_title.name = "Title"
	_title.anchor_left = 0.065
	_title.anchor_top = 0.80
	_title.anchor_right = 0.68
	_title.anchor_bottom = 0.88
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 1.0))
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_title)

	_subtitle = Label.new()
	_subtitle.name = "Subtitle"
	_subtitle.anchor_left = 0.066
	_subtitle.anchor_top = 0.89
	_subtitle.anchor_right = 0.72
	_subtitle.anchor_bottom = 0.95
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
	if game == null:
		return ""
	if game.get("activity_running") != true:
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
	_hold_until_ms = Time.get_ticks_msec() + MIN_HOLD_MS

	var image_path := str(cfg.get("image_path", ""))
	var has_full_cutin := not image_path.is_empty() and ResourceLoader.exists(image_path)
	if has_full_cutin:
		_background.texture = load(image_path) as Texture2D
		_subject.visible = false
		# 完整 Cut-in 自带统一光影，不再盖过重暗幕。
		_dim.color = Color(0.025, 0.02, 0.035, 0.08)
	else:
		_background.texture = cfg.get("background") as Texture2D
		_subject.texture = cfg.get("subject") as Texture2D
		_subject.visible = true
		_dim.color = Color(0.025, 0.02, 0.035, 0.24)

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
	# Cut-in 出现期间吞掉输入，避免活动刚结算时点击穿透到地图。
	if _root != null and _root.visible:
		get_viewport().set_input_as_handled()
