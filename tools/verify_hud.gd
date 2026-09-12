extends Node
## 校验顶部状态栏（HUD）：应有两个有真实宽度的状态条（健康/心情），不能塌成 0 宽


func _ready() -> void:
	var m = load("res://scenes/Main.tscn").instantiate()
	add_child(m)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var bars: Array = []
	_collect(m, bars)
	print("progress bars found = ", bars.size())

	var ok := bars.size() >= 2
	for b in bars:
		print("  bar.size=", b.size, " min=", b.custom_minimum_size)
		if b.size.x < 80.0:
			ok = false
			print("    !! 状态条宽度不足（塌陷）")
	print("HUD_OK" if ok else "HUD_FAIL")
	get_tree().quit(0 if ok else 1)


func _collect(n: Node, out: Array) -> void:
	if n is ProgressBar:
		out.append(n)
	for c in n.get_children():
		_collect(c, out)
