extends Node
var savePath = "user://arenatest.settings"

var oldFullscreen := false

var soundVolume := 100.0
var stepVolume := 100.0
var palette := true
var bonusLanguages := false
var defaultSkin := ""
var playerName := "Player"
var nameColor := "red"
var language := ""
var senstivity := 4
var fullscreen := false
func _process(delta: float) -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(soundVolume/100.0))
	if oldFullscreen != fullscreen:
		oldFullscreen = fullscreen
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 

func _ready() -> void:
	loadSettings()
	if language == "":
		TranslationServer.set_locale(OS.get_locale())
		language = OS.get_locale()

func getvar(vari,file):
	print(vari)
	var varr = file.get_var()
	if varr != null:
		set(vari,varr)

func saveSettings():
	language = TranslationServer.get_locale()
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(soundVolume)
	file.store_var(stepVolume)
	file.store_var(palette)
	file.store_var(bonusLanguages)
	file.store_var(defaultSkin)
	file.store_var(playerName)
	file.store_var(nameColor)
	file.store_var(language)
	file.store_var(senstivity)
	file.store_var(fullscreen)
	file.close()
	print("saved settings!")

func loadSettings():
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		getvar("soundVolume",file)
		getvar("stepVolume",file)
		getvar("palette",file)
		getvar("bonusLanguages",file)
		getvar("defaultSkin",file)
		getvar("playerName",file)
		getvar("nameColor",file)
		getvar("language",file)
		getvar("senstivity",file)
		getvar("fullscreen",file)
		TranslationServer.set_locale(language)
		print("loaded settings!")
		file.close()
