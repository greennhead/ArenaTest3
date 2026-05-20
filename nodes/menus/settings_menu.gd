extends MenuWindow
var stepDelay = 5

@onready var dsm: ItemList = $defaultSkinMenu
@onready var dsED: LineEdit = $DefaultSkin
@onready var bindMenu = preload("res://nodes/menus/rebind_controls.tscn")
func getSkins():
	var path = Settings.skinsPath + "/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var img = Image.load_from_file(path + file_name)
				if img.get_size() != Vector2i(192,120):
					img.resize(192,144,Image.INTERPOLATE_NEAREST)
				img.crop(24,24)
				print_rich("[color=YELLOW]File in skin folder found: " + path + file_name)
				dsm.add_item(file_name,ImageTexture.create_from_image(img))
			file_name = dir.get_next()

func _on_close_pressed() -> void:
	queue_free()
	Settings.saveSettings()

func _ready() -> void:
	getSkins()
	super()
	$volumeSound.value = Settings.soundVolume
	$StepSound.value = Settings.stepVolume
	$NameColor.text = Settings.nameColor
	$myName.text = Settings.playerName
	$Palette.button_pressed = Settings.palette
	$SillyLanguages.button_pressed = Settings.bonusLanguages
	$Sensitivity.value = Settings.senstivity
	$Fullscreen.button_pressed = Settings.fullscreen
	$fov.value = Settings.fov
	$DefaultSkin.text = Settings.defaultSkin
	$canVC.button_pressed = Settings.haveVC
	$enableVC.button_pressed = Settings.enableVC
	$hudscale.value = Settings.hudScale

func _process(delta: float) -> void:
	super(delta)
	if stepDelay > 0:
		stepDelay -= 1
	Settings.soundVolume = $volumeSound.value
	Settings.stepVolume = $StepSound.value
	Settings.nameColor = $NameColor.text
	Settings.playerName = $myName.text
	Settings.palette = $Palette.button_pressed
	Settings.bonusLanguages = $SillyLanguages.button_pressed
	Settings.senstivity = $Sensitivity.value
	Settings.fullscreen = $Fullscreen.button_pressed
	Settings.fov = $fov.value
	Settings.defaultSkin = $DefaultSkin.text
	Settings.haveVC = $canVC.button_pressed
	Settings.enableVC = $enableVC.button_pressed
	Settings.hudScale = $hudscale.value


func _on_step_sound_value_changed(value: float) -> void:
	if stepDelay == 0:
		$step.stream = load("res://sounds/ct_footstep_" + str(randi_range(0,3))+ ".ogg")
		$step.play()
		stepDelay = 4
	$step.volume_db = linear_to_db($StepSound.value/100)


func _on_volume_sound_value_changed(value: float) -> void:
	if stepDelay == 0:
		$hurt.play()
		stepDelay = 4


func _on_dir_open_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())


func _on_default_skin_menu_item_selected(index: int) -> void:
	dsED.text = dsm.get_item_text(index)


func _on_rebind_pressed() -> void:
	var b = bindMenu.instantiate()
	GameManager.main.add_child(b)
