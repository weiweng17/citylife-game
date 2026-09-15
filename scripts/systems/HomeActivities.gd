extends "res://scripts/systems/SpotActivities.gd"
## Spatial household interactions. The game owns effects and time settlement.
## 骨架在基类 SpotActivities；本层除了动态休息提示，还承载“做饭”的专属角色动作。
##
## COOK-ACTION-001 的原则：
## - 玩家仍然走到厨房站位后才可触发；
## - Game 仍然负责 20 元 / 30 分钟 / 饱食等结算；
## - 本脚本只负责 进入动作 -> 循环动作 -> 退出动作，以及和灶台的空间贴合；
## - 有正式 5 帧动作条时优先使用；资源尚未入库时也必须用角色帧循环 + 动态锅/蒸汽完成真正的动作反馈，
##   不再退回“原地静态站立 + 一个锅图标”的旧表现。

const COOK_ACTION_SHEET := "res://assets/art/production/player/actions/cook_5pose_1280x256.png"
const COOK_FRAME_SIZE := 256
const COOK_FRAME_COUNT := 5

## 床位的提示语由 Game 按当前时刻写进来：夜里是“睡到明早”，白天两小时小睡。
## 空着就退回 SPOTS 里的静态说明。
var rest_detail: String = ""

## 做饭专属表现层。正式资源是 5 帧横向条：
## 0-1 = 进入灶台；1-3-2 = 循环烹饪；3-4 = 收尾离开。
var cook_sprite: AnimatedSprite2D
var _cook_visual_requested: bool = false
var _cook_visual_active: bool = false
var _cook_exit_requested: bool = false
var _cook_using_sheet: bool = false
var _cook_asset_warned: bool = false
var _cook_time: float = 0.0
var _cook_base_scale := Vector2.ONE


func configure(manager) -> void:
	super(manager)
	_build_cook_visual()


func _define_spots() -> Dictionary:
	return {
		# position / approach_position 都是角色脚底中心的全局可行走坐标。
		# sleep_position 则是同一 LocationView 坐标空间中的睡姿美术中心，不能与脚底坐标混用。
		"rest": {
			"position": Vector2(430, 330), "approach_position": Vector2(430, 330),
			"sleep_position": Vector2(255, 412), "sleep_head_position": Vector2(156, 369),
			"facing": Vector2(-1, 0), "pose": "sleep", "depth": 518,
			"interactionType": "bed", "label": "床 · 休息", "detail": "2小时 · 健康+12 心情+8",
		},
		"study": {
			"position": Vector2(690, 365), "facing": Vector2(0, -1), "pose": "sit", "depth": 402,
			"interactionType": "desk", "label": "书桌 · 学习", "detail": "1小时 · 技能+3 心情−3",
		},
		"meal": {
			"position": Vector2(930, 440), "facing": Vector2(1, -0.35), "pose": "cook", "depth": 488,
			"interactionType": "kitchen", "label": "厨房 · 做饭", "detail": "30分钟 · 20元 健康+5",
		},
		"leave": {
			"position": Vector2(920, 550), "facing": Vector2(1, 0), "pose": "interact", "depth": 565,
			"interactionType": "door", "label": "房门 · 出门", "detail": "前往城南地铁站",
		},
	}


func _location_id() -> String:
	return "home"

func _layer_name() -> String:
	return "HomeInteractionLayer"

func _idle_prompt() -> String:
	return "走近家具，按 E 或点击标签互动"

func _approach_word() -> String:
	return "再互动"


func _detail_of(id: String) -> String:
	if id == "rest" and not rest_detail.is_empty():
		return rest_detail
	return str(SPOTS[id]["detail"])


