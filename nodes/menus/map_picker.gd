extends Control
@export var togglerMode := false
#@export var canLoad := false
@export var gamemodeRestriction := ""
@onready var map: Panel = $ScrollContainer/VBoxContainer/map
@onready var vb: VBoxContainer = $ScrollContainer/VBoxContainer
signal mapPicked(gamemode, path)



func pickedMap(gamemode, path):
	mapPicked.emit(gamemode,path)

func _on_close_pressed() -> void:
	queue_free()

func _ready() -> void:
	if !togglerMode:
		$ScrollContainer/VBoxContainer/map/Toggle.hide()
		$ToggleAll.hide()
	getMapList()


func _process(delta: float) -> void:
	global_position = get_viewport_rect().size/2.0 - size/2.0

func getMapList():
	var path = "res://maps/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var config = ConfigFile.new()
				var err = config.load(path + file_name + "/config.cfg")
				print("hi")
				if err == OK:
					if config.get_value("data","gamemode") == gamemodeRestriction || gamemodeRestriction == "":
						var newmap = map.duplicate()
						vb.add_child(newmap)
						newmap.path = path + file_name 
						newmap.gamemode = config.get_value("data","gamemode")
						newmap.preview.texture = load_image(path + file_name + "/preview.png")
						newmap.namelabel.text = config.get_value("data","name")
						newmap.author.text = tr("MENU_Author") + ": " + config.get_value("data","author") + "\n" + tr("MENU_Gamemode") + ": " + config.get_value("data","gamemode").to_pascal_case() 
						newmap.switchto.connect("pressed",pickedMap.bind(newmap.gamemode,newmap.path))
			file_name = dir.get_next()
	map.hide()

func load_image(path: String, blockify : bool = false):
	var image = ResourceLoader.load(path)
	if image == null:
		print_rich("[color=red]Failed loading: " +path)
		return load("res://images/preview.png")
	print_rich("[color=green]Loaded texture: " +path)
	if blockify:
		var img = image.get_image()
		img.resize(320,320,Image.INTERPOLATE_NEAREST)
		return ImageTexture.create_from_image(img)
	return image
