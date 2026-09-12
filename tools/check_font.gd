extends SceneTree

func _init() -> void:
	var dt := ThemeDB.get_default_theme()
	var f = dt.default_font
	print("default theme font: ", f)
	print("default theme font path: ", (f.resource_path if f != null else "null"))
	print("default theme font size: ", dt.default_font_size)
	# 直接检查我们的字体能否取到字形
	var mine = load("res://assets/fonts/GameCN.ttf")
	print("loaded mine: ", mine, " path=", (mine.resource_path if mine != null else "null"))
	if mine != null:
		print("has 都 :", mine.has_char(ord("都")))
		print("has 岁 :", mine.has_char(ord("岁")))
		var sz = mine.get_string_size("都市浮生", HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
		print("string size of 都市浮生@14: ", sz)
	quit()
