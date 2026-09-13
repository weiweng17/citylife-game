extends SceneTree
## 无头验证：地图、NPC、对话系统、主线推进
##
## ⚠ 已废弃（MAP-002）：这份套件针对「单张世界地图」的旧实现——旧 Player 的
## `moving/set_target`、`Game._detect_near()`、固定坐标 GOAL(600,600) 与
## 建筑/树木/POI 计数。独立地点场景迁移（c43c30e）之后旧世界被隐藏
## （`set_legacy_world_visible(false)`）、交互改由 `InteractionSystem` 负责，
## 本套件统计出来的都是 0，还会在 `_detect_near` 处抛 SCRIPT ERROR，
## 且因为断言宽松会照打 [OK]——继续跑它只会给出误导性的绿灯。
## 现在一旦发现旧接口不在就直接退出并指向替代套件。
## 替代：verify_locations / verify_navigation / verify_home_activities /
## verify_home_edges / verify_needs / verify_store。
##
## 运行：Godot --headless --path <项目> --script res://tools/verify.gd
##
## 必须在引擎的物理帧回调里驱动检查——在 _init() 里查，
## _ready() 还没跑、物理空间也没准备好，会看到「节点全是 0」的假象。

const Data = preload("res://scripts/Data.gd")
const GOAL := Vector2(600.0, 600.0)

var main: Node
var player: CharacterBody2D
var frames := 0
var phase := 0

var buildings := 0
var trees := 0
var pois := 0
var npcs := 0
var ground_sprites := 0
var start_pos := Vector2.ZERO
var move_frames := 0

func _init() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	main = scene.instantiate()
	get_root().add_child(main)


func _physics_process(_delta: float) -> bool:
	frames += 1

	# 阶段 0：等 _ready 建完地图，然后统计 + 开始移动测试
	if phase == 0 and frames == 3:
		_collect_stats()
		player = main.get_node_or_null("Player") as CharacterBody2D
		if player:
			start_pos = player.position
			player.set_target(GOAL)
		phase = 1
		return false

	# 阶段 1：等移动完成
	if phase == 1:
		move_frames += 1
		if (player and not player.moving) or move_frames > 600:
			phase = 2
		return false

	# 阶段 2：NPC 与对话测试
	if phase == 2:
		# 旧接口没了就别继续——继续跑只会在 _detect_near 上抛错并打出误导性的 [OK]。
		if not main.has_method("_detect_near"):
			printerr("verify.gd 已废弃：MAP-002 独立地点场景迁移后，旧单张世界与 Game._detect_near() 均已移除。")
			printerr("请改用：verify_locations / verify_navigation / verify_home_activities / verify_store。")
			quit(2)
			return true
		_test_npc()
		return true

	return false


func _collect_stats() -> void:
	for c in main.get_children():
		if c is StaticBody2D:
			if str(c.name).begins_with("Tree"):
				trees += 1
			else:
				buildings += 1
		elif c is Area2D:
			if str(c.name).begins_with("NPC_"):
				npcs += 1
			else:
				pois += 1
		elif c is Sprite2D:
			ground_sprites += 1


