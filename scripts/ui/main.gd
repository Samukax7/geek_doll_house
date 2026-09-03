extends Node2D

const ROOM_IDS := ["bedroom", "living_room", "studio"]
const ROOM_NAMES := ["QUARTO", "SALA", "ESTÚDIO"]
const ROOM_ITEMS := {
	"bedroom": ["CAMA", "CRIADO-MUDO"],
	"living_room": ["SOFÁ", "LUMINÁRIA"],
	"studio": ["MESA", "ESTANTE"]
}

var active_room := ""
var drag_index := -1
var selected_index := -1
var undo_stack: Array = []
var editing_avatar: Dictionary = {}
var identity_controls: Array[Control] = []

@onready var house: Node2D = $HouseView
@onready var avatar: Node2D = $HouseView/AvatarPlaceholder
@onready var camera: Camera2D = $Camera2D
@onready var room_title: Label = %RoomTitle
@onready var hint: Label = %Hint
@onready var catalog: HBoxContainer = %Catalog
@onready var overview_button: Button = %OverviewButton
@onready var room_color: ColorPickerButton = %RoomColor
@onready var item_color: ColorPickerButton = %ItemColor
@onready var avatar_editor: PanelContainer = %AvatarEditor
@onready var avatar_options: VBoxContainer = %AvatarOptions
@onready var lock_note: Label = %LockNote

func _ready() -> void:
	house.set_house_data(SaveService.data.rooms, SaveService.data.room_colors)
	avatar.apply_recipe(SaveService.get_avatar())
	_build_avatar_editor()
	_show_overview(false)

func _unhandled_input(event: InputEvent) -> void:
	if avatar_editor.visible: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var world_position := get_global_mouse_position()
		if event.pressed:
			if active_room.is_empty():
				var selected_room: String = house.room_at(world_position)
				if not selected_room.is_empty(): _enter_room(selected_room)
			else:
				drag_index = house.item_at(active_room, world_position)
				if drag_index >= 0:
					selected_index = drag_index
					item_color.color = Color.from_string(str(SaveService.data.rooms[active_room][selected_index].get("color", "#b0b0b0")), Color.LIGHT_GRAY)
					_save_undo()
		else:
			if drag_index >= 0: _persist_room("Casa salva")
			drag_index = -1
	elif event is InputEventMouseMotion and drag_index >= 0:
		var room_rect: Rect2 = house.get_room_rect(active_room)
		var p := get_global_mouse_position()
		p.x = clampf(p.x, room_rect.position.x + 28.0, room_rect.end.x - 28.0)
		p.y = clampf(p.y, room_rect.position.y + 28.0, room_rect.end.y - 28.0)
		var items: Array = SaveService.data.rooms[active_room]
		var dragged: Dictionary = items[drag_index]
		dragged["x"] = p.x
		dragged["y"] = p.y
		items[drag_index] = dragged
		house.queue_redraw()

func _enter_room(room_id: String) -> void:
	active_room = room_id
	room_title.text = ROOM_NAMES[ROOM_IDS.find(room_id)]
	hint.text = "Arraste as peças para decorar"
	overview_button.visible = true
	room_color.visible = true
	item_color.visible = true
	room_color.color = SaveService.get_room_color(room_id)
	avatar.position = house.room_center(room_id) + Vector2(0, 70)
	_build_catalog()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", house.room_center(room_id), 0.5)
	tween.tween_property(camera, "zoom", Vector2(1.75, 1.75), 0.5)

func _show_overview(animated := true) -> void:
	active_room = ""
	drag_index = -1
	selected_index = -1
	room_title.text = "TOQUE EM UM CÔMODO"
	hint.text = "A casa inteira é o mapa"
	overview_button.visible = false
	room_color.visible = false
	item_color.visible = false
	_clear_catalog()
	if animated:
		var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camera, "position", Vector2(360, 540), 0.5)
		tween.tween_property(camera, "zoom", Vector2.ONE, 0.5)
	else:
		camera.position = Vector2(360, 540)
		camera.zoom = Vector2.ONE

func _build_catalog() -> void:
	_clear_catalog()
	for item_name in ROOM_ITEMS[active_room]:
		var button := Button.new()
		button.text = item_name
		button.custom_minimum_size = Vector2(190, 64)
		button.pressed.connect(_add_item.bind(item_name))
		catalog.add_child(button)

func _clear_catalog() -> void:
	for child in catalog.get_children(): child.queue_free()

func _add_item(item_name: String) -> void:
	_save_undo()
	var center: Vector2 = house.room_center(active_room)
	var items: Array = SaveService.data.rooms[active_room]
	items.append({"asset": item_name, "x": center.x, "y": center.y, "rotation": 0.0, "scale": 1.0, "color": "#b0b0b0"})
	selected_index = items.size() - 1
	_persist_room("Peça adicionada")

func _save_undo() -> void:
	if active_room.is_empty(): return
	undo_stack.append(SaveService.data.rooms[active_room].duplicate(true))
	if undo_stack.size() > 10: undo_stack.pop_front()

func _on_undo_pressed() -> void:
	if undo_stack.is_empty() or active_room.is_empty(): return
	SaveService.data.rooms[active_room] = undo_stack.pop_back()
	_persist_room("Desfeito")

func _persist_room(message: String) -> void:
	SaveService.set_room_items(active_room, SaveService.data.rooms[active_room])
	house.set_house_data(SaveService.data.rooms, SaveService.data.room_colors)
	hint.text = message

