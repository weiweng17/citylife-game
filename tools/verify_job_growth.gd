extends SceneTree
## 第 3 阶段单元 2：工作技能成长（手艺分档 → 时薪；上班攒熟练度；熟练后能谈薪）。
##
## 覆盖：
## A. 纯算法：档位边界、时薪与谈薪级数、熟练度累积与升级、满技能不再攒、谈薪资格与门槛
## B. 在游戏里：上班按档位发钱、
##    上班真能涨技能（一次班跨过档位并给出旁白）、
##    技能不够时谈薪被挡下且不消耗时间、
##    谈薪一天一次、成功涨岗位工资、失败掉心情、
##    老张熟络后门槛降一档、
##    岗位工资到顶后拒绝再谈、
##    工位的时薪与谈薪按钮的显隐跟着技能走
## C. 存档：work_exp / raise_steps / raise_day 随 game_state 整份往返，不新增 payload 字段
##
## 说明：谈薪的判定刻意不用随机数（确定性），所以这里能直接断言成败，玩家也不能靠读档刷结果。

const Data = preload("res://scripts/Data.gd")
const JobGrowth = preload("res://scripts/systems/JobGrowth.gd")

const LAOZHANG := "laozhang"

var failures: Array[String] = []
var main


func _init() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL ", message)


func run() -> void:
	_math()

	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._choose_origin(Data.ORIGINS[0])
	main.dialog_queue.clear()
	main.dialog_ui.close_dialog()
	await process_frame
	# 先让 Game 把输入闸门算清楚再冻结（见 docs/QA_2026-09-13.md 的偶发红灯一节）。
	main._process(0.0)
	main.set_process(false)

	await _in_game()
	await _save_round_trip()

	print("job growth failures: ", failures.size())
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


## ---------------------------------------------------------------- A 纯算法
func _math() -> void:
	check(JobGrowth.title_of(0) == "学徒", "0 skill should be 学徒")
	check(JobGrowth.title_of(34) == "学徒", "34 skill should still be 学徒")
	check(JobGrowth.title_of(35) == "上手", "35 skill should cross into 上手")
	check(JobGrowth.title_of(48) == "上手", "the town origin's 48 skill should be 上手")
	check(JobGrowth.title_of(55) == "熟练", "55 skill should be 熟练")
	check(JobGrowth.title_of(100) == "独当一面", "100 skill should be 独当一面")

	check(JobGrowth.wage_of(48) == 120, "the baseline 上手 wage must stay 120, got %d" % JobGrowth.wage_of(48))
	check(JobGrowth.wage_of(0) == 90, "学徒 should earn less than 上手")
	check(JobGrowth.wage_of(48, 1) == 150, "one raise should add %d" % JobGrowth.RAISE_BONUS)
	check(JobGrowth.wage_of(48, 99) == 120 + JobGrowth.MAX_RAISES * JobGrowth.RAISE_BONUS,
		"raises must clamp at MAX_RAISES")
	check(JobGrowth.wage_of(88) > JobGrowth.wage_of(72), "higher tiers must pay more")

	check(JobGrowth.exp_needed(48) == 48, "48 skill should need 48 exp, got %d" % JobGrowth.exp_needed(48))
	check(JobGrowth.exp_needed(80) > JobGrowth.exp_needed(40), "higher skill must grow slower")

	var gain: Dictionary = JobGrowth.gain_shift(48, 40)
	check(int(gain["skill"]) == 49, "40+12 exp at skill 48 should level to 49, got %d" % int(gain["skill"]))
	check(int(gain["exp"]) == 4, "the leftover exp should carry over, got %d" % int(gain["exp"]))
	check(bool(gain["leveled"]) and not bool(gain["tier_up"]), "an inside-tier level must not count as a tier-up")

	var crossing: Dictionary = JobGrowth.gain_shift(54, 47)
	check(int(crossing["skill"]) == 55, "54 skill with 47 exp should land on 55, got %d" % int(crossing["skill"]))
	check(bool(crossing["tier_up"]), "54→55 must be reported as a tier-up")
	check(str(crossing["tier_title"]) == "熟练", "the tier-up should name 熟练")

	var capped: Dictionary = JobGrowth.gain_shift(100, 50)
	check(int(capped["skill"]) == 100, "skill must clamp at %d" % JobGrowth.MAX_SKILL)
	check(int(capped["exp"]) == 0, "at max skill the exp must stop piling up, got %d" % int(capped["exp"]))

	check(not JobGrowth.can_negotiate(54), "54 skill is not enough to open the negotiation")
	check(JobGrowth.can_negotiate(55), "55 skill is enough to open the negotiation")

	var even: Dictionary = JobGrowth.negotiate(55, 40, 0)
	check(bool(even["ok"]), "55 skill + 40 network should just make it, need %d score %d" % [int(even["need"]), int(even["score"])])
	var short: Dictionary = JobGrowth.negotiate(55, 30, 0)
	check(not bool(short["ok"]), "55 skill + 30 network should not be enough")
	var helped: Dictionary = JobGrowth.negotiate(55, 30, JobGrowth.FRIEND_RELATION)
	check(bool(helped["ok"]) and bool(helped["friend"]), "a 熟络 老张 should lower the bar enough to pass")
	var stranger_help: Dictionary = JobGrowth.negotiate(55, 30, JobGrowth.FRIEND_RELATION - 1)
	check(not bool(stranger_help["friend"]), "one point below 熟络 must not count as a friend")
	print("PASS job growth math (tiers, wage, exp, negotiation)")


