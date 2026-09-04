extends Node2D

const ROOM_RECTS := {
	"bedroom": Rect2(58, 145, 452, 210),
	"living_room": Rect2(58, 410, 452, 210),
	"studio": Rect2(58, 675, 452, 210)
}
const ROOM_LABELS := {"bedroom": "QUARTO", "living_room": "SALA", "studio": "ESTÚDIO"}
const ITEM_PATHS := {
	"CAMA": "res://assets/rooms/bedroom/item_01.png", "CRIADO-MUDO": "res://assets/rooms/bedroom/item_02.png",
	"SOFÁ": "res://assets/rooms/living_room/item_01.png", "LUMINÁRIA": "res://assets/rooms/living_room/item_02.png",
	"MESA": "res://assets/rooms/studio/item_01.png", "ESTANTE": "res://assets/rooms/studio/item_02.png"
}
var rooms: Dictionary = {}
var room_colors: Dictionary = {}

func set_house_data(new_rooms: Dictionary, new_colors: Dictionary) -> void:
	rooms = new_rooms
	room_colors = new_colors
	queue_redraw()

func get_room_rect(room_id: String) -> Rect2: return ROOM_RECTS.get(room_id, Rect2())
func room_center(room_id: String) -> Vector2: return get_room_rect(room_id).get_center()

func room_at(world_position: Vector2) -> String:
	for room_id in ROOM_RECTS:
		if ROOM_RECTS[room_id].has_point(world_position): return room_id
	return ""

func item_at(room_id: String, world_position: Vector2) -> int:
	var items: Array = rooms.get(room_id, [])
	for index in range(items.size() - 1, -1, -1):
		var item: Dictionary = items[index]
		var p := Vector2(float(item.get("x", 0.0)), float(item.get("y", 0.0)))
		if p.distance_to(world_position) <= 52.0: return index
	return -1

func _draw() -> void:
	# Casa-base vertical construída com formas nativas. O shell de arte pode ser
	# colocado por cima mais tarde sem alterar hitboxes, zoom ou salvamento.
	_draw_roof()
	draw_rect(Rect2(34, 118, 652, 795), Color("#f8f0ed"), true)
	draw_rect(Rect2(34, 118, 652, 795), Color("#504750"), false, 6.0)
	for room_id in ROOM_RECTS:
		var rect: Rect2 = ROOM_RECTS[room_id]
		var color := Color.from_string(str(room_colors.get(room_id, "#dddddd")), Color.LIGHT_GRAY)
		_draw_room_shell(rect, color)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(16, 28), ROOM_LABELS[room_id], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#62545f"))
		_draw_room_details(room_id, rect)
		for item in rooms.get(room_id, []): _draw_item(item)
	_draw_stairwell(Rect2(520, 145, 145, 210), false)
	_draw_stairwell(Rect2(520, 410, 145, 210), true)
	_draw_stairwell(Rect2(520, 675, 145, 210), true)
	# Lajes grossas separam os andares e mantêm a leitura em telas pequenas.
	for y in [365.0, 630.0, 895.0]:
		draw_rect(Rect2(42, y, 636, 18), Color("#f8f0ed"), true)
		draw_line(Vector2(42, y), Vector2(678, y), Color("#504750"), 5.0)
	var shell_path := "res://assets/house/house_shell.png"
	if ResourceLoader.exists(shell_path):
		var shell := load(shell_path) as Texture2D
		if shell: draw_texture_rect(shell, Rect2(0,0,720,1000), false, Color.WHITE)
	draw_line(Vector2(34,913), Vector2(686,913), Color("#504750"), 8.0)

func _draw_roof() -> void:
	var roof := PackedVector2Array([
		Vector2(28, 118), Vector2(105, 50), Vector2(615, 50), Vector2(692, 118)
	])
	draw_colored_polygon(roof, Color("#c88798"))
	draw_polyline(PackedVector2Array([Vector2(28,118),Vector2(105,50),Vector2(615,50),Vector2(692,118)]), Color("#504750"), 6.0)
	# Faixas simples sugerem telhas sem exigir uma textura.
	for y in [67.0, 86.0, 104.0]:
		draw_line(Vector2(82 + (y - 67) * 0.8, y), Vector2(638 - (y - 67) * 0.8, y), Color("#e4a8b5"), 5.0)

func _draw_room_shell(rect: Rect2, wall_color: Color) -> void:
	draw_rect(rect, wall_color, true)
	# Parede lateral e piso inclinado criam profundidade sem usar 3D real.
	var side := PackedVector2Array([
		rect.position,
		rect.position + Vector2(18, 16),
		Vector2(rect.position.x + 18, rect.end.y - 30),
		Vector2(rect.position.x, rect.end.y)
	])
	draw_colored_polygon(side, wall_color.darkened(0.16))
	var floor := PackedVector2Array([
		Vector2(rect.position.x, rect.end.y),
		Vector2(rect.position.x + 18, rect.end.y - 30),
		Vector2(rect.end.x - 12, rect.end.y - 30),
		Vector2(rect.end.x, rect.end.y)
	])
	draw_colored_polygon(floor, Color("#d7ae83"))
	draw_polyline(PackedVector2Array([rect.position, Vector2(rect.end.x,rect.position.y), rect.end, Vector2(rect.position.x,rect.end.y), rect.position]), Color("#62545f"), 4.0)

