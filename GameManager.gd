extends Node
signal messageSent(message : String)
var scene
var main : Main
var godotPath = !false
var mapName := ""
var gmName := "deathmatch"
var mappath := ""
var Players={}
var myPlayer = null
var debug := false
var tree
var oldmappath 
var preloadskin := ""
var globalMaplist := []
var trackNum := true
var num := 0:
	set(value):
		num = value
		print_rich("[color=pink]Num just set to " + str(value))
var mapnum := -1
var level 
var customObjects : Array[mapObject]
var testMap := ""
const modsPath := "user://mods/" 
var myName := ""
var mods = []
var address = "localhost"
var enabledMaps = []
var customGMProperties = {}
@onready var errorWindow = preload("uid://bp8lkc3ukjnna")
func _ready() -> void:
	var path = "res://objects/"
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with(".tres"): 
			print_rich("[color=green]Loaded custom object: "+ res) 
			customObjects.append(load(path+res))
	addModeNodes()
func _init() -> void:
	Settings.loadSettings()
	loadMods()

func addModeNodes():
	for i in Settings.enabledMods:
		var path = Settings.modsPath + "/"
		var config = ConfigFile.new()
		var err = config.load(path + i + "/mod.cfg")
		if err == OK:
			if config.get_value("data","modNode") != "":
				var modNode = load(config.get_value("data","modNode")).instantiate()
				add_child(modNode)

func loadMods():
	for i in Settings.enabledMods:
		var path = Settings.modsPath + "/"
		var config = ConfigFile.new()
		var err = config.load(path + i + "/mod.cfg")
		if err == OK:
			var success = false
			if config.get_value("data","overwrite") == 0:
				success = ProjectSettings.load_resource_pack(path + i + "/mod.pck",false)
			else:
				success = ProjectSettings.load_resource_pack(path + i + "/mod.pck",true)
			if success:
				print_rich("[b][color=green]Mod loaded: " + path + i + "/mod.pck")
				if config.get_value("data","overwrite") != 0:
					print_rich("[b][color=green]" + i + " can overwrite files")
				else:
					print_rich("[b][color=red]" + i + " cannot overwrite files")
			else:
				print_rich("[b][color=red]Mod failed to be loaded: " + path + i + "/mod.pck")

#func _physics_process(delta: float) -> void:
	#if mappath != oldmappath:
		#oldmappath = mappath
		#if mappath != "" && mappath != null:
			#var folder = mappath.replace(".json","")
			#if !DirAccess.dir_exists_absolute(folder):
				#Palleterizer.texture = load("uid://c6i0rbaomcv3u")
				#return
			#if FileAccess.file_exists(folder + "/palette.png"):
				#Palleterizer.texture = load_image(folder + "/palette.png")
			#else:
				#Palleterizer.texture = load("uid://c6i0rbaomcv3u")

func load_image(path: String):
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	return texture

@rpc("any_peer")
func message(message : String,system : bool = false):
	var msg = message
	msg = msg.replace("[","{")
	msg = msg.replace("]","}")
	msg = msg.replace(":red:","[color=red]")
	msg = msg.replace(":blue:","[color=blue]")
	msg = msg.replace(":green:","[color=green]")
	msg = msg.replace(":yellow:","[color=yellow]")
	msg = msg.replace(":white:","[color=white]")
	messageSent.emit(msg)

func popup(toptext : String, bottomtext : String):
	var p = errorWindow.instantiate()
	get_tree().current_scene.add_child(p)
	p.toptext.text = toptext
	p.intext.text = bottomtext
	return p
