extends RefCounted
class_name JobGrowth
## 第 3 阶段「工作技能成长」。
##
## 三件事：
##  1. 手艺分档（`TIERS`）——技能越高，岗位名头越像样，时薪越高。这是"技能影响收益"。
##  2. 上班攒熟练度——上一次班加一点 `WORK_EXP_PER_SHIFT`，攒够就涨一点技能。
##     比读书慢得多（读书一小时 +3，上班一班约 1/4 点），但上班本来就该长手艺。
##  3. 谈薪——技能到「熟练」才敢开口，成功与否看**技能 + 人脉**；老张要是跟你
##     熟络了，会替你说话，门槛降一档。这是"关系影响后续选择"。
##
## 全静态、无状态：所有数字都从 GameState 传进来，结算仍然只发生在 Game.gd。

const MAX_SKILL := 100
const WORK_EXP_PER_SHIFT := 12
const RAISE_BONUS := 30        # 每涨一级岗位工资加多少
const MAX_RAISES := 3
const NEGOTIATE_SKILL := 55    # 「熟练」才到能开口的份上
const NEGOTIATE_MINUTES := 30  # 谈一次耗多久
const NEGOTIATE_SCORE := 95    # 技能 + 人脉 的门槛
const FRIEND_RELATION := 45    # 老张到「熟络」才肯帮腔
const FRIEND_CREDIT := 10      # 帮腔能抵掉多少门槛

## min 是进入这一档所需的最低技能。第一个必须是 0，否则低技能会取不到档位。
const TIERS := [
	{"id": "apprentice", "min": 0, "title": "学徒", "wage": 90},
	{"id": "junior", "min": 35, "title": "上手", "wage": 120},
	{"id": "skilled", "min": 55, "title": "熟练", "wage": 155},
	{"id": "core", "min": 72, "title": "骨干", "wage": 195},
	{"id": "lead", "min": 88, "title": "独当一面", "wage": 245},
]


static func tier_of(skill: int) -> Dictionary:
	var value := clampi(skill, 0, MAX_SKILL)
	var current: Dictionary = TIERS[0]
	for tier in TIERS:
		if value >= int(tier["min"]):
			current = tier
	return current


static func title_of(skill: int) -> String:
	return str(tier_of(skill)["title"])


static func tier_id_of(skill: int) -> String:
	return str(tier_of(skill)["id"])


## 一次班拿多少。岗位工资 + 谈下来的级数。
static func wage_of(skill: int, raises: int = 0) -> int:
	return int(tier_of(skill)["wage"]) + clampi(raises, 0, MAX_RAISES) * RAISE_BONUS


## 从当前技能涨到下一点，还需要攒多少熟练度。技能越高越慢。
static func exp_needed(skill: int) -> int:
	return 24 + int(clampi(skill, 0, MAX_SKILL) / 2)


## 上一次班。返回新的技能/熟练度，以及这次有没有涨技能、有没有跨档。
static func gain_shift(skill: int, exp: int, gained: int = WORK_EXP_PER_SHIFT) -> Dictionary:
	var before := clampi(skill, 0, MAX_SKILL)
	var next_skill := before
	var next_exp: int = maxi(0, exp) + maxi(0, gained)
	var levels := 0
	while next_skill < MAX_SKILL and next_exp >= exp_needed(next_skill):
		next_exp -= exp_needed(next_skill)
		next_skill += 1
		levels += 1
	if next_skill >= MAX_SKILL:
		# 到顶了，熟练度不再攒；否则进度条会一直显示满格却永远不动。
		next_exp = 0
	var tier_up := tier_id_of(before) != tier_id_of(next_skill)
	return {
		"skill": next_skill,
		"exp": next_exp,
		"levels": levels,
		"leveled": levels > 0,
		"tier_up": tier_up,
		"tier_title": title_of(next_skill),
	}


## 到「熟练」才有谈薪的资格。资格与成败分开：有资格不等于谈得下来。
static func can_negotiate(skill: int) -> bool:
	return clampi(skill, 0, MAX_SKILL) >= NEGOTIATE_SKILL


## 谈薪判定。`relation` 是老张对你的好感：到了「熟络」他会替你说话，门槛降一档。
## 刻意做成确定性的（不用随机数），否则玩家读档刷结果，也测不稳。
static func negotiate(skill: int, network: int, relation: int) -> Dictionary:
	var friend: bool = relation >= FRIEND_RELATION
	var need: int = NEGOTIATE_SCORE - (FRIEND_CREDIT if friend else 0)
	var score: int = clampi(skill, 0, MAX_SKILL) + clampi(network, 0, MAX_SKILL)
	return {
		"score": score,
		"need": need,
		"ok": score >= need,
		"friend": friend,
	}
