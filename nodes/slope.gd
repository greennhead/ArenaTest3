extends StaticBody3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var texture = "res://images/brick.png"
func post_ready() -> void:
	var map = GameManager.mapName
	var txtr
	if texture == null:
		txtr = load("res://images/brick.png")
	else:
		txtr = load(map.path_join("/blockTextures/").path_join(texture))
	if txtr == null:
		txtr = load("res://images/brick.png")
	mesh.material_override = mesh.material_override.duplicate()
	txtr = txtr.get_image()
	txtr.resize(24,24)
	var txtur = ImageTexture.create_from_image(txtr)
	mesh.material_override.set("albedo_texture",txtur)
