extends MenuWindow

func restart():
	get_tree().quit() 
	var exec_path := OS.get_executable_path()
	var err := OS.execute(exec_path,[])

@onready var vb: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var mod: Panel = $ScrollContainer/VBoxContainer/mod

func _on_restart_pressed() -> void:
	Settings.enabledMods = []
	for i in vb.get_children():
		Settings.enabledMods.append(i.modname)
	Settings.saveSettings()
	restart()

func load_image(path: String, blockify : bool = false):
	var image = Image.load_from_file(path)
	if image == null:
		print_rich("[color=red]Failed loading: " +path)
		return load("res://images/preview.png")
	print_rich("[color=green]Loaded texture: " +path)
	return ImageTexture.create_from_image(image)

func _ready() -> void:
	super()
	var mapList = []
	var path = Settings.modsPath  + "/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var config = ConfigFile.new()
				var err = config.load(path + file_name + "/mod.cfg")
				if err == OK:
					if config.get_value("data","name") != null && FileAccess.file_exists(path + file_name + "/mod.pck"):
						var newmap = mod.duplicate()
						if Settings.enabledMods.has(config.get_value("data","name")):
							newmap.originallyToggled = true
						vb.add_child(newmap)
						if Settings.enabledMods.has(config.get_value("data","name")):
							if config.get_value("data","settingsPath") != "":
								newmap.settings.show()
						newmap.path = path + file_name 
						newmap.preview.texture = load_image(path + file_name + "/icon.png")
						newmap.namelabel.text = config.get_value("data","name") + " (" + config.get_value("data","version") + ")"
						newmap.author.text = tr("MENU_Author") + ": " + config.get_value("data","author") + "\n" + config.get_value("data","description")
						newmap.show()
						newmap.modname = config.get_value("data","name")
						newmap.name = config.get_value("data","name") + config.get_value("data","author") 
			file_name = dir.get_next()

func _on_close_pressed() -> void:
	queue_free()


func _on_dir_open_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
