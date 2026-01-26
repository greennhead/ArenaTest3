extends CanvasLayer
@onready var hudText: Label = $hudPlate/hudText
@onready var hudPlate: TextureRect = $hudPlate
@onready var hudFace: Sprite2D = $hudPlate/hudFace


func _physics_process(delta: float) -> void:
	var p : Player = GameManager.myPlayer
	if p != null:
		hudFace.texture = p.billb.texture
		hudText.text = ""
		hudText.text += "\nHealth: " + str(p.hp) + "\n"
		hudFace.frame = 0
		if p.ouchTime > 0:
			hudFace.frame = 1
		if p.smirkTime > 0:
			hudFace.frame = 2
		if p.taunting:
			hudFace.frame = 3
		if p.weapon != null:
			hudText.text += p.weapon.weapon.name + " (" + str(p.weapon.ammo) + ")"
