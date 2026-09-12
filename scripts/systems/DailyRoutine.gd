extends Node
class_name DailyRoutine
## 每日流程状态：只跟踪“一天之内”的目标进度。
## 与旧年度人生事件严格分离——这里不推进年龄、不触发年度结算，
## 每日目标只由分钟/每日循环驱动（阶段 2 要求）。

signal task_completed(task_id: String)
signal day_reset(day: int)

const TASKS := {
	"commute": {"label": "通勤", "hint": "出门去公司"},
	"work": {"label": "工作", "hint": "完成今天的班次"},
	"meal": {"label": "吃饭", "hint": "别让自己饿着"},
	"sleep": {"label": "休息", "hint": "回家睡一觉"},
}

var day: int = 1
var done: Dictionary = {}

func reset(day_value: int) -> void:
	day = maxi(1, day_value)
	done = {}
	for task_id in TASKS:
		done[task_id] = false
	day_reset.emit(day)

func complete(task_id: String) -> bool:
	if not TASKS.has(task_id) or bool(done.get(task_id, false)):
		return false
	done[task_id] = true
	task_completed.emit(task_id)
	return true

func is_done(task_id: String) -> bool:
	return bool(done.get(task_id, false))

func all_done() -> bool:
	for task_id in TASKS:
		if not bool(done.get(task_id, false)):
			return false
	return true

## HUD 用的一行摘要：已完成打勾，未完成留点。
func summary() -> String:
	var parts: Array[String] = []
	for task_id in TASKS:
		var info: Dictionary = TASKS[task_id]
		parts.append("%s%s" % ["√" if is_done(task_id) else "·", str(info.get("label", task_id))])
	return "  ".join(parts)

## 当前该做的事：第一个未完成的，全部完成则返回空。
func next_task_label() -> String:
	for task_id in TASKS:
		if not is_done(task_id):
			return str((TASKS[task_id] as Dictionary).get("hint", ""))
	return ""

func to_save_dict() -> Dictionary:
	return {"day": day, "done": done.duplicate()}

func apply_save_dict(data: Dictionary) -> void:
	reset(int(data.get("day", 1)))
	var saved: Dictionary = data.get("done", {})
	for task_id in TASKS:
		done[task_id] = bool(saved.get(task_id, false))
