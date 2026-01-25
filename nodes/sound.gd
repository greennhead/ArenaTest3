extends AudioStreamPlayer3D
var source
func _ready() -> void:
	play()

func _process(delta: float) -> void:
	if source != null:
		global_position = source.global_position

func _on_finished() -> void:
	queue_free()
	pass # Replace with function body.
