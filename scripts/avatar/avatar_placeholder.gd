extends Node2D

var recipe: Dictionary = {}

func apply_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe.duplicate(true)
	queue_redraw()

func _draw() -> void:
	if recipe.is_empty(): return
	if _draw_custom_recipe(): return
	var skin := Color.from_string(str(recipe.get("skin_color", "#d8b6a4")), Color("#d8b6a4"))
	var hair := Color.from_string(str(recipe.get("hair_color", "#4b3c55")), Color("#4b3c55"))
	var eyes := Color.from_string(str(recipe.get("eye_color", "#55445f")), Color("#55445f"))
	var clothes := Color.from_string(str(recipe.get("clothing_color", "#b58ac5")), Color("#b58ac5"))
	var head_variant := clampi(int(recipe.get("head", 0)), 0, 2)
	var head_size: Vector2 = [Vector2(66,60), Vector2(72,56), Vector2(62,66)][head_variant]
	draw_rect(Rect2(-28,-8,22,55), clothes.darkened(0.12), true)
	draw_rect(Rect2(6,-8,22,55), clothes.darkened(0.12), true)
	draw_circle(Vector2(-17,48), 14, Color("#555555"))
	draw_circle(Vector2(17,48), 14, Color("#555555"))
	draw_rect(Rect2(-38,-75,76,72), clothes, true)
	draw_circle(Vector2(-48,-42), 14, skin)
	draw_circle(Vector2(48,-42), 14, skin)
	_draw_ellipse(Vector2(0,-112), head_size, skin)
	draw_arc(Vector2(0,-123), head_size.x * 0.52, PI, TAU, 24, hair, 18)
	for x in [-18.0,18.0]:
		draw_circle(Vector2(x,-112), 9, Color.WHITE) # esclera
		draw_circle(Vector2(x,-112), 5, eyes) # íris
		draw_circle(Vector2(x,-112), 2.2, Color("#222222")) # pupila
	draw_arc(Vector2(0,-98), 10, 0.15, PI-0.15, 10, Color("#704c55"), 2)

func _draw_custom_recipe() -> bool:
	var head_number := int(recipe.get("head", 0)) + 1
	var arms_number := int(recipe.get("arms", 0)) + 1
	var legs_number := int(recipe.get("legs", 0)) + 1
	var torso_number := int(recipe.get("torso", 0)) + 1
	var eyes_number := int(recipe.get("eyes", 0)) + 1
	var hair_number := int(recipe.get("hair", 0)) + 1
	var core := [
		"res://assets/avatar/heads/head_%02d.png" % head_number,
		"res://assets/avatar/arms/arms_%02d.png" % arms_number,
		"res://assets/avatar/legs/legs_%02d.png" % legs_number,
		"res://assets/avatar/torsos/torso_%02d.png" % torso_number,
		"res://assets/avatar/eyes/eye_%02d/sclera.png" % eyes_number,
		"res://assets/avatar/eyes/eye_%02d/iris.png" % eyes_number,
		"res://assets/avatar/eyes/eye_%02d/pupil.png" % eyes_number,
		"res://assets/avatar/hair/hair_%02d_back.png" % hair_number,
		"res://assets/avatar/hair/hair_%02d_front.png" % hair_number
	]
	for path in core:
		if not ResourceLoader.exists(path): return false
	var skin := Color.from_string(str(recipe.get("skin_color", "#d8b6a4")), Color.WHITE)
	var hair := Color.from_string(str(recipe.get("hair_color", "#4b3c55")), Color.WHITE)
	var eyes := Color.from_string(str(recipe.get("eye_color", "#55445f")), Color.WHITE)
	var clothes := Color.from_string(str(recipe.get("clothing_color", "#b58ac5")), Color.WHITE)
	_draw_part(core[7], hair)
	_draw_part(core[2], skin)
	_draw_part(core[3], skin)
	_draw_part(core[1], skin)
	_draw_part(core[0], skin)
	_draw_part(core[4], Color.WHITE)
	_draw_part(core[5], eyes)
	_draw_part(core[6], Color("#222222"))
	var outfit_category := str(recipe.get("outfit_category", "blouses"))
	var outfit_path := "res://assets/avatar/clothing/%s/%s_%02d.png" % [outfit_category, _file_stem(outfit_category), int(recipe.get("outfit", 0)) + 1]
	if ResourceLoader.exists(outfit_path): _draw_part(outfit_path, clothes)
	if outfit_category != "dresses":
		var lower_category := str(recipe.get("lower_category", "skirts"))
		var lower_path := "res://assets/avatar/clothing/%s/%s_%02d.png" % [lower_category, _file_stem(lower_category), int(recipe.get("lower", 0)) + 1]
		if ResourceLoader.exists(lower_path): _draw_part(lower_path, clothes)
	var shoes_path := "res://assets/avatar/clothing/shoes/shoe_%02d.png" % (int(recipe.get("shoes", 0)) + 1)
	if ResourceLoader.exists(shoes_path): _draw_part(shoes_path, clothes.darkened(0.2))
	_draw_part(core[8], hair)
	return true

func _draw_part(path: String, tint: Color) -> void:
	var texture := load(path) as Texture2D
	if texture: draw_texture_rect(texture, Rect2(-128, -256, 256, 256), false, tint)

func _file_stem(category: String) -> String:
	return {"blouses":"blouse", "dresses":"dress", "pants":"pant", "skirts":"skirt", "shorts":"short"}.get(category, category)

func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 32:
		var angle := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_polygon(points, PackedColorArray([color]))
