extends MenuWindow
@onready var toptext: Label = $Name

@onready var intext: Label = $Name2


func _on_close_pressed() -> void:
	queue_free()
