extends Node2D
## 游戏入口：初始化系统，并协调事件、年度、对话、剧情与世界交互

const Data = preload("res://scripts/Data.gd")
const EventSystemScript = preload("res://scripts/systems/EventSystem.gd")
const StorySystemScript = preload("res://scripts/systems/StorySystem.gd")
const Rules = preload("res://scripts/Rules.gd")
const GameStateScript = preload("res://scripts/GameState.gd")
const HUDScript = preload("res://scripts/ui/HUD.gd")
const DialogUIScript = preload("res://scripts/ui/DialogUI.gd")
const EventUIScript = preload("res://scripts/ui/EventUI.gd")
const WorldManagerScript = preload("res://scripts/world/WorldManager.gd")
const InteractionSystemScript = preload("res://scripts/systems/InteractionSystem.gd")
const StartUIScript = preload("res://scripts/ui/StartUI.gd")
const EndingUIScript = preload("res://scripts/ui/EndingUI.gd")
const ArtCatalog = preload("res://scripts/ArtCatalog.gd")
const TimeManagerScript = preload("res://scripts/systems/TimeManager.gd")
const NPCScheduleSystemScript = preload("res://scripts/systems/NPCScheduleSystem.gd")
const DarkLocationSystemScript = preload("res://scripts/systems/DarkLocationSystem.gd")
const EncounterSystemScript = preload("res://scripts/systems/EncounterSystem.gd")
const SaveManagerScript = preload("res://scripts/systems/SaveManager.gd")
const WeatherSystemScript = preload("res://scripts/systems/WeatherSystem.gd")
const LocationManagerScript = preload("res://scripts/systems/LocationManager.gd")

# 地点（与 tools/gen_scene.py 的 BUILDINGS / POI 坐标一致；都落在建筑脚下的可走地面）
const POI_DATA := [
	{"id": "home", "pos": Vector2(310, 392), "name": "回家", "scene": "rent"},
	{"id": "store", "pos": Vector2(385, 962), "name": "便利店", "scene": "cafe"},
	{"id": "office", "pos": Vector2(935, 522), "name": "公司", "scene": "office"},
	{"id": "park", "pos": Vector2(235, 545), "name": "公园", "scene": "park"},
	{"id": "subway", "pos": Vector2(520, 668), "name": "地铁站", "scene": "subway"},
	{"id": "hospital", "pos": Vector2(930, 272), "name": "医院", "scene": "hospital"},
	{"id": "rooftop", "pos": Vector2(115, 980), "name": "老楼天台", "scene": "rooftop"},
	{"id": "alley", "pos": Vector2(230, 935), "name": "旧巷口", "scene": "alley"},
]

# 玩家状态：由 GameState 作为唯一数据源。
# 下面这些代理属性暂时保留旧调用方式，避免一次性重写整个 Game.gd；后续模块拆分时直接依赖 game_state。
var game_state = GameStateScript.new()

var age: int:
	get:
		return game_state.age
	set(value):
		game_state.age = value
var money: int:
	get:
		return game_state.money
	set(value):
		game_state.money = value
var health: int:
	get:
		return game_state.health
	set(value):
		game_state.health = value
var mood: int:
	get:
		return game_state.mood
	set(value):
		game_state.mood = value
var skill: int:
	get:
		return game_state.skill
	set(value):
		game_state.skill = value
var network: int:
	get:
		return game_state.network
	set(value):
		game_state.network = value
var job: String:
	get:
		return game_state.job
	set(value):
		game_state.job = value
var flags: Dictionary:
	get:
		return game_state.flags
	set(value):
		game_state.flags = value
var clues: Array:
	get:
		return game_state.clues
	set(value):
		game_state.clues = value
var stage_idx: int:
	get:
		return game_state.stage_idx
	set(value):
		game_state.stage_idx = value
var jobless_years: int:
	get:
		return game_state.jobless_years
	set(value):
		game_state.jobless_years = value


var near_target := {}
var world_manager
var npc_schedule_sys
var dark_location_sys
var encounter_sys
var save_sys
var weather_sys
var location_sys
var interaction_sys
var events_sys: Node
var story_sys: Node
var rules_sys: Node
var time_sys: Node
var cur_event = null
var cur_event_kind := "event"
var cur_event_time_cost := 0
var game_over := false

