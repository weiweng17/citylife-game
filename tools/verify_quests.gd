extends SceneTree
## 第 3 阶段单元 3：首批连续任务（串行主线）。
##
## 覆盖：
## A. 内容体检——validate() 必须干净。id 重复 / next 指空 / 步骤类型不认识，
##    任何一个都会变成**不报错的死路**，这是本单元最要防的东西。
## B. 系统层——intro 只发一次、计数与步进、幂等（重复 evaluate 不再发任何事件）、
##    收尾与奖励只发一次、整条链能走完。
## C. 游戏内——开局自动挂任务并弹开场白、HUD 那行有任务、计数从**真实结算点**进来
##    （上班/做饭/便利店）；"计数只对当前任务生效"不是死路（之后再做一次即可）。
## D. 存档——进度随 game_state 往返，读档后不重复发奖励、不重复说开场白。
##
## 注意：测试冻结了 `Game._process`，所以每一步结算之后都要手动
## `main._evaluate_quests()`——真实游戏里这是每帧自动跑的。

const Data = preload("res://scripts/Data.gd")
const QuestSystemScript = preload("res://scripts/systems/QuestSystem.gd")

var failures: Array[String] = []
var main
var quest


func _init() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL ", message)


## 切图之后，交互层的 `layer.visible` 要等它自己的 `_process` 才会亮；
## 只等固定帧数会踩中"layer 还没亮就 _activate → 静默返回"的坑（见 verify_day_flow）。
func _wait_for_layer(activities) -> void:
	var guard: int = 0
	while guard < 600:
		if activities.layer.visible and not activities.blocked:
			await process_frame
			return
		await process_frame
		guard += 1
	check(false, "the interaction layer never became visible for " + str(activities.name))


