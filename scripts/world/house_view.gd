extends Node2D

const ROOM_RECTS := {
	"bedroom": Rect2(60, 120, 600, 245),
	"living_room": Rect2(60, 395, 600, 245),
	"studio": Rect2(60, 670, 600, 245)
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
	# Fallback cinza. Depois, house_shell.png pode ser desenhada sobre estas áreas.
	draw_polygon(PackedVector2Array([Vector2(35,120),Vector2(360,35),Vector2(685,120)]), PackedColorArray([Color("#777777")]))
	draw_rect(Rect2(40, 105, 640, 835), Color("#eeeeee"), true)
	for room_id in ROOM_RECTS:
		var rect: Rect2 = ROOM_RECTS[room_id]
		var color := Color.from_string(str(room_colors.get(room_id, "#dddddd")), Color.LIGHT_GRAY)
		draw_rect(rect, color, true)
		draw_rect(rect, Color("#555555"), false, 6.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 32), ROOM_LABELS[room_id], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#555555"))
		_draw_room_details(room_id, rect)
		for item in rooms.get(room_id, []): _draw_item(item)
	var shell_path := "res://assets/house/house_shell.png"
	if ResourceLoader.exists(shell_path):
		var shell := load(shell_path) as Texture2D
		if shell: draw_texture_rect(shell, Rect2(0,0,720,1000), false, Color.WHITE)
	draw_line(Vector2(40,940), Vector2(680,940), Color("#444444"), 10.0)

func _draw_room_details(room_id: String, rect: Rect2) -> void:
	var line := Color("#888888")
	if room_id == "bedroom":
		draw_rect(Rect2(rect.position + Vector2(365,70), Vector2(175,105)), Color("#bdbdbd"), true)
		draw_rect(Rect2(rect.position + Vector2(365,70), Vector2(175,105)), line, false, 4)
	elif room_id == "living_room":
		draw_rect(Rect2(rect.position + Vector2(70,100), Vector2(230,85)), Color("#b5b5b5"), true)
		draw_line(rect.position + Vector2(185,100), rect.position + Vector2(185,185), line, 3)
	else:
		draw_rect(Rect2(rect.position + Vector2(390,45), Vector2(130,150)), Color("#c3c3c3"), true)
		for y in [85.0, 125.0, 165.0]: draw_line(rect.position + Vector2(390,y), rect.position + Vector2(520,y), line, 3)

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
