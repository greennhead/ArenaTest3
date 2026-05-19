extends Node3D
var weaponName := ""
const weaponsPath = "res://nodes/weapons/"
@onready var trueWeaponPickup = preload("res://nodes/weapon_pickup.tscn")
@onready var sprite: Sprite3D = $sprite
func post_ready():
	$name.text = weaponName 
	for path in GameManager.gunPaths:
		for i in ResourceLoader.list_directory(path):
			print(i)
			if i.ends_with(".tscn"):
				var wep = load(path.path_join(i))
				##if the line below gives you an error then you messed up your weapon 
				if wep.instantiate().weapon != null:
					if wep.instantiate().weapon.legacyName == weaponName:
						print_rich("[color=lime]Found legacy weapon: " + weaponName)
						queue_free()
						var p = trueWeaponPickup.instantiate()
						p.position = position
						p.weapon = path.path_join(i)
						p.name = "converted_" + name
						get_parent().add_child(p)
						return
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if !dir.current_is_dir() && (file_name.replace(".remap","").ends_with(".tscn")): #what the fuck is a remap file
				###if the line below gives you an error then you messed up your weapon
				#var respath = path + "/" + file_name
				#print(respath)
				#if ResourceLoader.load(respath).instantiate().weapon.legacyName == weaponName:
					#print_rich("[color=lime]Found legacy weapon: " + weaponName)
					#queue_free()
					#var p = trueWeaponPickup.instantiate()
					#p.position = position
					#p.weapon = path + "/" + file_name
					#p.name = "converted_" + name
					#get_parent().add_child(p)
					#return
			#file_name = dir.get_next()


func _physics_process(delta: float) -> void:
	sprite.rotation_degrees.y += 2
