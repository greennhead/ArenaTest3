extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var settingsMenu = preload("res://nodes/menus/settings_menu.tscn")
@onready var mapMenu = preload("res://nodes/menus/mapPicker.tscn")
@onready var mpMenu = preload("res://nodes/menus/lobby.tscn")
@onready var joinMenu = preload("res://nodes/menus/join.tscn")

@onready var credits: Label = $Control/credits
@onready var map_loader: mapLoader = $mapLoader
@onready var camera: Camera3D = $things/Camera3D

func _ready() -> void:
	GameManager.testMap = ""
	map_loader.getMapList()
	map_loader.nextMap()
	if GameManager.mapName != "":
		$Control/version.text += "\n\nShown Map: " + GameManager.getMapData(GameManager.mapName,"name") + " by " + GameManager.getMapData(GameManager.mapName,"author")
	if get_tree().get_nodes_in_group("spawnPoint").size() > 0:
		camera.global_position = get_tree().get_nodes_in_group("spawnPoint").pick_random().global_position
	camera.position.y += 1
	for i in get_tree().get_nodes_in_group("spawnPoint"):
		i.queue_free()
	#GameManager.popup("Info","This is still a beta of the full ARENATEST3 release! Stuff is missing and subject to change.")

func _physics_process(delta: float) -> void:
	camera.fov = Settings.fov
	$Control/modsLoaded.text = str(ModLoader.modsLoaded) + " mods loaded"
	$Control/MarginContainer/Control2/pirate.visible = Settings.bonusLanguages
	camera.rotation.y += 0.0018*2


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
	GameManager.main.add_child(settingsMenu.instantiate())


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
					ppath = path.path_join(file_name).path_join("mode.tres") 
			file_name = dir.get_next()
	if ppath != null:
		GameManager.Players[1] = {
			"name" : Settings.playerName,
			"id" : 1,
			"score" : 0,
			"team" : 0,
			"checksum" : "hello",
		}
		GameManager.testMap = map
		GameManager.main.changeScene(load(ppath).levelScene)

func _on_testmode_pressed() -> void:
	var m = mapMenu.instantiate()
	GameManager.main.add_child(m)
	m.mapPicked.connect(mapPickedTestMode)
	#get_tree().change_scene_to_packed(levelScene)


func _on_host_pressed() -> void:
	var m = mpMenu.instantiate()
	m.hosted = true
	GameManager.main.add_child(m)


func _on_join_pressed() -> void:
	var m = joinMenu.instantiate()
	GameManager.main.add_child(m)


func _on_mods_pressed() -> void:
	print(GameManager.modProfile)
	if GameManager.modProfile != null:
		GameManager.modProfile.show()


func _on_editor_pressed() -> void:
	GameManager.popup("Work in progress","Level editor not avalible in beta version!")


func _on_credits_pressed() -> void:
	credits.visible = !credits.visible
