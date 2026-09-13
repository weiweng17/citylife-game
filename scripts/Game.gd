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
const DailyRoutineScript = preload("res://scripts/systems/DailyRoutine.gd")
const OfficeActivitiesScript = preload("res://scripts/systems/OfficeActivities.gd")
const StoreActivitiesScript = preload("res://scripts/systems/StoreActivities.gd")
const InventoryScript = preload("res://scripts/systems/Inventory.gd")
const NpcRelationsScript = preload("res://scripts/systems/NpcRelations.gd")
const JobGrowthScript = preload("res://scripts/systems/JobGrowth.gd")
const QuestSystemScript = preload("res://scripts/systems/QuestSystem.gd")
const ParkActivitiesScript = preload("res://scripts/systems/ParkActivities.gd")
const CafeActivitiesScript = preload("res://scripts/systems/CafeActivities.gd")
const HospitalActivitiesScript = preload("res://scripts/systems/HospitalActivities.gd")
const AlleyActivitiesScript = preload("res://scripts/systems/AlleyActivities.gd")
const RooftopActivitiesScript = preload("res://scripts/systems/RooftopActivities.gd")
const ShopUIScript = preload("res://scripts/ui/ShopUI.gd")
const LocationManagerScript = preload("res://scripts/systems/LocationManager.gd")

const SCHEDULE_LOCATION_ALIASES := {
	"convenience_store": "store",
	"old_alley": "alley",
}

# 每日循环需求：每游戏小时的消耗、低值与告急阈值。
const FULLNESS_PER_HOUR := 4
const ENERGY_PER_HOUR := 3
const NEED_LOW := 25
const MURMURS := {
	"fullness": "肚子在叫。你想不起来上一顿是什么时候吃的了。",
	"energy": "眼皮沉得抬不起来。这城市还没睡，你已经撑不住了。",
}
# 能顶一顿的才算“吃饭”：牛奶这种垫垫肚子的不算，免得每日目标被随手糊弄过去。
const MEAL_FULLNESS := 20

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
var fullness: int:
	get:
		return game_state.fullness
	set(value):
		game_state.fullness = value
var energy: int:
	get:
		return game_state.energy
	set(value):
		game_state.energy = value
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
## NPC 关系（好感度/熟悉度）。纯逻辑，不进场景树。
var npc_relations_sys
## 主线任务（一次一条，串行推进）。判定与进度在这里，奖励仍然由 Game 发。
var quest_sys
var dark_location_sys
var encounter_sys
var save_sys
var weather_sys
var location_sys
var home_activities
var office_activities
var store_activities
var park_activities
var cafe_activities
var hospital_activities
var alley_activities
var rooftop_activities
var daily_routine
var inventory
var activity_running: bool = false
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
var shop_ui
var toast_label: Label
## 提示的序号：只有最新一条的定时器能把它藏掉（见 _show_toast 的注释）。
var _toast_seq: int = 0

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
## 本次对话结束后要结算关系的 NPC。与线索一样，读完了才算数。
var dialog_pending_npc := ""
var dialog_queue: Array = []  # 对话队列：当前对话关闭后依次播放
var murmur_shown: Dictionary = {}  # 需求告急独白每天每种只播一次
var _last_total_minutes: int = -1
var need_fraction: float = 0.0  # 不足一小时的消耗先攒着，避免每帧被舍掉

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
	home_activities = preload("res://scripts/systems/HomeActivities.gd").new()
	add_child(home_activities)
	home_activities.configure(location_sys)
	home_activities.activity_requested.connect(_on_home_activity)
	office_activities = OfficeActivitiesScript.new()
	office_activities.name = "OfficeActivities"
	add_child(office_activities)
	office_activities.configure(location_sys)
	office_activities.activity_requested.connect(_on_office_activity)
	store_activities = StoreActivitiesScript.new()
	store_activities.name = "StoreActivities"
	add_child(store_activities)
	store_activities.configure(location_sys)
	store_activities.activity_requested.connect(_on_store_activity)
	# 公园是第 4 阶段扩展内容的第一个场景：此前只有地图与 NPC，玩家到了没事可做。
	park_activities = ParkActivitiesScript.new()
	park_activities.name = "ParkActivities"
	add_child(park_activities)
	park_activities.configure(location_sys)
	park_activities.activity_requested.connect(_on_park_activity)
	# 咖啡馆是第 4 阶段扩展内容的第二个场景：点杯咖啡要花钱，发呆免费。
	cafe_activities = CafeActivitiesScript.new()
	cafe_activities.name = "CafeActivities"
	add_child(cafe_activities)
	cafe_activities.configure(location_sys)
	cafe_activities.activity_requested.connect(_on_cafe_activity)
	# 医院是第 4 阶段扩展内容的第三个场景：健康目前只有睡觉和感冒药能补，
	# 这里是第一个正经的健康恢复出口——挂号费不便宜，但补得多。
	hospital_activities = HospitalActivitiesScript.new()
	hospital_activities.name = "HospitalActivities"
	add_child(hospital_activities)
	hospital_activities.configure(location_sys)
	hospital_activities.activity_requested.connect(_on_hospital_activity)
	# 旧巷与天台是第 4 阶段扩展内容的最后两个场景：都是免费的慢节奏去处，
	# 旧巷多一炷 5 元的香。
	alley_activities = AlleyActivitiesScript.new()
	alley_activities.name = "AlleyActivities"
	add_child(alley_activities)
	alley_activities.configure(location_sys)
	alley_activities.activity_requested.connect(_on_alley_activity)
	rooftop_activities = RooftopActivitiesScript.new()
	rooftop_activities.name = "RooftopActivities"
	add_child(rooftop_activities)
	rooftop_activities.configure(location_sys)
	rooftop_activities.activity_requested.connect(_on_rooftop_activity)
	# 背包只存物品数量；买到的东西随时可以取用，具体效果由这里结算。
	inventory = InventoryScript.new()
	inventory.name = "Inventory"
	add_child(inventory)
	# 每日循环只跟踪一天内的目标，不推进年龄、不触发年度结算。
	daily_routine = DailyRoutineScript.new()
	daily_routine.name = "DailyRoutine"
	add_child(daily_routine)
	daily_routine.reset(time_sys.day)
	time_sys.day_changed.connect(_on_day_changed)
	npc_schedule_sys = NPCScheduleSystemScript.new()
	npc_schedule_sys.name = "NPCScheduleSys"
	add_child(npc_schedule_sys)
	npc_schedule_sys.configure(world_manager)
	npc_schedule_sys.reset(time_sys, weather_sys)
	# 纯逻辑，不需要进场景树（和 GameState 一样是 RefCounted）。
	npc_relations_sys = NpcRelationsScript.new()
	quest_sys = QuestSystemScript.new()
	quest_sys.name = "QuestSys"
	add_child(quest_sys)
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
	hud.backpack_requested.connect(_open_bag)

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
	# 自审放宽了这块：追加型提示（任务进度接在结算提示下面）会有两三行，
	# 原来只留了 40px 高、320px 宽，多行会溢出到场景外面去。
	toast_label.offset_top = -185
	toast_label.offset_bottom = -90
	toast_label.offset_left = -280
	toast_label.offset_right = 280
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	toast_label.add_theme_font_size_override("font_size", 14)
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
	# 货架/背包面板放在 UI 层最后，保证它盖在 HUD 与地点视图之上。
	shop_ui = ShopUIScript.new()
	shop_ui.buy_requested.connect(_on_shop_buy)
	shop_ui.use_requested.connect(_on_shop_use)
	shop_ui.closed.connect(_on_shop_closed)
	ui.add_child(shop_ui)


