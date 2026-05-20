extends Control
@onready var icon: Sprite2D = $icon
@onready var cross: Sprite2D = $icon/cross
var player
var dead := false
var pnode
var shake = 0
func _physics_process(delta: float) -> void:
	scale.x = Settings.hudScale
	scale.y = Settings.hudScale
	if shake > 0:
		shake -= 0.5
		icon.offset = Vector2(randf_range(-shake/4,shake/4),randf_range(-shake/4,shake/4))
	if player != null:
		for i in get_tree().get_nodes_in_group("player"):
			if i.id == player:
				pnode = i
	if pnode != null:
		icon.texture = pnode.billb.texture
		if pnode.dead != dead:
			dead =  pnode.dead
			if dead == true:
				shake = 30
			cross.visible = dead