## 在基类真正触发 activity_requested 之前记下“这一次是做饭”。
## Game 的 signal handler 会在同一帧把 blocked 设为 true；下一帧再进入专属动作，
## 因而余额不足等被 Game 拒绝的请求不会误播放做饭动画。
func _activate(id: String) -> void:
	var can_activate := (
		not blocked
		and layer != null
		and layer.visible
		and SPOTS.has(id)
		and location != null
		and location.player_sprite.position.distance_to(SPOTS[id].position) <= 82.0
	)
	if can_activate and id == "meal":
		_cook_visual_requested = true
	super(id)


func _process(delta: float) -> void:
	super(delta)
	if location == null:
		return

	# Game._begin_activity() 在 signal 回调里同步把 blocked=true；这里以它作为“结算已接受”的凭据。
	if _cook_visual_requested:
		_cook_visual_requested = false
		if blocked:
			_begin_cook_visual()

	if _cook_visual_active and not _cook_using_sheet:
		_animate_runtime_cook(delta)

	# Game._end_activity() 会先解除 blocked。专属动作必须再补一个很短的退出段，
	# 退出段结束之前重新锁住输入，避免角色一边收锅一边已经走开。
	if _cook_visual_active and not blocked and not _cook_exit_requested:
		_request_cook_exit()


func has_cook_action_asset() -> bool:
	if not ResourceLoader.exists(COOK_ACTION_SHEET):
		return false
	var texture := load(COOK_ACTION_SHEET) as Texture2D
	return (
		texture != null
		and texture.get_width() == COOK_FRAME_SIZE * COOK_FRAME_COUNT
		and texture.get_height() == COOK_FRAME_SIZE
	)


func _build_cook_visual() -> void:
	cook_sprite = AnimatedSprite2D.new()
	cook_sprite.name = "CookActionPlayer"
	cook_sprite.visible = false
	cook_sprite.centered = false
	# 与 LocationManager 普通 256x256 主角完全一致的脚底锚点。
	cook_sprite.offset = Vector2(-128.0, -248.0)
	cook_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	cook_sprite.z_index = int(SPOTS["meal"].get("depth", 488))
	location.root.add_child(cook_sprite)
	cook_sprite.animation_finished.connect(_on_cook_animation_finished)

	if has_cook_action_asset():
		cook_sprite.sprite_frames = _make_cook_frames()


func _make_cook_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	for default_name in frames.get_animation_names():
		frames.remove_animation(default_name)
	var texture := load(COOK_ACTION_SHEET) as Texture2D
	if texture == null:
		return frames

	_add_cook_animation(frames, &"cook_enter", texture, [0, 1], 7.0, false)
	_add_cook_animation(frames, &"cook_loop", texture, [1, 2, 3, 2], 7.5, true)
	_add_cook_animation(frames, &"cook_exit", texture, [3, 4], 8.0, false)
	return frames


func _add_cook_animation(
	frames: SpriteFrames,
	name: StringName,
	texture: Texture2D,
	indices: Array,
	fps: float,
	looped: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, looped)
	for raw_index in indices:
		var index := int(raw_index)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * COOK_FRAME_SIZE, 0, COOK_FRAME_SIZE, COOK_FRAME_SIZE)
		frames.add_frame(name, atlas)