func _refresh_ui() -> void:
	if hud and daily_routine:
		hud.refresh_daily(daily_routine.summary())
	if hud and inventory:
		hud.refresh_bag(inventory.total_count())
	# 床位提示随时刻变化，所以每帧写一次（只是一个字符串赋值）。
	if home_activities:
		home_activities.rest_detail = _rest_detail_text()
	# 工位的时薪、谈薪是否够格、今天谈过没，都由 Game 算好喂给交互层（判定不放在那边）。
	# 这几样只在变化时才重新喂：自审发现旧写法每帧新建字典、还每帧跑一次谈薪判定，
	# 虽然不贵，但完全没必要。
	if office_activities:
		var today: int = time_sys.day if time_sys else 0
		var laozhang_relation: int = 0
		if npc_relations_sys != null:
			laozhang_relation = npc_relations_sys.value_of(game_state.relations, "laozhang")
		# 「有没有人帮腔」只是一个阈值比较，不必为了它每帧跑一遍 negotiate() 再丢掉结果。
		var friend: bool = laozhang_relation >= JobGrowthScript.FRIEND_RELATION
		var wage: int = JobGrowthScript.wage_of(skill, game_state.raise_steps)
		var context: Dictionary = {
			"skill": skill,
			"wage": wage,
			"title": JobGrowthScript.title_of(skill),
			"can_negotiate": JobGrowthScript.can_negotiate(skill),
			"raised_today": int(game_state.raise_day) == today,
			"friend": friend,
		}
		if office_activities.context != context:
			office_activities.sync_context(context)
	if hud:
		hud.refresh_skill(skill, JobGrowthScript.title_of(skill))
	# 人生阶段目标与主线任务共用同一行（HUD 高度被地点标题的偏移量盯死，不能再加行）。
	# `_state()` 每帧只取一次，别在一帧里反复构造字典。
	var st: Dictionary = _state()
	var stage: Dictionary = story_sys.current_stage(st) if story_sys else {}
	if hud and not stage.is_empty():
		var quest_text: String = quest_sys.objective_text(st) if quest_sys else ""
		hud.refresh(game_state, str(stage.get("name", "")), str(stage.get("goal", "")), Data.DARK_CLUE_TOTAL, quest_text)
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
	dialog_pending_npc = ""
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
	if daily_routine:
		daily_routine.reset(1)
	if inventory:
		inventory.reset()
	if shop_ui and shop_ui.is_open():
		shop_ui.close()
	need_fraction = 0.0
	murmur_shown = {}
	# 开局即记录时间基准，否则第一次同步只会初始化、漏掉开局后流逝的时间。
	_last_total_minutes = time_sys.day * 1440 + time_sys.get_minute_of_day() if time_sys != null else -1
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
	if activity_running:
		_show_toast("行动完成后即可保存。")
		return
	if save_sys == null or not game_started or game_over:
		_show_toast("当前没有可以保存的游戏进度。")
		return
	if (dialog_ui and dialog_ui.is_busy()) or (event_ui and event_ui.is_busy()):
		_show_toast("请先结束当前对话或事件，再保存。")
		return
	var result: Dictionary = save_sys.save_game(build_save_payload())
	_show_toast(str(result.get("message", "存档失败。")))
	if start_ui:
		start_ui.set_load_available(save_sys.has_save())


