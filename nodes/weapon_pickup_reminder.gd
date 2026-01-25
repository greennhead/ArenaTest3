extends Node3D
var weaponName := ""
const weaponsPath = "res://nodes/weapons/"

func post_ready():
	$name.text = weaponName 
	var path = weaponsPath
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.ends_with(".tscn"):
				if load(path + "/" + file_name).instantiate().weapon.legacyName == weaponName:
					print_rich("[color=lime]Found legacy weapon: " + weaponName)
					queue_free()
			file_name = dir.get_next()


func _physics_process(delta: float) -> void:
	$sprite.rotation_degrees.y += 2
