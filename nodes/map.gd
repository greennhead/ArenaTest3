extends Node3D
var folder
@export var world : WorldEnvironment
@export var mapList = []
var mapname := ""
var mappath 
var ends := 0

var blockNum := 0
@onready var BLOCK = preload("res://nodes/block.tscn")

@onready var mat = preload("res://resources/mat.tres")
@onready var mesh = preload("res://resources/mesh.tres")
@onready var smesh = preload("res://resources/slope.tres")
@onready var gridMap: GridMap = $GridMap
@onready var spawnPoint = preload("res://nodes/spawn_point.tscn")
@onready var slopeCollision = preload("res://resources/slopeCollision.tres")
func load_image(path: String, blockify : bool = false):
	var image = ResourceLoader.load(path)
	if image == null:
		print_rich("[color=red]Failed loading: " +path)
		return load("res://images/brick.png")
	print_rich("[color=green]Loaded texture: " +path)
	if blockify:
		var img = image.get_image()
		img.resize(24,24,Image.INTERPOLATE_NEAREST)
		return ImageTexture.create_from_image(img)
	return image
	#var image = Image.load_from_file(path)
	#var texture = ImageTexture.create_from_image(image)
	#return texture

func _ready() -> void:
	var rand = 0
	for i in GameManager.Players:
		rand += int(i)
	GameManager.mapnum += 1
	GameManager.num = rand
	print(rand)
	await get_tree().create_timer(0.1).timeout
	getMapList()
	loadMap(mapList[GameManager.mapnum])

@rpc("authority","call_local","reliable")
func spawnPlayers():
	seed(GameManager.num)
	GameManager.num += 1
	var idx = 0
	var order = get_tree().get_nodes_in_group("spawnPoint")
	order.shuffle()
	for i in get_tree().get_nodes_in_group("player"):
		if idx > order.size():
			idx = 0
		i.global_position = order[idx].global_position
		idx += 1



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
	GameManager.mapName = map
	if ResourceLoader.exists(map + "/palette.png"):
		Palleterizer.set_palette(load_image(map + "/palette.png"))
	world.environment.sky.sky_material.set("panorama",load_image(map + "/skybox.png"))
	if world.environment.sky.sky_material.get("panorama") == load("res://images/brick.png"):
		world.environment.sky.sky_material.set("panorama",load_image(map + "/Skybox.png"))
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
		for i in GameManager.customObjects:
			if i.name.to_lower() == node_data["name"].to_lower():
				var b = load(i.node).instantiate()
				if node_data.has("pos_x") && node_data.has("pos_y") && node_data.has("pos_z"):
					b.position = Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"])
				b.name = node_data["name"].to_lower() + str(blockNum)
				blockNum += 1
				add_child(b)
				for ii in i.properties:
					if i.properties[ii] is Vector2:
						b.set(ii,Vector2(node_data[str(ii) + "_x"],node_data[str(ii) + "_y"]))
					elif i.properties[ii] is Vector3:
						b.set(ii,Vector3(node_data[str(ii) + "_x"],node_data[str(ii) + "_y"],node_data[str(ii) + "_z"]))
					elif i.properties[ii] is Vector4:
						b.set(ii,Vector4(node_data[str(ii) + "_x"],node_data[str(ii) + "_y"],node_data[str(ii) + "_z"],node_data[str(ii) + "_w"]))
					else:
						if node_data.has(str(ii)):
							b.set(ii,node_data[str(ii)])
				if b.has_method("post_ready"):
					b.post_ready()
				for ch in b.get_children():
					if ch.is_in_group("editorOnly"):
						ch.hide()
		#if node_data["name"] == "slope":
			#if !materials.has(str(node_data["texture"]) + "_slope"):
				#var meshmat  = smesh.duplicate()
				#meshmat.set("surface_0/material",meshmat.get("surface_0/material").duplicate()) 
				#meshmat.get("surface_0/material").set("albedo_texture",load_image(map + "/blockTextures/" + str(node_data["texture"]),true)) 
				#materials.set(str(node_data["texture"])+ "_slope",meshmat.get("surface_0/material"))
				#indexes.set(str(node_data["texture"])+ "_slope",meshLib.get_last_unused_item_id())
				#meshLib.create_item(meshLib.get_last_unused_item_id())
				#meshLib.set_item_mesh(meshLib.get_last_unused_item_id()-1,meshmat)
				#meshLib.set_item_name(meshLib.get_last_unused_item_id()-1,str(node_data["texture"]))
				#meshLib.set_item_shapes(meshLib.get_last_unused_item_id()-1,[slopeCollision])
				#gridMap.mesh_library = meshLib
				#var rot = gridMap.get_orthogonal_index_from_basis(Quaternion(rad_to_deg(node_data["rotation_x"]/90),1,rad_to_deg(node_data["rotation_z"]/90),node_data["rotation_y"]))
				#gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),meshLib.get_last_unused_item_id()-1,rot)
			#else:
				#var rot = gridMap.get_orthogonal_index_from_basis(Quaternion(rad_to_deg(node_data["rotation_x"]/90),1,rad_to_deg(node_data["rotation_z"]/90),node_data["rotation_y"]))
				#gridMap.set_cell_item(Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]),indexes[str(node_data["texture"])+ "_slope"],rot)
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
	spawnPlayers()




@rpc("reliable","call_local")
func getMapList():
	if GameManager.testMap != "":
		mapList = []
		mapList.append(GameManager.testMap)
		return
	var path = "res://maps/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var config = ConfigFile.new()
				var err = config.load(path + file_name + "/config.cfg")
				if err == OK:
					if config.get_value("data","gamemode") == GameManager.gmName && GameManager.enabledMaps.has(file_name):
						GameManager.globalMaplist.append(file_name)
			file_name = dir.get_next()
	mapList = []
	var rand = 0
	for i in GameManager.Players:
		rand += int(i)
	var seed = rand
	for i in GameManager.globalMaplist:
		mapList.append(path + i)
	for i in GameManager.Players:
		seed += int(GameManager.Players[i].id)
	seed(seed + ends)
	mapList.shuffle()
	print(mapList)
	rand = randf_range(0,10000)
