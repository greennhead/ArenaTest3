extends Area3D
class_name Water
var texture 
var txt
var read = 0
@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var ladder = false
@onready var ladtext = preload("res://images/ladder.png")

func load_image(path: String, blockify : bool = true):
	var tpath = GameManager.mapName+"/blockTextures/"+path
	var image = ResourceLoader.load(tpath)
	if image == null:
		print_rich("[color=red]Failed loading: " +tpath)
		return load("res://images/brick.png")
	print_rich("[color=green]Loaded texture: " +tpath)
	if blockify:
		var img = image.get_image()
		img.resize(24,24,Image.INTERPOLATE_NEAREST)
		return ImageTexture.create_from_image(img)
	return image

func post_ready() -> void:
	if ladder:
		$MeshInstance3D.add_to_group("editorOnly")
	$MeshInstance3D.material_override = $MeshInstance3D.material_override.duplicate()
	if texture == null:
		return
	if texture is int or texture is float:
		texture = null
		return
	mesh.material_override.set("shader_parameter/texture_albedo",load_image(texture))






func _physics_process(delta: float) -> void:
	for i in get_overlapping_bodies():
		if i is Player:
			i.coyote = i.maxCoyote + 1
	if ladder:
		mesh.material_override.set("shader_parameter/texture_albedo",ladtext)
		visible = false
		return
