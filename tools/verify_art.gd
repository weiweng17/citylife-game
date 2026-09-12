extends Node
## 美术 / 光照自检
## ------------------------------------------------------------------
## 1) 11 个素材全部存在、能加载、尺寸符合预期（防止改尺寸悄悄破坏碰撞与布局）
## 2) 实例化 Main.tscn，确认氛围光照三层节点都在：
##       Ambient(CanvasModulate) / WarmLight(PointLight2D xN) / Vignette(CanvasLayer)
## 3) 确认暗角层没有盖住 UI
##
## 运行： godot --headless --path . res://tools/VerifyArt.tscn
## 成功打印 ART_OK（退出码 0），失败打印 ART_FAIL + 原因（退出码 1）

const SPRITES: Array[String] = [
	"player.png", "grass.png", "road.png", "road_line.png",
	"building_home.png", "building_store.png", "building_office.png",
	"tree.png", "poi.png", "light_warm.png", "vignette.png",
]

# 尺寸是硬约束：v1/v2 刻意保持一致，动了就会踩坏碰撞体与布局
const EXPECTED_SIZE := {
	"player.png": Vector2i(24, 32),
	"grass.png": Vector2i(32, 32),
	"road.png": Vector2i(32, 32),
	"road_line.png": Vector2i(32, 32),
	"building_home.png": Vector2i(64, 64),
	"building_store.png": Vector2i(64, 64),
	"building_office.png": Vector2i(64, 64),
	"tree.png": Vector2i(32, 40),
	"poi.png": Vector2i(24, 24),
	"vignette.png": Vector2i(360, 640),
}


func _ready() -> void:
	var fails: Array[String] = []

	# ---- 1. 素材 ----
	for fname in SPRITES:
		var path := "res://assets/sprites/" + fname
		if not ResourceLoader.exists(path):
			fails.append("素材缺失: " + fname)
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			fails.append("素材加载失败: " + fname)
			continue
		if EXPECTED_SIZE.has(fname):
			var want: Vector2i = EXPECTED_SIZE[fname]
			if Vector2i(tex.get_size()) != want:
				fails.append("%s 尺寸不符: %s != %s" % [fname, tex.get_size(), want])
		print("  素材 OK: %-22s %s" % [fname, tex.get_size()])

	# ---- 2. 光照节点 ----
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var ambient := main.get_node_or_null("Ambient") as CanvasModulate
	if ambient == null:
		fails.append("缺少冷调层 Ambient(CanvasModulate)")
	else:
		print("  冷调统一 OK: Ambient color=%s" % ambient.color)

	var lights := 0
	for c in main.get_children():
		if c is PointLight2D:
			lights += 1
	if lights < 3:
		fails.append("暖光池数量不足: %d（应 >= 3）" % lights)
	else:
		print("  暖光池 OK: %d 个 PointLight2D" % lights)

	var vig := main.get_node_or_null("Vignette") as CanvasLayer
	if vig == null:
		fails.append("缺少暗角层 Vignette(CanvasLayer)")
	else:
		var tr: TextureRect = null
		for c in vig.get_children():
			if c is TextureRect:
				tr = c
		if tr == null or tr.texture == null:
			fails.append("暗角贴图未挂载")
		else:
			print("  暗角 OK: %s (layer=%d)" % [tr.texture.get_size(), vig.layer])
		if vig.layer >= 2:
			fails.append("暗角层会盖住 UI: layer=%d（应 < 2）" % vig.layer)

	# ---- 3. 结论 ----
	main.queue_free()
	if fails.is_empty():
		print("ART_OK")
		get_tree().quit(0)
	else:
		for f in fails:
			print("  FAIL: " + f)
		print("ART_FAIL")
		get_tree().quit(1)
