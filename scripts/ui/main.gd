extends Control

const ROOM_NAMES := ["QUARTO", "SALA", "ESTÚDIO"]
const ROOM_IDS := ["bedroom", "living_room", "studio"]
const ITEM_COLORS := [Color("#f59f9f"), Color("#8fc7b5"), Color("#f2c879"), Color("#b59adf"), Color("#91b9e8")]
const ITEM_NAMES := ["CAMA", "SOFÁ", "PLANTA", "LUMINÁRIA", "PELÚCIA"]

var room_index := 0
var items: Array[Dictionary] = []
var selected_index := -1
var drag_index := -1
var undo_stack: Array = []

@onready var room_canvas: Control = %RoomCanvas
@onready var room_title: Label = %RoomTitle
@onready var status: Label = %Status

func _ready() -> void:
	_load_room()
	_build_catalog()

func _load_room() -> void:
	items.clear()
	for item in SaveService.get_room_items(ROOM_IDS[room_index]):
		items.append(item.duplicate())
	_render_items()
	room_title.text = ROOM_NAMES[room_index]

func _build_catalog() -> void:
	for index in ITEM_NAMES.size():
		var button := Button.new()
		button.text = ITEM_NAMES[index]
		button.custom_minimum_size = Vector2(120, 72)
		button.add_theme_color_override("font_color", Color("#3b2942"))
		button.tooltip_text = "Adicionar " + ITEM_NAMES[index].to_lower()
		button.pressed.connect(_add_item.bind(index))
		%Catalog.add_child(button)

func _add_item(kind: int) -> void:
	_save_undo()
	items.append({"kind": kind, "position": Vector2(360, 470), "rotation": 0.0, "scale": 1.0})
	selected_index = items.size() - 1
	_persist_and_render("Peça adicionada")

func _render_items() -> void:
	for child in room_canvas.get_children():
		child.queue_free()
	for index in items.size():
		var item: Dictionary = items[index]
		var piece := Button.new()
		piece.text = ITEM_NAMES[int(item.kind)]
		piece.position = Vector2(item.position)
		piece.size = Vector2(142, 64)
		piece.rotation = float(item.rotation)
		piece.modulate = ITEM_COLORS[int(item.kind)]
		piece.tooltip_text = "Arraste para mover"
		piece.button_down.connect(_start_drag.bind(index))
		room_canvas.add_child(piece)

func _start_drag(index: int) -> void:
	drag_index = index
	selected_index = index
	_save_undo()

func _gui_input(event: InputEvent) -> void:
	if drag_index < 0:
		return
	if event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		items[drag_index].position = event.position
		_render_items()
	if event is InputEventMouseButton and not event.pressed:
		drag_index = -1
		_persist_and_render("Casa salva")

func _save_undo() -> void:
	undo_stack.append(items.duplicate(true))
	if undo_stack.size() > 10:
		undo_stack.pop_front()

func _on_undo_pressed() -> void:
	if undo_stack.is_empty():
		return
	items = undo_stack.pop_back()
	_persist_and_render("Desfeito")

func _on_room_previous_pressed() -> void:
	room_index = (room_index + ROOM_IDS.size() - 1) % ROOM_IDS.size()
	_load_room()

func _on_room_next_pressed() -> void:
	room_index = (room_index + 1) % ROOM_IDS.size()
	_load_room()

func _persist_and_render(message: String) -> void:
	SaveService.set_room_items(ROOM_IDS[room_index], items)
	status.text = message
	_render_items()
