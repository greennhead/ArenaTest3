extends Area3D
class_name GunPickup
@export_file("*.tscn") var weapon : String
@export var delay : int = 10
@export var currdelay = 0
var weaponName 
var editor = false
var timer = 0
var blocked = false
var wepframe = 0
var oneTime = false
@onready var swayTime = randi_range(-124,115)
func _ready() -> void:
	updateGun()
@onready var label_3d: Label3D = $Label3D
@onready var label_3d_2: Label3D = $Label3D2
@onready var sprite: Sprite3D = $sprite


func updateGun():
	sprite.texture = load(weapon.replace(".tscn",".tres")).singularSprite
	if weapon == null:
		blocked = true

func _physics_process(delta: float) -> void:
	swayTime += 1
	sprite.offset.y = cos(swayTime * 0.03) * 4 +4
	if currdelay > 0:
		label_3d.visible = true
		sprite.modulate.a = 0.5
		sprite.rotation_degrees.y += (2*60)*delta
	else:
		label_3d.visible = false
		sprite.modulate.a = 1
		sprite.rotation_degrees.y += (4*60)*delta
	if editor:
		$CollisionShape3D.disabled = false
	if blocked: 
		label_3d_2.visible = true
		return
	var weaponSprite = $sprite
	if weapon == null:
		blocked = true
		return
	for body in get_overlapping_bodies():
		if blocked: 
			return
		if currdelay > 0:
			return
		if body is Player && body.weapon == null:
			if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
				startDelay.rpc()
				giveWeapon.rpc(body.id)
	$MultiplayerSynchronizer.set_multiplayer_authority(1)
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if editor:
		label_3d.visible = true
		sprite.rotation_degrees.y += (2*60)*delta
		if weaponName != null:
			label_3d.text = weaponName
		return
	if !editor:
		timer += 60*delta
	if !editor:
		if timer > 60:
			timer = 0
			if currdelay > 0:
				currdelay -= 1
	if currdelay > 0:
		$CollisionShape3D.disabled = true
	else:
		$CollisionShape3D.disabled = false
	label_3d.text = str(round(currdelay)).replace(".0","")




@rpc("any_peer","call_local","reliable")
func startDelay():
	currdelay = delay

@rpc("any_peer","call_local","reliable")
func giveWeapon(id):
	var body = null
	for i in get_tree().get_nodes_in_group("player"):
		if i.id == id:
			body = i
	if body == null:
		return
	if body.dead:
		return
	body.smirkTime = 120
	body.giveWeapon(weapon)
	if oneTime == true:
		queue_free()
