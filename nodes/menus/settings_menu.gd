extends Control
var stepDelay = 5

func _on_close_pressed() -> void:
	queue_free()
	Settings.saveSettings()

func _ready() -> void:
	$volumeSound.value = Settings.soundVolume
	$StepSound.value = Settings.stepVolume
	$NameColor.text = Settings.nameColor
	$myName.text = Settings.playerName
	$Palette.button_pressed = Settings.palette
	$SillyLanguages.button_pressed = Settings.bonusLanguages
	$Sensitivity.value = Settings.senstivity
	$Fullscreen.button_pressed = Settings.fullscreen

func _process(delta: float) -> void:
	if stepDelay > 0:
		stepDelay -= 1
	global_position = get_viewport_rect().size/2 - size/2
	Settings.soundVolume = $volumeSound.value
	Settings.stepVolume = $StepSound.value
	Settings.nameColor = $NameColor.text
	Settings.playerName = $myName.text
	Settings.palette = $Palette.button_pressed
	Settings.bonusLanguages = $SillyLanguages.button_pressed
	Settings.senstivity = $Sensitivity.value
	Settings.fullscreen = $Fullscreen.button_pressed


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
