extends Node3D
var folder
@export var world : WorldEnvironment
@export var terrain : VoxelTerrain
@export var mapList = []
var mapname = ""
var mappath 
var ends = 0
var rand = 0
const gen = preload("uid://ct6pyiwelx5ka")
func load_image(path: String):
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	return texture

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	terrain.generator = gen.new()
	getMapList()
	loadMap(mapList[0])

func loadMap(map):
		var path = map + "/map.json"
		mappath = path
		mapname = path.get_file()
		world.environment.sky.sky_material.set("panorama",load_image(map + "/Skybox.png"))
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
			if node_data["filename"] == "res://nodes/spawn_point.tscn":
				$"../player".position = Vector3(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"])
			if node_data["filename"] == "res://nodes/block.tscn":
				terrain.generator.blocks.append(Vector3i(node_data["pos_x"], node_data["pos_y"],node_data["pos_z"]))
			progress += 1




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
	var seed = 0
	for i in GameManager.globalMaplist:
		mapList.append(path + i)
	for i in GameManager.Players:
		seed += GameManager.Players[i].id
	seed(seed + ends)
	mapList.shuffle()
	print(mapList)
	rand = randf_range(0,10000)
