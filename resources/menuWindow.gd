extends Control
class_name MenuWindow

func _process(delta: float) -> void:
	global_position = get_viewport_rect().size/2.0 - size/2.0
