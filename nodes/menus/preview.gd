extends Container
@onready var preview: Sprite2D = $"../Preview"
@onready var ogScale = preview.scale
@onready var ogPos = preview.position

func _on_mouse_entered() -> void:
	preview.scale = Vector2.ONE
	preview.top_level = true
	preview.global_position = get_global_mouse_position()


func _on_mouse_exited() -> void:
	preview.scale = ogScale
	preview.top_level = false
	preview.position = ogPos
