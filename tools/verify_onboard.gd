extends SceneTree

func _init() -> void:
	var d = preload("res://scripts/Data.gd")
	var tutorial = d.TUTORIAL
	print("TUTORIAL lines count:", tutorial.size())
	if tutorial.size() != 6:
		print("FAIL size")
		quit(1)
	var joined = ""
	for ln in tutorial:
		if ln == "":
			print("FAIL empty line")
			quit(1)
		joined += ln
	for kw in ["点击地图", "发光", "说话", "家", "22 岁", "60 岁"]:
		if kw not in joined:
			print("FAIL missing kw:", kw)
			quit(1)
	print("first line:", tutorial[0])
	print("last line:", tutorial[-1])
	print("ONBOARD_OK")
	quit()
