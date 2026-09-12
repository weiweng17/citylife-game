extends RefCounted
class_name ArtCatalog
## 统一美术资源索引。
## 事件/UI 只通过 scene/event_id 取资源，不在业务代码中散落 PNG 路径。

const SCENE_BACKGROUNDS := {
	"rent": "res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp",
	"home": "res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp",
	"office": "res://assets/backgrounds/dialogue/company/open_office_rain_night.webp",
	"cafe": "res://assets/backgrounds/dialogue/life/cafe_rain_night.webp",
	"street": "res://assets/backgrounds/dialogue/city/street_corner_rain_night.webp",
	"park": "res://assets/backgrounds/dialogue/life/park_pavilion_rain_night.webp",
	"gym": "res://assets/backgrounds/dialogue/life/park_pavilion_rain_night.webp",
	"subway": "res://assets/backgrounds/dialogue/transport/subway_platform_rain_night.webp",
	"hospital": "res://assets/backgrounds/dialogue/hospital/clinic_room_rain_night.webp",
	"rooftop": "res://assets/backgrounds/dialogue/city/rooftop_rain_night.webp",
	"alley": "res://assets/backgrounds/dialogue/city/old_alley_rain_night.webp",
}

# 少量关键事件用更精确的场景覆盖默认 scene 背景。
const EVENT_BACKGROUND_OVERRIDES := {
	"e_layoff": "res://assets/backgrounds/dialogue/company/meeting_room_rain_night.webp",
	"e_promote": "res://assets/backgrounds/dialogue/company/meeting_room_rain_night.webp",
	"e_promotion_lose": "res://assets/backgrounds/dialogue/company/meeting_room_rain_night.webp",
	"e_office_politics": "res://assets/backgrounds/dialogue/company/meeting_room_rain_night.webp",
	"e_boss_talk": "res://assets/backgrounds/dialogue/company/boss_office_rain_night.webp",
	"e_final_health": "res://assets/backgrounds/dialogue/hospital/ward_room_rain_night.webp",
	"e_oldfriend_ill": "res://assets/backgrounds/dialogue/hospital/ward_room_rain_night.webp",
	"dark_alley": "res://assets/backgrounds/dialogue/city/old_alley_rain_night.webp",
	"dark_rooftop": "res://assets/backgrounds/dialogue/city/rooftop_rain_night.webp",
}

const CHARACTER_REFERENCE := {
	"core_cast": "res://assets/characters/reference/core_cast_ten_overview.png",
	"protagonist": "res://assets/characters/reference/protagonist_stages_expression_sheet.png",
	"core_npcs": "res://assets/characters/reference/core_npc_five_pack.png",
	"special_growth": "res://assets/characters/reference/special_character_growth_sheet.png",
}

const PROTOTYPE_SPRITES := {
	"protagonist": "res://assets/characters/sprites/prototype/protagonist_walk_candidate.png",
	"xiaoyu": "res://assets/characters/sprites/prototype/xiaoyu_walk_candidate.png",
	"chenjie": "res://assets/characters/sprites/prototype/chenjie_walk_candidate.png",
}

static func event_background_path(event_data: Dictionary) -> String:
	var event_id := str(event_data.get("id", ""))
	if EVENT_BACKGROUND_OVERRIDES.has(event_id):
		return str(EVENT_BACKGROUND_OVERRIDES[event_id])
	return str(SCENE_BACKGROUNDS.get(str(event_data.get("scene", "")), ""))

static func event_background(event_data: Dictionary) -> Texture2D:
	var path := event_background_path(event_data)
	if path.is_empty():
		return null
	return load(path) as Texture2D