func _draw_stairwell(rect: Rect2, with_stairs: bool) -> void:
	draw_rect(rect, Color("#cfe4e4"), true)
	var side := PackedVector2Array([rect.position, rect.position + Vector2(14,14), Vector2(rect.position.x+14,rect.end.y-28), Vector2(rect.position.x,rect.end.y)])
	draw_colored_polygon(side, Color("#abcaca"))
	var floor := PackedVector2Array([Vector2(rect.position.x,rect.end.y),Vector2(rect.position.x+14,rect.end.y-28),Vector2(rect.end.x-8,rect.end.y-28),rect.end])
	draw_colored_polygon(floor, Color("#d7ae83"))
	draw_rect(rect, Color("#62545f"), false, 4.0)
	_draw_lamp(rect.position + Vector2(rect.size.x - 22, 20))
	if not with_stairs:
		draw_line(rect.position + Vector2(24,145), rect.position + Vector2(122,145), Color("#8d7268"), 5.0)
		for x in range(30, 124, 16): draw_line(rect.position + Vector2(x,145), rect.position + Vector2(x,185), Color("#8d7268"), 2.0)
		return
	var bottom_left := rect.position + Vector2(18, 176)
	var top_right := rect.position + Vector2(125, 52)
	draw_line(bottom_left, top_right, Color("#a87862"), 10.0)
	draw_line(bottom_left + Vector2(0,-9), top_right + Vector2(0,-9), Color("#efd2b5"), 4.0)
	for i in 8:
		var t := float(i) / 7.0
		var p := bottom_left.lerp(top_right, t)
		draw_line(p + Vector2(-5,-2), p + Vector2(14,-2), Color("#8d7268"), 3.0)

func _draw_window(rect: Rect2) -> void:
	draw_rect(rect, Color("#9fd5e0"), true)
	draw_rect(rect, Color("#9a765f"), false, 4.0)
	draw_line(Vector2(rect.get_center().x,rect.position.y), Vector2(rect.get_center().x,rect.end.y), Color("#9a765f"), 3.0)
	draw_line(Vector2(rect.position.x,rect.get_center().y), Vector2(rect.end.x,rect.get_center().y), Color("#9a765f"), 3.0)

func _draw_lamp(center: Vector2) -> void:
	draw_line(center - Vector2(0,16), center, Color("#62545f"), 3.0)
	draw_colored_polygon(PackedVector2Array([center-Vector2(13,0),center+Vector2(13,0),center+Vector2(9,11),center-Vector2(9,-11)]), Color("#d98fa3"))
	draw_circle(center + Vector2(0,13), 5.0, Color("#fff0bd"))

func _draw_room_details(room_id: String, rect: Rect2) -> void:
	var line := Color("#8d7268")
	if room_id == "bedroom":
		_draw_window(Rect2(rect.position + Vector2(280,45), Vector2(118,76)))
		_draw_lamp(rect.position + Vector2(225,22))
	elif room_id == "living_room":
		_draw_window(Rect2(rect.position + Vector2(55,48), Vector2(145,60)))
		_draw_lamp(rect.position + Vector2(388,22))
	else:
		draw_rect(Rect2(rect.position + Vector2(305,38), Vector2(105,118)), Color("#c9b9c6"), true)
		draw_rect(Rect2(rect.position + Vector2(305,38), Vector2(105,118)), line, false, 4)
		for y in [68.0, 98.0, 128.0]: draw_line(rect.position + Vector2(305,y), rect.position + Vector2(410,y), line, 3)

func _draw_item(item: Dictionary) -> void:
	var p := Vector2(float(item.get("x", 0.0)), float(item.get("y", 0.0)))
	var label := str(item.get("asset", "PEÇA"))
	var tint := Color.from_string(str(item.get("color", "#b0b0b0")), Color.LIGHT_GRAY)
	var path := str(ITEM_PATHS.get(label, ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture: draw_texture_rect(texture, Rect2(p - Vector2(64,64), Vector2(128,128)), false, tint)
		return
	draw_rect(Rect2(p - Vector2(44,30), Vector2(88,60)), tint, true)
	draw_rect(Rect2(p - Vector2(44,30), Vector2(88,60)), Color("#555555"), false, 3)
	draw_string(ThemeDB.fallback_font, p + Vector2(-38,5), label, HORIZONTAL_ALIGNMENT_CENTER, 76, 11, Color("#333333"))
