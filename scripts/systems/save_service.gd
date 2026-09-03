extends Node

const SAVE_PATH := "user://dollhouse_save.json"
const VERSION := 1

var rooms: Dictionary = {"bedroom": [], "living_room": [], "studio": []}

func _ready() -> void:
	load_house()

func save_house() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": VERSION, "rooms": rooms}))

func load_house() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.get("version", 0) == VERSION:
		rooms = parsed.get("rooms", rooms)

func get_room_items(room_id: String) -> Array:
	return rooms.get(room_id, [])

func set_room_items(room_id: String, items: Array) -> void:
	rooms[room_id] = items
	save_house()
