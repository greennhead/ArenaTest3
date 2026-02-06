extends Control
class_name MenuWindow
@export var snapToCenter := true

func snap():
	if snapToCenter:
		global_position = get_viewport_rect().size/2.0 - size/2.0


func ready():
	snap()

func _process(delta: float) -> void:
	snap()
