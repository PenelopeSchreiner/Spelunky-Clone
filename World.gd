extends Node2D


@onready var room_h = $Rooms
@onready var map = $TileMap
@onready var unit_manager = $Units

# -- prefabs
var room_prefab = preload("res://room.tscn")

# -- noise
#var noise := FastNoiseLite.new()
# --

var data := WorldData.new()

var world_astar = AStar2D.new()


func regenerate_room(_room_pos, _type) -> void:
	if data.room_grid.has(_room_pos) == true:
		data.room_grid[_room_pos].generate(_room_pos, _type)
		update_tiles_in_room(data.room_grid[_room_pos])

func build_solution_path() -> void:
	
	var room_path := []
	var rolls := []
	
	
	var start_pos := Vector2i(randi_range(0, data.world_size.x - 1), data.world_size.y - 1)
	var cur_pos := start_pos
	var last_room_type := 1
	var upCounter := 0
	
	var dirs = [Vector2i(-1, 0), # left
				Vector2i(1, 0),  # right
				Vector2i(0, -1), # up
				Vector2i(0, 1)] # down
	
	# generate start room
	spawn_room(start_pos, randi_range(1, 4), true)
	room_path.append(start_pos)
	
	while true:
		
		# -- room ids
		# 0 - not on path
		# 1 - left/right exits
		# 2 - left/right/top exits
		# 3 - left/right/bot exits
		# 4 - all exits
		
		# get next position
		var num := randi_range(1, 5)
		var next_room : Vector2i	# where the next room to spawn is
		var next_room_type := 1		# what kind of room it is
		var is_going_up := false
		
		rolls.append(num)
		
		if num < 3:
			# -- going left
			#print("-left")
			
			# -- if going out of bounds, instead go up
			if cur_pos.x + dirs[0].x < 0:
				continue
				#next_room = cur_pos + dirs[2]
				#next_room_type = 3
				
				#is_going_up = true
			else:
				upCounter = 0
				
				next_room = cur_pos + dirs[0]
				next_room_type = randi_range(1, 4)
		elif num < 5:
			# -- going right
			#print("-right")
			
			if cur_pos.x + dirs[1].x > data.world_size.x - 1:
				continue
				#next_room = cur_pos + dirs[2]
				#next_room_type = 3
				
				#is_going_up = true
			else:
				upCounter = 0
				
				next_room = cur_pos + dirs[1]
				next_room_type = randi_range(1, 4)
		else:
			# -- going up
			#print("-up")
			upCounter += 1
			#print(upCounter)
			
			#print(" -- cur_pos: " + str(cur_pos))
			
			is_going_up = true
		
		if is_going_up == true:
			if cur_pos.y == 0:
				# can't go up, so this is the level exit
				data.room_grid[cur_pos].add_level_exit()
				break
			else:
				# - move up a floor
				
				if upCounter >= 2:
					# change the previous room to a type 4
					var old_room_type : int = 4
					data.room_grid[cur_pos].generate(cur_pos, old_room_type, false)
					#print(" -- prev room: " + str(cur_pos))
					#print(" -- new type for prev room: " + str(old_room_type))
				else:
					# change the previous room to a type 3 or 4
					var arr := [2, 4]
					var old_room_type : int = arr[randi_range(0, 1)]
					data.room_grid[cur_pos].generate(cur_pos, old_room_type, false)
					#print(" -- prev room: " + str(cur_pos))
					#print(" -- new type for prev room: " + str(old_room_type))
				
				next_room = cur_pos + dirs[2]
				next_room_type = randi_range(3, 4)
				#print(" -- next up room pos: " + str(next_room))
				#print("next room type for an up room: " + str(next_room_type))
					
					#data.room_grid[cur_pos].add_side_exit(Vector2i(0, 1))
		
		room_path.append(next_room)
		
		# - spawn next room
		if data.room_grid.has(next_room) == false:
			spawn_room(next_room, next_room_type, false)
			
