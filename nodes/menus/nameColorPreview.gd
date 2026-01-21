extends Label

func _process(delta: float) -> void:
	modulate = Color($"..".text)
