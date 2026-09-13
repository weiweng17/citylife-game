extends Node
class_name QuestSystem
## 第 3 阶段「首批连续任务」。
##
## 内容写在 `data/quests.json`，这里只做**串行主线**的推进：
## 一次只挂一条任务，走完 `next` 自动接上一条。没有限时、没有失败状态。
##
## 为什么这样就不会形成死路（这是本单元的核心约束）：
##  1. **条件只有单调量**——计数器、技能/钱/好感的"至少"、第几天。这些量不会被花掉或
##     倒退到再也够不着（钱会被花，但上班能再挣；好感只增不减）。
##  2. **没有时钟**——不设截止时间，玩家什么时候做都行。
##  3. **没有失败态**——不合格就是"还没完成"，不存在"已经失败所以卡住"。
##  4. 需要的那两个 NPC（老张、小雨）都在 `data/npc_schedules.json` 里，**每天都会出现**。
##
## 结算仍然只在 Game.gd：这里只负责判断与推进，奖励由 Game 发放。
## 进度存在 `GameState.quests`（随存档走），"是否已发过奖励"由 `done` 标记决定，
## 所以读档、重复调用 `evaluate()` 都不会重复结算。

const QUEST_PATH := "res://data/quests.json"

## 已支持的步骤类型。写 quests.json 时只能用这些——
## **类型写错的步骤会永远完不成，等于给整条链埋一个不报错的死路**，
## 所以 `_load()` 后必须 `validate()` 一遍（加载时打印、测试里断言）。
const STEP_TYPES := [
	"counter", "skill_at_least", "relation_at_least",
	"raise_at_least", "money_at_least", "day_at_least", "flag",
]

var quests: Array = []
var index: Dictionary = {}


func _ready() -> void:
	_load()


func _load() -> void:
	var file := FileAccess.open(QUEST_PATH, FileAccess.READ)
	if file == null:
		push_error("[QuestSystem] 读不到 " + QUEST_PATH)
		return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not (parser.data is Array):
		push_error("[QuestSystem] quests.json 解析失败")
		return
	quests = parser.data
	index = {}
	for quest in quests:
		index[str(quest.get("id", ""))] = quest
	var problems := validate()
	if problems.is_empty():
		print("[QuestSystem] 载入 %d 条任务" % quests.size())
	else:
		push_error("[QuestSystem] 任务内容有问题（%d 条）：" % problems.size())
		for problem in problems:
			push_error("  - " + str(problem))


## 内容体检：重复 id、next 指向不存在的任务、next 成环、步骤类型不认识。
## 任何一条都会让链卡死或静默失效，所以宁可在加载时就喊出来。
func validate() -> Array:
	var problems: Array = []
	var seen := {}
	for quest in quests:
		var quest_id := str(quest.get("id", ""))
		if quest_id.is_empty():
			problems.append("有一条任务没有 id")
			continue
		if seen.has(quest_id):
			problems.append("任务 id 重复：" + quest_id)
		seen[quest_id] = true
		var steps: Array = quest.get("steps", [])
		if steps.is_empty():
			problems.append("任务 %s 没有任何步骤" % quest_id)
		for step in steps:
			var type := str(step.get("type", ""))
			if not STEP_TYPES.has(type):
				problems.append("任务 %s 有不认识的步骤类型：%s" % [quest_id, type])
			if str(step.get("text", "")).is_empty():
				problems.append("任务 %s 有一步没有文案" % quest_id)
		var next_id := str(quest.get("next", ""))
		if not next_id.is_empty() and not index.has(next_id):
			problems.append("任务 %s 的 next 指向不存在的任务：%s" % [quest_id, next_id])
	return problems


## 当前该做的那条：从第一条顺着 next 走，第一条没完成的即是。
func active_quest(state: Dictionary) -> Dictionary:
	if quests.is_empty():
		return {}
	var id := str(quests[0].get("id", ""))
	var guard := 0
	while not id.is_empty() and guard <= quests.size():
		guard += 1
		var quest: Dictionary = index.get(id, {})
		if quest.is_empty():
			return {}
		if not is_done(state, id):
			return quest
		id = str(quest.get("next", ""))
	return {}


func is_done(state: Dictionary, quest_id: String) -> bool:
	var root := _root(state)
	var prog: Dictionary = root.get(quest_id, {})
	return bool(prog.get("done", false))


## 当前任务进行到第几步（0 基）。给 HUD 显示进度用。
func current_step_index(state: Dictionary) -> int:
	var quest := active_quest(state)
	if quest.is_empty():
		return -1
	var prog := _progress(state, str(quest.get("id", "")), false)
	return clampi(int(prog.get("step", 0)), 0, (quest.get("steps", []) as Array).size())


## HUD 上那一句"现在该干什么"。没任务时返回空，调用方保持原样。
func objective_text(state: Dictionary) -> String:
	var step := current_step(state)
	if step.is_empty():
		return ""
	return str(step.get("text", ""))


