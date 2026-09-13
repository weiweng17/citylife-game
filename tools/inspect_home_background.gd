extends SceneTree

func _init() -> void:
	var image := Image.load_from_file("res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp")
	if image == null or image.is_empty():
		push_error("Unable to load apartment background")
		quit(1)
		return
	print("APARTMENT_BACKGROUND_SIZE=%dx%d" % [image.get_width(), image.get_height()])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	image.get_region(Rect2i(100, 390, 470, 280)).save_png("res://build/qa/home_bed_source_crop.png")
	quit()