func _begin_cook_visual() -> void:
	_cook_visual_active = true
	_cook_exit_requested = false
	_cook_time = 0.0
	_cook_base_scale = location.player_sprite.scale
	var anchor: Dictionary = SPOTS["meal"]

	if has_cook_action_asset():
		_cook_using_sheet = true
		if cook_sprite.sprite_frames == null or not cook_sprite.sprite_frames.has_animation(&"cook_enter"):
			cook_sprite.sprite_frames = _make_cook_frames()
		cook_sprite.position = anchor["position"]
		cook_sprite.scale = location.player_sprite.scale
		cook_sprite.modulate = location.player_sprite.modulate
		cook_sprite.z_index = int(anchor.get("depth", 488))
		cook_sprite.visible = true
		location.player_sprite.visible = false
		# 正式动作条内已有手部烹饪动作，旧程序化锅不再叠一层。
		if location.activity_prop != null:
			location.activity_prop.visible = false
		cook_sprite.play(&"cook_enter")
		return

	# 正式动作条尚未入库时，先使用“站位锁定 + 角色帧循环 + 动态锅 + 上升蒸汽”的运行时动作。
	# 这条路径会真实播放角色帧和道具动画，所以开发/验收不会退回静态贴图。
	_cook_using_sheet = false
	if not _cook_asset_warned:
		_cook_asset_warned = true
		push_warning("COOK-ACTION-001: dedicated 5-frame sheet not found; runtime cook rig is active until art ingest completes.")
	location.player_sprite.visible = true
	location.player_sprite.position = anchor["position"]
	location.player_sprite.z_index = int(anchor.get("depth", 488))
	location.face_direction(anchor["facing"])
	# 复用主角右向行走帧的手臂变化，但把速度压低，脚底位置保持不动，读感更接近搅拌/备菜。
	location.player_sprite.play(location.player_sprite.animation, 0.30)
	if location.activity_prop != null:
		location.activity_prop.setup("meal")
		location.activity_prop.visible = true


func _animate_runtime_cook(delta: float) -> void:
	_cook_time += delta
	var anchor_position: Vector2 = SPOTS["meal"]["position"]
	# 身体轻微前探/回收，脚底不离开厨房交互点。
	var lean := sin(_cook_time * 4.2)
	location.player_sprite.position = anchor_position + Vector2(lean * 1.2, 0.0)
	location.player_sprite.rotation = lean * 0.008
	location.player_sprite.scale = _cook_base_scale * Vector2(1.0 + lean * 0.008, 0.985 - lean * 0.010)
	if location.activity_prop != null and location.activity_prop.visible:
		# 锅固定在灶台/手部之间，小幅左右移动；蒸汽与颠锅由 ActivityProp 自己持续绘制。
		location.activity_prop.position = anchor_position + Vector2(20.0 + sin(_cook_time * 7.5) * 2.5, -50.0 + cos(_cook_time * 7.5) * 1.5)
		location.activity_prop.z_index = int(SPOTS["meal"].get("depth", 488)) + 3


func _request_cook_exit() -> void:
	if not _cook_visual_active:
		return
	_cook_exit_requested = true
	# Game 已完成数值结算，但视觉还在收尾；这 0.2~0.25 秒继续锁输入。
	blocked = true
	location.input_blocked = true
	if _cook_using_sheet:
		if cook_sprite.animation != &"cook_enter":
			cook_sprite.play(&"cook_exit")
		return

	location.player_sprite.stop()
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(location.player_sprite, "position", SPOTS["meal"]["position"], 0.18)
	tween.tween_property(location.player_sprite, "rotation", 0.0, 0.18)
	tween.tween_property(location.player_sprite, "scale", _cook_base_scale, 0.18)
	tween.set_parallel(false)
	tween.tween_callback(_finish_cook_visual)


func _on_cook_animation_finished() -> void:
	if not _cook_visual_active or not _cook_using_sheet:
		return
	match cook_sprite.animation:
		&"cook_enter":
			if _cook_exit_requested:
				cook_sprite.play(&"cook_exit")
			else:
				cook_sprite.play(&"cook_loop")
		&"cook_exit":
			_finish_cook_visual()


func _finish_cook_visual() -> void:
	if cook_sprite != null:
		cook_sprite.stop()
		cook_sprite.visible = false
	_cook_visual_active = false
	_cook_exit_requested = false
	_cook_using_sheet = false
	location.player_sprite.stop()
	location.player_sprite.visible = true
	location.player_sprite.rotation = 0.0
	location.player_sprite.scale = _cook_base_scale
	location.player_sprite.position = SPOTS["meal"]["position"]
	location.player_target = location.player_sprite.position
	location.face_direction(SPOTS["meal"]["facing"])
	if location.activity_prop != null:
		location.activity_prop.setup("")
	# 只释放我们为退出动作追加的短锁；Game 的活动本体此时已经结束。
	location.input_blocked = false
	blocked = false
