extends Node3D
var folder
@export var world : WorldEnvironment
@export var mapList = []
var mapname := ""
var mappath 
var ends := 0
var rand := 0
var blockNum := 0
@onready var BLOCK = preload("res://nodes/block.tscn")

@onready var mat = preload("res://resources/mat.tres")
@onready var mesh = preload("res://resources/mesh.tres")
@onready var smesh = preload("res://resources/slope.tres")
@onready var gridMap: GridMap = $GridMap
@onready var spawnPoint = preload("res://nodes/spawn_point.tscn")
@onready var slopeCollision = preload("res://resources/slopeCollision.tres")
func load_image(path: String, blockify : bool = false):
	var image = load(path)
	if image == null:
		return load("res://images/brick.png")
	if blockify:
		var img = image.get_image()
		img.resize(24,24,Image.INTERPOLATE_NEAREST)
		return ImageTexture.create_from_image(img)
	return image
	#var image = Image.load_from_file(path)
	#var texture = ImageTexture.create_from_image(image)
	#return texture

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	sendRandom.rpc(randi_range(0,99999999))
	await get_tree().create_timer(0.1).timeout
	getMapList()
	loadMap(mapList[0])

@rpc("call_local","reliable","authority")
func sendRandom(random):
	rand = random

func loadMap(map):
	for i in get_children():
		if i != gridMap:
			i.queue_free()
	gridMap.clear()
	var meshLib = MeshLibrary.new()
	blockNum = 0
	var path = map + "/map.json"
	var materials = {}
	var indexes = {}
	mappath = path
	mapname = path.get_file()
	if FileAccess.file_exists(map + "/palette.png"):
		Palleterizer.set_palette(load_image(map + "/palette.png"))
	else:
		Palleterizer.set_palette(null)
	if world != null && FileAccess.file_exists(map + "/skybox.png"):
		world.environment.sky.sky_material.set("panorama",load_image(map + "/skybox.png"))
	if not FileAccess.file_exists(path):
		print("FILE DOESNT EXIST")
		return # Error! We don't have a save to load.
	var save_nodes = get_tree().get_nodes_in_group("editorObject")
	for i in save_nodes:
		i.queue_free()
	var save_file = FileAccess.open(path, FileAccess.READ)
	var progress = 0
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		if node_data["name"] == "spawn_point":
			var sp = spawnPoint.instantiate()
			sp.position = Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"])
			add_child(sp)
		if node_data["name"] == "slope":
			if !materials.has(str(node_data["texture"]) + "_slope"):
				var meshmat  = smesh.duplicate()
				meshmat.set("surface_0/material",meshmat.get("surface_0/material").duplicate()) 
				meshmat.get("surface_0/material").set("albedo_texture",load_image(map + "/blockTextures/" + str(node_data["texture"]),true)) 
				materials.set(str(node_data["texture"])+ "_slope",meshmat.get("surface_0/material"))
				indexes.set(str(node_data["texture"])+ "_slope",meshLib.get_last_unused_item_id())
				meshLib.create_item(meshLib.get_last_unused_item_id())
				meshLib.set_item_mesh(meshLib.get_last_unused_item_id()-1,meshmat)
				meshLib.set_item_name(meshLib.get_last_unused_item_id()-1,str(node_data["texture"]))
				meshLib.set_item_shapes(meshLib.get_last_unused_item_id()-1,[slopeCollision])
				gridMap.mesh_library = meshLib
				var rot = gridMap.get_orthogonal_index_from_basis(Quaternion(rad_to_deg(node_data["rotation_x"]/90),1,rad_to_deg(node_data["rotation_z"]/90),node_data["rotation_y"]))
				gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),meshLib.get_last_unused_item_id()-1,rot)
			else:
				var rot = gridMap.get_orthogonal_index_from_basis(Quaternion(rad_to_deg(node_data["rotation_x"]/90),1,rad_to_deg(node_data["rotation_z"]/90),node_data["rotation_y"]))
				gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),indexes[str(node_data["texture"])+ "_slope"],rot)
		if node_data["name"] == "block":
			if !materials.has(str(node_data["texture"])):
				var meshmat  = mesh.duplicate()
				meshmat.material = meshmat.material.duplicate()
				meshmat.material.set("albedo_texture",load_image(map + "/blockTextures/" + str(node_data["texture"]),true)) 
				materials.set(str(node_data["texture"]),meshmat.material)
				indexes.set(str(node_data["texture"]),meshLib.get_last_unused_item_id())
				meshLib.create_item(meshLib.get_last_unused_item_id())
				meshLib.set_item_mesh(meshLib.get_last_unused_item_id()-1,meshmat)
				meshLib.set_item_name(meshLib.get_last_unused_item_id()-1,str(node_data["texture"]))
				meshLib.set_item_shapes(meshLib.get_last_unused_item_id()-1,[BoxShape3D.new()])
				gridMap.mesh_library = meshLib
				gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),meshLib.get_last_unused_item_id()-1)
			else:
				gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),indexes[node_data["texture"]])
		#if node_data["filename"] == "res://nodes/block.tscn":
			#var b = BLOCK.instantiate()
			#b.position = Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"])
			#add_child(b)
			#blockNum += 1
			#b.name = "block_" + str(blockNum)
			#if !materials.has(str(node_data["texture"])):
				#b.mesh.material_override = b.mesh.material_override.duplicate()
				#b.mesh.material_override.set("shader_parameter/texture_albedo",load_image(map + "/blockTextures/" + str(node_data["texture"]),true)) 
				#materials.set(str(node_data["texture"]),b.mesh.material_override)
			#else:
				#b.mesh.material_override = materials.get(str(node_data["texture"]))
		progress += 1
	$"../player".position = get_tree().get_nodes_in_group("spawnPoint").pick_random().position


@rpc("reliable","call_local")
func getMapList():
	var path = "res://maps/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				GameManager.globalMaplist.append(file_name)
			file_name = dir.get_next()
	mapList = []
	var seed = rand
	for i in GameManager.globalMaplist:
		mapList.append(path + i)
	for i in GameManager.Players:
		seed += GameManager.Players[i].id
	seed(seed + ends)
	mapList.shuffle()
	print(mapList)
	rand = randf_range(0,10000)