func current_step(state: Dictionary) -> Dictionary:
	var quest := active_quest(state)
	if quest.is_empty():
		return {}
	var steps: Array = quest.get("steps", [])
	var idx := current_step_index(state)
	if idx < 0 or idx >= steps.size():
		return {}
	return steps[idx]


## 计数型条件由 Game 在结算点喂进来（"上了几个班""做了几顿饭"没法从状态里推）。
func notify(state: Dictionary, key: String, amount: int = 1) -> void:
	var quest := active_quest(state)
	if quest.is_empty() or amount == 0:
		return
	var prog := _progress(state, str(quest.get("id", "")), true)
	var counters: Dictionary = prog.get("counters", {})
	counters[key] = int(counters.get(key, 0)) + amount
	prog["counters"] = counters


## 推进判定。返回本次发生的事件（可能一次发生多件）：
##   {"kind": "intro",  "quest_id", "title", "text"}
##   {"kind": "step",   "quest_id", "title", "text"}   —— 完成了一步
##   {"kind": "quest",  "quest_id", "title", "text", "reward"}
## 自己会改 state（进度写在 `state["quests"]` 里），但**不发奖励**——奖励归 Game。
## 幂等：同一状态重复调用，第二次返回空数组。
func evaluate(state: Dictionary, day: int) -> Array:
	var out: Array = []
	var guard := 0
	while guard < 64:
		guard += 1
		var quest := active_quest(state)
		if quest.is_empty():
			break
		var quest_id := str(quest.get("id", ""))
		var prog := _progress(state, quest_id, true)

		# 第一次挂上这条任务时，把开场白交给调用方去说一次。
		if not bool(prog.get("intro", false)):
			prog["intro"] = true
			out.append({
				"kind": "intro", "quest_id": quest_id,
				"title": str(quest.get("title", "")), "text": str(quest.get("intro", "")),
			})

		var steps: Array = quest.get("steps", [])
		var idx := clampi(int(prog.get("step", 0)), 0, steps.size())
		if idx >= steps.size():
			# 全部步骤走完 → 收尾（`done` 只会被写一次，所以奖励不会重复发）。
			if not bool(prog.get("done", false)):
				prog["done"] = true
				out.append({
					"kind": "quest", "quest_id": quest_id,
					"title": str(quest.get("title", "")), "text": str(quest.get("closing", "")),
					"reward": quest.get("reward", {}),
				})
			continue
		var step: Dictionary = steps[idx]
		if not _step_done(step, prog, state, day):
			break
		prog["step"] = idx + 1
		out.append({
			"kind": "step", "quest_id": quest_id,
			"title": str(quest.get("title", "")),
			"text": str(step.get("done_text", step.get("text", ""))),
		})
	return out


## HUD 用：`任务名 2/4`。没有任务时为空。
func progress_label(state: Dictionary) -> String:
	var quest := active_quest(state)
	if quest.is_empty():
		return ""
	var steps: Array = quest.get("steps", [])
	return "%s %d/%d" % [str(quest.get("title", "")), current_step_index(state) + 1, steps.size()]


func total_count() -> int:
	return quests.size()


func _step_done(step: Dictionary, prog: Dictionary, state: Dictionary, day: int) -> bool:
	var counters: Dictionary = prog.get("counters", {})
	var type := str(step.get("type", ""))
	if not STEP_TYPES.has(type):
		# 未知类型按"未完成"处理：宁可停在这一步，也不要静默算完成。
		return false
	match type:
		"counter":
			var key := str(step.get("key", ""))
			return int(counters.get(key, 0)) >= int(step.get("count", 1))
		"skill_at_least":
			return int(state.get("skill", 0)) >= int(step.get("value", 0))
		"relation_at_least":
			var relations: Dictionary = state.get("relations", {})
			var npc := str(step.get("npc", ""))
			return int(relations.get(npc, 0)) >= int(step.get("value", 0))
		"raise_at_least":
			return int(state.get("raise_steps", 0)) >= int(step.get("value", 0))
		"money_at_least":
			return int(state.get("money", 0)) >= int(step.get("value", 0))
		"day_at_least":
			return day >= int(step.get("value", 0))
		"flag":
			var flags: Dictionary = state.get("flags", {})
			return bool(flags.get(str(step.get("key", "")), false))
	push_warning("[QuestSystem] 不认识的步骤类型：" + str(step.get("type", "")))
	return false


func _root(state: Dictionary) -> Dictionary:
	# state 通常是 `game_state.to_dict()`；里面的字典是按引用带出来的，
	# 所以就地改也能落回 GameState。缺字段时补一个空的，别让存档结构在这里分叉。
	if not (state.get("quests") is Dictionary):
		state["quests"] = {}
	return state["quests"]


func _progress(state: Dictionary, quest_id: String, create: bool) -> Dictionary:
	var root := _root(state)
	if not (root.get(quest_id) is Dictionary):
		if not create:
			return {}
		root[quest_id] = {"step": 0, "counters": {}, "intro": false, "done": false}
	return root[quest_id]