## 存档内容集中在这一个函数里。这样"中途存档 → 读回"可以在内存里整份往返验证，
## 不必去碰玩家真正的存档文件（user://savegame.json）。
func build_save_payload() -> Dictionary:
	return {
		"game_state": game_state.to_dict(),
		"time": time_sys.to_save_dict() if time_sys else {},
		"weather": weather_sys.to_save_dict() if weather_sys else {},
		"events": events_sys.to_save_dict() if events_sys else {},
		"encounters": encounter_sys.to_save_dict() if encounter_sys else {},
		"world": world_manager.to_save_dict(player) if world_manager else {},
		"locations": location_sys.to_save_dict() if location_sys else {},
		"daily": daily_routine.to_save_dict() if daily_routine else {},
		"inventory": inventory.to_save_dict() if inventory else {},
		"origin": origin.duplicate(true),
	}


## 读档的唯一入口：把 payload 整份盖回运行时状态。
func apply_save_payload(payload: Dictionary) -> void:
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
	if daily_routine:
		daily_routine.apply_save_dict(payload.get("daily", {}))
	if inventory:
		inventory.apply_save_dict(payload.get("inventory", {}))
	if npc_schedule_sys:
		npc_schedule_sys.reset(time_sys, weather_sys)
	if dark_location_sys:
		dark_location_sys.reset(time_sys, _state())
	# 读档会把时间整体跳到存档那一刻，必须重设消耗基准，否则这一跳会被当成
	# "真实流过的时间"扣掉一大截饱食与精力。
	need_fraction = 0.0
	_last_total_minutes = time_sys.day * 1440 + time_sys.get_minute_of_day() if time_sys != null else -1
	dialog_queue.clear()
	dialog_pending_clue = ""
	dialog_pending_npc = ""
	cur_event = null
	cur_event_kind = "event"
	cur_event_time_cost = 0
	game_over = false
	game_started = true


func _load_game() -> void:
	if activity_running:
		_show_toast("请等待当前行动完成，再读取存档。")
		return
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
	# 读档会整体替换状态，货架/背包面板必须先收起来。
	if shop_ui and shop_ui.is_open():
		shop_ui.close()
	apply_save_payload(result.get("payload", {}))
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
	_evaluate_quests()
	if location_sys and location_sys.is_active():
		near_target = {}
	else:
		_update_near_target()
	_refresh_ui()
	_check_stage()
	var ui_busy: bool = (dialog_ui != null and dialog_ui.is_busy()) or (event_ui != null and event_ui.is_busy()) or (ending_ui != null and ending_ui.visible)
	ui_busy = ui_busy or activity_running
	# 货架/背包打开时也算“界面占用”：不让角色走开，也暂停时间，免得挑东西的时候一直在掉饱食。
	ui_busy = ui_busy or (shop_ui != null and shop_ui.is_open())
	location_sys.input_blocked = ui_busy
	home_activities.blocked = ui_busy
	office_activities.blocked = ui_busy
	store_activities.blocked = ui_busy
	park_activities.blocked = ui_busy
	cafe_activities.blocked = ui_busy
	hospital_activities.blocked = ui_busy
	alley_activities.blocked = ui_busy
	rooftop_activities.blocked = ui_busy
	if time_sys:
		time_sys.set_paused(ui_busy)
		time_sys.tick(delta)
	_sync_needs_to_time()
	# 结局判定只走这一个入口；界面/活动忙时等交互收尾后再评估，避免结局层与事件层同时弹出。
	if not ui_busy and _evaluate_terminal_state():
		return
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

## 活动公用的开头：上锁 + 头顶反馈 + 进度条。所有场景活动都从这里走，
## 别再各自抄一份（此前三处各抄一份，连"哪些活动脚本要上锁"都对不上）。
func _begin_activity(prompt_label: Label, progress_text: String, feedback_text: String, activity_id: String, anchor: Dictionary = {}) -> void:
	activity_running = true
	location_sys.input_blocked = true
	home_activities.blocked = true
	office_activities.blocked = true
	store_activities.blocked = true
	park_activities.blocked = true
	cafe_activities.blocked = true
	hospital_activities.blocked = true
	alley_activities.blocked = true
	rooftop_activities.blocked = true
	location_sys.set_activity_feedback(feedback_text, true, activity_id, anchor)
	for step in range(10):
		prompt_label.text = "%s… %d%%" % [progress_text, (step + 1) * 10]
		await get_tree().create_timer(0.12).timeout


## 活动公用的结尾：解锁 + 刷新。数值结算发生在调用方，这里只管收尾。
func _end_activity() -> void:
	activity_running = false
	location_sys.set_activity_feedback("", false)
	var still_busy: bool = dialog_ui.is_busy() or event_ui.is_busy() or game_over
	location_sys.input_blocked = still_busy
	home_activities.blocked = still_busy
	office_activities.blocked = still_busy
	store_activities.blocked = still_busy
	park_activities.blocked = still_busy
	cafe_activities.blocked = still_busy
	hospital_activities.blocked = still_busy
	alley_activities.blocked = still_busy
	rooftop_activities.blocked = still_busy
	_refresh_ui()