func run() -> void:
	await _content_audit()
	_system_level()

	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	quest = main.quest_sys
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	main._process(0.0)
	main.set_process(false)

	await _in_game()
	await _save_round_trip()

	print("quest failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


## ------------------------------------------------- A 内容体检
func _content_audit() -> void:
	var probe = QuestSystemScript.new()
	root.add_child(probe)
	var problems: Array = probe.validate()
	if problems.is_empty():
		check(true, "ok")
	else:
		var joined := ""
		for problem in problems:
			joined += str(problem) + "; "
		check(false, "quests.json must pass validation, got: " + joined)
	check(probe.total_count() == 3, "the first quest chain should have 3 quests, got %d" % probe.total_count())
	probe.queue_free()
	await process_frame
	print("PASS quest content audit (ids, next links, step types)")


## ------------------------------------------------- B 系统层
func _system_level() -> void:
	var q = QuestSystemScript.new()
	root.add_child(q)
	var state: Dictionary = {
		"skill": 0, "money": 0, "raise_steps": 0, "relations": {}, "flags": {}, "quests": {},
	}
	var day: int = 1

	check(str(q.active_quest(state).get("id", "")) == "q1_stand_firm", "the chain must start at q1")
	check(q.progress_label(state).contains("1/4"), "q1 should report step 1 of 4, got " + q.progress_label(state))

	# intro 只发一次：第一次有，之后永远没有
	var first: Array = q.evaluate(state, day)
	check(first.size() >= 1 and str(first[0].get("kind", "")) == "intro",
		"the first evaluate must emit the intro first")
	var repeats: Array = q.evaluate(state, day)
	check(repeats.is_empty(), "a repeat evaluate must emit nothing, got %d events" % repeats.size())

	# 计数 + 步进
	q.notify(state, "work_shift")
	var step_events: Array = q.evaluate(state, day)
	check(step_events.size() == 1 and str(step_events[0].get("kind", "")) == "step",
		"one counted shift should advance exactly one step")
	check(q.current_step_index(state) == 1, "the step pointer should sit on the skill step")
	check(not q.objective_text(state).is_empty(), "the objective line must not go empty mid-quest")

	# 多步一次收敛 + 收尾只发一次
	state["skill"] = 55
	q.notify(state, "meal_cooked")
	state["money"] = 3000
	var many: Array = q.evaluate(state, day)
	var kinds := {}
	for ev in many:
		kinds[str(ev.get("kind", ""))] = true
	check(kinds.has("step") and kinds.has("quest"), "several satisfiable steps must converge in one pass")
	check(q.is_done(state, "q1_stand_firm"), "q1 must be marked done")
	check(q.evaluate(state, day).is_empty(), "a repeat evaluate after completion must emit nothing")
	check(str(q.active_quest(state).get("id", "")) == "q2_laozhang", "the chain must move on to q2")
	# 收尾事件已在 many 里出现过一次；再跑不会再出现
	var quest_events := 0
	for ev in q.evaluate(state, day):
		if str(ev.get("kind", "")) == "quest":
			quest_events += 1
	check(quest_events == 0, "a completed quest must not emit its closing event again")
	print("PASS quest system is idempotent and hands out rewards exactly once")

	# 全链走完。条件全是单调量（技能/钱/好感/计数），所以一定走得完 → 不形成死路。
	# 计数只对**当前激活**的任务生效，所以分两段喂：先喂 q1 的，链推进到 q3 再喂 store_buy。
	state["quests"] = {}
	state["skill"] = 60
	state["money"] = 5000
	state["relations"] = {"laozhang": 20, "xiaoyu": 45}
	state["raise_steps"] = 1
	q.notify(state, "work_shift")
	q.notify(state, "meal_cooked")
	check(q.evaluate(state, day).size() > 0, "q1 and q2 should converge in one pass")
	check(q.is_done(state, "q1_stand_firm") and q.is_done(state, "q2_laozhang"),
		"q1 and q2 must both close from a fresh state")
	check(str(q.active_quest(state).get("id", "")) == "q3_someone_waits", "q3 should now be active")
	q.notify(state, "store_buy")
	check(q.evaluate(state, day).size() > 0, "q3 should converge once its own counter is fed")
	check(q.is_done(state, "q3_someone_waits"), "all three quests must be completable")
	check(q.active_quest(state).is_empty(), "after the chain there must be no dangling quest")
	check(q.objective_text(state).is_empty(), "the objective line must go empty once the chain is done")
	print("PASS the whole chain walks to the end with no dead end")


## ------------------------------------------------- C 游戏内
func _in_game() -> void:
	# 开局自动挂上 q1，开场白弹一次，HUD 那行有任务
	check(main.toast_label.text.contains("先站住脚"), "the intro should toast on start, got: " + main.toast_label.text)
	check(str(quest.active_quest(main._state()).get("id", "")) == "q1_stand_firm", "q1 should be active in game")
	var goal_text: String = main.hud.goal_label.text
	check(goal_text.contains("任务："), "the goal row should carry the quest, got: " + goal_text)
	check(quest.objective_text(main._state()).contains("上一天班"), "the objective should be the first step, got: " + quest.objective_text(main._state()))
	print("PASS the quest hooks into the HUD and toasts its intro on start")

	# 上班 → 计数从真实结算点进来 → 第一步完成
	main.location_sys.unlock("office")
	main.location_sys.travel_to("office")
	main.location_sys.player_sprite.position = main.office_activities.SPOTS.work.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.office_activities.blocked = false
	main.daily_routine.reset(main.time_sys.day)
	await _wait_for_layer(main.office_activities)
	main.office_activities._activate("work")
	await create_timer(1.6).timeout
	main._evaluate_quests()
	check(quest.current_step_index(main._state()) == 1,
		"a real shift must complete the first step, got %d" % quest.current_step_index(main._state()))
	check(main.toast_label.text.contains("班上了"),
		"the step completion should be appended to the toast, got: " + main.toast_label.text)
	print("PASS a real work shift advances the quest")

	# 便利店购买：q1 期间买的**不会**记到 q3 的账上（计数只对当前任务生效），
	# 但这不是死路——等 q3 激活后再买一次就行（下面会验证）。
	main.money = 500
	main._on_shop_buy("instant_noodles")
	var q3_prog: Dictionary = (main._state().get("quests", {}) as Dictionary).get("q3_someone_waits", {})
	var q3_counters: Dictionary = q3_prog.get("counters", {})
	check(int(q3_counters.get("store_buy", 0)) == 0,
		"purchases made before q3 is active must not be counted for it")
	print("PASS counters only count for the active quest (and that is not a dead end)")

	# 做饭 → meal_cooked 计数；把 skill 抬上去后，第 2、3 步一起清掉
	main.location_sys.travel_to("home")
	main.location_sys.player_sprite.position = main.home_activities.SPOTS.meal.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.home_activities.blocked = false
	main.money = maxi(main.money, 200)
	main.daily_routine.reset(main.time_sys.day)
	await _wait_for_layer(main.home_activities)
	main.home_activities._activate("meal")
	await create_timer(1.5).timeout
	check(main.daily_routine.is_done("meal"), "the meal must actually settle (the layer may still be hidden right after a travel)")
	main.skill = 55
	main._evaluate_quests()
	check(quest.current_step_index(main._state()) == 3,
		"the shift + skill + a cooked meal should leave only the money step, got %d" % quest.current_step_index(main._state()))
	check(not quest.is_done(main._state(), "q1_stand_firm"), "q1 must wait for the money step")

	main.money = 3000
	main._evaluate_quests()
	check(quest.is_done(main._state(), "q1_stand_firm"), "enough money must close q1")
	check(str(quest.active_quest(main._state()).get("id", "")) == "q2_laozhang", "the chain must hand over to q2")
	check(main.toast_label.text.contains("还行"), "q1's closing line should be toasted, got: " + main.toast_label.text)
	print("PASS real settlements drive the whole first quest")

	# q2：老张 + 谈薪
	main.game_state.relations["laozhang"] = 20
	main.game_state.raise_steps = 1
	main._evaluate_quests()
	check(str(quest.active_quest(main._state()).get("id", "")) == "q3_someone_waits", "q2 should hand over to q3")

	# q3 激活后再买一次，账才记上；然后好感两步
	main.money = maxi(main.money, 20)
	main._on_shop_buy("instant_noodles")
	main.game_state.relations["xiaoyu"] = 20
	main._evaluate_quests()
	check(quest.current_step_index(main._state()) == 2,
		"the purchase made during q3 must count, got %d" % quest.current_step_index(main._state()))
	main.game_state.relations["xiaoyu"] = 45
	main._evaluate_quests()
	check(quest.is_done(main._state(), "q3_someone_waits"), "q3 must close at 45 affinity")
	check(quest.active_quest(main._state()).is_empty(), "the chain must end cleanly")
	check(quest.objective_text(main._state()).is_empty(), "the objective line must be empty at the end")
	check(quest.evaluate(main._state(), main.time_sys.day).is_empty(), "nothing may be emitted after the chain is done")
	print("PASS the in-game chain walks to the end, exactly once")


## ------------------------------------------------- D 存档
func _save_round_trip() -> void:
	var saved: Dictionary = main.build_save_payload()
	var saved_state: Dictionary = saved.get("game_state", {})
	check(saved_state.has("quests"), "quest progress should ride inside game_state, not as a new payload field")
	var copied: Dictionary = (saved_state as Dictionary).duplicate(true)
	# 清空进度再读回，模拟"在别的机器上从旧档继续"
	main.game_state.quests = {}
	main.apply_save_payload({"game_state": copied})
	for quest_id in ["q1_stand_firm", "q2_laozhang", "q3_someone_waits"]:
		check(quest.is_done(main._state(), quest_id), "the done flag for %s must come back" % quest_id)
	check(quest.evaluate(main._state(), main.time_sys.day).is_empty(),
		"after loading a finished chain nothing may fire again (no double reward)")
	print("PASS quest progress survives a save round-trip without re-awarding")