@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UI

var hud
var interact_btn: Button
var dialog_ui
var toast_label: Label

# 开局 / 出身
var start_ui
var game_started := false
var origin_open_pending := ""
var origin: Dictionary = {}

# 事件面板
var event_ui

# 结局面板
var ending_ui

var dialog_pending_clue := ""
var dialog_queue: Array = []  # 对话队列：当前对话关闭后依次播放

func _ready() -> void:
	events_sys = EventSystemScript.new()
	events_sys.name = "EventsSys"
	add_child(events_sys)
	story_sys = StorySystemScript.new()
	story_sys.name = "StorySys"
	add_child(story_sys)
	rules_sys = Rules.new()
	rules_sys.name = "RulesSys"
	add_child(rules_sys)
	time_sys = TimeManagerScript.new()
	time_sys.name = "TimeSys"
	add_child(time_sys)
	time_sys.reset()
	weather_sys = WeatherSystemScript.new()
	weather_sys.name = "WeatherSys"
	add_child(weather_sys)
	weather_sys.reset(time_sys)

	y_sort_enabled = true
	world_manager = WorldManagerScript.new()
	world_manager.name = "WorldManager"
	add_child(world_manager)
	world_manager.build(self, player, POI_DATA, Data.NPCS)
	# MAP-001：旧的单张世界地图保留为兼容层，但默认隐藏；正式体验使用独立地点场景。
	world_manager.set_legacy_world_visible(false)
	if player:
		player.visible = false
	location_sys = LocationManagerScript.new()
	location_sys.name = "LocationSys"
	add_child(location_sys)
	location_sys.action_requested.connect(_on_location_action)
	location_sys.travel_requested.connect(_on_location_travel)
	location_sys.npc_requested.connect(_on_location_npc_requested)
	location_sys.set_active(false)
	npc_schedule_sys = NPCScheduleSystemScript.new()
	npc_schedule_sys.name = "NPCScheduleSys"
	add_child(npc_schedule_sys)
	npc_schedule_sys.configure(world_manager)
	npc_schedule_sys.reset(time_sys, weather_sys)
	dark_location_sys = DarkLocationSystemScript.new()
	dark_location_sys.name = "DarkLocationSys"
	add_child(dark_location_sys)
	dark_location_sys.configure(world_manager)
	dark_location_sys.reset(time_sys, _state())
	encounter_sys = EncounterSystemScript.new()
	encounter_sys.name = "EncounterSys"
	add_child(encounter_sys)
	save_sys = SaveManagerScript.new()
	save_sys.name = "SaveSys"
	add_child(save_sys)
	interaction_sys = InteractionSystemScript.new()
	interaction_sys.name = "InteractionSys"
	add_child(interaction_sys)
	interaction_sys.configure(player, world_manager, POI_DATA)
	_setup_ui()
	_show_start_screen()

# ---------------------------------------------------------------- 地图

func _setup_ui() -> void:
	ui.layer = 2  # 保证 UI 永远在暗角层之上
	hud = HUDScript.new()
	ui.add_child(hud)
	hud.save_requested.connect(_save_game)
	hud.load_requested.connect(_load_game)
	hud.quit_requested.connect(_quit_game)

	interact_btn = Button.new()
	interact_btn.name = "InteractBtn"
	interact_btn.visible = false
	interact_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	interact_btn.offset_top = -70
	interact_btn.offset_bottom = -20
	interact_btn.offset_left = -90
	interact_btn.offset_right = 90
	interact_btn.pressed.connect(_on_interact_pressed)
	ui.add_child(interact_btn)

	toast_label = Label.new()
	toast_label.name = "Toast"
	toast_label.visible = false
	toast_label.set_anchors_preset(Control.PRESET_CENTER)
	toast_label.offset_top = -140
	toast_label.offset_bottom = -100
	toast_label.offset_left = -160
	toast_label.offset_right = 160
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(toast_label)

	dialog_ui = DialogUIScript.new()
	dialog_ui.dialog_finished.connect(_on_dialog_finished)
	ui.add_child(dialog_ui)

	event_ui = EventUIScript.new()
	event_ui.option_selected.connect(_choose_option)
	event_ui.continue_requested.connect(_close_event)
	ui.add_child(event_ui)
	start_ui = StartUIScript.new()
	start_ui.setup(Data.ORIGINS, Callable(self, "_fmt_money"))
	start_ui.origin_selected.connect(_choose_origin)
	start_ui.load_requested.connect(_load_game)
	ui.add_child(start_ui)
	ending_ui = EndingUIScript.new()
	ending_ui.restart_requested.connect(_restart)
	ui.add_child(ending_ui)