#			if last_room_type == 2: # or 3?
#				# last room was had a top exit
#				# add bot exit to this room
#				data.room_grid[next_room].add_side_exit(Vector2i(0, -1))
		
		
		# - update cur pos
		cur_pos = next_room
		
		# - update last room type
		last_room_type = next_room_type
	
	#print(room_path)
	#print(rolls)
	
	# -- add temp start door
	data.room_grid[start_pos].add_level_exit()
	update_tiles_in_room(data.room_grid[cur_pos])
	

func fill_rest_of_map() -> void:
	# fill the rest of the map with 0 rooms
	for x in data.world_size.x:
		for y in range(data.world_size.y - 1, -1, -1):
			if data.room_grid.has(Vector2i(x, y)) == false:
				spawn_room(Vector2i(x, y), 0, false)


func make_outer_wall() -> void:
	# add outline wall
	for x in range(-1, data.world_size.x * data.room_size.x + 1, 1):
		map.set_cell(0, Vector2i(x, -1), 0, Vector2i(4, 0))
		map.set_cell(0, Vector2i(x, data.world_size.y * data.room_size.y), 0, Vector2i(4, 0))
	
	for y in range(-1, data.world_size.y * data.room_size.y + 1, 1):
		map.set_cell(0, Vector2i(-1, y), 0, Vector2i(4, 0))
		map.set_cell(0, Vector2i(data.world_size.x * data.room_size.x, y), 0, Vector2i(4, 0))


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	#noise.seed = randi()
	#noise.frequency = 0.1
	
	
	# -- debug
	#set_debug_grid_tiles()
	# --
	
	# -- preinit
	room_h.initialize()
	
	# -- init
	initialize()
	# --
	
	# -- update display
	for i in data.room_grid:
		update_tiles_in_room(data.room_grid[i])
	
	# -- spawn test player
	var starting_room = get_starting_room()
	
	while starting_room == null:
		initialize()
		
		starting_room = get_starting_room()
	
	if starting_room != null:
		
		# -- update rooms individually
		for i in data.room_grid:
			update_tiles_in_room(data.room_grid[i])
		
		# -- update terrain sets
		update_terrain_set_tiles(1)
		
		# get the pos of the startind door in the starting room
		unit_manager.spawn_player(starting_room.data.grid_pos * data.tile_size * data.room_size + starting_room.data.start_door_pos * data.tile_size) # room position + starting door position in room
		#unit_manager.spawn_player(Vector2(0, 0))
		


func _draw():
	
	for x in data.world_size.x:
		for y in data.world_size.y:
			if world_astar.has_point(calculate_point_index(x, y)) == true:
				draw_circle(Vector2i(x, -y) * data.room_size * 16, 5, Color(1, 0, world_astar.get_point_weight_scale(calculate_point_index(x, y)), 1))
				
				# draw line to connected neighbors
				var neighbors = get_neighboring_rooms(Vector2i(x, y))
				
				for n in neighbors:
					if world_astar.are_points_connected(calculate_point_index(x, y), calculate_point_index(n.x, n.y)) == true:
						draw_line(Vector2i(x, -y) * data.room_size * 16, Vector2i(n.x, -n.y) * data.room_size * 16, Color(1, 0, 0, 1), 1.0)


func initialize() -> void:
	
	# clear tiles
	clear_all_tiles()
	
	# clear room grid and objs
	for i in data.room_grid:
		data.room_grid[i].queue_free()
	
	data.room_grid.clear()
	
	fill_backwall()
	
	build_solution_path()
	fill_rest_of_map()
	make_outer_wall()


func spawn_room(_pos : Vector2i, _roomType : int, is_start : bool) -> void:
	var r = room_prefab.instantiate()
	room_h.add_child(r)
	r.generate(_pos, _roomType, is_start)
	
	#print(_pos)
	#print(is_start)
	
	#print("spawning room at: " + str(_pos))

