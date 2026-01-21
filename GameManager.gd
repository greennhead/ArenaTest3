extends Node

var godotPath = !false
var mapName := ""
var gmName := "Default"
var mappath = ""
var Players={}
var myPlayer = null
var debug = !false
var tree
var oldmappath 
var preloadskin = ""
var globalMaplist = []
var num = 0
var level 

func _process(delta):
	if mappath != oldmappath:
		oldmappath = mappath
		if mappath != "" && mappath != null:
			var folder = mappath.replace(".json","")
			if !DirAccess.dir_exists_absolute(folder):
				Palleterizer.texture = load("uid://c6i0rbaomcv3u")
				return
			if FileAccess.file_exists(folder + "/palette.png"):
				Palleterizer.texture = load_image(folder + "/palette.png")
			else:
				Palleterizer.texture = load("uid://c6i0rbaomcv3u")

func load_image(path: String):
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	return texture
