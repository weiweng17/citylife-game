extends SceneTree

const GAME_PATH := "res://scripts/Game.gd"

func _init() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	if file == null:
		push_error("GAME-FIX-001: cannot open %s" % GAME_PATH)
		quit(1)
		return
	var source := file.get_as_text()
	file.close()

	var failures: Array[String] = []
	var close_event := _function_block(source, "func _close_event() -> void:")
	if close_event.is_empty():
		failures.append("missing _close_event")
	elif "_year_pass()" in close_event:
		failures.append("regular event closure still calls _year_pass()")

	var enter_place := _function_block(source, "func _enter_place(d: Dictionary) -> void:")
	if enter_place.is_empty():
		failures.append("missing _enter_place")
	elif "这里今天没什么事" in enter_place and "\n\t\t_year_pass()" in enter_place:
		failures.append("legacy place no-event path still advances a year")

	var interior_boss := _function_block(source, "func _interior_boss() -> void:")
	if interior_boss.is_empty():
		failures.append("missing _interior_boss")
	elif "今天没什么要汇报的" in interior_boss and "\n\t\t_year_pass()" in interior_boss:
		failures.append("office no-event path still advances a year")

	var year_pass := _function_block(source, "func _year_pass() -> void:")
	if year_pass.is_empty() or "rules_sys.year_tick(st)" not in year_pass:
		failures.append("explicit annual progression entry point was removed or no longer calls Rules.year_tick")

	if not failures.is_empty():
		for failure in failures:
			push_error("GAME-FIX-001 regression: %s" % failure)
		quit(1)
		return

	print("GAME-FIX-001 PASS: regular event/no-event closure is separated from explicit annual progression")
	quit(0)


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
