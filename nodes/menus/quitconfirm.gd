extends MenuWindow


func _on_button_pressed() -> void:
	queue_free()


func _on_button_2_pressed() -> void:
	Console.disconnectToMenu()
	queue_free()
