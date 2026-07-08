extends CanvasLayer
func _process(delta: float) -> void:
	visible = Settings.palette
func set_palette(palette : Texture2D):
	if palette == null:
		$ColorRect.material.set("shader_parameter/palette",load("res://images/palette.png"))
		return
	var pal = palette.get_image()
	pal.resize(clamp(pal.get_width(),1,48),clamp(pal.get_height(),1,32))
	$ColorRect.material.set("shader_parameter/palette",ImageTexture.create_from_image(pal))
