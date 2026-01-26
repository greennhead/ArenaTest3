extends RayCast3D
class_name ExampleRay
var damage := 0
var knockback := 0
var Owner = null
var timer := 0
@onready var trail: MeshInstance3D = $trail


func _physics_process(delta: float) -> void:
	var origin = global_position
	var collision_point = get_collision_point()
	var distance = origin.distance_to(collision_point)
	if trail.position.z > -distance:
		trail.position.z -= 1
	timer += 1
	if timer == 1:
		check()
	if timer >= 6:
		queue_free()

func check():
	force_update_transform()
	if is_colliding():
		if get_collider() is Player or get_collider() is BulletCollider or get_collider().is_in_group("shootable"):
			var hit = get_collider()
			if get_collider() is BulletCollider:
				hit = get_collider().player
			if hit != Owner:
				hit.hurt(damage,knockback,self)