## ---------------------------------------------------------------- B 在游戏里
func _go_office() -> void:
	main.location_sys.unlock("office")
	main.location_sys.travel_to("office")
	main.location_sys.player_sprite.position = main.office_activities.SPOTS.work.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	main.office_activities.blocked = false
	main.daily_routine.reset(main.time_sys.day)
	# 新增的谈薪点必须真的走得到，否则技能够了玩家也点不到（站位是照美术估的，容易压进阻挡区）。
	check(main.location_sys.walk_to(main.office_activities.SPOTS.negotiate.position),
		"the negotiation spot must be reachable from the office spawn")
	main.location_sys.stop_walking()
	main.location_sys.player_sprite.position = main.office_activities.SPOTS.work.position
	main.location_sys.player_target = main.location_sys.player_sprite.position
	await process_frame


func _in_game() -> void:
	await _go_office()

	# ---- 上班：按当前档位发钱，并且这一班刚好跨档
	main.skill = 54
	main.game_state.work_exp = 47  # 47 + 12 = 59 >= exp_needed(54)=51 → 涨到 55
	var before_money: int = main.money
	var before_minutes: int = main.time_sys.get_minute_of_day()
	main.office_activities._activate("work")
	check(main.activity_running, "the work shift should start")
	await create_timer(1.6).timeout
	check(not main.activity_running, "the work shift should end")
	check(main.money == before_money + 120,
		"a 上手 shift must still pay 120 (the raise must not apply retroactively), got %d" % main.money)
	check(main.time_sys.get_minute_of_day() - before_minutes == 240, "a shift must still cost 4 hours")
	check(main.skill == 55, "the shift should have grown the skill to 55, got %d" % main.skill)
	check(int(main.game_state.work_exp) == 8, "the leftover exp should be kept, got %d" % int(main.game_state.work_exp))
	check(main.toast_label.text.contains("熟练"), "a tier-up must be narrated, got: " + main.toast_label.text)
	check(main.daily_routine.is_done("work"), "a shift must still tick the daily goal")
	print("PASS a shift pays by tier and grows the skill into 熟练")

	# ---- 技能不够：谈薪被挡下，而且不花时间、不占当天的名额
	main.skill = 48
	main.game_state.raise_steps = 0
	main.game_state.raise_day = 0
	main.money = 500
	main.mood = 60
	var minutes_before: int = main.time_sys.get_minute_of_day()
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 0, "a refused negotiation must not raise anything")
	check(int(main.game_state.raise_day) == 0, "a refused negotiation must not burn the day")
	check(main.time_sys.get_minute_of_day() == minutes_before, "a refused negotiation must not cost time")
	check(main.toast_label.text.contains("技能 %d" % JobGrowth.NEGOTIATE_SKILL),
		"the refusal should say what is missing, got: " + main.toast_label.text)
	print("PASS the negotiation is gated behind 熟练 and costs nothing when refused")

	# ---- 谈成：涨岗位工资、给心情；同一天第二次被挡
	main.skill = 60
	main.network = 40  # 60 + 40 = 100 >= 95
	main.game_state.relations.erase(LAOZHANG)
	var mood_before_ok: int = main.mood
	var minutes_before_ok: int = main.time_sys.get_minute_of_day()
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 1, "a successful negotiation should raise one step")
	check(int(main.game_state.raise_day) == main.time_sys.day, "the day of the talk must be recorded")
	check(main.mood == mood_before_ok + 6, "a success should give back 6 mood, got %d" % main.mood)
	check(main.time_sys.get_minute_of_day() - minutes_before_ok == JobGrowth.NEGOTIATE_MINUTES,
		"a negotiation should cost %d minutes" % JobGrowth.NEGOTIATE_MINUTES)
	check(main.office_activities.context.get("wage") == JobGrowth.wage_of(60, 1),
		"the desk tooltip should pick up the new wage, got %s" % str(main.office_activities.context.get("wage")))
	var minutes_after_ok: int = main.time_sys.get_minute_of_day()
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 1, "a second talk on the same day must be refused")
	check(main.time_sys.get_minute_of_day() == minutes_after_ok, "the refused repeat must not cost time")
	check(main.toast_label.text.contains("今天已经找过主管了"), "the repeat should say so, got: " + main.toast_label.text)
	print("PASS a successful negotiation raises the wage, once per day")

	# ---- 跨天之后可以再谈
	main.time_sys.advance_minutes(24 * 60)
	main._last_total_minutes = main.time_sys.day * 1440 + main.time_sys.get_minute_of_day()
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 2, "a new day should allow another talk")
	print("PASS a new day allows another negotiation")

	# ---- 老张熟络：同样的属性，这次谈得下来
	main.game_state.raise_steps = 0
	main.game_state.raise_day = 0
	main.skill = 55
	main.network = 30  # 85 < 95，单独谈不下来
	main.mood = 60
	main.game_state.relations[LAOZHANG] = JobGrowth.FRIEND_RELATION
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 1, "老张's word should tip the negotiation")
	check(main.toast_label.text.contains("老张"), "the help should be named in the feedback, got: " + main.toast_label.text)
	print("PASS a 熟络 老张 lowers the bar for the negotiation")

	# ---- 谈不下来：掉心情，并如实告诉玩家
	main.game_state.raise_steps = 0
	main.game_state.raise_day = 0
	main.skill = 55
	main.network = 30
	main.game_state.relations.erase(LAOZHANG)
	main.mood = 60
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == 0, "without help the talk should fail")
	check(main.mood == 54, "a failed talk should cost 6 mood, got %d" % main.mood)
	print("PASS a failed negotiation costs mood and says so")

	# ---- 岗位工资到顶
	main.game_state.raise_steps = JobGrowth.MAX_RAISES
	main.game_state.raise_day = 0
	main.skill = 60
	main.network = 40
	main.mood = 60
	await main._do_negotiate()
	check(int(main.game_state.raise_steps) == JobGrowth.MAX_RAISES, "the raises must stop at the cap")
	check(main.mood == 60, "a talk refused for being capped must not cost mood")
	check(main.toast_label.text.contains("到顶"), "the cap should be explained, got: " + main.toast_label.text)
	print("PASS the raises stop at the cap without punishing the player")

	# ---- 展示层跟着技能走：不到熟练看不见谈薪，到了就出现
	# Game._process 已被冻结，所以展示上下文要手动推一次（`_refresh_ui` 就是干这个的）；
	# 按钮的显隐又是在 OfficeActivities._process 里刷的，而 process_frame 信号在节点
	# 处理之前发出，所以只等一帧会在"刚改完、还没刷"的空档上断言——等两帧才稳。
	main.game_state.raise_steps = 0
	main.game_state.raise_day = 0
	main.skill = 48
	main._refresh_ui()
	await process_frame
	await process_frame
	check(not main.office_activities.buttons["negotiate"].visible,
		"the negotiation hotspot must stay hidden below 熟练")
	main.skill = 60
	main._refresh_ui()
	await process_frame
	await process_frame
	check(main.office_activities.buttons["negotiate"].visible,
		"the negotiation hotspot must appear at 熟练")
	check(str(main.office_activities.buttons["work"].tooltip_text).contains(str(JobGrowth.wage_of(60, 0))),
		"the desk tooltip must show the current wage, got: " + str(main.office_activities.buttons["work"].tooltip_text))
	print("PASS the negotiation hotspot and the desk wage follow the skill")


