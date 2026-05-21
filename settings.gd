extends Node
var savePath = "user://arenatest.settings"
var inputsPath = "user://inputs.res"
var skinsPath = "user://skins"
var modsPath = "user://mods"
var oldFullscreen := false

var soundVolume := 100.0
var stepVolume := 100.0
var palette := true
var bonusLanguages := false
var defaultSkin := ""
var playerName := "Player"
var nameColor := "red"
var language := ""
var senstivity := 4.0
var fov := 110
var fullscreen := false
var enableVC := true
var haveVC := false
var mappings = {}
var mappingsRes = Mappings
var enabledMods := []
var hudScale := 1

var editableVars = ["senstivity", "soundvolume","stepvolume","palette","senstivity","fov","fullscreen","hudscale","namecolor","language","soundvolume","stepvolume"]
func updateMappings():
	var inputs = InputMap.get_actions()
	for i in mappings:
		if inputs.has(i) && !i.contains("ui_"):
			InputMap.action_erase_events(i)
			for event in mappings[i]:
				InputMap.action_add_event(i,event)

func _process(delta: float) -> void:
	#ProjectSettings.set_setting("audio/driver/driver",haveVC)
	AudioServer.set_bus_volume_db(0,linear_to_db(soundVolume/100.0))
	if oldFullscreen != fullscreen:
		oldFullscreen = fullscreen
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(skinsPath):
		DirAccess.make_dir_absolute(skinsPath)
	if !DirAccess.dir_exists_absolute(modsPath):
		DirAccess.make_dir_absolute(modsPath)
	loadSettings()

	if language == "":
		TranslationServer.set_locale(OS.get_locale())
		language = OS.get_locale()
	var inputs = InputMap.get_actions()
	for i in inputs:
		if !mappings.has(i) && !i.contains("ui_"):
			mappings.set(i,InputMap.action_get_events(i))
	updateMappings()

func getvar(vari,file):
	print_rich("[color=yellow]Loading setting " + vari)
	var varr = file.get_var()
	if varr != null:
		set(vari,varr)



func getvarreturn(vari,file):
	print_rich("[color=yellow]Loading setting " + vari)
	var varr = file.get_var()
	return varr

#This is horrible saving code. please save your mod data using the modmanager stuff
func saveSettings():
	var keys = mappingsRes.new()
	keys.keys = mappings
	ResourceSaver.save(keys,inputsPath)
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
	file.store_var(fov)
	file.store_var(enableVC)
	file.store_var(haveVC)
	file.store_var(enabledMods)
	file.store_var(hudScale) 
	#file.store_var(mappings,true)
	file.close()
	print_rich("[color=green]Saved settings!")

func loadSettings():
	for i in enabledMods:
		if i == "":
			enabledMods.erase(i)
	if FileAccess.file_exists(inputsPath):
		mappingsRes = ResourceLoader.load(inputsPath)
		mappings = mappingsRes.keys
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
		getvar("fov",file)
		getvar("enableVC",file)
		getvar("haveVC",file)
		getvar("enabledMods",file)
		getvar("hudScale",file)
		#getvar("mappings",file)
		#var map = getvarreturn("mappings",file)
		#if map != null:
			#mappings = JSON.parse_string(map)
		TranslationServer.set_locale(language)
		print_rich("[color=green]Loaded settings!")
		file.close()