func _test_npc() -> void:
	var ok := true
	print("")
	print("=== 都市浮生 · Godot 版验证 ===")

	if player == null:
		print("[FAIL] 找不到 Player")
		quit(1)
		return

	# 1. 地图
	print("[OK] 建筑 = %d（期望 5：家/便利店/公司/医院/老楼）" % buildings)
	print("[OK] 树 = %d（期望 12）" % trees)
	print("[OK] 地点交互点 = %d（期望 7）" % pois)
	print("[OK] NPC = %d（期望 6）" % npcs)
	print("[OK] 地面/道路 Sprite = %d（期望 3）" % ground_sprites)
	ok = ok and buildings == 5 and trees == 12 and pois == 7 and npcs == 6 and ground_sprites == 3

	# 2. 移动
	var dist := player.position.distance_to(GOAL)
	print("[OK] 移动 %d 帧：%s → %s，距目标 %.0f px" % [move_frames, start_pos, player.position, dist])
	ok = ok and dist < 12.0

	# 3. NPC 靠近检测：传送到陈姐旁
	var chen := _find_npc("chenjie")
	if chen.is_empty():
		print("[FAIL] 找不到陈姐数据")
		quit(1)
		return
	player.position = chen["pos"] + Vector2(20, 20)
	main._detect_near()
	var nt: Dictionary = main.get("near_target")
	print("[OK] 靠近陈姐 → near_target = %s" % (nt.get("data", {}).get("name", "空")))
	ok = ok and nt.get("type", "") == "npc" and nt.get("data", {}).get("name", "") == "陈姐"

	# 4. 对话系统
	main._talk_to(chen)
	var panel = main.get("dialog_panel")
	var visible := bool(panel.visible) if panel else false
	var dlg_text := str(main.get("dialog_text").text) if main.get("dialog_text") else ""
	print("[OK] 触发对话 → 对话框可见 = %s" % visible)
	print("[OK] 首句 = 「%s」" % dlg_text.substr(0, mini(dlg_text.length(), 18)))
	ok = ok and visible and dlg_text.length() > 0

	# 5. 暗线：把年龄提到 40 再谈，应触发暗线并记线索
	main.set("age", 40)
	main.set("clues", [])
	main._talk_to(chen)
	var lines: Array = main.get("dialog_lines")
	print("[OK] 40 岁对话条数 = %d（应含暗线追加 > 3）" % lines.size())
	ok = ok and lines.size() > 3
	# 走完对话收集线索
	while bool(main.get("dialog_panel").visible):
		main._on_dialog_next()
	var clues: Array = main.get("clues")
	print("[OK] 暗线线索收集 = %d 条" % clues.size())
	ok = ok and clues.size() == 1

	# 6. 事件系统
	var ev = main.get("events_sys")
	var ev_count: int = ev.events.size() if ev else 0
	print("[OK] 载入事件数 = %d（期望 65）" % ev_count)
	ok = ok and ev_count == 65

	var st30 := {"age": 30, "money": 100000, "health": 80, "mood": 70,
		"skill": 50, "network": 40, "flags": {}, "job": "operator"}
	var picked = ev.pick("office", st30)
	var picked_ok: bool = picked != null
	print("[OK] 公司抽事件 = %s" % (str(picked.get("title", "")) if picked_ok else "null"))
	ok = ok and picked_ok

	# 场景别名：每个地点都要能抽到事件
	for sc in ["hospital", "rooftop", "park", "subway", "rent", "cafe"]:
		var p2 = ev.pick(sc, st30)
		print("[OK] 地点「%s」可抽事件 = %s" % [sc, "是" if p2 != null else "否"])

	# 完整事件流程
	if picked_ok:
		main._show_event(picked)
		var ep = main.get("event_panel")
		var opt_count: int = main.get("event_opts").get_child_count()
		print("[OK] 事件面板可见 = %s，选项数 = %d" % [bool(ep.visible), opt_count])
		ok = ok and bool(ep.visible) and opt_count > 0
		var before_age: int = int(main.get("age"))
		for b in main.get("event_opts").get_children():
			if not b.disabled:
				b.pressed.emit()
				break
		print("[OK] 选择后结果文案长度 = %d" % str(main.get("event_body").text).length())
		main._close_event()
		print("[OK] 关闭事件后年龄 %d → %d" % [before_age, int(main.get("age"))])
		ok = ok and int(main.get("age")) == before_age + 1

	# 7. 年度结算
	var ru = main.get("rules_sys")
	print("[OK] 职业 = %d（期望 16）  结局 = %d（期望 12）" % [ru.jobs.size(), ru.endings.size()])
	ok = ok and ru.jobs.size() == 16 and ru.endings.size() == 12

	var st1 := {"age": 30, "money": 100000, "health": 80, "mood": 70,
		"skill": 50, "network": 40, "flags": {}, "job": "operator", "jobless_years": 0}
	var res1: Dictionary = ru.year_tick(st1)
	print("[OK] 年度结算：收入 %d / 支出 %d / 结余 %d，年龄 30 → %d" % [
		int(res1["income"]), int(res1["cost"]), int(res1["net"]), int(st1["age"])])
	ok = ok and int(res1["income"]) > 0 and int(st1["age"]) == 31

	# 高技能+高人脉 → 可能晋升（跑多次看是否触发）
	var promoted_cnt := 0
	for i in range(200):
		var stp := {"age": 40, "money": 500000, "health": 80, "mood": 70,
			"skill": 85, "network": 70, "flags": {}, "job": "operator", "jobless_years": 0}
		var rp: Dictionary = ru.year_tick(stp)
		if str(rp["promoted"]) != "":
			promoted_cnt += 1
	print("[OK] 200 次高属性结算中晋升 %d 次（应 > 0）" % promoted_cnt)
	ok = ok and promoted_cnt > 0

	# 8. 死亡与结局判定
	var old_st := {"age": 61, "money": 0, "health": 50, "mood": 50,
		"skill": 50, "network": 50, "flags": {}, "job": "operator"}
	print("[OK] 61 岁结束原因 = %s（期望 age）" % ru.death_reason(old_st))
	ok = ok and ru.death_reason(old_st) == "age"

	var mid_st := {"age": 45, "money": 0, "health": 0, "mood": 50,
		"skill": 50, "network": 50, "flags": {}, "job": "operator"}
	print("[OK] 健康归零结束原因 = %s（期望 health）" % ru.death_reason(mid_st))
	ok = ok and ru.death_reason(mid_st) == "health"

	var rich_st := {"age": 60, "money": 5000000, "health": 85, "mood": 80,
		"skill": 85, "network": 85, "flags": {}, "job": "boss"}
	var end_rich: Dictionary = ru.judge_ending(rich_st)
	print("[OK] 高属性结局 = 「%s」" % str(end_rich.get("name", "")))
	ok = ok and str(end_rich.get("name", "")) != ""

	# 触发一次真实结局面板
	main.set("age", 61)
	main._year_pass()
	var e_panel = main.get("ending_panel")
	print("[OK] 结局面板可见 = %s，标题 = %s" % [bool(e_panel.visible), str(main.get("ending_title").text)])
	ok = ok and bool(e_panel.visible)

	# 9. 主线阶段
	var stage_idx := int(main.get("stage_idx"))
	var st_name: String = "（已完成全部）" if stage_idx >= Data.STAGES.size() else str(Data.STAGES[stage_idx]["name"])
	print("[OK] 当前主线阶段 = %s（index %d）" % [st_name, stage_idx])
	# 给足条件看能否推进
	main.set("money", 999999)
	main._check_stage()
	var after := int(main.get("stage_idx"))
	print("[OK] 满足条件后阶段推进：%d → %d" % [stage_idx, after])
	ok = ok and after > stage_idx

	print("")
	print("===== 全部通过 =====" if ok else "===== 存在问题 =====")
	quit(0 if ok else 1)


func _find_npc(id: String) -> Dictionary:
	for n in Data.NPCS:
		if n["id"] == id:
			return n
	return {}
