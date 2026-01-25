extends Area3D
class_name Water
var texture 
var txt
var read = 0
var editor = false
@onready var mesh: MeshInstance3D = $MeshInstance3D
var timer = 0
@export var ladder = false
@onready var ladtext = preload("res://textures/ladder.png")
func load_image(path: String):
	var image = Image.load_from_file(path)
	image.resize(24,24)
	var texture = ImageTexture.create_from_image(image)
	return texture

func _ready() -> void:
	$MeshInstance3D.material_override = $MeshInstance3D.material_override.duplicate()
	if texture == null:
		return
	if texture is int or texture is float:
		texture = null
		return
	mesh.material_override.set("shader_parameter/texture_albedo",load_image(GameManager.mappath.replace(".json","") + "/blockTextures/" + texture))




func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"texture" : texture,
		"rotation_x" : rotation.x,
		"rotation_y" : rotation.y,
		"rotation_z" : rotation.z,
		"ladder" : ladder
	}
	return save_dict
	
func _process(delta: float) -> void:
	timer += 1
	if ladder:
		if editor:
			mesh.material_override.set("shader_parameter/texture_albedo",ladtext)
			return
		visible = false
		return
	if timer < 3:
		if texture == null:
			return
		if texture is int or texture is float:
			texture = null
			return
		mesh.material_override.set("shader_parameter/texture_albedo",load_image(GameManager.mappath.replace(".json","") + "/blockTextures/" + texture))