func _refresh_ui() -> void:
	var stage: Dictionary = story_sys.current_stage(_state()) if story_sys else {}
	if hud and not stage.is_empty():
		hud.refresh(game_state, str(stage.get("name", "")), str(stage.get("goal", "")), Data.DARK_CLUE_TOTAL)
		if time_sys:
			hud.refresh_time(time_sys.day, time_sys.get_clock_text(), time_sys.get_period_name())
		if weather_sys:
			hud.refresh_weather(weather_sys.get_weather_name())

	if interact_btn:
		var busy: bool = (dialog_ui != null and dialog_ui.is_busy()) or (event_ui != null and event_ui.is_busy())
		interact_btn.visible = (not near_target.is_empty()) and (not busy)
		if interact_btn.visible:
			var t: String = near_target["type"]
			if t == "npc" or t == "interior_npc":
				interact_btn.text = "和%s说话" % near_target["data"]["name"]
			elif t == "place":
				interact_btn.text = "进入%s" % near_target["data"]["name"]
			elif t == "locked_place":
				interact_btn.text = "查看%s" % near_target["data"]["name"]
			else:
				interact_btn.text = "出门"


# ---------------------------------------------------------------- 开局 / 出身

func _show_start_screen() -> void:
	game_started = false
	game_over = false
	if start_ui:
		start_ui.set_load_available(save_sys != null and save_sys.has_save())
		start_ui.open()


func _choose_origin(o: Dictionary) -> void:
	origin = o
	var ini: Dictionary = o.get("init", {})
	game_state.reset_from_origin(ini, str(o.get("flag", "")))
	game_over = false
	game_started = true
	start_ui.close()
	events_sys.reset_used()
	if encounter_sys:
		encounter_sys.reset()
	if time_sys:
		time_sys.reset()
	if weather_sys:
		weather_sys.reset(time_sys)
	if npc_schedule_sys:
		npc_schedule_sys.reset(time_sys, weather_sys)
	if dark_location_sys:
		dark_location_sys.reset(time_sys, _state())
	if player:
		player.position = Vector2(300, 400)
		player.set_target(Vector2(300, 400))
	if location_sys:
		location_sys.reset_new_game()
	origin_open_pending = str(o.get("open", ""))
	# 对话链：梦 → 出身开场白（旁白）→ 新手引导（操作指引）
	if str(o.get("open", "")) != "":
		_enqueue_dialog("旁白", [str(o.get("open", ""))])
	_enqueue_dialog("操作指引", Data.TUTORIAL)
	_show_dialog("梦", Data.DARK_INTRO["lines"])

# ---------------------------------------------------------------- 存档


func _quit_game() -> void:
	if dialog_ui and dialog_ui.is_busy():
		_show_toast("请先结束当前对话。")
		return
	if event_ui and event_ui.is_busy():
		_show_toast("请先结束当前事件。")
		return
	get_tree().quit()

func _save_game() -> void:
	if save_sys == null or not game_started or game_over:
		_show_toast("当前没有可以保存的游戏进度。")
		return
	if (dialog_ui and dialog_ui.is_busy()) or (event_ui and event_ui.is_busy()):
		_show_toast("请先结束当前对话或事件，再保存。")
		return
	var payload := {
		"game_state": game_state.to_dict(),
		"time": time_sys.to_save_dict() if time_sys else {},
		"weather": weather_sys.to_save_dict() if weather_sys else {},
		"events": events_sys.to_save_dict() if events_sys else {},
		"encounters": encounter_sys.to_save_dict() if encounter_sys else {},
		"world": world_manager.to_save_dict(player) if world_manager else {},
		"locations": location_sys.to_save_dict() if location_sys else {},
		"origin": origin.duplicate(true),
	}
	var result: Dictionary = save_sys.save_game(payload)
	_show_toast(str(result.get("message", "存档失败。")))
	if start_ui:
		start_ui.set_load_available(save_sys.has_save())