func _on_home_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "home" or not home_activities.SPOTS.has(id):
		return
	if id == "leave":
		location_sys.unlock("subway")
		location_sys.travel_to("subway")
		return
	if id == "meal" and money < 20:
		_show_toast("食材需要20元，当前余额不足。")
		return
	var progress_words := {"rest": "睡意渐浓", "study": "书页翻动", "meal": "锅里咕嘟作响"}
	var activity_icons := {"rest": "Zzz", "study": "专注中", "meal": "烹饪中"}
	# 先由 SpotActivities 自动走到 position，再把完整锚点交给地点表现层处理姿态与景深。
	await _begin_activity(home_activities.prompt, str(progress_words.get(id, "进行中")), str(activity_icons.get(id, "进行中")), id, home_activities.SPOTS[id])
	var feedback: String = ""
	var slept_through := false
	match id:
		"rest":
			# 夜里上床就是睡一整夜、跨到次日；白天躺下只是两小时小睡。
			if _is_sleep_hour():
				feedback = _sleep_through_night()
				slept_through = true
				if game_over:
					_end_activity()
					return
			else:
				health = mini(100, health + 12)
				mood = mini(100, mood + 8)
				energy = mini(100, energy + 50)
				time_sys.advance_minutes(120)
				feedback = "你躺下睡了两个钟头，梦里什么都没有。醒来时身体松快了些。（健康+12 心情+8 精力+50）"
		"study":
			skill = mini(100, skill + 3)
			mood = maxi(0, mood - 3)
			time_sys.advance_minutes(60)
			feedback = "台灯下坐了一个小时，书翻过去又翻回来。手艺见长，人有点乏。（技能+3 心情−3）"
		"meal":
			money -= 20
			health = mini(100, health + 5)
			fullness = mini(100, fullness + 45)
			time_sys.advance_minutes(30)
			feedback = "一个人也要好好吃饭。热汤下肚，身上暖了起来。（−20元 健康+5 饱食+45）"
	# 睡整夜时"休息"已经在跨天前记进昨天了，跨天会把当日进度清空，
	# 所以新的一天从小目标全空开始，不能在这里再补一次。
	if daily_routine and not slept_through:
		if id == "meal":
			daily_routine.complete("meal")
			if quest_sys:
				quest_sys.notify(_state(), "meal_cooked")
		elif id == "rest":
			daily_routine.complete("sleep")
	_end_activity()
	_show_toast(feedback)


# ---------------------------------------------------------------- 过夜

## 20:00 之后、或凌晨 5:00 之前上床就是睡一整夜；白天躺下只是小睡。
func _is_sleep_hour() -> bool:
	if time_sys == null:
		return false
	var minute: int = time_sys.get_minute_of_day()
	return minute >= 20 * 60 or minute < 5 * 60


## 从当前时刻睡到次日 07:30 需要多少分钟。
func _sleep_minutes_to_morning() -> int:
	if time_sys == null:
		return 0
	var minute: int = time_sys.get_minute_of_day()
	var wake: int = 7 * 60 + 30
	if minute < 5 * 60:
		# 已经过了午夜，睡到"今天"早上就够了。
		return wake - minute
	return (24 * 60 - minute) + wake


## 床位的提示语按当前时刻变化：夜里告诉玩家这一觉睡到明早，白天就照常写两小时小睡。
func _rest_detail_text() -> String:
	if _is_sleep_hour():
		return "睡到明早 7:30 · 跨天结算"
	return "2小时 · 健康+12 心情+8 精力+50"


## 睡一整夜：跨过午夜触发次日，醒来是早上 7:30。
## 昨天一天的目标必须在跨天之前先记下来——跨天会把当日进度清空。
func _sleep_through_night() -> String:
	var minutes: int = _sleep_minutes_to_morning()
	var yesterday: String = ""
	if daily_routine:
		daily_routine.complete("sleep")
		yesterday = daily_routine.summary()
	if time_sys:
		time_sys.advance_minutes(minutes)
	# 睡觉本身也是"时间流过"：先把这一夜该掉的饱食掉掉，再回满精力。
	# 醒来是"睡饱了但饿"，而不是睡完还累。
	_sync_needs_to_time()
	# GAME-FIX-007：过夜需求结算如果已经触发终局，必须先走统一 evaluator，
	# 不能让随后同一流程的睡眠恢复把 0 健康/心情重新抬高。
	if _evaluate_terminal_state():
		return ""
	health = mini(100, health + 12)
	mood = mini(100, mood + 8)
	energy = 100
	var day_now: int = time_sys.day if time_sys != null else 0
	var wake_text: String = time_sys.get_clock_text() if time_sys != null else "07:30"
	return "你把自己扔到床上，灯也没关。再睁眼是第 %d 天的早上 %s，雨还在下。\n昨天：%s\n（睡了 %.1f 小时 · 精力回满 健康+12 心情+8）" % [
		day_now, wake_text, yesterday, float(minutes) / 60.0,
	]

func _on_office_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "office" or not office_activities.SPOTS.has(id):
		return
	if id == "negotiate":
		await _do_negotiate()
		return
	await _do_work_shift()


## 上班：拿钱、掉状态、攒熟练度。时薪按技能档位走，所以"多上班"本身会涨价。
func _do_work_shift() -> void:
	var wage: int = JobGrowthScript.wage_of(skill, game_state.raise_steps)
	await _begin_activity(office_activities.prompt, "键盘敲个不停", "工作中", "work")
	money += wage
	health = maxi(0, health - 6)
	mood = maxi(0, mood - 4)
	time_sys.advance_minutes(240)
	# 先结算工资再涨技能：同一班不会因为刚涨了档就按新价算，账才对得上。
	var growth: Dictionary = JobGrowthScript.gain_shift(skill, game_state.work_exp)
	skill = int(growth["skill"])
	game_state.work_exp = int(growth["exp"])
	if daily_routine:
		daily_routine.complete("work")
	if quest_sys:
		quest_sys.notify(_state(), "work_shift")
	_end_activity()
	_show_toast("你把一整天交给了格子间。下班时雨还在下，手机里多了 %d 块。身体发沉，话也不想说。（工资+%d 健康−6 心情−4，耗时4小时）%s" % [wage, wage, _work_growth_line(growth)])


