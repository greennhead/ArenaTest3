extends CanvasLayer

@onready var settingsMenu = preload("res://nodes/menus/settings_menu.tscn")
@onready var quitMenu = preload("res://nodes/menus/quitconfirm.tscn")
func _on_settings_pressed() -> void:
	var a = settingsMenu.instantiate()
	GameManager.main.add_child(a)


func _on_quit_pressed() -> void:
	var a = quitMenu.instantiate()
	GameManager.main.add_child(a)
