extends SceneTree

const GAME_PATH := "res://scripts/Game.gd"

func _init() -> void:
	var file := FileAccess.open(GAME_PATH, FileAccess.READ)
	if file == null:
		push_error("GAME-FIX-002: cannot open %s" % GAME_PATH)
		quit(1)
		return
	var source := file.get_as_text()
	file.close()

	var failures: Array[String] = []
	var sync_needs := _function_block(source, "func _sync_needs_to_time() -> void:")
	if sync_needs.is_empty():
		failures.append("missing _sync_needs_to_time")
	else:
		var hourly_anchor := "\twhile need_fraction >= 1.0:"
		var warning_anchor := "\t_warn_if_need_low()"
		var loop_start := sync_needs.find(hourly_anchor)
		var warning_start := sync_needs.find(warning_anchor)
		if loop_start < 0:
			failures.append("missing hourly need-drain loop")
		elif warning_start < 0:
			failures.append("missing low-need warning call")
		else:
			var hourly_block := sync_needs.substr(loop_start, warning_start - loop_start)
			if "\t\tif fullness <= 0:\n\t\t\thealth = maxi(0, health - 2)" not in hourly_block:
				failures.append("zero-fullness health penalty is not inside the hourly cadence")
			if "\t\tif energy <= 0:\n\t\t\tmood = maxi(0, mood - 2)" not in hourly_block:
				failures.append("zero-energy mood penalty is not inside the hourly cadence")
		if "\n\tif fullness <= 0:\n\t\thealth = maxi(0, health - 2)" in sync_needs:
			failures.append("zero-fullness penalty still exists outside the hourly loop")
		if "\n\tif energy <= 0:\n\t\tmood = maxi(0, mood - 2)" in sync_needs:
			failures.append("zero-energy penalty still exists outside the hourly loop")
		if "fullness = maxi(0, fullness - FULLNESS_PER_HOUR)" not in sync_needs:
			failures.append("existing hourly fullness drain changed or disappeared")
		if "energy = maxi(0, energy - ENERGY_PER_HOUR)" not in sync_needs:
			failures.append("existing hourly energy drain changed or disappeared")

	if not failures.is_empty():
		for failure in failures:
			push_error("GAME-FIX-002 regression: %s" % failure)
		quit(1)
		return

	print("GAME-FIX-002 PASS: zero-need penalties run only on the hourly need-drain cadence")
	quit(0)


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_func := source.find("\nfunc ", start + signature.length())
	if next_func < 0:
		return source.substr(start)
	return source.substr(start, next_func - start)
