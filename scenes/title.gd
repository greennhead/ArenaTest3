extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var settingsMenu = preload("res://nodes/menus/settings_menu.tscn")


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
