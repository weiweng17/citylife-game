extends SceneTree
## UI-FIX-001 narrow regression for the active NPC presentation helper.
## This verifies the node contract only; it is not visual acceptance evidence.

const ActiveNpcVisualScript = preload("res://scripts/world/ActiveNpcVisual.gd")

var failures: Array[String] = []


func _init() -> void:
	_verify_walk_sheet()
	_verify_fallback()
	if failures.is_empty():
		print("[PASS] active NPC visual helper contract")
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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
