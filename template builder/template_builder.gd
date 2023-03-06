extends Node2D

@onready var map = $TileMap

# -- ui
@onready var tile_pos_label = $"CanvasLayer/Tile Pos Label"
@onready var button_container = $"CanvasLayer/Tile Selector/PanelContainer/MarginContainer/GridContainer"
@onready var room_type_container = $"CanvasLayer/SaveLoad/MarginContainer/VBoxContainer/room_type container"
# --

# -- prefabs
var tile_btn_prefab = preload("res://tile_button.tscn")
# --

# -- atlas texture
var template_atlas = load("res://template builder/template tiles.png")

# load room size from template settings resource
var room_size := Vector2i(10, 10)

# -- flags
var is_mouse_held_down := false


# --- saved
var selected_tile := -1
var tile_to_atlas := {}

var room_type := 0
var tiles_dict := {}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	initialize()
	set_up_tile_buttons()
	
	# set tile button indices
	var ind := 0
	for child in button_container.get_children():
		
		child.index = ind
		child.get_child(0).pressed.connect(select_tile.bind(ind))
		
		ind += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var tile_pos = get_tile_under_cursor()
	
	if within_bounds(tile_pos):
		if tile_pos_label.visible == false:
			tile_pos_label.show()
		tile_pos_label.text = "Tile Pos: " + str(tile_pos)
		
		clear_hover_tiles()
		map.set_cell(1, tile_pos, 0, Vector2i(7, 7))
	else:
		tile_pos_label.hide()
		clear_hover_tiles()
	
	if is_mouse_held_down:
		change_tile(get_tile_under_cursor())


func initialize():
	for x in room_size.x:
		for y in room_size.y:
			tiles_dict[Vector2i(x, y)] = 0
	
	for x in room_size.x:
		for y in room_size.y:
			map.set_cell(0, Vector2i(x, y), 0, Vector2i(tiles_dict[Vector2i(x, y)], 0))
	
	var ind := 0
	for i in room_type_container.get_children():
		i.get_child(0).pressed.connect(choose_room_type.bind(ind))
		
		ind += 1

func choose_room_type(type):
	room_type = type

func set_up_tile_buttons():
	var tile_source = map.tile_set.get_source(0)
	var tile_count = tile_source.get_tiles_count()
	
	for t in tile_count:
		var tile_coord = tile_source.get_tile_id(t)
		
		if tile_coord != Vector2i(7, 7):
			# add to tile_to_atlas dict
			tile_to_atlas[t] = tile_coord
			
			# create new tile button and add to button container
			var tb = tile_btn_prefab.instantiate()
			button_container.add_child(tb)
			
			var atlas = AtlasTexture.new()
			atlas.atlas = template_atlas
			atlas.region = Rect2(tile_coord * map.tile_set.tile_size, map.tile_set.tile_size)
			
			tb.initialize(atlas)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_mouse_held_down = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			is_mouse_held_down = false

func change_tile(tile_pos) -> void:
	if selected_tile > -1 and within_bounds(tile_pos):
		map.set_cell(0, tile_pos, 0, tile_to_atlas[selected_tile])
		
		#print(selected_tile)
		# update tiles_dict
		tiles_dict[tile_pos] = selected_tile

func update_tiles() -> void:
	for x in room_size.x:
		for y in room_size.y:
			map.set_cell(0, Vector2i(x, y), 0, tile_to_atlas[tiles_dict[Vector2i(x, y)]])

func select_tile(tile):
	selected_tile = tile

func clear_hover_tiles() -> void:
	for x in room_size.x:
		for y in room_size.y:
			map.set_cell(1, Vector2i(x, y))

func clear_map() -> void:
	for x in room_size.x:
		for y in room_size.y:
			map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# reset tiles_dict
			tiles_dict[Vector2i(x, y)] = 0

func get_tile_under_cursor() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	
	return map.local_to_map(mouse_pos)

func within_bounds(tile_pos) -> bool:
	return tile_pos.x >= 0 and tile_pos.x < room_size.x and tile_pos.y >= 0 and tile_pos.y < room_size.y


func _on_clear_button_pressed():
	clear_map()
