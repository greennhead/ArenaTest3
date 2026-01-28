extends GPUParticles3D
var texture : Texture2D


func _ready() -> void:
	draw_pass_1.material = draw_pass_1.material.duplicate()
	$bones.draw_pass_1.material = $bones.draw_pass_1.material.duplicate()
	$bones2.draw_pass_1.material = $bones2.draw_pass_1.material.duplicate()
	draw_pass_1.material.set("albedo_texture",texture)
	$bones.draw_pass_1.material.set("albedo_texture",texture)
	$bones2.draw_pass_1.material.set("albedo_texture",texture)
	emitting = true
	$bones.emitting = true
	$bones2.emitting = true



func _on_timer_timeout() -> void:
	queue_free()