func _on_room_color_color_changed(color: Color) -> void:
	if active_room.is_empty(): return
	SaveService.set_room_color(active_room, color)
	house.set_house_data(SaveService.data.rooms, SaveService.data.room_colors)

func _on_item_color_color_changed(color: Color) -> void:
	if active_room.is_empty() or selected_index < 0: return
	var items: Array = SaveService.data.rooms[active_room]
	var selected: Dictionary = items[selected_index]
	selected["color"] = color.to_html(false)
	items[selected_index] = selected
	_persist_room("Cor da peça alterada")

func _on_avatar_pressed() -> void:
	editing_avatar = SaveService.get_avatar()
	avatar_editor.visible = true
	_refresh_avatar_editor()

func _build_avatar_editor() -> void:
	_add_selector("Cabeça", "head", 3, true)
	_add_selector("Braços", "arms", 3, true)
	_add_selector("Pernas", "legs", 3, true)
	_add_selector("Tronco", "torso", 3, true)
	_add_selector("Olhos", "eyes", 4, true)
	_add_selector("Cabelo", "hair", 3, true)
	_add_category_selector("Tipo superior", "outfit_category", ["blouses", "dresses"], ["Blusa", "Vestido"])
	_add_selector("Modelo superior", "outfit", 3, false)
	_add_category_selector("Tipo inferior", "lower_category", ["pants", "skirts", "shorts"], ["Calça", "Saia", "Short"])
	_add_selector("Parte inferior", "lower", 3, false)
	_add_selector("Sapatos", "shoes", 3, false)
	_add_color("Pele", "skin_color", true)
	_add_color("Olhos", "eye_color", true)
	_add_color("Cabelo", "hair_color", true)
	_add_color("Roupa", "clothing_color", false)

func _add_selector(label_text: String, key: String, count: int, permanent: bool) -> void:
	var row := HBoxContainer.new()
	var label := Label.new(); label.text = label_text; label.custom_minimum_size.x = 210
	var selector := OptionButton.new(); selector.name = "selector_" + key; selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in count: selector.add_item("Opção %d" % (i + 1), i)
	selector.item_selected.connect(_on_avatar_option.bind(key))
	row.add_child(label); row.add_child(selector); avatar_options.add_child(row)
	if permanent: identity_controls.append(selector)

func _add_color(label_text: String, key: String, permanent: bool) -> void:
	var row := HBoxContainer.new()
	var label := Label.new(); label.text = "Cor: " + label_text; label.custom_minimum_size.x = 210
	var picker := ColorPickerButton.new(); picker.name = "color_" + key; picker.custom_minimum_size = Vector2(160, 52)
	picker.color_changed.connect(_on_avatar_color.bind(key))
	row.add_child(label); row.add_child(picker); avatar_options.add_child(row)
	if permanent: identity_controls.append(picker)

func _add_category_selector(label_text: String, key: String, values: Array, labels: Array) -> void:
	var row := HBoxContainer.new()
	var label := Label.new(); label.text = label_text; label.custom_minimum_size.x = 210
	var selector := OptionButton.new(); selector.name = "category_" + key; selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in values.size(): selector.add_item(str(labels[i]), i)
	selector.item_selected.connect(_on_avatar_category.bind(key, values))
	row.add_child(label); row.add_child(selector); avatar_options.add_child(row)

func _refresh_avatar_editor() -> void:
	var locked := SaveService.is_identity_locked()
	lock_note.text = "Identidade definida. Agora você troca roupas e acessórios." if locked else "Escolha com calma: corpo, rosto e cabelo só podem ser definidos uma vez."
	for control in identity_controls: control.disabled = locked
	for key in ["head", "arms", "legs", "torso", "eyes", "hair", "outfit", "lower", "shoes"]:
		var selector := avatar_options.find_child("selector_" + key, true, false) as OptionButton
		if selector: selector.select(int(editing_avatar.get(key, 0)))
	var upper := avatar_options.find_child("category_outfit_category", true, false) as OptionButton
	if upper: upper.select(["blouses", "dresses"].find(str(editing_avatar.get("outfit_category", "blouses"))))
	var lower := avatar_options.find_child("category_lower_category", true, false) as OptionButton
	if lower: lower.select(["pants", "skirts", "shorts"].find(str(editing_avatar.get("lower_category", "skirts"))))
	for key in ["skin_color", "eye_color", "hair_color", "clothing_color"]:
		var picker := avatar_options.find_child("color_" + key, true, false) as ColorPickerButton
		if picker: picker.color = Color.from_string(str(editing_avatar.get(key, "#ffffff")), Color.WHITE)
	%LockIdentity.visible = not locked
	avatar.apply_recipe(editing_avatar)

func _on_avatar_option(index: int, key: String) -> void:
	editing_avatar[key] = index
	avatar.apply_recipe(editing_avatar)

func _on_avatar_category(index: int, key: String, values: Array) -> void:
	editing_avatar[key] = values[index]
	avatar.apply_recipe(editing_avatar)

func _on_avatar_color(color: Color, key: String) -> void:
	editing_avatar[key] = color.to_html(false)
	avatar.apply_recipe(editing_avatar)

func _on_save_outfit_pressed() -> void:
	SaveService.set_avatar(editing_avatar)
	avatar_editor.visible = false
	hint.text = "Visual salvo"

func _on_lock_identity_pressed() -> void:
	SaveService.set_avatar(editing_avatar)
	SaveService.lock_identity()
	_refresh_avatar_editor()

func _on_close_avatar_pressed() -> void:
	editing_avatar = SaveService.get_avatar()
	avatar.apply_recipe(editing_avatar)
	avatar_editor.visible = false