func _load_game() -> void:
	if save_sys == null:
		_show_toast("存档系统尚未初始化。")
		return
	if (dialog_ui and dialog_ui.is_busy()) or (event_ui and event_ui.is_busy()):
		_show_toast("请先结束当前对话或事件，再读取。")
		return
	var result: Dictionary = save_sys.load_game()
	if not bool(result.get("ok", false)):
		_show_toast(str(result.get("message", "读取失败。")))
		return
	var payload: Dictionary = result.get("payload", {})
	game_state.apply_dict(payload.get("game_state", {}))
	var saved_origin = payload.get("origin", {})
	origin = saved_origin if typeof(saved_origin) == TYPE_DICTIONARY else {}
	if events_sys:
		events_sys.apply_save_dict(payload.get("events", {}))
	if encounter_sys:
		encounter_sys.apply_save_dict(payload.get("encounters", {}))
	if time_sys:
		time_sys.apply_save_dict(payload.get("time", {}))
	if weather_sys:
		weather_sys.apply_save_dict(payload.get("weather", {}), time_sys)
	if world_manager:
		world_manager.apply_save_dict(payload.get("world", {}), player)
	if location_sys:
		location_sys.apply_save_dict(payload.get("locations", {}))
	if npc_schedule_sys:
		npc_schedule_sys.reset(time_sys, weather_sys)
	if dark_location_sys:
		dark_location_sys.reset(time_sys, _state())
	dialog_queue.clear()
	dialog_pending_clue = ""
	cur_event = null
	cur_event_kind = "event"
	cur_event_time_cost = 0
	game_over = false
	game_started = true
	if start_ui:
		start_ui.close()
	if ending_ui:
		ending_ui.close()
	_refresh_ui()
	_show_toast("已读取存档。")


# ---------------------------------------------------------------- 输入与循环

func _unhandled_input(event: InputEvent) -> void:
	if not game_started:
		return
	if location_sys and location_sys.is_active():
		return
	var pressed := false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not pressed:
		return
	if (dialog_ui and dialog_ui.is_busy()) \
		or (event_ui and event_ui.is_busy()) \
		or (ending_ui and ending_ui.visible):
		return
	var click := get_global_mouse_position()
	var clicked_place := _poi_at_click(click)
	if not clicked_place.is_empty():
		var poi_id := str(clicked_place.get("id", ""))
		if world_manager and not world_manager.is_poi_interactable(poi_id):
			_show_toast(world_manager.get_poi_lock_reason(poi_id))
		else:
			_enter_place(clicked_place)
		return
	if player and player.has_method("set_target"):
		player.set_target(click)
		world_manager.spawn_move_marker(click)
		if not bool(flags.get("tut_moved", false)):
			flags["tut_moved"] = true
			_show_toast("点击地面移动；也可以直接点击发光地点进入。")


func _poi_at_click(world_pos: Vector2) -> Dictionary:
	# 让地点图标本身可以直接点击，不再要求先走到旁边再找交互按钮。
	# 半径略大于视觉图标，兼顾鼠标和触屏操作。
	for poi in POI_DATA:
		var pos: Vector2 = poi.get("pos", Vector2.ZERO)
		if world_pos.distance_to(pos) <= 58.0:
			return poi
	return {}


