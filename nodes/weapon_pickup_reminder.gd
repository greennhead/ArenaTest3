extends Node3D
var weaponName := ""

func post_ready():
	$name.text = weaponName 


func _physics_process(delta: float) -> void:
	$sprite.rotation_degrees.y += 2
