extends Area3D
class_name Teleporter
@export var exit = false
var id = 0
var randomExit = false
@onready var la: Label3D = $Label3D2
@onready var ladtext = preload("res://images/teleportexit.png")
var sound = ""
func _ready() -> void:
	$MeshInstance3D.material_override = $MeshInstance3D.material_override.duplicate()

func _process(delta: float) -> void:
	if exit:
		$MeshInstance3D.material_override.set("shader_parameter/texture_albedo",ladtext)
	if exit:
		la.text = "EXIT " + str(id)
	else:
		la.text = "ENTRANCE " + str(id)


func _on_body_entered(body: Node3D) -> void:
	var myExit = null
	var myExits = []
	if exit:
		return
	if !randomExit:
		for i in get_tree().get_nodes_in_group("teleporter"):
			if i.exit == true && i.id == id:
				myExit = i
	else:
		for i in get_tree().get_nodes_in_group("teleporter"):
			if i.exit == true && i.id == id:
				myExits.append(i)
	if body is Player && myExit != null && !randomExit:
		#TODO play sound
		body.position = myExit.position
	if body is Player && myExits.size() > 0 && randomExit:
		#TODO play sound
		myExits.shuffle()
		body.position = myExits[0].position
