extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var settingsMenu = preload("res://nodes/menus/settings_menu.tscn")
@onready var mapMenu = preload("res://nodes/menus/mapPicker.tscn")
@export var levelScene : PackedScene

func _ready() -> void:
	GameManager.testMap = ""

func _physics_process(delta: float) -> void:
	$Control/MarginContainer/Control2/pirate.visible = Settings.bonusLanguages
	world_environment.environment.sky_rotation.y += 0.0018*2


func _on_us_pressed() -> void:
	TranslationServer.set_locale("us")
	Settings.saveSettings()


func _on_ru_pressed() -> void:
	TranslationServer.set_locale("ru")
	Settings.saveSettings()


func _on_pl_pressed() -> void:
	TranslationServer.set_locale("pl")
	Settings.saveSettings()


func _on_pirate_pressed() -> void:
	TranslationServer.set_locale("pirate")
	Settings.saveSettings()


func _on_settings_pressed() -> void:
	add_child(settingsMenu.instantiate())


func _on_quit_pressed() -> void:
	get_tree().quit()



func mapPickedTestMode(gamemode,map):
	var path = "res://modes/"
	var ppath
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print(file_name)
			if dir.current_is_dir():
				if file_name == gamemode:
					ppath = path + file_name + "/mode.tres"
			file_name = dir.get_next()
	if ppath != null:
		GameManager.testMap = map
		print(map)
		get_tree().change_scene_to_file(load(ppath).levelScene)

func _on_testmode_pressed() -> void:
	var m = mapMenu.instantiate()
	add_child(m)
	m.mapPicked.connect(mapPickedTestMode)
	#get_tree().change_scene_to_packed(levelScene)
