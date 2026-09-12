extends Node
## 规则层：年度结算、死亡判定、结局判定
##
## 数值全部来自 data/rules.json（由 tools/export_rules.mjs 从 Canvas 版导出）。
## 这套数值在 Canvas 版已用 600 局模拟调过平衡（寿命 ~60 岁、破产率个位数），
## 直接搬过来，不要重新拍脑袋改。

const EventSystemScript = preload("res://scripts/systems/EventSystem.gd")

var rules: Dictionary = {}
var jobs: Dictionary = {}
var consts: Dictionary = {}
var endings: Array = []

func _ready() -> void:
	_load()


func _load() -> void:
	var f := FileAccess.open("res://data/rules.json", FileAccess.READ)
	if f == null:
		push_error("[Rules] 读不到 res://data/rules.json")
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) == OK:
		rules = j.data
	jobs = rules.get("jobs", {})
	consts = rules.get("const", {})
	endings = rules.get("endings", [])
	print("[Rules] 载入 %d 个职业 / %d 个结局" % [jobs.size(), endings.size()])


## 年度结算：收入、支出、晋升、再就业、创业结算、自然恢复。
## st 是玩家状态字典（会被直接修改），返回结算明细供 UI 展示。
func year_tick(st: Dictionary) -> Dictionary:
	var job_key := str(st.get("job", "unemployed"))
	var job: Dictionary = jobs.get(job_key, jobs.get("unemployed", {}))
	var flags: Dictionary = st.get("flags", {})

	# ---- 收入：受技能与人脉加成
	var rate: float = float(consts.get("income_base", 0.85)) \
		+ float(st.get("skill", 0)) / float(consts.get("income_skill_div", 280)) \
		+ float(st.get("network", 0)) / float(consts.get("income_network_div", 550))
	var income: int = int(float(job.get("salary", 0)) * rate)

	# ---- 支出：生活成本 + 房贷 + 消费升级
	var cost: int = int(rules.get("living_cost_own", 32000)) if bool(flags.get("hasHouse", false)) else int(rules.get("living_cost", 72000))
	if bool(flags.get("mortgage", false)):
		cost += int(rules.get("mortgage_year", 48000))
	var age_from: int = int(consts.get("lifestyle_age_from", 30))
	var lifestyle: float = float(consts.get("lifestyle_base", 0.25)) \
		+ max(0, int(st.get("age", 22)) - age_from) * float(consts.get("lifestyle_age_step", 0.007))
	cost += int(income * lifestyle)

	st["money"] = int(st.get("money", 0)) + income - cost

	# ---- 晋升
	var promoted := ""
	var nxt: String = str(rules.get("promote_path", {}).get(job_key, ""))
	if nxt != "" \
		and int(st.get("skill", 0)) >= int(consts.get("promote_skill", 68)) \
		and int(st.get("network", 0)) >= int(consts.get("promote_network", 50)) \
		and randf() < float(consts.get("promote_chance", 0.12)):
		st["job"] = nxt
		st["mood"] = mini(100, int(st.get("mood", 0)) + 6)
		st["skill"] = mini(100, int(st.get("skill", 0)) + 2)
		promoted = str(jobs.get(nxt, {}).get("name", nxt))

	# ---- 失业再就业（待业久了会降档重新上岗，避免无底洞）
	if job_key == "unemployed":
		var jy: int = int(st.get("jobless_years", 0)) + 1
		st["jobless_years"] = jy
		if jy >= int(consts.get("rehire_min_years", 2)) \
			and randf() < float(consts.get("rehire_base", 0.35)) + jy * float(consts.get("rehire_step", 0.12)):
			st["job"] = "coder" if int(st.get("skill", 0)) >= 62 else ("operator" if int(st.get("skill", 0)) >= 45 else "rider")
			st["jobless_years"] = 0
			st["mood"] = mini(100, int(st.get("mood", 0)) + 10)
	else:
		st["jobless_years"] = 0

	# ---- 创业结算：熬出头
	var ipo := false
	if job_key == "founder" \
		and int(st.get("skill", 0)) >= int(consts.get("ipo_skill", 66)) \
		and int(st.get("network", 0)) >= int(consts.get("ipo_network", 58)) \
		and randf() < float(consts.get("ipo_chance", 0.07)):
		st["job"] = "boss"
		st["money"] = int(st.get("money", 0)) + int(consts.get("ipo_bonus", 500000))
		st["mood"] = mini(100, int(st.get("mood", 0)) + 15)
		ipo = true

	# ---- 自然恢复（随年龄递减）
	var recover: float = float(consts.get("recover_base", 3.2)) \
		- (int(st.get("age", 22)) - int(consts.get("start_age", 22))) * float(consts.get("recover_age_step", 0.05))
	st["health"] = clampi(int(st.get("health", 0)) + float(job.get("dHealth", 0)) + recover, 0, 100)
	st["mood"] = clampi(int(st.get("mood", 0)) + float(job.get("dMood", 0)) + float(consts.get("mood_recover", 1.4)), 0, 100)

	st["age"] = int(st.get("age", 22)) + 1

	return {
		"income": income,
		"cost": cost,
		"net": income - cost,
		"promoted": promoted,
		"ipo": ipo,
	}


## 死亡/结束原因，空串表示继续
func death_reason(st: Dictionary) -> String:
	if int(st.get("health", 100)) <= 0:
		return "health"
	if int(st.get("mood", 100)) <= 0:
		return "mood"
	if int(st.get("money", 0)) < int(consts.get("bankrupt_limit", -600000)):
		return "money"
	if int(st.get("age", 22)) > int(consts.get("end_age", 60)):
		return "age"
	return ""


## 结局判定：按顺序取第一个满足条件的（数组顺序 = 优先级）
func judge_ending(st: Dictionary) -> Dictionary:
	for e in endings:
		if EventSystemScript.cond_ok(e.get("cond"), st):
			return e
	if endings.is_empty():
		return {"id": "none", "name": "未完待续", "desc": "这一生，说不清是什么。"}
	return endings[-1]


## 职业中文名
func job_name(key: String) -> String:
	return str(jobs.get(key, {}).get("name", key))
