extends SceneTree
## v3：仅截取正式床面上会压在睡姿腰腿前方的小段被子，不重建整床。

const SOURCE := "res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp"
const OUTPUT := "res://assets/backgrounds/interactions/home_bed_blanket_foreground_v3.png"
const CROP := Rect2i(300, 480, 190, 90)
var front_duvet := PackedVector2Array([
	Vector2(0, 0), Vector2(80, 0), Vector2(155, 28), Vector2(189, 55),
	Vector2(164, 77), Vector2(95, 65), Vector2(35, 55), Vector2(8, 30),
])

func _init() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Unable to load apartment background for bed foreground extraction")
		quit(1)
		return
	if FileAccess.file_exists(OUTPUT):
		push_error("Refusing to overwrite existing bed blanket v3")
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
		push_error("Failed to save bed blanket v3: %s" % result)
		quit(1)
		return
	print("EXTRACTED small bed blanket v3: crop=%s polygon_points=%d" % [CROP, front_duvet.size()])
	quit()