func _process(delta: float) -> void:
	if not game_started:
		return
	if location_sys and location_sys.is_active():
		near_target = {}
	else:
		_update_near_target()
	_refresh_ui()
	_check_stage()
	var ui_busy: bool = (dialog_ui != null and dialog_ui.is_busy()) or (event_ui != null and event_ui.is_busy()) or (ending_ui != null and ending_ui.visible)
	if time_sys:
		time_sys.set_paused(ui_busy)
		time_sys.tick(delta)
	if weather_sys:
		weather_sys.update(time_sys)
	if npc_schedule_sys:
		npc_schedule_sys.apply(time_sys, false, weather_sys)
	if dark_location_sys:
		dark_location_sys.apply(time_sys, _state())
	if location_sys:
		location_sys.apply_story_unlocks(_state(), time_sys)
		_sync_location_npcs()
	if world_manager:
		world_manager.process_visuals(delta, player, time_sys, weather_sys)


func _update_near_target() -> void:
	if not interaction_sys:
		near_target = {}
		return
	var result: Dictionary = interaction_sys.detect_near(flags)
	near_target = result.get("target", {})
	var tutorial := str(result.get("tutorial", ""))
	if not tutorial.is_empty():
		_show_toast(tutorial)


# ---------------------------------------------------------------- 分场景地图

func _on_location_travel(location_id: String) -> void:
	# 第一次抵达地铁/公司等地点即完成“地图解锁”的体验；旅行本身消耗少量时间。
	if time_sys:
		time_sys.advance_minutes(20 if location_id == "subway" else 35)
	var location_name: String = location_id
	if location_sys != null and location_sys.LOCATIONS.has(location_id):
		location_name = str(location_sys.LOCATIONS[location_id].get("name", location_id))
	_show_toast("已到达：%s" % location_name)


func _on_location_action(location_id: String) -> void:
	var scene_map: Dictionary = {
		"home": "rent",
		"subway": "subway",
		"office": "office",
		"park": "park",
		"store": "street",
		"cafe": "cafe",
		"hospital": "hospital",
		"rooftop": "rooftop",
		"alley": "alley",
	}
	var scene: String = str(scene_map.get(location_id, location_id))
	# MAP-002：独立场景模式下，公司也直接在当前美术场景触发内容，
	# 不再切回旧的程序化室内兼容层。
	var dark_result: Dictionary = story_sys.resolve_dark_place(scene, _state()) if story_sys else {"handled": false}
	if bool(dark_result.get("handled", false)):
		if dark_result.has("event"):
			_show_event(dark_result["event"])
		else:
			var dark_toast: String = str(dark_result.get("toast", ""))
			if not dark_toast.is_empty():
				_show_toast(dark_toast)
		return
	var encounter = _try_encounter(scene)
	if encounter != null:
		_show_encounter(encounter)
		return
	var event = events_sys.pick(scene, _state())
	if event == null:
		_show_toast("这里暂时没有新的事情发生。")
		if time_sys:
			time_sys.advance_minutes(30)
		return
	_show_event(event)


func _on_location_npc_requested(npc_id: String) -> void:
	for npc in Data.NPCS:
		if str(npc.get("id", "")) == npc_id:
			_talk_to(npc)
			return


func _sync_location_npcs() -> void:
	if location_sys == null or npc_schedule_sys == null or time_sys == null:
		return
	if not location_sys.is_active():
		return
	var visible_items: Array = []
	for npc in Data.NPCS:
		var npc_id: String = str(npc.get("id", ""))
		var state: Dictionary = npc_schedule_sys.get_state_for(npc_id, time_sys, weather_sys)
		if not bool(state.get("visible", false)):
			continue
		if str(state.get("location", "")) != location_sys.current_location:
			continue
		visible_items.append({"id": npc_id, "name": str(npc.get("name", npc_id))})
	location_sys.set_visible_npcs(visible_items)

# ---------------------------------------------------------------- 交互

func _on_interact_pressed() -> void:
	if near_target.is_empty():
		return
	if near_target["type"] == "npc":
		_talk_to(near_target["data"])
	elif near_target["type"] == "place":
		_enter_place(near_target["data"])
	elif near_target["type"] == "locked_place":
		_show_toast(str(near_target.get("reason", "这里现在无法进入。")))
	elif near_target["type"] == "interior_npc":
		_interior_boss()
	elif near_target["type"] == "exit":
		_exit_interior()


