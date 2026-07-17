extends MenuWindow


func _on_button_pressed() -> void:
	queue_free()


func _on_button_2_pressed() -> void:
	GameManager.clearWindows()
	Console.disconnectToMenu()
	queue_free()
