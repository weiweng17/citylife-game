extends Node
class_name SaveManager
## FEAT-005: 单槽位 JSON 存档系统。
## 只负责持久化 Dictionary，不直接了解具体玩法模块。

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(payload: Dictionary) -> Dictionary:
	var document := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"payload": payload,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "无法创建存档文件。"}
	file.store_string(JSON.stringify(document, "\t"))
	file.close()
	return {"ok": true, "message": "存档完成。", "path": SAVE_PATH}


func load_game() -> Dictionary:
	if not has_save():
		return {"ok": false, "message": "没有可读取的存档。"}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": "无法打开存档文件。"}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "存档格式损坏。"}
	var document: Dictionary = parsed
	var version := int(document.get("version", 0))
	if version <= 0 or version > SAVE_VERSION:
		return {"ok": false, "message": "存档版本不兼容。"}
	var payload = document.get("payload", {})
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "message": "存档内容损坏。"}
	return {
		"ok": true,
		"message": "读取成功。",
		"version": version,
		"saved_at": str(document.get("saved_at", "")),
		"payload": payload,
	}


func delete_save() -> bool:
	if not has_save():
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH)) == OK