## 上班这一班的"手艺长进"。没长进时也给一句，免得玩家觉得白干。
func _work_growth_line(growth: Dictionary) -> String:
	if bool(growth.get("tier_up", false)):
		return "手上的活终于有了章法——你算得上「%s」了。（时薪 %d）" % [
			str(growth["tier_title"]), JobGrowthScript.wage_of(skill, game_state.raise_steps),
		]
	if bool(growth.get("leveled", false)):
		return "活儿还是这些活儿，你做得比上个月快了。（技能 %d/%d）" % [skill, JobGrowthScript.MAX_SKILL]
	return "同样的报表，你今天少改了两遍。"


## 谈薪：技能到「熟练」才有资格开口；谈得下来要看技能+人脉，老张熟络了会替你说一句。
## 一天只能谈一次——不管成没成，今天都算数，省得反复进出门刷结果。
func _do_negotiate() -> void:
	var today: int = time_sys.day if time_sys else 0
	if not JobGrowthScript.can_negotiate(skill):
		_show_toast("话到嘴边又咽了回去——手上的活还不够硬。（谈薪要技能 %d，你现在 %d）" % [
			JobGrowthScript.NEGOTIATE_SKILL, skill,
		])
		return
	if int(game_state.raise_day) == today:
		_show_toast("今天已经找过主管了。再进去一次，就不叫争取了。")
		return
	if int(game_state.raise_steps) >= JobGrowthScript.MAX_RAISES:
		_show_toast("你的岗位工资已经到顶了。剩下的路，不在这一间办公室里。")
		return
	game_state.raise_day = today
	await _begin_activity(office_activities.prompt, "你在主管门口站了一会儿", "在门口", "negotiate")
	var relation: int = 0
	if npc_relations_sys != null:
		relation = npc_relations_sys.value_of(game_state.relations, "laozhang")
	var result: Dictionary = JobGrowthScript.negotiate(skill, network, relation)
	var feedback: String
	if bool(result["ok"]):
		game_state.raise_steps = mini(JobGrowthScript.MAX_RAISES, int(game_state.raise_steps) + 1)
		mood = mini(100, mood + 6)
		feedback = "主管翻完你的考核表，沉默了一会儿，说「下个月起调一下」。（岗位工资+%d，现在 %d；心情+6）" % [
			JobGrowthScript.RAISE_BONUS, JobGrowthScript.wage_of(skill, game_state.raise_steps),
		]
		if bool(result["friend"]):
			feedback += "出门的时候老张在走廊抽烟，冲你点了点头。"
	else:
		mood = maxi(0, mood - 6)
		feedback = "主管头也没抬：「再攒攒。」你站了两秒，说了声好。（心情−6）"
		if bool(result["friend"]):
			feedback += "老张后来替你说了一句，但这次没顶用。"
		else:
			feedback += "你想起老张说过，会干活的不如会说话的。"
	time_sys.advance_minutes(JobGrowthScript.NEGOTIATE_MINUTES)
	_end_activity()
	_show_toast(feedback)


# ---------------------------------------------------------------- 便利店与背包

func _on_store_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "store" or not store_activities.SPOTS.has(id):
		return
	if id == "shop":
		_open_shop()


# ---------------------------------------------------------------- 公园

## 公园的两个歇脚点。刻意**不算**每日目标里的"休息"——那仍然只属于回家睡觉，
## 公园是顺路喘口气的地方，不该变成另一种打卡。
func _on_park_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "park" or not park_activities.SPOTS.has(id):
		return
	var feedback: String = ""
	match id:
		"bench":
			await _begin_activity(park_activities.prompt, "你在长椅上坐了下来", "发呆中", "bench")
			energy = mini(100, energy + 20)
			mood = mini(100, mood + 5)
			time_sys.advance_minutes(30)
			feedback = "长椅是湿的，你垫了下手还是坐了。雨声把脑子里的杂音盖掉了一半。（精力+20 心情+5，耗时30分钟）"
		"pond":
			await _begin_activity(park_activities.prompt, "你看着水面上的圈", "看雨中", "pond")
			mood = mini(100, mood + 8)
			time_sys.advance_minutes(20)
			feedback = "池塘边的石栏被雨洗得发亮。你看了会儿水面的圈。（心情+8，耗时20分钟）"
	_end_activity()
	_show_toast(feedback)


func _on_cafe_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "cafe" or not cafe_activities.SPOTS.has(id):
		return
	# 咖啡要先看钱：余额不足时不下单、不结算，和做饭的食材检查同一套做法。
	if id == "coffee" and money < 15:
		_show_toast("一杯咖啡15元，当前余额不足。")
		return
	var feedback: String = ""
	match id:
		"coffee":
			await _begin_activity(cafe_activities.prompt, "咖啡机的蒸汽声", "冲泡中", "coffee")
			money -= 15
			energy = mini(100, energy + 15)
			mood = mini(100, mood + 6)
			time_sys.advance_minutes(30)
			feedback = "靠窗的位置看得到雨。咖啡是烫的，你捧着杯子没说话，觉得缓过来一点。（−15元 精力+15 心情+6，耗时30分钟）"
		"idle":
			await _begin_activity(cafe_activities.prompt, "雨点敲着玻璃", "发呆中", "idle")
			mood = mini(100, mood + 8)
			time_sys.advance_minutes(20)
			feedback = "你对着一桌子的烛光坐了二十分钟，谁的消息也没回。有些累是闲下来的那一刻才追上你的。（心情+8，耗时20分钟）"
	_end_activity()
	_show_toast(feedback)


