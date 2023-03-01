extends Node2D

var room_templates := {
	0 : [],
	1 : [],
	2 : [],
	3 : [],
	4 : []
}

func get_room_templates_of_type(type) -> Array:
	if room_templates.has(type) == true:
		return room_templates[type]
	else:
		return []


func initialize():
	
	# get all template files for each room type
	
	for type in range(5):
		var dir = DirAccess.open("user://templates/" + str(type))
		if dir:
			dir.list_dir_begin()
			var filename = dir.get_next()
			while filename != "":
				var file = FileAccess.open(dir.get_current_dir() + "/" + filename, FileAccess.READ)
				
				var new_temp = RoomTemplate.new()
				new_temp.type = type
				new_temp.data = file.get_var()
				
				room_templates[type].append(new_temp)
				
				filename = dir.get_next()
