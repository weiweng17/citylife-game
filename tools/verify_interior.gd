extends Node
## 室内切换自检：进公司 → 室内 → 出门，验证地图/玩家/老板节点正确切换
## 运行：godot --headless --path . res://tools/VerifyInterior.tscn
## 成功打印 INTERIOR_OK（退出码 0）

func _ready() -> void:
	var fails: Array[String] = []
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var world: Node2D = main.get("_world")
	var interior: Node2D = main.get("_interior")
	if world == null or interior == null:
		print("INTERIOR_FAIL 缺少 World/Interior 节点")
		get_tree().quit(1)
		return

	if main.get("inside") != "":
		fails.append("初始应在街道 inside=%s" % main.get("inside"))

	main.call("_enter_interior", "office")
	await get_tree().process_frame
	if main.get("inside") != "office":
		fails.append("进入室内失败 inside=%s" % main.get("inside"))
	if world.visible:
		fails.append("街道未隐藏")
	if not interior.visible:
		fails.append("室内未显示")
	if main.get_node_or_null("Interior/INPC_boss") == null:
		fails.append("缺少室内老板 NPC")
	if main.get_node_or_null("Interior/InteriorDoor") == null:
		fails.append("缺少室内出口门")

	main.call("_exit_interior")
	await get_tree().process_frame
	if main.get("inside") != "":
		fails.append("出门失败 inside=%s" % main.get("inside"))
	if not world.visible:
		fails.append("街道未恢复显示")

	main.queue_free()
	if fails.is_empty():
		print("INTERIOR_OK 进公司→室内→出门 切换正常")
		get_tree().quit(0)
	else:
		for f in fails:
			print("  FAIL: " + f)
		print("INTERIOR_FAIL")
		get_tree().quit(1)