func _on_hospital_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "hospital" or not hospital_activities.SPOTS.has(id):
		return
	# 挂号费先看余额：与做饭的食材、咖啡馆的咖啡同一套做法。
	if id == "clinic" and money < 50:
		_show_toast("挂号加拿药要50元，当前余额不足。")
		return
	var feedback: String = ""
	match id:
		"clinic":
			await _begin_activity(hospital_activities.prompt, "医生在写病历", "问诊中", "clinic")
			money -= 50
			health = mini(100, health + 25)
			time_sys.advance_minutes(60)
			feedback = "验了血，听了肺，医生说没大毛病，开了一周的药。走出诊室时你忽然觉得，能嫌医院冷的人其实是有福的。（−50元 健康+25，耗时60分钟）"
		"bench":
			await _begin_activity(hospital_activities.prompt, "走廊的灯白得发凉", "候诊中", "bench")
			mood = mini(100, mood + 5)
			time_sys.advance_minutes(15)
			feedback = "你在候诊椅上坐了一会儿。护士推着车走过，喊到的名字都不是你的。这样想想，好像也值得高兴。（心情+5，耗时15分钟）"
	_end_activity()
	_show_toast(feedback)


func _on_alley_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "alley" or not alley_activities.SPOTS.has(id):
		return
	# 香钱先看余额：与做饭/咖啡/挂号同一套检查。
	if id == "shrine" and money < 5:
		_show_toast("一炷香5元，当前余额不足。")
		return
	var feedback: String = ""
	match id:
		"shrine":
			await _begin_activity(alley_activities.prompt, "香灰簌簌地落", "上香中", "shrine")
			money -= 5
			mood = mini(100, mood + 8)
			time_sys.advance_minutes(15)
			feedback = "你点了一炷香插进炉里，没许愿，就是站了一会儿。火光在雨里晃，心里那点堵着的东西好像松了半寸。（−5元 心情+8，耗时15分钟）"
		"door":
			await _begin_activity(alley_activities.prompt, "门缝里透出灯光", "歇脚中", "door")
			mood = mini(100, mood + 6)
			time_sys.advance_minutes(20)
			feedback = "这扇门总亮着灯，你从没见谁进出。你在台阶下站了二十分钟，猜里面的日子是什么样的，然后回去继续过自己的。（心情+6，耗时20分钟）"
	_end_activity()
	_show_toast(feedback)


func _on_rooftop_activity(id: String) -> void:
	if activity_running or not game_started or game_over or dialog_ui.is_busy() or event_ui.is_busy():
		return
	if location_sys.current_location != "rooftop" or not rooftop_activities.SPOTS.has(id):
		return
	var feedback: String = ""
	match id:
		"ledge":
			await _begin_activity(rooftop_activities.prompt, "城市在脚下亮着", "看夜景", "ledge")
			mood = mini(100, mood + 10)
			time_sys.advance_minutes(25)
			feedback = "你在栏杆边站了二十五分钟。楼下是别人的人生，一扇一扇亮着；从这里看，连烦恼都显得小了一圈。（心情+10，耗时25分钟）"
		"bench":
			await _begin_activity(rooftop_activities.prompt, "风把雨丝吹斜", "吹风中", "bench")
			mood = mini(100, mood + 8)
			energy = mini(100, energy + 5)
			time_sys.advance_minutes(20)
			feedback = "天台的长椅没人抢。你坐下来吹了吹风，什么也没想，肩膀自己松了下来。（心情+8 精力+5，耗时20分钟）"
	_end_activity()
	_show_toast(feedback)


func _open_shop() -> void:
	if shop_ui == null:
		return
	shop_ui.open_buy(money, inventory)


func _open_bag() -> void:
	if shop_ui == null or not game_started or game_over:
		return
	if activity_running:
		_show_toast("请等待当前行动完成，再打开背包。")
		return
	if (dialog_ui and dialog_ui.is_busy()) or (event_ui and event_ui.is_busy()):
		_show_toast("请先结束当前对话或事件。")
		return
	shop_ui.open_bag(money, inventory)


func _on_shop_closed() -> void:
	_refresh_ui()


func _on_shop_buy(item_id: String) -> void:
	if inventory == null or not InventoryScript.ITEMS.has(item_id):
		return
	var price: int = InventoryScript.price_of(item_id)
	if money < price:
		# 面板里按钮已经按下去表示买不起了，这里兜住键盘/异常路径。
		shop_ui.set_status("你把口袋翻了个底朝天，还差 %d 元。这一样先放回去了。" % (price - money))
		return
	money -= price
	inventory.add(item_id, 1)
	if quest_sys:
		quest_sys.notify(_state(), "store_buy")
	shop_ui.refresh(money, inventory)
	shop_ui.set_status("你把%s放上收银台。扫码的滴声很轻，塑料袋在手里晃了一下。（−%d元）" % [
		InventoryScript.item_name(item_id), price,
	])
	_refresh_ui()


