extends CanvasLayer
func _process(delta: float) -> void:
	visible = Settings.palette
func set_palette(palette : Texture2D):
	if palette == null:
		$ColorRect.material.set("shader_parameter/palette",load("res://images/palette.png"))
		return
	$ColorRect.material.set("shader_parameter/palette",palette)
