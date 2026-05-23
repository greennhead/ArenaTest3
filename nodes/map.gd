extends Node3D
class_name mapLoader
var folder


signal outOfMaps
signal mapSwitched
@export var noMultiplayer := false
@export var changePalette := true
@export var world : WorldEnvironment
@export var mapList = []
var mapname := ""
var mappath 
var ends := 0
var blockNum := 0
var mapIdx := 0
@onready var BLOCK = preload("res://nodes/block.tscn")
@export var loadAllMaps := false
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
	GameManager.mapnum = 0
	var rand = 0
	for i in GameManager.Players:
		rand += int(i)
	GameManager.num = rand
	print(rand)



func nextMap():
	if mapList.size() == 0:
		outOfMaps.emit()
		return
	if noMultiplayer:
		loadMap(mapList[GameManager.mapnum])
		return
	if multiplayer.is_server():
		loadMap.rpc(mapList[GameManager.mapnum])
	mapList.remove_at(0)

@rpc("authority","reliable")
func syncNum(num):
	GameManager.num = num


@rpc("authority","call_local","reliable")
func loadMap(map):
	var save_nodes = get_tree().get_nodes_in_group("editorObject")
	for i in get_tree().get_nodes_in_group("disposeOnMapSwitch"):
		i.queue_free()
		print_rich("[color=red]Deleted " + i.name)
	for i in save_nodes:
		i.queue_free()
		print_rich("[color=red]Deleted " + i.name)
	print_rich("[color=yellow]Loading map " + map +"...")
	for i in get_children():
		if i != gridMap:
			i.queue_free()
	gridMap.clear()
	var meshLib = MeshLibrary.new()
	blockNum = mapIdx
	var path = map.path_join("map.json")
	var materials = {}
	var indexes = {}
	mappath = path
	mapname = path.get_file()
	GameManager.mapName = map
	if ResourceLoader.exists(map.path_join("palette.png")) && changePalette:
		Palleterizer.set_palette(load(map.path_join("palette.png")))
	world.environment.sky.sky_material.set("panorama",load_image(map.path_join("skybox.png")))
	if world.environment.sky.sky_material.get("panorama") == load("res://images/brick.png"):
		world.environment.sky.sky_material.set("panorama",load_image(map.path_join("Skybox.png")))
	var save_file = FileAccess.open(path, FileAccess.READ)
	var progress = 0
	while save_file.get_position() < save_file.get_length():
		mapIdx += 1
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
				print_rich("[color=green]Spawned " + b.name)
				for ch in b.get_children():
					if ch.is_in_group("editorOnly"):
						ch.hide()
					if !ch.is_in_group("editorObject"):
						ch.add_to_group("editorObject")
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
			if !materials.has(str(node_data["texture"])) || node_data["texture"] == null:
				var meshmat  = mesh.duplicate()
				meshmat.material = meshmat.material.duplicate()
				if node_data["texture"] != null:
					meshmat.material.set("albedo_texture",load_image(map.path_join("blockTextures").path_join(str(node_data["texture"])),true)) 
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
	mapSwitched.emit()
	if multiplayer.is_server():
		syncNum.rpc(GameManager.num)




@rpc("reliable","call_local")
func getMapList():
	ends += 1
	if GameManager.testMap != "":
		mapList = []
		mapList.append(GameManager.testMap)
		return
	mapList = []
	GameManager.globalMaplist = []
	for path in GameManager.mapPaths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					var config = ConfigFile.new()
					var err = config.load(path.path_join(file_name).path_join("config.cfg"))
					if err == OK:
						if (config.get_value("data","gamemode") == GameManager.gmName && GameManager.enabledMaps.has(file_name)) || loadAllMaps:
							GameManager.globalMaplist.append(file_name)
							mapList.append(path.path_join(file_name))
				file_name = dir.get_next()
	var rand = 0
	for i in GameManager.Players:
		rand += int(i)
	var seed = rand
	for i in GameManager.Players:
		seed += int(GameManager.Players[i].id)
	if !noMultiplayer:
		seed(seed + ends)
	mapList.shuffle()
	print(mapList)
	#rand = randf_range(0,10000)
