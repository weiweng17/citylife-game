extends SceneTree
## 新手引导文案契约。
##
## 注意：旧版断言的是单张地图时代的 6 行文案（"点击地图 / 发光 / 说话 / 家 / 60 岁"），
## MAP-002 改成独立地点场景后文案已经换掉，那份断言全部落空。
## 这里断言的是当前地点场景版本的文案，不再绑定具体句子。
##
## 另外：原先失败分支写的 `quit(1)` 在 `_init()` 里不生效——后面的 `quit()`
## 会把退出码覆盖回 0，于是"打印了 FAIL 却退出 0"。现在统一在末尾按失败数定退出码。

func _init() -> void:
	call_deferred("run")


func run() -> void:
	var d = preload("res://scripts/Data.gd")
	var tutorial: Array = d.TUTORIAL
	var failures: Array[String] = []

	if tutorial.size() < 5:
		failures.append("引导至少要有 5 行，当前 %d 行" % tutorial.size())

	var joined := ""
	for raw_line in tutorial:
		var text := str(raw_line)
		joined += text
		if text.strip_edges().is_empty():
			failures.append("引导里不能有空行")

	# 关键信息必须在场：年龄、地点是独立场景、地点解锁、行动入口、旅行耗时。
	for keyword in ["22 岁", "独立场景", "解锁", "行动", "旅行"]:
		if keyword not in joined:
			failures.append("引导缺少关键信息：%s" % keyword)

	print("TUTORIAL lines count: ", tutorial.size())
	print("first line: ", tutorial[0])
	print("last line: ", tutorial[-1])
	for message in failures:
		printerr("FAIL ", message)
	print("ONBOARD_OK" if failures.is_empty() else "ONBOARD_FAIL")
	quit(0 if failures.is_empty() else 1)
