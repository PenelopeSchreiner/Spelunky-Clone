extends PanelContainer

@onready var file_dialog = $"../FileDialog"
@onready var overwrite_dialog = $"../OverwriteConfirm"

@onready var save_btn = $"MarginContainer/VBoxContainer/Save Button"
@onready var load_btn = $"MarginContainer/VBoxContainer/Load Button"
@onready var name_text = $MarginContainer/VBoxContainer/TextEdit
@onready var saved_label = $"../saved label"
@onready var label_timer = $"../label timer"

@onready var template_builder = $"../.."


func check_save_template():
	var filename : String = name_text.text + ".txt"
	if check_if_file_exists(filename) == false:
		save_file(filename)
	else:
		# file exists, so ask to overwrite
		overwrite_dialog.show()

func save_file(filename):
	
	var file = FileAccess.open("user://templates/" + str(template_builder.room_type) +"/" + filename, FileAccess.WRITE)
	file.store_var(template_builder.tiles_dict)
	file.store_var(template_builder.room_type)
	
	saved_label.show()
	label_timer.start()

func load_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	
	var new_t = filename.substr(19, -1)
	new_t = new_t.substr(0, new_t.length() - 4)
	name_text.text = new_t
	
	template_builder.tiles_dict = file.get_var()
	template_builder.update_tiles()
	
	# select room type btn based on loaded room type var
	template_builder.room_type_container.get_child(file.get_var()).grab_focus()


func check_if_file_exists(filename) -> bool:
	return FileAccess.file_exists(filename)


# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open("user://")
	if dir.dir_exists("templates") == false:
		dir.make_dir("templates")
		
		var d2 = DirAccess.open("user://templates")
		
		d2.make_dir("0")
		d2.make_dir("1")
		d2.make_dir("2")
		d2.make_dir("3")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_save_button_pressed():
	check_save_template()


func _on_load_button_pressed():
	file_dialog.show()
	


func _on_overwrite_confirm_confirmed():
	save_file("user://" + name_text.text + ".txt")
	
	saved_label.show()
	label_timer.start()


func _on_label_timer_timeout():
	saved_label.hide()


func _on_file_dialog_file_selected(path):
	load_file(path)