## ---------------------------------------------------------------- C 存档
func _save_round_trip() -> void:
	main.skill = 61
	main.game_state.work_exp = 13
	main.game_state.raise_steps = 2
	var talk_day: int = main.time_sys.day
	main.game_state.raise_day = talk_day
	var saved: Dictionary = main.build_save_payload()
	var saved_state: Dictionary = saved.get("game_state", {})
	for key in ["work_exp", "raise_steps", "raise_day"]:
		check(saved_state.has(key), "%s should ride inside game_state, not as a new payload field" % key)

	# 深拷贝再读回，模拟真的落盘（引用同一本字典等于没测序列化）。
	var copied: Dictionary = (saved_state as Dictionary).duplicate(true)
	main.game_state.work_exp = 0
	main.game_state.raise_steps = 0
	main.game_state.raise_day = 0
	main.apply_save_payload({"game_state": copied})
	check(int(main.game_state.work_exp) == 13, "work_exp must come back, got %d" % int(main.game_state.work_exp))
	check(int(main.game_state.raise_steps) == 2, "raise_steps must come back, got %d" % int(main.game_state.raise_steps))
	check(int(main.game_state.raise_day) == talk_day,
		"raise_day must come back (expected day %d, got %d)" % [talk_day, int(main.game_state.raise_day)])
	check(main.skill == 61, "skill must come back too, got %d" % main.skill)
	print("PASS job growth state survives a save round-trip inside game_state")
