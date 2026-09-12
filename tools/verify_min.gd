extends Node
## 最小隔离测试：只实例化 Main.tscn，不做任何室内操作
## 用来判断崩溃是「实例化主场景」还是「进/出室内」引起的

func _ready() -> void:
	print("STEP1 开始")
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	print("STEP2 已实例化")
	add_child(main)
	print("STEP3 已入树")
	await get_tree().process_frame
	await get_tree().process_frame
	print("STEP4 已过两帧")
	var w = main.get("_world")
	var i = main.get("_interior")
	print("STEP5 world=", w, " interior=", i)
	print("STEP6 NPC数=", (main.get("npc_nodes") as Array).size())
	main.queue_free()
	print("MIN_OK 实例化主场景正常")
	get_tree().quit(0)
