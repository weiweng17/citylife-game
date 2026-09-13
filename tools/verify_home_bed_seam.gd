extends SceneTree
## UI-FIX-002 narrow repository/runtime presentation contract check.
## This verifies both the localized feathered foreground asset and the default sleep layering contract.
## It does NOT prove rendered visual acceptance in the real home scene.

const HomeInteractionVisualScript := preload("res://scripts/world/HomeInteractionVisual.gd")
const BLANKET_PATH := "res://assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png"
const EXPECTED_CANVAS := Vector2i(1200, 900)
const MAX_USED_WIDTH := 750
const MAX_USED_HEIGHT := 330
const MAX_FOOTPRINT_RATIO := 0.25
const MAX_VISIBLE_PIXEL_RATIO := 0.16
const MIN_SOFT_ALPHA_RATIO := 0.02
const MIN_EDGE_MARGIN := 8

var failures: Array[String] = []


func _init() -> void:
	var image := Image.new()
	var load_error := image.load(BLANKET_PATH)
	_expect(load_error == OK, "default home bed foreground must load")
	if load_error == OK:
		_verify_local_patch(image)
	_verify_default_layering_contract()

	if failures.is_empty():
		print("[PASS] home bed seam presentation contract")
		quit(0)
	else:
		for failure in failures:
			printerr("[FAIL] %s" % failure)
		quit(1)


func _verify_default_layering_contract() -> void:
	var visual = HomeInteractionVisualScript.new()
	root.add_child(visual)

	_expect(not visual.use_candidate_bed_group, "candidate bed group must stay disabled by default")
	_expect(not visual.use_background_blanket_v2, "background blanket v2 must stay disabled by default")
	_expect(not visual.use_background_blanket_v3, "background blanket v3 A/B mode must stay disabled by default")
	_expect(visual.sleep_sprite != null, "default home sleep pose must exist")
	_expect(visual.blanket_sprite != null, "default home bed foreground must exist")
	_expect(visual.z_label != null, "programmatic sleep Z effect must exist")

	if visual.sleep_sprite != null and visual.blanket_sprite != null:
		_expect(visual.blanket_sprite.texture != null, "default foreground sprite must have a texture")
		if visual.blanket_sprite.texture != null:
			_expect(visual.blanket_sprite.texture.resource_path == BLANKET_PATH, "default foreground must use the cleaned legacy-path asset")
		_expect(visual.sleep_sprite.z_index < visual.blanket_sprite.z_index, "sleep pose must render below the local duvet foreground")
	if visual.blanket_sprite != null and visual.z_label != null:
		_expect(visual.blanket_sprite.z_index < visual.z_label.z_index, "programmatic Z effect must render above the duvet foreground")
	_expect(not visual.visible, "home sleep presentation must remain hidden until begin_sleep")

	root.remove_child(visual)
	visual.free()


func _verify_local_patch(image: Image) -> void:
	var size := Vector2i(image.get_width(), image.get_height())
	_expect(size == EXPECTED_CANVAS, "cleaned foreground canvas must remain 1200x900")

	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	var visible_pixel_count := 0
	var soft_alpha_count := 0

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha <= 0.001:
				continue
			visible_pixel_count += 1
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
			if alpha < 0.95:
				soft_alpha_count += 1

	_expect(max_x >= min_x and max_y >= min_y, "foreground patch must contain visible pixels")
	if max_x < min_x or max_y < min_y:
		return

	var used := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	_expect(used.position.x >= 450, "foreground patch shifted too far left from baked v3 alignment")
	_expect(used.position.y <= 40, "foreground patch shifted too far down from baked v3 alignment")
	_expect(used.size.x <= MAX_USED_WIDTH, "foreground width is too large for a local waist/leg occluder")
	_expect(used.size.y <= MAX_USED_HEIGHT, "foreground height is too large for a local waist/leg occluder")

	var canvas_pixels := image.get_width() * image.get_height()
	var footprint_ratio := float(used.size.x * used.size.y) / float(canvas_pixels)
	var visible_ratio := float(visible_pixel_count) / float(canvas_pixels)
	var soft_alpha_ratio := float(soft_alpha_count) / float(maxi(visible_pixel_count, 1))
	_expect(footprint_ratio < MAX_FOOTPRINT_RATIO, "foreground footprint is too large; do not restore a whole-bed overlay")
	_expect(visible_ratio < MAX_VISIBLE_PIXEL_RATIO, "foreground contains too many visible pixels for a localized waist/leg patch")
	_expect(soft_alpha_ratio >= MIN_SOFT_ALPHA_RATIO, "foreground seam needs a meaningful feathered-alpha edge, not only isolated soft pixels")

	# A localized foreground should have transparent breathing room on all canvas edges.
	# Touching an edge usually means the baked patch was clipped or enlarged accidentally.
	_expect(used.position.x >= MIN_EDGE_MARGIN, "foreground patch touches/clips the left canvas edge")
	_expect(used.position.y >= MIN_EDGE_MARGIN, "foreground patch touches/clips the top canvas edge")
	_expect(used.end.x <= image.get_width() - MIN_EDGE_MARGIN, "foreground patch touches/clips the right canvas edge")
	_expect(used.end.y <= image.get_height() - MIN_EDGE_MARGIN, "foreground patch touches/clips the bottom canvas edge")

	print("Bed seam used rect: %s; footprint: %.4f; visible: %.4f; soft-alpha: %.4f" % [
		used,
		footprint_ratio,
		visible_ratio,
		soft_alpha_ratio,
	])


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
