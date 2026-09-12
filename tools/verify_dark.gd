extends SceneTree

func _init() -> void:
	var d = preload("res://scripts/Data.gd")
	assert(d.DARK_ALLEY.has("options"), "DARK_ALLEY missing options")
	assert(d.DARK_ROOFTOP.has("options"), "DARK_ROOFTOP missing options")
	assert(d.DARK_ALLEY["options"].size() == 2, "alley options != 2")
	assert(d.DARK_ROOFTOP["options"].size() == 3, "rooftop options != 3")

	var r = preload("res://scripts/Rules.gd").new()
	r._ready()  # 手动触发载入 rules.json

	var base := {"age": 60, "money": 100000, "health": 80, "mood": 80, "job": "coder"}

	var st_lucid = base.duplicate(); st_lucid["flags"] = {"dark_path_lucid": true}
	var e1 = r.judge_ending(st_lucid)
	print("lucid -> ", e1["id"])
	assert(e1["id"] == "end_dark_lucid", "lucid ending wrong")

	var st_mad = base.duplicate(); st_mad["flags"] = {"dark_path_mad": true}
	var e2 = r.judge_ending(st_mad)
	print("mad -> ", e2["id"])
	assert(e2["id"] == "end_dark_mad", "mad ending wrong")

	var st_aw = base.duplicate(); st_aw["flags"] = {"dark_path_awakened": true}
	var e3 = r.judge_ending(st_aw)
	print("awakened -> ", e3["id"])
	assert(e3["id"] == "end_dark_awakened", "awakened ending wrong")

	# 没走暗线 → 不应命中暗线结局
	var st_none = base.duplicate(); st_none["flags"] = {}
	var e4 = r.judge_ending(st_none)
	print("no-dark -> ", e4["id"])
	assert(not str(e4["id"]).begins_with("end_dark"), "no-dark wrongly hit dark ending")

	print("VERIFY_DARK OK")
	quit()