func _on_shop_use(item_id: String) -> void:
	if inventory == null or not InventoryScript.ITEMS.has(item_id) or not inventory.has(item_id):
		return
	var effects: Dictionary = InventoryScript.ITEMS[item_id].get("effects", {})
	if not inventory.remove(item_id, 1):
		return
	for key in effects:
		var delta: int = int(effects[key])
		match str(key):
			"fullness":
				fullness = clampi(fullness + delta, 0, 100)
			"energy":
				energy = clampi(energy + delta, 0, 100)
			"health":
				health = clampi(health + delta, 0, 100)
			"mood":
				mood = clampi(mood + delta, 0, 100)
			"skill":
				skill = clampi(skill + delta, 0, 100)
	var minutes: int = InventoryScript.minutes_of(item_id)
	if time_sys:
		time_sys.advance_minutes(minutes)
	# 能顶一顿的算吃饭；牛奶这种垫肚子的不算，免得每日目标被随手糊弄过去。
	if daily_routine and int(effects.get("fullness", 0)) >= MEAL_FULLNESS:
		daily_routine.complete("meal")
	shop_ui.refresh(money, inventory)
	shop_ui.set_status("%s（%s，耗时%d分钟）" % [
		InventoryScript.use_text(item_id),
		InventoryScript.effect_text(item_id),
		minutes,
	])
	_refresh_ui()


## 需求按真实流经的分钟数消耗，不依赖 hour_changed——
## advance_minutes 无论推进多少都只 emit 一次 hour_changed，按信号扣会算错比例。
func _sync_needs_to_time() -> void:
	if time_sys == null:
		return
	var total: int = time_sys.day * 1440 + time_sys.get_minute_of_day()
	if _last_total_minutes == -1:
		_last_total_minutes = total
		return
	var delta: int = total - _last_total_minutes
	_last_total_minutes = total
	if delta <= 0:
		return
	if not game_started or game_over:
		return
	need_fraction += float(delta) / 60.0
	while need_fraction >= 1.0:
		need_fraction -= 1.0
		fullness = maxi(0, fullness - FULLNESS_PER_HOUR)
		energy = maxi(0, energy - ENERGY_PER_HOUR)
		if fullness <= 0:
			health = maxi(0, health - 2)
		if energy <= 0:
			mood = maxi(0, mood - 2)
	_warn_if_need_low()

## 告急时用角色的口气说一句话，而不是弹出“饱食度过低”这种数值提示。
func _warn_if_need_low() -> void:
	for need in ["fullness", "energy"]:
		var value: int = fullness if need == "fullness" else energy
		if value > NEED_LOW:
			continue
		if int(murmur_shown.get(need, -1)) == time_sys.day:
			continue
		murmur_shown[need] = time_sys.day
		_show_toast(str(MURMURS[need]))


func _on_day_changed(day: int) -> void:
	# 只重置每日目标；年龄与年度事件由旧人生系统负责，这里不碰。
	if daily_routine:
		daily_routine.reset(day)
		_show_toast("第 %d 天 · 今日目标已重置" % day)


func _on_location_travel(location_id: String) -> void:
	# 第一次抵达地铁/公司等地点即完成“地图解锁”的体验；旅行本身消耗少量时间。
	if time_sys:
		time_sys.advance_minutes(20 if location_id == "subway" else 35)
	if daily_routine and location_id == "office":
		daily_routine.complete("commute")
	var location_name: String = location_id
	if location_sys != null and location_sys.LOCATIONS.has(location_id):
		location_name = str(location_sys.LOCATIONS[location_id].get("name", location_id))
	_show_toast("已到达：%s" % location_name)


func _on_location_action(location_id: String) -> void:
	if activity_running:
		return
	if not game_started:
		_show_toast("请先选择出身开始游戏。")
		return
	if dialog_ui != null and dialog_ui.is_busy():
		_show_toast("请先结束当前对话。")
		return
	if event_ui != null and event_ui.is_busy():
		_show_toast("当前事件尚未结束。")
		return
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
	if activity_running:
		return
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
		var scheduled_location: String = str(state.get("location", ""))
		scheduled_location = str(SCHEDULE_LOCATION_ALIASES.get(scheduled_location, scheduled_location))
		if scheduled_location != location_sys.current_location:
			continue
		visible_items.append({
			"id": npc_id,
			"name": str(npc.get("name", npc_id)),
			# 悬停标签带上熟悉度，关系变化在场景里就能看见。
			"note": npc_relations_sys.label_for(game_state.relations, npc_id) if npc_relations_sys != null else "",
		})
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
		return
	_show_event(e)


func _talk_to(npc: Dictionary) -> void:
	var npc_id := str(npc.get("id", ""))
	var dialog_data: Dictionary = story_sys.build_npc_dialog(npc, _state()) if story_sys else {"lines": Data.npc_lines(npc, age), "pending_clue": ""}
	dialog_pending_clue = str(dialog_data.get("pending_clue", ""))
	# 关系也在对话读完后再结算（见 _on_dialog_finished），这里只记下是谁。
	dialog_pending_npc = npc_id
	var lines: Array = (dialog_data.get("lines", []) as Array).duplicate()
	# 同一天再聊不涨好感。与其让玩家自己猜，不如在对话里说清楚。
	if _talked_today(npc_id):
		lines.append("（今天已经聊过了。话是说不完的，但意思到了。）")
	var title := "%s · %s" % [npc["name"], npc["title"]]
	if npc_relations_sys != null:
		title += " · %s" % npc_relations_sys.label_for(game_state.relations, npc_id)
	_show_dialog(title, lines)


func _talked_today(npc_id: String) -> bool:
	if npc_relations_sys == null or time_sys == null:
		return false
	return npc_relations_sys.talked_today(game_state.talk_day, npc_id, time_sys.day)


func _npc_name(npc_id: String) -> String:
	for npc in Data.NPCS:
		if str(npc.get("id", "")) == npc_id:
			return str(npc.get("name", npc_id))
	return npc_id


