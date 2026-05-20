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
#var mods = []
var address = "localhost"
var enabledMaps = []
var customGMProperties = {}

var gunPaths : Array[String] = ["res://nodes/weapons/"]
var mapPaths : Array[String] = ["res://maps/"]
var gamemodePaths : Array[String] = ["res://modes/"]

var rules := {
	"bhop" : 0, #Enables quake-like movement
	"autobhop" : 0, #Autojump
	"bhopwiggle" : 0 #Can fly by wiggling ASD in air if bhop is 1
}
var rulesDefault := {}

var modProfile

@onready var errorWindow = preload("uid://bp8lkc3ukjnna")
func _ready() -> void:
	var path = "res://objects/"
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with(".tres"): 
			print_rich("[color=green]Loaded custom object: "+ res) 
			customObjects.append(load(path+res))
	addModeNodes()
	rulesDefault = rules.duplicate()
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
	return #old
	for i in Settings.enabledMods:
		var path = Settings.modsPath + "/"
		var config = ConfigFile.new()
		var err = config.load(path + i + "/mod.cfg")
		if err == OK:
			var success = false
			if config.get_value("data","overwrite") != 0:
				success = ProjectSettings.load_resource_pack(path + i + "/mod.pck",true)
			else:
				success = ProjectSettings.load_resource_pack(path + i + "/mod.pck",false)
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


# probably could have used an enum but its 9 pm
# tag 0 = all
# tag 1 = tile removing
# tag 2 = op
# tag 3 = cant deal damage
func getAllGuns(tag := 0):
	var arr = []
	for path in GameManager.gunPaths:
		for i in ResourceLoader.list_directory(path):
			if i.ends_with(".tscn"):
				var wep = load(path.path_join(i)).instantiate()
				##if the line below gives you an error then you messed up your weapon 
				if wep.weapon != null:
					if tag == 0:
						arr.append(path.path_join(i))
					elif tag == 1 && wep.weapon.consideredTileRemoving:
						arr.append(path.path_join(i))
					elif tag == 2 && wep.weapon.consideredOverpowered:
						arr.append(path.path_join(i))
					elif tag == 3 && wep.weapon.consideredUnableToDealDamage:
						arr.append(path.path_join(i))
	return arr

func getAllMaps(gamemodeRestriction : String = ""):
	var arr = []
	for path in GameManager.mapPaths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					var config = ConfigFile.new()
					var err = config.load(path.path_join(file_name).path_join("config.cfg"))
					if err == OK:
						if config.get_value("data","gamemode") == gamemodeRestriction || gamemodeRestriction == "":
							arr.append(path.path_join(file_name))
				file_name = dir.get_next()
	return arr

func getMapData(path : String, data : String = "name"):
	var config = ConfigFile.new()
	var err = config.load((path).path_join("config.cfg"))
	if err == OK:
		return config.get_value("data",data)
	return "Error"
