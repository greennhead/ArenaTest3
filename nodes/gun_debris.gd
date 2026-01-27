extends RigidBody3D
var timer := 0
@onready var sprite: Sprite3D = $gunSprite
var hframes := 0
var vframes := 0
var texture = null
func _ready() -> void:
	apply_central_impulse(Vector3(randf_range(-4.5,4.5),3,randf_range(-4.5,4.5)))


func _physics_process(delta: float) -> void:
	if texture != null && sprite.texture == null:
		sprite.texture = texture
		sprite.hframes = hframes
		sprite.vframes = vframes
	timer += 1
	if timer > 290:
		sprite.modulate.a -= 0.1
	if timer > 300:
		queue_free()
