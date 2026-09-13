extends RefCounted
class_name NpcRelations
## NPC 关系：好感度、熟悉度分档，以及"每天只有第一次算数"的交谈结算。
##
## 只负责数值与档位。台词、提示文案与展示都交给 Data / Game，方便以后换措辞。
## 状态挂在 `GameState.relations` 与 `GameState.talk_day` 上，因此随现有存档一起走，
## **不需要给 `build_save_payload()` 增加新字段**（少动存档格式就少一处读档风险）。
##
## 设计取舍：
## - 好感只在**对话读完**之后写回（与线索 `claim_clue` 的领法一致），
##   否则"点开对话再关掉"就能刷好感。
## - 同一天重复聊天**不加好感**，而不是加一点点。加一点点等于把"每天一次"变成
##   "每天点满"，违背《众生》那种"日子是一天天过"的调子。

const MAX_VALUE := 100
## 当天第一次好好聊的天数。四天左右从陌生到认识，十几天的交情才算朋友。
const DAILY_GAIN := 4

## 从低到高排列，`tier_of` 取最后一个满足 min 的档位。
## `mood` 是"今天第一次和这个人好好说话"能回的心情：越熟，被记得的感觉越暖。
const TIERS := [
	{"id": "stranger", "min": 0, "label": "陌生人", "mood": 0},
	{"id": "acquaintance", "min": 20, "label": "认识", "mood": 1},
	{"id": "familiar", "min": 45, "label": "熟络", "mood": 2},
	{"id": "friend", "min": 70, "label": "朋友", "mood": 3},
]

## 跨过一档时补一句旁白，让"关系变了"这件事被玩家看见，而不是只跳个数字。
const MILESTONES := {
	"acquaintance": "（他记住了你的脸。）",
	"familiar": "（你们之间不用再寒暄了。）",
	"friend": "（他见你来了，脸上的线条松了一下。）",
}


static func tier_of(value: int) -> Dictionary:
	var result: Dictionary = TIERS[0]
	for tier in TIERS:
		if value >= int(tier["min"]):
			result = tier
	return result


static func label_of(value: int) -> String:
	return str(tier_of(value).get("label", "陌生人"))


static func milestone_for(tier_id: String) -> String:
	return str(MILESTONES.get(tier_id, ""))


func value_of(relations: Dictionary, npc_id: String) -> int:
	return int(relations.get(npc_id, 0))


func label_for(relations: Dictionary, npc_id: String) -> String:
	return label_of(value_of(relations, npc_id))


## 今天是否已经和这个人聊过。
func talked_today(talk_day: Dictionary, npc_id: String, day: int) -> bool:
	return int(talk_day.get(npc_id, -1)) == day


## 一次交谈的结算。对话读完再调用；`relations` / `talk_day` 是字典（引用传递），会被就地改写。
## 返回值给展示层用：有没有涨、涨了多少、是否跨档、要不要回心情。
func talk(relations: Dictionary, talk_day: Dictionary, npc_id: String, day: int) -> Dictionary:
	var before := value_of(relations, npc_id)
	var first_today := not talked_today(talk_day, npc_id, day)
	var capped := before >= MAX_VALUE
	var gain := DAILY_GAIN if (first_today and not capped) else 0
	var after := clampi(before + gain, 0, MAX_VALUE)
	var before_tier := tier_of(before)
	var after_tier := tier_of(after)
	var tier_up := str(after_tier["id"]) != str(before_tier["id"])
	# 只有真的涨了好感才回心情。当天重复聊天既不涨好感也不回心情，规则才讲得清。
	var mood_gain := int(after_tier["mood"]) if gain > 0 else 0

	relations[npc_id] = after
	if first_today:
		talk_day[npc_id] = day

	return {
		"npc_id": npc_id,
		"before": before,
		"after": after,
		"gain": gain,
		"mood_gain": mood_gain,
		"first_today": first_today,
		"capped": capped,
		"tier_up": tier_up,
		"tier_id": str(after_tier["id"]),
		"tier_label": str(after_tier["label"]),
		"milestone": milestone_for(str(after_tier["id"])) if tier_up else "",
	}
