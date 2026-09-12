extends Node
class_name StorySystem
## 主线与暗线流程系统。
##
## 负责：
## - 当前主线阶段与阶段完成判断
## - 主线推进
## - NPC 暗线对话附加与线索领取
## - 旧巷口 / 天台暗线特殊地点判定
##
## 不负责 UI、地图移动或事件选项结算。

const Data = preload("res://scripts/Data.gd")


func current_stage(st: Dictionary) -> Dictionary:
	if Data.STAGES.is_empty():
		return {}
	var idx := clampi(int(st.get("stage_idx", 0)), 0, Data.STAGES.size() - 1)
	return Data.STAGES[idx]


func check_and_advance_stage(st: Dictionary) -> Dictionary:
	var idx := int(st.get("stage_idx", 0))
	if idx >= Data.STAGES.size():
		return {"advanced": false}
	var stage: Dictionary = Data.STAGES[idx]
	if not _stage_done(stage, st):
		return {"advanced": false}

	var text := str(stage.get("done_text", ""))
	# 旧数据里保留过占位注释；展示层不应该看到它。
	if text.find("/*") >= 0:
		text = "你有了牵挂。这座城市不再只是你一个人的事。"
	st["stage_idx"] = idx + 1
	return {
		"advanced": true,
		"stage_id": str(stage.get("id", "")),
		"text": text,
	}


func _stage_done(stage: Dictionary, st: Dictionary) -> bool:
	var check: Dictionary = stage.get("check", {})
	if check.has("money") and int(st.get("money", 0)) >= int(check["money"]):
		return true
	if check.has("job_stable") and str(st.get("job", "unemployed")) != "unemployed":
		return true
	if check.has("job_senior") and str(st.get("job", "unemployed")) in ["manager", "director", "boss"]:
		return true
	var flags: Dictionary = st.get("flags", {})
	if check.has("flag_married") and bool(flags.get("married", false)):
		return true
	if check.has("flag_house") and bool(flags.get("hasHouse", false)):
		return true
	if check.has("age") and int(st.get("age", 0)) >= int(check["age"]):
		return true
	return false


## 返回 NPC 本次对话需要展示的完整文本，以及对话结束后应领取的暗线线索 id。
func build_npc_dialog(npc: Dictionary, st: Dictionary) -> Dictionary:
	var age := int(st.get("age", 22))
	var lines: Array = Data.npc_lines(npc, age).duplicate()
	var pending_clue := ""
	var clues: Array = st.get("clues", [])
	if Data.dark_ready(npc, age) and not clues.has(npc.get("id", "")):
		var dark: Dictionary = npc.get("dark", {})
		if not dark.is_empty():
			lines.append("（你想起那个梦。）")
			lines += dark.get("lines", [])
			pending_clue = str(npc.get("id", ""))
	return {
		"lines": lines,
		"pending_clue": pending_clue,
	}


## 对话完成后真正写入线索，避免玩家打开对话却没读完就获得线索。
func claim_clue(npc_id: String, st: Dictionary) -> Dictionary:
	if npc_id.is_empty():
		return {"added": false}
	var clues: Array = st.get("clues", [])
	if clues.has(npc_id):
		return {"added": false}
	clues.append(npc_id)
	st["clues"] = clues
	var npc := _find_npc(npc_id)
	return {
		"added": true,
		"npc_id": npc_id,
		"clue": str(npc.get("dark", {}).get("clue", "……")),
	}


## 判定暗线特殊地点。Game 只负责根据返回值展示 UI / 推进年份。
## handled=false 表示该地点本次应继续走普通事件系统。
func resolve_dark_place(scene: String, st: Dictionary) -> Dictionary:
	var flags: Dictionary = st.get("flags", {})
	var clues: Array = st.get("clues", [])
	var age := int(st.get("age", 22))

	if scene == "alley":
		if bool(flags.get("dark_alley_done", false)):
			return {"handled": true, "toast": "你已经在那条巷子里找过了。", "pass_year": true}
		if clues.size() < Data.DARK_CLUE_TOTAL:
			return {"handled": true, "toast": "只是一条普通的老巷子，没什么特别的。", "pass_year": true}
		return {"handled": true, "event": Data.DARK_ALLEY, "pass_year": false}

	if scene == "rooftop":
		if bool(flags.get("dark_rooftop_done", false)):
			return {"handled": true, "toast": "天台的风还是那么大。", "pass_year": true}
		if not bool(flags.get("dark_pursued", false)):
			return {"handled": false}
		if age < 40:
			return {"handled": true, "toast": "你站上天台。那个记号还在手机里，但你还不想面对它。", "pass_year": true}
		return {"handled": true, "event": Data.DARK_ROOFTOP, "pass_year": false}

	return {"handled": false}


func _find_npc(id: String) -> Dictionary:
	for npc in Data.NPCS:
		if str(npc.get("id", "")) == id:
			return npc
	return {}
