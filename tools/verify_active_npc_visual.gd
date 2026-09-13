extends SceneTree
## UI-FIX-001 narrow regression for the grounded active-NPC presentation path.
## This verifies node/click contracts only; it is not rendered visual acceptance evidence.

const ActiveNpcVisualScript = preload("res://scripts/world/ActiveNpcVisual.gd")
const LocationManagerScript = preload("res://scripts/systems/LocationManager.gd")

var failures: Array[String] = []
var emitted_npc_ids: Array[String] = []


func _init() -> void:
	_verify_walk_sheet()
	_verify_fallback()
	_verify_location_manager_integration()
	if failures.is_empty():
		print("[PASS] active NPC visual + LocationManager integration contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _verify_walk_sheet() -> void:
	var visual = ActiveNpcVisualScript.new()
	root.add_child(visual)
	visual.configure(
		"res://assets/characters/sprites/prototype/xiaoyu_walk_candidate.png",
		"",
		420.0,
		Color(1.0, 0.88, 0.73, 1.0)
	)
	var body := visual.get_node_or_null("NpcBody")
	var shadow := visual.get_node_or_null("NpcShadow")
	_expect(body is AnimatedSprite2D, "xiaoyu walk sheet should create AnimatedSprite2D")
	_expect(shadow is Sprite2D, "grounded NPC should include a shadow")
	_expect(visual.has_walk_animation(), "walk-capable sheet should report animation support")
	if body is AnimatedSprite2D:
		var animated := body as AnimatedSprite2D
		for animation in ["walk_down", "walk_left", "walk_right", "walk_up"]:
			_expect(animated.sprite_frames.has_animation(animation), "missing %s animation" % animation)
			if animated.sprite_frames.has_animation(animation):
				_expect(animated.sprite_frames.get_frame_count(animation) == 4, "%s should have four frames" % animation)
		_expect(animated.offset.y < 0.0, "animated body must anchor above the foot origin")
		visual.play_walk(Vector2.RIGHT)
		_expect(animated.animation == &"walk_right", "walk direction should select the matching animation")
		_expect(animated.is_playing(), "walk-capable body should be able to play its walk animation")
		visual.play_idle_facing_down()
		_expect(animated.animation == &"walk_down" and animated.frame == 0 and not animated.is_playing(), "idle reset should stop on the grounded down-facing frame")
	_expect(shadow.position.y >= 0.0 if shadow is Sprite2D else false, "shadow should sit at/below foot contact")
	visual.queue_free()


func _verify_fallback() -> void:
	var visual = ActiveNpcVisualScript.new()
	root.add_child(visual)
	visual.configure(
		"",
		"res://assets/sprites/npc_laozhang.png",
		455.0,
		Color(0.69, 0.76, 0.92, 1.0)
	)
	var body := visual.get_node_or_null("NpcBody")
	_expect(body is Sprite2D, "legacy NPC art should retain a Sprite2D fallback")
	_expect(not visual.has_walk_animation(), "fallback art must not claim walk animation")
	if body is Sprite2D:
		_expect((body as Sprite2D).offset.y <= 0.0, "fallback body must anchor above the foot origin")
	visual.queue_free()


func _verify_location_manager_integration() -> void:
	var manager = LocationManagerScript.new()
	root.add_child(manager)
	manager.current_lighting = Color(1.0, 0.88, 0.73, 1.0)
	manager.npc_requested.connect(_on_npc_requested)

	var foot := Vector2(760.0, 420.0)
	manager._add_npc_entity("xiaoyu", "小雨", foot, "认识")
	var visual = manager.npc_layer.get_node_or_null("NpcVisual_xiaoyu")
	var button = manager.npc_layer.get_node_or_null("Npc_xiaoyu")
	_expect(visual != null, "LocationManager should create a dedicated grounded visual sibling")
	_expect(visual != null and visual.has_walk_animation(), "active Xiaoyu should use the walk-capable presentation")
	_expect(visual != null and visual.position == foot, "active NPC visual origin should equal configured foot coordinate")
	_expect(visual != null and visual.z_index == int(foot.y), "active NPC depth should derive from foot y")
	_expect(button is Button, "active NPC should retain the named click button")
	if button is Button:
		_expect((button as Button).tooltip_text == "与小雨交谈（认识）", "relationship tooltip contract should stay intact")
		(button as Button).pressed.emit()
	_expect(emitted_npc_ids == ["xiaoyu"], "pressing active NPC should still route npc_requested")

	manager._clear_npcs()
	_expect(manager.npc_layer.get_child_count() == 0, "active NPC cleanup should detach visual and button together")
	manager.queue_free()


func _on_npc_requested(npc_id: String) -> void:
	emitted_npc_ids.append(npc_id)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