func _enter_place(d: Dictionary) -> void:
	var scene: String = str(d["scene"])
	# 当前只有公司拥有正式室内 Scene；WorldManager 统一负责切换。
	if scene == "office":
		_enter_interior(scene)
		return
	# 暗线特殊地点优先于普通事件，但流程判定由 StorySystem 统一负责。
	var dark_result: Dictionary = story_sys.resolve_dark_place(scene, _state()) if story_sys else {"handled": false}
	if bool(dark_result.get("handled", false)):
		if dark_result.has("event"):
			_show_event(dark_result["event"])
		else:
			var dark_toast := str(dark_result.get("toast", ""))
			if not dark_toast.is_empty():
				_show_toast(dark_toast)
			if bool(dark_result.get("pass_year", false)):
				_year_pass()
		return
	var encounter = _try_encounter(scene)
	if encounter != null:
		_show_encounter(encounter)
		return
	var e = events_sys.pick(scene, _state())
	if e == null:
		_show_toast("这里今天没什么事。")
		_year_pass()
		return
	_show_event(e)


## 进入室内：切掉街道、显示室内背景，把玩家放到门口
func _enter_interior(id: String) -> void:
	if world_manager:
		world_manager.enter_interior(id, player)


func _exit_interior() -> void:
	if world_manager:
		world_manager.exit_interior(player)


func _interior_boss() -> void:
	var encounter = _try_encounter("office")
	if encounter != null:
		_show_encounter(encounter)
		return
	var e = events_sys.pick("office", _state())
	if e == null:
		_show_toast("今天没什么要汇报的，早点回家吧。")
		_year_pass()
		return
	_show_event(e)


func _talk_to(npc: Dictionary) -> void:
	var dialog_data: Dictionary = story_sys.build_npc_dialog(npc, _state()) if story_sys else {"lines": Data.npc_lines(npc, age), "pending_clue": ""}
	dialog_pending_clue = str(dialog_data.get("pending_clue", ""))
	_show_dialog("%s · %s" % [npc["name"], npc["title"]], dialog_data.get("lines", []))

# ---------------------------------------------------------------- 事件

func _state() -> Dictionary:
	return game_state.to_dict()


## 结算引擎改的是状态字典，统一同步回 GameState。
func _sync_from_state(st: Dictionary) -> void:
	game_state.apply_dict(st)


func _show_event(e) -> void:
	cur_event = e
	cur_event_kind = "event"
	cur_event_time_cost = 0
	var option_views: Array = events_sys.build_option_views(e, _state())
	if event_ui:
		var background: Texture2D = ArtCatalog.event_background(e)
		event_ui.show_event(
			"%s · %s" % [str(e.get("speaker", "")), str(e.get("title", ""))],
			str(e.get("text", "")),
			option_views,
			background
		)


func _try_encounter(scene: String):
	if encounter_sys == null or time_sys == null:
		return null
	return encounter_sys.pick(scene, _state(), time_sys, weather_sys.get_encounter_context() if weather_sys else {"weather": "clear"})


func _show_encounter(e: Dictionary) -> void:
	cur_event = e
	cur_event_kind = "encounter"
	cur_event_time_cost = int(e.get("time_cost", 90))
	var option_views: Array = encounter_sys.build_option_views(e, _state())
	if event_ui:
		var background: Texture2D = ArtCatalog.event_background(e)
		event_ui.show_event(
			"奇遇 · %s" % str(e.get("title", "")),
			str(e.get("text", "")),
			option_views,
			background
		)


func _choose_option(idx: int) -> void:
	if cur_event == null:
		return
	var st := _state()
	var result: Dictionary
	if cur_event_kind == "encounter":
		result = encounter_sys.apply_choice(cur_event, idx, st)
	else:
		result = events_sys.apply_choice(cur_event, idx, st)
	if not bool(result.get("ok", false)):
		return
	_sync_from_state(st)
	if cur_event_kind == "encounter":
		cur_event_time_cost = int(result.get("time_cost", cur_event_time_cost))
	if event_ui:
		event_ui.show_result(str(result.get("result", "")))


