extends Node
## 校验开局「出身选择」卡片布局：卡片应占满宽度、描述文字应有真实宽度（不会挤成一列）

func _ready() -> void:
	var m = load("res://scenes/Main.tscn").instantiate()
	add_child(m)
	await get_tree().process_frame
	await get_tree().process_frame
	var panel = m.find_child("StartPanel", true, false)
	if panel == null:
		print("FAIL: 未找到 StartPanel")
		get_tree().quit(1)
		return
	panel.visible = true
	await get_tree().process_frame

	var cards: Array = []
	_collect(panel.get_child(0), cards)
	print("panel.size = ", panel.size)
	print("cards found = ", cards.size())

	var ok := cards.size() >= 4
	for c in cards:
		var body = c.get_child(0)
		var ds = body.get_child(1)
		print("  card.size=", c.size, "  desc.size=", ds.size)
		if c.size.x < 250.0:
			ok = false
			print("    !! 卡片太窄")
		if ds.size.x < 200.0:
			ok = false
			print("    !! 描述文字宽度不足（仍会被挤成一列）")
	print("LAYOUT_OK" if ok else "LAYOUT_FAIL")
	get_tree().quit(0 if ok else 1)


func _collect(n: Node, out: Array) -> void:
	for c in n.get_children():
		if c is PanelContainer:
			out.append(c)
		_collect(c, out)