## 把一次交谈的结果落到玩家身上，并用一句生活化的话说出来（数值放括号里）。
func _apply_talk_result(npc_id: String, result: Dictionary) -> void:
	if result.is_empty():
		return
	var gain := int(result.get("gain", 0))
	var mood_gain := int(result.get("mood_gain", 0))
	if mood_gain > 0:
		mood = clampi(mood + mood_gain, 0, 100)

	var parts := PackedStringArray()
	if gain > 0:
		parts.append("好感+%d(%d)" % [gain, int(result.get("after", 0))])
	if mood_gain > 0:
		parts.append("心情+%d" % mood_gain)

	var npc_name := _npc_name(npc_id)
	var text := ""
	if bool(result.get("tier_up", false)):
		text = "你和%s的交情到了「%s」。" % [npc_name, str(result.get("tier_label", ""))]
		if not parts.is_empty():
			text += "（%s）" % ", ".join(parts)
	elif not parts.is_empty():
		text = "你和%s聊了几句。（%s）" % [npc_name, ", ".join(parts)]
	if text.is_empty():
		return
	var milestone := str(result.get("milestone", ""))
	if not milestone.is_empty():
		text += " " + milestone
	_show_toast(text)

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
	# 普通日常事件到这里结束；年度推进只保留给显式调用 `_year_pass()` 的剧情路径。
	return


func _year_pass() -> void:
	var st := _state()
	var res: Dictionary = rules_sys.year_tick(st)
	_sync_from_state(st)

	if _evaluate_terminal_state():
		return

	var txt := "%d 岁  收入 %s / 支出 %s / 结余 %s" % [
		age, _fmt_money(int(res["income"])), _fmt_money(int(res["cost"])), _fmt_money(int(res["net"]))
	]
	if str(res["promoted"]) != "":
		txt += "\n晋升为 %s！" % str(res["promoted"])
	if bool(res["ipo"]):
		txt += "\n公司熬出头了，你成了老板。"
	_show_toast(txt)


## 所有健康/心情/破产/年龄终局统一从这里判定。
## 调用方只决定“什么时候评估”，阈值与优先级仍完全由 Rules.death_reason() 决定。
## game_over 是幂等护栏，避免刷新、重入或年度路径重复触发结局 UI。
func _evaluate_terminal_state() -> bool:
	if game_over:
		return true
	if rules_sys == null:
		return false
	var st: Dictionary = _state()
	var reason: String = rules_sys.death_reason(st)
	if reason.is_empty():
		return false
	_show_ending(reason, st)
	return true


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
	if activity_running:
		_show_toast("请等待当前行动完成。")
		return
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
	if inventory:
		inventory.reset()
	if shop_ui and shop_ui.is_open():
		shop_ui.close()
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
	if dialog_pending_npc != "":
		var talked_id := dialog_pending_npc
		dialog_pending_npc = ""
		if npc_relations_sys != null:
			var result: Dictionary = npc_relations_sys.talk(
				game_state.relations,
				game_state.talk_day,
				talked_id,
				time_sys.day if time_sys != null else 0
			)
			_apply_talk_result(talked_id, result)
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


## 主线任务推进。放在 `_process` 每帧跑一次，判定是幂等的（进度里的标记只写一次），
## 所以读档、漏掉信号都不会卡住。步进不弹提示（HUD 上那行一直挂着，变化看得见），
## 开场白和收尾才弹——它们不常发生，弹一次不会被结算提示顶掉。
func _evaluate_quests() -> void:
	if quest_sys == null or time_sys == null:
		return
	var st := _state()
	var events: Array = quest_sys.evaluate(st, time_sys.day)
	if events.is_empty():
		return
	_sync_from_state(st)
	for ev in events:
		var kind := str(ev.get("kind", ""))
		var text := str(ev.get("text", ""))
		if kind == "intro":
			_show_toast("任务「%s」：%s" % [str(ev.get("title", "")), text], true)
		elif kind == "step":
			_show_toast(text, true)
		elif kind == "quest":
			_show_toast("任务完成 · %s\n%s" % [str(ev.get("title", "")), text], true)
			_apply_quest_reward(ev.get("reward", {}))
	_refresh_ui()


func _apply_quest_reward(reward) -> void:
	if not reward is Dictionary:
		return
	for key in reward:
		var delta: int = int(reward[key])
		match str(key):
			"money":
				money = maxi(0, money + delta)
			"mood":
				mood = clampi(mood + delta, 0, 100)
			"health":
				health = clampi(health + delta, 0, 100)
			"skill":
				skill = clampi(skill + delta, 0, 100)
			"fullness":
				fullness = clampi(fullness + delta, 0, 100)
			"energy":
				energy = clampi(energy + delta, 0, 100)
			_:
				push_warning("[Game] 不认识的任务奖励字段：" + str(key))


## 顶部提示。自审修掉的一个真问题：以前连着弹两条时，前一条的定时器会把
## **后一条刚写上去的文字**提前藏掉（3.5 秒一到就 visible=false，不管文字是谁写的）。
## 现在用递增序号，只有"最新那条"的定时器能收尾。
## `append=true` 用于追加型提示（任务进度）：结算提示还在屏上时，任务提示接在下面，
## 而不是把玩家刚看到的"工资+120"顶掉。
func _show_toast(text: String, append: bool = false) -> void:
	if not toast_label:
		return
	if append and toast_label.visible and not toast_label.text.is_empty():
		toast_label.text = "%s\n%s" % [toast_label.text, text]
	else:
		toast_label.text = text
	toast_label.visible = true
	_toast_seq += 1
	var seq: int = _toast_seq
	await get_tree().create_timer(3.5).timeout
	if toast_label and seq == _toast_seq:
		toast_label.visible = false
