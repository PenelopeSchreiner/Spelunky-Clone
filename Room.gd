extends Node2D

var world

var data := RoomData.new()


func get_random_template_of_type(type) -> RoomTemplate:
	if world.room_h.room_templates.has(type) == true:
		var templates : Array = world.room_h.get_room_templates_of_type(type)
		if templates.size() > 0:
			var ran = randi_range(0, templates.size() - 1)
			return templates[ran]
	
	return RoomTemplate.new()

func fill_room_with_template(template : RoomTemplate) -> void:
	
	#print(template.type)
	#print(template.data)
	
	if template.type >= 0:
		for x in range(world.data.room_size.x):
			for y in range(world.data.room_size.y):
				var pos = Vector2i(x, y)
				
				data.grid[pos] = template.data[pos]

# Called when the node enters the scene tree for the first time.
func generate(_gridPos : Vector2i, _roomType : int, is_start : bool):
	
	if world == null:
		world = get_tree().get_nodes_in_group("World")[0]
	
	data.size = world.data.room_size
	data.grid_pos = _gridPos
	data.room_type = _roomType
	data.is_start = is_start
	#print(data.is_start)
	
	if _roomType == 0:
		# not on path
		# -- load a random template for a '0' room
		var template = get_random_template_of_type(0)
		fill_room_with_template(template)
	elif _roomType == 1:
		# left/right exits
		var template = get_random_template_of_type(1)
		fill_room_with_template(template)
	elif _roomType == 2:
		# left/right/top exits
		var template = get_random_template_of_type(2)
		fill_room_with_template(template)
	elif _roomType == 3:
		# left/right/bot exits
		var template = get_random_template_of_type(3)
		fill_room_with_template(template)
	elif _roomType == 4:
		# L/R/T/B exits
		var template = get_random_template_of_type(4)
		fill_room_with_template(template)
	
	
	if is_start == true:
		# set the position of the starting door in the room
		# prefer near the middle of the room
		# -- make a template for room sections
		# -- prefer a placement where the same tiles are kept between the section template and the room template
		# -- loop through the whole room and check each room tile with the section template tile
		# -- add up how many tiles are the same in each position
		# -- place it where the most match up
		
		# -- place the start template in a spot where it doesn't block the solution path
		data.start_door_pos = Vector2i(5, 5)
		# -- or have a set of starting room templates
		print("start room pos: " + str(_gridPos))
		print("is start: " + str(is_start))
		print(" ++ in Room.generate, define how the starting room door is positioned, probably starting room templates ++")
	
	# -- add to room grid
	world.data.room_grid[_gridPos] = self


func add_side_exit(_dir : Vector2i) -> void:
	# clear some tiles from center of room to a specific side
	
	print(" - add side exit")
	
	var start := Vector2i(world.data.room_size.x/2, world.data.room_size.y/2)
	
	if _dir == Vector2i(-1, 0):
		# left
		for x in range(start.x, 0, -1):
			for y in range(start.y - 1, start.y, 1):
				data.grid[Vector2i(x, y)] = 0
	elif _dir == Vector2i(1, 0):
		# right
		for x in range(start.x, world.data.room_size.x, 1):
			for y in range(start.y - 1, start.y, 1):
				data.grid[Vector2i(x, y)] = 0
	elif _dir == Vector2i(0, 1):
		# top
		for x in range(start.x - 1, start.x + 1, 1):
			for y in range(start.y, world.data.room_size.y, 1):
				data.grid[Vector2i(x, y)] = 0
	elif _dir == Vector2i(0, -1):
		# bot
		for x in range(start.x - 1, start.x + 1, 1):
			for y in range(start.y, -1, -1):
				data.grid[Vector2i(x, y)] = 0


func add_level_exit() -> void:
	# exit room
	#if data.is_exit == true:
	data.grid[Vector2i(5, 5)] = 4
	
	#print(" + add level exit")
	
#	if _roomType == "Start":
#		# this is the starting room for the level, put in an open door
#
#		fill_room_with_tile(1)
#
#		data.grid[Vector2i(3, 2)] = 2
#	elif _roomType == "Room":
#
#		fill_room_with_tile(1)
#	elif _roomType == "Exit":
#
#		fill_room_with_tile(1)
#
#		# add exit door
#		data.grid[Vector2i(6, 9)] = 4
		
	# generate a path through this room based on connections to surrounding rooms
	
	
	# generate test room
#	for x in data.size.x:
#		for y in data.size.y:
#			var n = noise.get_noise_2d(x, y)
#
#			var val = 0
#
#			if n > 0.8:
#				val = 2
#			elif n > 0.5:
#				val = 1
#			elif n > 0.25:
#				val = 3
#			else:
#				val = 0
#
#			print(val)
#
#			data.grid[Vector2i(x, y)] = val

func point_to_previous_room(_backDir : Vector2i):
	if _backDir == Vector2i(-1, 0):
		#print("left")
		# left
		data.grid[Vector2i(world.data.room_size.x - 1, world.data.room_size.y/2)] = 3
	elif _backDir == Vector2i(1, 0):
		#print("right")
		# right
		data.grid[Vector2i(0, world.data.room_size.y/2)] = 3
	elif _backDir == Vector2i(0, 1):
		#print("up")
		# right
		data.grid[Vector2i(world.data.room_size.x/2, 0)] = 3
	elif _backDir == Vector2i(0, -1):
		#print("down")
		# right
		data.grid[Vector2i(world.data.room_size.x/2, world.data.room_size.y - 1)] = 3
	
	world.update_tiles_in_room(self)


func fill_room_with_tile(_tile):
	for x in data.size.x:
		for y in data.size.y:
			data.grid[Vector2i(x, y)] = _tile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
