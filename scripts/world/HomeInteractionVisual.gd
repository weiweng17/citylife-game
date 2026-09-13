extends Node2D
class_name HomeInteractionVisual
## 出租屋床的真实美术层：睡姿、被子前景、头部 Z 效果均以同一场景坐标空间布置。
## 这里刻意不绘制 Polygon2D 或纯色几何遮挡；被子是带 alpha 的正式纹理资源。

const LEGACY_SLEEP_TEXTURE := preload("res://assets/characters/sprites/interactions/protagonist_sleep_side_v6.png")
const LEGACY_BLANKET_TEXTURE := preload("res://assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png")
const BACKGROUND_BLANKET_V2_TEXTURE := preload("res://assets/backgrounds/interactions/home_bed_blanket_foreground_v2.png")
const BACKGROUND_BLANKET_V3_TEXTURE := preload("res://assets/backgrounds/interactions/home_bed_blanket_foreground_v3.png")
const CANDIDATE_SLEEP_TEXTURE := preload("res://assets/characters/sprites/interactions/protagonist_sleep_side_candidate_v1.png")
const CANDIDATE_BLANKET_TEXTURE := preload("res://assets/backgrounds/interactions/home_bed_blanket_foreground_candidate_v1.png")

# 候选睡姿图横向包含入睡帧和睡眠帧；仅取右侧睡眠区域。校准值只用于 A/B 视觉对比。
const LEGACY_SLEEP_SCALE := Vector2(0.205, 0.205)
const LEGACY_BLANKET_SCALE := Vector2(0.205, 0.205)
const CANDIDATE_SLEEP_REGION := Rect2(51, 0, 94, 105)
const CANDIDATE_SLEEP_SCALE := Vector2(2.15, 2.15)
const CANDIDATE_BLANKET_SCALE := Vector2(1.38, 1.38)
# v2 是从 1672×941 正式背景的 (100,390,470,280) 裁图提取；按 1280×720 显示比例还原。
const BACKGROUND_BLANKET_V2_SCALE := Vector2(0.7655, 0.7651)
const BACKGROUND_BLANKET_V2_LOCAL_POSITION := Vector2(1.5, -6.5)
# v3 是原背景 (300,480,190,90) 的腰腿局部，显示坐标恢复后中心落在床面内。
const BACKGROUND_BLANKET_V3_SCALE := Vector2(0.7655, 0.7651)
const BACKGROUND_BLANKET_V3_LOCAL_POSITION := Vector2(47.0, -10.0)
const BACKGROUND_BLANKET_V3_SLEEP_SCALE := Vector2(0.185, 0.185)
const BACKGROUND_BLANKET_V3_SLEEP_LOCAL_POSITION := Vector2(-28.0, -23.0)

var sleeping := false
var use_candidate_bed_group := false
var use_background_blanket_v2 := false
var use_background_blanket_v3 := false
var breath := 0.0
var sleep_sprite: Sprite2D
var blanket_sprite: Sprite2D
var z_label: Label
var sleep_position := Vector2.ZERO
var head_position := Vector2.ZERO

func _ready() -> void:
	sleep_sprite = Sprite2D.new()
	sleep_sprite.name = "SleepPose"
	sleep_sprite.texture = LEGACY_SLEEP_TEXTURE
	sleep_sprite.centered = true
	sleep_sprite.scale = LEGACY_SLEEP_SCALE
	sleep_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sleep_sprite.z_index = 0
	add_child(sleep_sprite)

	blanket_sprite = Sprite2D.new()
	blanket_sprite.name = "BedBlanketForeground"
	blanket_sprite.texture = LEGACY_BLANKET_TEXTURE
	blanket_sprite.centered = true
	blanket_sprite.scale = LEGACY_BLANKET_SCALE
	blanket_sprite.position = Vector2(0, 42)
	blanket_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	blanket_sprite.z_index = 2
	add_child(blanket_sprite)

	z_label = Label.new()
	z_label.name = "SleepHeadEffect"
	z_label.text = "z"
	z_label.add_theme_font_size_override("font_size", 24)
	z_label.add_theme_color_override("font_color", Color(0.72, 0.77, 0.90, 0.88))
	z_label.z_index = 3
	add_child(z_label)
	visible = false
	_apply_bed_group()

func set_candidate_bed_group(enabled: bool) -> void:
	use_candidate_bed_group = enabled
	_apply_bed_group()

func set_background_blanket_v2(enabled: bool) -> void:
	use_background_blanket_v2 = enabled
	_apply_bed_group()

func set_background_blanket_v3(enabled: bool) -> void:
	use_background_blanket_v3 = enabled
	_apply_bed_group()