func get_starting_room():
	var dict := {}
	
	for x in data.world_size.x:
		for y in data.world_size.y:
			
			#print(Vector2i(x, y))
			#print(data.room_grid[Vector2i(x, y)].data.is_start)
			dict[Vector2i(x, y)] = data.room_grid[Vector2i(x, y)].data.is_start
	
	#print(dict)
	
	for i in dict:
		if dict[i] == true:
			return data.room_grid[i]
	
	print("-- NO START ROOM FOUND --")
	return null


func clear_all_tiles() -> void:
	for x in data.world_size.x * data.room_size.x:
		for y in data.world_size.y * data.room_size.y:
			map.set_cell(0, Vector2i(x, y))
			map.set_cell(1, Vector2i(x, y))


func fill_backwall() -> void:
	for x in data.world_size.x * data.room_size.x:
		for y in data.world_size.y * data.room_size.y:
			map.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 4))


func update_tiles_in_room(_room):
	
	# read room data and change tiles
	for pos in _room.data.grid.keys():
		# get tile pos
		var tile_pos = _room.data.grid_pos * data.room_size + pos
		
		var temp_tile_id = _room.data.grid[pos]
		#var arr := []
		
		if temp_tile_id == 0:
			# -- backwall
			map.set_cell(0, tile_pos, 1, Vector2i(0, 4))
			
			# !!! change the template builder to be blank with a grid
			# and allows using id 0 for a different block
			
		elif temp_tile_id == 1:
			# -- walls
			map.set_cell(1, tile_pos, 1, Vector2i(3, 3))
		elif temp_tile_id == 2:
			# -- backwall
			#map.set_cell(0, tile_pos, 1, Vector2i(0, 4))
			# -- wood platform
			map.set_cell(1, tile_pos, 2, Vector2i(2, 0))
		elif temp_tile_id == 3:
			# -- backwall
			#map.set_cell(0, tile_pos, 1, Vector2i(0, 4))
			# -- ladder top
			# platform
			map.set_cell(1, tile_pos, 2, Vector2i(2, 0))
			# ladder
			map.set_cell(2, tile_pos, 2, Vector2i(1, 0))
		elif temp_tile_id == 4:
			# -- backwall
			#map.set_cell(0, tile_pos, 1, Vector2i(0, 4))
			# -- door
			map.set_cell(1, tile_pos, 2, Vector2i(0, 0))
		elif temp_tile_id == 5:
			# -- ladder
			map.set_cell(2, tile_pos, 2, Vector2i(1, 0))
		
		#if arr.size() > 0:
			#map.set_cells_terrain_connect(0, arr, 0, 0)
			#map.set_cells_terrain_path(0, arr, 0, 0)


func update_terrain_set_tiles(terrain_source_id : int):
	
	var arr := []
	
	for y in data.world_size.y * data.room_size.y:
		for x in data.world_size.x * data.room_size.x:
			var cell := Vector2i(x, y)
			
			# -- make sure that it's only checking tiles with the terrain_source_id
			if map.get_cell_source_id(0, cell) == terrain_source_id:
				if map.get_cell_atlas_coords(0, cell) != Vector2i(0, 4):
					# make sure this isn't a backwall tile
					arr.append(cell)
	
	map.set_cells_terrain_connect(0, arr, 0, 0)


func set_debug_grid_tiles():
	var step := 10
	
	for x in range(data.world_size.x):
		for y in range(data.world_size.y):
			map.set_cell(2, Vector2i(x * step, y * step), 0, Vector2i(2, 0))


func get_neighboring_rooms(room_pos : Vector2i) -> Array:
	var arr := []
	
	var dirs = [Vector2i(-1, 0), # left
				Vector2i(1, 0),  # right
				Vector2i(0, 1), # up
				Vector2i(0, -1)] # down
	
	for d in dirs:
		if within_bounds_of_world_grid(room_pos + d) == true:
			arr.append(room_pos + d)
	
	return arr

func within_bounds_of_world_grid(point : Vector2i) -> bool:
	if point.x >= 0 and point.x < data.world_size.x and point.y >= 0 and point.y < data.world_size.y:
		return true
	
	return false


func calculate_point_index(x, y) -> int:
	return x + data.world_size.x * y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
