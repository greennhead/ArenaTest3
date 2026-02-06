extends Node
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
var num := 0
var mapnum := -1
var level 
var customObjects : Array[mapObject]
var testMap := ""
const modsPath := "user://mods/" 
var myName := ""
var mods = []
var address = "localhost"
var enabledMaps = []
func _ready() -> void:
	var path = "res://objects/"
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with(".tres"): 
			print_rich("[color=green]Loaded custom object: "+ res) 
			customObjects.append(load(path+res))

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