func _close_event() -> void:
	if event_ui:
		event_ui.close_event()
	var closed_kind := cur_event_kind
	var time_cost := cur_event_time_cost
	cur_event = null
	cur_event_kind = "event"
	cur_event_time_cost = 0
	if closed_kind == "encounter":
		if time_sys:
			time_sys.advance_minutes(time_cost)
		_show_toast("这一段插曲过去了，城市时间继续向前。")
		return
	_year_pass()


func _year_pass() -> void:
	var st := _state()
	var res: Dictionary = rules_sys.year_tick(st)
	_sync_from_state(st)

	var reason: String = rules_sys.death_reason(st)
	if reason != "":
		_show_ending(reason, st)
		return

	var txt := "%d 岁  收入 %s / 支出 %s / 结余 %s" % [
		age, _fmt_money(int(res["income"])), _fmt_money(int(res["cost"])), _fmt_money(int(res["net"]))
	]
	if str(res["promoted"]) != "":
		txt += "\n晋升为 %s！" % str(res["promoted"])
	if bool(res["ipo"]):
		txt += "\n公司熬出头了，你成了老板。"
	_show_toast(txt)


func _fmt_money(v: int) -> String:
	if absi(v) >= 10000:
		return "%d 万" % int(v / 10000)
	return "%d 元" % v


func _show_ending(reason: String, st: Dictionary) -> void:
	game_over = true
	var ending: Dictionary = rules_sys.judge_ending(st)
	var reason_txt: String = {
		"health": "身体先垮了。",
		"mood": "心先于身体垮了。",
		"money": "债再也还不上了。",
		"age": "六十岁了。",
	}.get(reason, "")
	var title_text := "「%s」" % str(ending.get("name", "？"))
	var desc_text := "%s\n\n%s\n\n——你活了 %d 岁，最后存下 %s。收集到 %d/%d 条线索。" % [
		reason_txt, str(ending.get("desc", "")), age, _fmt_money(money), clues.size(), Data.DARK_CLUE_TOTAL,
	]
	if ending_ui:
		ending_ui.show_ending(title_text, desc_text)


func _restart() -> void:
	if ending_ui:
		ending_ui.close()
	game_state.reset_default()
	origin = {}
	origin_open_pending = ""
	dialog_queue.clear()
	events_sys.reset_used()
	if encounter_sys:
		encounter_sys.reset()
	if time_sys:
		time_sys.reset()
	if weather_sys:
		weather_sys.reset(time_sys)
	if npc_schedule_sys:
		npc_schedule_sys.reset(time_sys, weather_sys)
	if dark_location_sys:
		dark_location_sys.reset(time_sys, _state())
	if player:
		player.position = Vector2(300, 400)
		player.set_target(Vector2(300, 400))
	if location_sys:
		location_sys.set_active(false)
	_show_start_screen()

# ---------------------------------------------------------------- 对话

func _show_dialog(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	if dialog_ui:
		dialog_ui.show_dialog(speaker, lines)


func _enqueue_dialog(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	dialog_queue.append({"speaker": speaker, "lines": lines})


func _on_dialog_finished() -> void:
	if dialog_pending_clue != "":
		var npc_id := dialog_pending_clue
		dialog_pending_clue = ""
		var st := _state()
		var clue_result: Dictionary = story_sys.claim_clue(npc_id, st) if story_sys else {"added": false}
		if bool(clue_result.get("added", false)):
			_sync_from_state(st)
			_show_toast("记下了一条线索：%s" % str(clue_result.get("clue", "……")))
	if not dialog_queue.is_empty():
		var nxt: Dictionary = dialog_queue.pop_front()
		_show_dialog(nxt["speaker"], nxt["lines"])


# ---------------------------------------------------------------- 主线

func _check_stage() -> void:
	if not story_sys:
		return
	var st := _state()
	var result: Dictionary = story_sys.check_and_advance_stage(st)
	if bool(result.get("advanced", false)):
		_sync_from_state(st)
		_show_toast(str(result.get("text", "")))


func _show_toast(text: String) -> void:
	if not toast_label:
		return
	toast_label.text = text
	toast_label.visible = true
	await get_tree().create_timer(3.5).timeout
	if toast_label:
		toast_label.visible = false
