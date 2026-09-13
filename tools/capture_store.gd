extends SceneTree
## 便利店与背包截图抽查：
## build/qa/store_shelf.png（货架标签）、store_shop_buy.png（货架面板）、
## store_bag.png（背包面板）。排版是否合理只能靠眼睛，自动测试看不出来。

const Data = preload("res://scripts/Data.gd")

var main: Node
var frame_count: int = 0
var phase: int = 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/qa"))
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frame_count += 1
	match phase:
		0:
			if frame_count >= 8:
				_setup()
				phase = 1
				frame_count = 0
		1:
			if frame_count >= 16:
				_capture("res://build/qa/store_shelf.png")
				main.store_activities._activate("shop")
				phase = 2
				frame_count = 0
		2:
			if frame_count >= 10:
				_capture("res://build/qa/store_shop_buy.png")
				phase = 3
				frame_count = 0
		3:
			if frame_count >= 4:
				main.shop_ui.buy_requested.emit("instant_noodles")
				main.shop_ui.buy_requested.emit("canned_coffee")
				main.shop_ui.close()
				main._open_bag()
				phase = 4
				frame_count = 0
		4:
			if frame_count >= 10:
				_capture("res://build/qa/store_bag.png")
				quit(0)
				return true
	return false


func _setup() -> void:
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	var store = main.store_activities
	location.unlock("store")
	location.travel_to("store")
	location.player_sprite.position = store.SPOTS.shop.position
	location.player_target = location.player_sprite.position
	location._update_player_grounding()
	main.money = 128
	main._refresh_ui()


func _capture(path: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(path)
	print("[%s] %s" % ["OK" if result == OK else "FAIL", path])
