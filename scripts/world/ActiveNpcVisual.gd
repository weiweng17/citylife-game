extends Node2D
class_name ActiveNpcVisual

## Active location NPC presentation primitive.
##
## The node origin is the NPC foot contact point. High-resolution 4x4 sheets use an
## AnimatedSprite2D walk presentation; legacy one-frame art stays a Sprite2D fallback.
## LocationManager owns click/talk behavior and only needs to place this node at the
## configured foot position and assign a matching z-index.

const WALK_ROWS := ["walk_down", "walk_left", "walk_right", "walk_up"]
const WALK_COLUMNS := 4
const TARGET_FRAME_HEIGHT := 256.0

var _body: CanvasItem
var _shadow: Sprite2D
var _foot_y: float = 420.0


func configure(
	walk_sheet_path: String,
	fallback_path: String,
	foot_y: float,
	lighting: Color = Color.WHITE
) -> void:
	_foot_y = foot_y
	_clear_body()
	_ensure_shadow()

	var sheet: Texture2D = load(walk_sheet_path) as Texture2D if not walk_sheet_path.is_empty() else null
	if sheet != null and sheet.get_width() >= WALK_COLUMNS and sheet.get_height() >= WALK_ROWS.size():
		_build_animated_body(sheet)
	else:
		var fallback: Texture2D = load(fallback_path) as Texture2D if not fallback_path.is_empty() else null
		_build_static_body(fallback)

	_apply_grounding(lighting)


func has_walk_animation() -> bool:
	return _body is AnimatedSprite2D


func play_idle_facing_down() -> void:
	if _body is AnimatedSprite2D:
		var animated := _body as AnimatedSprite2D
		animated.stop()
		animated.animation = &"walk_down"
		animated.frame = 0


func play_walk(direction: Vector2) -> void:
	if not _body is AnimatedSprite2D:
		return
	var animated := _body as AnimatedSprite2D
	var animation: StringName
	if absf(direction.x) > absf(direction.y):
		animation = &"walk_right" if direction.x > 0.0 else &"walk_left"
	else:
		animation = &"walk_down" if direction.y > 0.0 else &"walk_up"
	if animated.animation != animation:
		animated.animation = animation
	if not animated.is_playing():
		animated.play()


func set_grounding(foot_y: float, lighting: Color) -> void:
	_foot_y = foot_y
	_apply_grounding(lighting)


func _clear_body() -> void:
	if _body != null and is_instance_valid(_body):
		_body.queue_free()
	_body = null


func _ensure_shadow() -> void:
	if _shadow != null and is_instance_valid(_shadow):
		return
	_shadow = Sprite2D.new()
	_shadow.name = "NpcShadow"
	_shadow.texture = _make_shadow_texture(Color(0.0, 0.0, 0.0, 0.30))
	_shadow.scale = Vector2(48.0 / 96.0, 14.0 / 32.0)
	_shadow.position = Vector2(0.0, 4.0)
	_shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_shadow.z_index = -1
	add_child(_shadow)


func _build_animated_body(sheet: Texture2D) -> void:
	var frame_width := int(sheet.get_width() / WALK_COLUMNS)
	var frame_height := int(sheet.get_height() / WALK_ROWS.size())
	if frame_width <= 0 or frame_height <= 0:
		_build_static_body(sheet)
		return

	var frames := SpriteFrames.new()
	for default_name in frames.get_animation_names():
		frames.remove_animation(default_name)
	for row in range(WALK_ROWS.size()):
		var animation: String = WALK_ROWS[row]
		frames.add_animation(animation)
		frames.set_animation_speed(animation, 6.0)
		frames.set_animation_loop(animation, true)
		for column in range(WALK_COLUMNS):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(column * frame_width, row * frame_height, frame_width, frame_height)
			frames.add_frame(animation, atlas)

	var animated := AnimatedSprite2D.new()
	animated.name = "NpcBody"
	animated.sprite_frames = frames
	animated.animation = &"walk_down"
	animated.frame = 0
	animated.centered = false
	animated.offset = Vector2(-frame_width * 0.5, -float(frame_height))
	animated.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(animated)
	_body = animated


func _build_static_body(texture: Texture2D) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "NpcBody"
	sprite.texture = texture
	sprite.centered = false
	if texture != null:
		sprite.offset = Vector2(-texture.get_width() * 0.5, -float(texture.get_height()))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	_body = sprite


func _apply_grounding(lighting: Color) -> void:
	if _body == null:
		return
	var scale_value := _depth_scale(_foot_y)
	var texture_height := TARGET_FRAME_HEIGHT
	if _body is AnimatedSprite2D:
		var animated := _body as AnimatedSprite2D
		var texture := animated.sprite_frames.get_frame_texture(animated.animation, 0)
		if texture != null:
			texture_height = float(texture.get_height())
	elif _body is Sprite2D:
		var texture := (_body as Sprite2D).texture
		if texture != null:
			texture_height = float(texture.get_height())

	# _depth_scale is calibrated for the protagonist's 256 px source frame. Normalize
	# other NPC source sizes to the same target visual height before applying depth.
	var source_normalization := TARGET_FRAME_HEIGHT / maxf(texture_height, 1.0)
	_body.scale = Vector2.ONE * scale_value * source_normalization
	_body.modulate = lighting.lerp(Color(0.92, 0.90, 0.86, 1.0), 0.22)
	if _shadow != null:
		_shadow.scale = Vector2(48.0 / 96.0, 14.0 / 32.0) * clampf(scale_value / 0.32, 0.86, 1.12)


func _depth_scale(y: float) -> float:
	var t := clampf((y - 280.0) / 350.0, 0.0, 1.0)
	return lerpf(0.292, 0.342, t)


func _make_shadow_texture(color: Color) -> Texture2D:
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
	return texture
