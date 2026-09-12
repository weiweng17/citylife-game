extends CharacterBody2D
## 玩家角色：点击地面移动（CharacterBody2D + move_and_slide）
##
## 美术方向：漫画风 2D（平滑线稿 + 赛璐璐上色），不再是像素点阵。
## 素材是 AI 出图后抠底、按原比例缩到 18x64 的单张全身像（脚在贴图最底部）。
## 因此：
##   · 必须用 LINEAR（平滑）过滤，不能用 NEAREST——否则缩小后会糊成马赛克
##   · 单张静态姿势，没有行走帧，用「上下轻晃」表达走路
## 脚下补光（站灯下烤暖 / 暗处沉底）由 Game.gd 用 lightmap 设置 modulate。

const PLAYER_TEX := "res://assets/sprites/player_v5.png"

const SPEED := 110.0
const ARRIVE_DIST := 4.0

## 走路起伏（单帧图靠它表达行走）
const BOB_SPEED := 14.0
const BOB_AMP := 1.6

var target := Vector2.ZERO
var moving := false
var _sprite_base := Vector2.ZERO   # 由场景里设定的基准偏移（-9,-64：脚落在节点原点）
var _bob := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	target = position
	moving = false
	sprite.sprite_frames = _make_frames()
	# 锚点按贴图尺寸自动算（脚落在节点原点、水平居中）——换尺寸不用再改场景坐标
	var tex := load(PLAYER_TEX) as Texture2D
	if tex != null:
		_sprite_base = Vector2(-tex.get_width() / 2.0, -float(tex.get_height()))
	sprite.position = _sprite_base
	# 漫画风 2D 是平滑画面，必须线性过滤（全局默认 NEAREST 是给像素素材用的）
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.play("walk")
	sprite.pause()
	sprite.frame = 0


## 单张全身像，只有一帧
func _make_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation("walk")
	var tex: Texture2D = load(PLAYER_TEX)
	sf.add_frame("walk", tex)
	sf.set_animation_speed("walk", 8)
	sf.set_animation_loop("walk", false)
	return sf


## 设置移动目标（世界坐标）
func set_target(p: Vector2) -> void:
	target = p
	moving = true


func _physics_process(delta: float) -> void:
	if not moving:
		velocity = Vector2.ZERO
		if sprite.is_playing():
			sprite.pause()
			sprite.frame = 0
		sprite.position = _sprite_base
		move_and_slide()
		return

	var d := target - position
	if d.length() < ARRIVE_DIST:
		position = target
		moving = false
		velocity = Vector2.ZERO
		if sprite.is_playing():
			sprite.pause()
			sprite.frame = 0
		sprite.position = _sprite_base
	else:
		velocity = d.normalized() * SPEED
		# 朝向：向左走时水平翻转
		if abs(d.x) > 2.0:
			sprite.flip_h = d.x < 0
		if not sprite.is_playing():
			sprite.play("walk")
		# 上下轻晃代替行走帧
		_bob += delta * BOB_SPEED
		sprite.position = _sprite_base + Vector2(0.0, sin(_bob) * BOB_AMP)

	move_and_slide()
