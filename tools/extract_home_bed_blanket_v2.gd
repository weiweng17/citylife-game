extends SceneTree
## 从正式出租屋背景提取床被下沿；输出透明小图，不生成或重画任何床铺内容。

const SOURCE := "res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp"
const OUTPUT := "res://assets/backgrounds/interactions/home_bed_blanket_foreground_v2.png"
const CROP := Rect2i(100, 390, 470, 280)
# 仅保留睡姿身体前方的被子带；坐标相对于 CROP，枕头、床架与大面积背景不在内。
var front_duvet := PackedVector2Array([
	Vector2(20, 80), Vector2(130, 55), Vector2(250, 86), Vector2(370, 153),
	Vector2(390, 192), Vector2(350, 213), Vector2(277, 190), Vector2(188, 166),
	Vector2(113, 164), Vector2(45, 132),
])

func _init() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Unable to load apartment background for bed foreground extraction")
		quit(1)
		return
	if FileAccess.file_exists(OUTPUT):
		push_error("Refusing to overwrite existing bed blanket v2")
		quit(1)
		return
	var foreground := Image.create(CROP.size.x, CROP.size.y, false, Image.FORMAT_RGBA8)
	foreground.fill(Color.TRANSPARENT)
	for y in range(CROP.size.y):
		for x in range(CROP.size.x):
			if Geometry2D.is_point_in_polygon(Vector2(x, y), front_duvet):
				foreground.set_pixel(x, y, source.get_pixel(CROP.position.x + x, CROP.position.y + y))
	var result := foreground.save_png(OUTPUT)
	if result != OK:
		push_error("Failed to save bed blanket v2: %s" % result)
		quit(1)
		return
	print("EXTRACTED bed blanket v2: crop=%s polygon_points=%d" % [CROP, front_duvet.size()])
	quit()
