extends GPUParticles3D



func _ready() -> void:
	emitting = true
	$bones.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_timer_timeout() -> void:
	queue_free()
