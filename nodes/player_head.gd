extends RigidBody3D
@onready var sprite: Sprite3D = $Sprite3D
var texture : Texture2D
func _ready() -> void:
	seed(GameManager.num)
	apply_central_impulse(Vector3(randf_range(-10,10),10,randf_range(-10,10)))
	seed(GameManager.num)
	sprite.texture = texture
	$gibEffect.draw_pass_1.material = $gibEffect.draw_pass_1.material.duplicate()
	$gibEffect.draw_pass_1.material.set("albedo_texture",sprite.texture)


func _on_timer_timeout() -> void:
	$gibEffect.emitting = false
