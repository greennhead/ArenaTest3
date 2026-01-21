extends CenterContainer

@export var containX : bool = true
@export var containY : bool = true
func _physics_process(delta: float) -> void:
	if containX:
		size.x = get_viewport_rect().size.x
	if containY:
		size.y = get_viewport_rect().size.y
	position.y = get_viewport_rect().size.y - size.y
