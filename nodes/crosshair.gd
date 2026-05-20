extends Sprite2D


func _process(delta: float) -> void:
	scale = Vector2(Settings.hudScale,Settings.hudScale)
	global_position = get_viewport_rect().size/2.0
