extends Node3D
var weaponName := ""
const weaponsPath = "res://nodes/weapons/"
@onready var trueWeaponPickup = preload("res://nodes/weapon_pickup.tscn")
func post_ready():
	$name.text = weaponName 
	var path = weaponsPath
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.ends_with(".tscn"):
				##if the line below gives you an error then you messed up your weapon
				if load(path + "/" + file_name).instantiate().weapon.legacyName == weaponName:
					print_rich("[color=lime]Found legacy weapon: " + weaponName)
					queue_free()
					var p = trueWeaponPickup.instantiate()
					p.position = position
					p.weapon = path + "/" + file_name
					get_parent().add_child(p)
					return
			file_name = dir.get_next()


func _physics_process(delta: float) -> void:
	$sprite.rotation_degrees.y += 2
