extends Node

const SAVE_PATH := "user://dollhouse_save.json"
const VERSION := 2
var data: Dictionary = {}

func _ready() -> void:
	data = _default_data()
	load_house()

func _default_data() -> Dictionary:
	return {
		"version": VERSION,
		"rooms": {"bedroom": [], "living_room": [], "studio": []},
		"room_colors": {"bedroom": "#dedede", "living_room": "#c9c9c9", "studio": "#e8e8e8"},
		"identity_locked": false,
		"avatar": {
			"head": 0, "arms": 0, "legs": 0, "torso": 0, "eyes": 0, "hair": 0,
			"skin_color": "#d8b6a4", "eye_color": "#55445f", "hair_color": "#4b3c55",
			"clothing_color": "#b58ac5", "outfit_category": "sets", "outfit": 0,
			"lower_category": "skirts", "lower": 0, "shoes": 0
		}
	}

func save_house() -> void:
	data.version = VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_house() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary: return
	if int(parsed.get("version", 0)) == 1:
		data.rooms = _sanitize_legacy_rooms(parsed.get("rooms", data.rooms))
		save_house()
	elif int(parsed.get("version", 0)) == VERSION:
		data.rooms = parsed.get("rooms", data.rooms)
		data.room_colors = parsed.get("room_colors", data.room_colors)
		data.identity_locked = bool(parsed.get("identity_locked", false))
		var loaded_avatar = parsed.get("avatar", {})
		if loaded_avatar is Dictionary:
			for key in loaded_avatar:
				if data.avatar.has(key): data.avatar[key] = loaded_avatar[key]

func _sanitize_legacy_rooms(legacy: Dictionary) -> Dictionary:
	var clean := {"bedroom": [], "living_room": [], "studio": []}
	for room_id in clean:
		for old_item in legacy.get(room_id, []):
			var raw_position = old_item.get("position", Vector2(360, 500))
			var p: Vector2 = raw_position if raw_position is Vector2 else Vector2(360, 500)
			clean[room_id].append({"asset": "PEÇA", "x": p.x, "y": p.y, "rotation": 0.0, "scale": 1.0})
	return clean

func get_room_items(room_id: String) -> Array: return data.rooms.get(room_id, [])
func set_room_items(room_id: String, items: Array) -> void:
	data.rooms[room_id] = items.duplicate(true); save_house()
func get_room_color(room_id: String) -> Color:
	return Color.from_string(str(data.room_colors.get(room_id, "#dddddd")), Color.LIGHT_GRAY)
func set_room_color(room_id: String, color: Color) -> void:
	data.room_colors[room_id] = color.to_html(false); save_house()
func get_avatar() -> Dictionary: return data.avatar.duplicate(true)
func set_avatar(recipe: Dictionary) -> void:
	data.avatar = recipe.duplicate(true); save_house()
func is_identity_locked() -> bool: return bool(data.identity_locked)
func lock_identity() -> void:
	data.identity_locked = true; save_house()