func _apply_bed_group() -> void:
	if sleep_sprite == null or blanket_sprite == null:
		return
	if use_candidate_bed_group:
		sleep_sprite.texture = CANDIDATE_SLEEP_TEXTURE
		sleep_sprite.region_enabled = true
		sleep_sprite.region_rect = CANDIDATE_SLEEP_REGION
		sleep_sprite.position = Vector2.ZERO
		sleep_sprite.scale = CANDIDATE_SLEEP_SCALE
		blanket_sprite.texture = CANDIDATE_BLANKET_TEXTURE
		blanket_sprite.scale = CANDIDATE_BLANKET_SCALE
		blanket_sprite.position = Vector2(0, 32)
	elif use_background_blanket_v3:
		sleep_sprite.texture = LEGACY_SLEEP_TEXTURE
		sleep_sprite.region_enabled = false
		sleep_sprite.position = BACKGROUND_BLANKET_V3_SLEEP_LOCAL_POSITION
		sleep_sprite.scale = BACKGROUND_BLANKET_V3_SLEEP_SCALE
		blanket_sprite.texture = BACKGROUND_BLANKET_V3_TEXTURE
		blanket_sprite.scale = BACKGROUND_BLANKET_V3_SCALE
		blanket_sprite.position = BACKGROUND_BLANKET_V3_LOCAL_POSITION
	elif use_background_blanket_v2:
		sleep_sprite.texture = LEGACY_SLEEP_TEXTURE
		sleep_sprite.region_enabled = false
		sleep_sprite.position = Vector2.ZERO
		sleep_sprite.scale = LEGACY_SLEEP_SCALE
		blanket_sprite.texture = BACKGROUND_BLANKET_V2_TEXTURE
		blanket_sprite.scale = BACKGROUND_BLANKET_V2_SCALE
		blanket_sprite.position = BACKGROUND_BLANKET_V2_LOCAL_POSITION
	else:
		sleep_sprite.texture = LEGACY_SLEEP_TEXTURE
		sleep_sprite.region_enabled = false
		sleep_sprite.position = Vector2.ZERO
		sleep_sprite.scale = LEGACY_SLEEP_SCALE
		blanket_sprite.texture = LEGACY_BLANKET_TEXTURE
		blanket_sprite.scale = LEGACY_BLANKET_SCALE
		blanket_sprite.position = Vector2(0, 42)

func begin_sleep(anchor: Dictionary, from_global: Vector2, warm_tint: Color) -> void:
	sleeping = true
	sleep_position = anchor.get("sleep_position", from_global)
	head_position = anchor.get("sleep_head_position", sleep_position + Vector2(-92, -43))
	position = from_global
	modulate = warm_tint
	visible = true
	sleep_sprite.modulate.a = 0.0
	blanket_sprite.modulate.a = 0.0
	z_label.modulate.a = 0.0
	var enter := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	enter.set_parallel(true)
	enter.tween_property(self, "position", sleep_position, 0.34)
	enter.tween_property(sleep_sprite, "modulate:a", 1.0, 0.22)
	enter.tween_property(blanket_sprite, "modulate:a", 1.0, 0.30)
	enter.tween_property(z_label, "modulate:a", 0.0 if use_candidate_bed_group else 0.88, 0.40)

func end_sleep() -> void:
	if not sleeping:
		return
	sleeping = false
	var leave := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	leave.set_parallel(true)
	leave.tween_property(sleep_sprite, "modulate:a", 0.0, 0.18)
	leave.tween_property(blanket_sprite, "modulate:a", 0.0, 0.18)
	leave.tween_property(z_label, "modulate:a", 0.0, 0.12)
	leave.tween_callback(func(): visible = false).set_delay(0.2)

func force_hidden() -> void:
	sleeping = false
	visible = false

func _process(delta: float) -> void:
	if not sleeping:
		return
	breath += delta
	# 呼吸仅影响躯干和被子极小幅度；头和枕头保持稳定，避免漂浮感。
	var base_sleep_scale := CANDIDATE_SLEEP_SCALE if use_candidate_bed_group else (BACKGROUND_BLANKET_V3_SLEEP_SCALE if use_background_blanket_v3 else LEGACY_SLEEP_SCALE)
	var base_blanket_scale := CANDIDATE_BLANKET_SCALE if use_candidate_bed_group else (BACKGROUND_BLANKET_V3_SCALE if use_background_blanket_v3 else LEGACY_BLANKET_SCALE)
	var pulse := sin(breath * 1.55) * 0.008
	sleep_sprite.scale = Vector2(base_sleep_scale.x + pulse, base_sleep_scale.y - pulse * 0.32)
	blanket_sprite.scale = Vector2(base_blanket_scale.x + pulse * 0.72, base_blanket_scale.y - pulse * 0.22)
	# Z 从头部附近产生，再缓慢上浮并淡出；它不固定在床中央。
	if use_candidate_bed_group:
		return
	var cycle := fmod(breath, 2.4) / 2.4
	z_label.text = "z" if cycle < 0.52 else "Z"
	z_label.position = head_position - position + Vector2(12.0 + cycle * 13.0, -cycle * 28.0)
	z_label.scale = Vector2.ONE * (0.80 + cycle * 0.24)
	z_label.modulate.a = 0.82 * (1.0 - cycle)
