extends SceneTree
## 阶段 2 便利店与背包：解锁与货架可达、买不起的拒绝、购买扣钱入包、
## 取用消耗并回补需求、每日吃饭目标联动、存档往返。

const InventoryScript = preload("res://scripts/systems/Inventory.gd")


func _init() -> void:
	call_deferred("run")


func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(main.Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	main.set_process(false)
	var location = main.location_sys
	var store = main.store_activities
	var inventory = main.inventory
	var routine = main.daily_routine
	var shop = main.shop_ui
	var time_sys = main.time_sys

	assert(inventory != null, "inventory must exist")
	assert(store != null, "store activities must exist")
	assert(shop != null, "shop ui must exist")
	assert(inventory.total_count() == 0, "the bag must start empty")

	# 便利店由"到过公司"解锁；这里直接解锁，只验证它自己这一环。
	location.unlock("store")
	location.travel_to("store")
	await process_frame
	assert(location.current_location == "store")
	assert(store.layer.visible, "store interaction layer must be visible in the store")
	assert(location.walk_to(store.SPOTS.shop.position), "the shelf spot must be reachable from the spawn")
	print("PASS store unlocks and the shelf is reachable")

	# 走到货架前按 E，面板打开
	location.player_sprite.position = store.SPOTS.shop.position
	location.player_target = location.player_sprite.position
	store.blocked = false
	store._activate("shop")
	assert(shop.is_open(), "activating the shelf must open the panel")
	assert(shop.mode == "buy", "the shelf must open in buy mode")
	assert(location.player_sprite.animation == &"walk_up", "shopping must face the shelf")
	assert(
		shop.list_box.get_child_count() == InventoryScript.DISPLAY_ORDER.size(),
		"the shelf must list every catalogue item"
	)
	print("PASS shelf opens the buy panel with the full catalogue")

	# 面板打开期间必须锁住走动，否则玩家能一边挑东西一边走出便利店
	main._last_total_minutes = time_sys.day * 1440 + time_sys.get_minute_of_day()
	main.need_fraction = 0.0
	location.input_blocked = false
	main._process(0.0)
	assert(location.input_blocked, "an open panel must block walking")
	shop.close()
	assert(not shop.is_open())
	main._process(0.0)
	assert(not location.input_blocked, "closing the panel must release walking")
	print("PASS an open panel locks walking and time")

	# 买不起：不扣钱、不进包，面板里要给出原因
	shop.open_buy(3, inventory)
	shop.refresh(3, inventory)
	var medicine_button: Button = _row_button(shop, "cold_medicine")
	assert(medicine_button != null, "the medicine row must have a button")
	assert(medicine_button.disabled, "an unaffordable row must be disabled in the panel")
	main.money = 3
	shop.buy_requested.emit("cold_medicine")
	assert(main.money == 3, "buying without enough money must not charge")
	assert(inventory.count("cold_medicine") == 0, "buying without enough money must not add items")
	assert(not shop.status_label.text.is_empty(), "a refused purchase must be explained")
	print("PASS unaffordable purchase is refused without side effects")

	# 正常购买：扣钱、进包、HUD 件数同步
	main.money = 100
	shop.buy_requested.emit("instant_noodles")
	assert(main.money == 94, "instant noodles must cost 6, money=%d" % main.money)
	assert(inventory.count("instant_noodles") == 1, "the purchase must land in the bag")
	assert(main.hud.bag_btn.text.contains("1"), "the HUD bag button must show the count")
	var medicine_button_after: Button = _row_button(shop, "cold_medicine")
	assert(not medicine_button_after.disabled, "rows must re-enable once the player can afford them")
	print("PASS buying deducts money and fills the bag")

	# 取用：补饱食、扣时间、算作今天的饭
	main.fullness = 20
	routine.reset(time_sys.day)
	var before_total: int = time_sys.day * 1440 + time_sys.get_minute_of_day()
	shop.use_requested.emit("instant_noodles")
	var after_total: int = time_sys.day * 1440 + time_sys.get_minute_of_day()
	assert(after_total - before_total == 15, "eating noodles must take 15 minutes")
	assert(main.fullness == 52, "noodles must restore 32 fullness, got %d" % main.fullness)
	assert(inventory.count("instant_noodles") == 0, "using an item must consume it")
	assert(routine.is_done("meal"), "a filling snack must count as the daily meal")
	print("PASS using an item restores needs and consumes it")

	# 垫肚子的不算吃饭：牛奶补得少，糊弄不过每日目标
	main.fullness = 10
	routine.reset(time_sys.day)
	inventory.add("milk", 1)
	shop.use_requested.emit("milk")
	assert(main.fullness == 22, "milk must restore 12 fullness, got %d" % main.fullness)
	assert(main.health > 0)
	assert(not routine.is_done("meal"), "milk must not complete the daily meal")
	print("PASS a light snack does not complete the daily meal")

	# 药品只养身体，不顶饿
	main.health = 40
	inventory.add("cold_medicine", 1)
	shop.use_requested.emit("cold_medicine")
	assert(main.health == 58, "medicine must restore 18 health, got %d" % main.health)
	assert(not routine.is_done("meal"), "medicine is not a meal")
	print("PASS medicine restores health only")

	# 背包面板只列真正持有且还有货的东西
	inventory.add("bread", 2)
	main._open_bag()
	assert(shop.is_open() and shop.mode == "bag", "the HUD entry must open the bag view")
	assert(
		shop.list_box.get_child_count() == inventory.owned_items().size(),
		"the bag must list exactly what is owned"
	)
	shop.close()
	assert(not shop.is_open())
	print("PASS the bag panel lists exactly what is owned")

	# 存档往返：数量保留，目录里没有的旧物品要被丢掉
	var saved: Dictionary = inventory.to_save_dict()
	inventory.reset()
	assert(inventory.total_count() == 0)
	inventory.apply_save_dict(saved)
	assert(inventory.count("bread") == 2, "the bag must survive a save round-trip")
	inventory.apply_save_dict({"counts": {"bread": 1, "ghost_item": 5}})
	assert(inventory.count("bread") == 1)
	assert(not inventory.has("ghost_item"), "unknown items must not survive a load")
	print("PASS the bag survives a save round-trip")

	quit(0)


## 按显示顺序取某一行的操作按钮，用来验证"买不起"的视觉状态。
func _row_button(shop: Control, item_id: String) -> Button:
	var index: int = InventoryScript.DISPLAY_ORDER.find(item_id)
	if index < 0 or index >= shop.list_box.get_child_count():
		return null
	var holder: Node = shop.list_box.get_child(index)
	if holder.get_child_count() == 0:
		return null
	var row: Node = holder.get_child(0)
	for i in range(row.get_child_count() - 1, -1, -1):
		if row.get_child(i) is Button:
			return row.get_child(i)
	return null
