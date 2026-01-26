extends CharacterBody3D
class_name Player

@onready var head: Node3D = $head

@onready var playerName: Label3D = $playerName


@export var hp := 100
@onready var camera: Camera3D = $head/Camera3D

@onready var snd = preload("res://nodes/sound.tscn")

var coyote := 0 
@export var maxCoyote := 4
var id := 1
var ouchTime := 0
var smirkTime := 0
@export var canMoveMouse := true

@export_file("*.tres") var animation : String =  "res://resources/anim_WALK.tres"
@onready var normalAnim = preload("res://resources/anim_WALK.tres")
@onready var deadAnim = preload("res://resources/anim_DEAD.tres")
@onready var tauntAnim = preload("res://resources/anim_TAUNT.tres")

@onready var billb: directionalBillboard = $DirectionalBillboard

@onready var hand1: Sprite3D = $DirectionalBillboard/hand
@onready var hand2: Sprite3D = $DirectionalBillboard/hand2

@export var icyness := 0.9
var time = 0
const SPEED := 10.0
const JUMP_VELOCITY := 6.5
var sensetivity := 0.003
@export var grav := Vector3(0,-14,0)
var watergrav := Vector3(0,-4,0)

@export var textureBase64 := ""
var weapon = null
@onready var mulSync: MultiplayerSynchronizer = $MultiplayerSynchronizer
var cursorLocked := true
enum STATES {
NORMAL,
DEAD
}
var stepDelay = 0
var state = STATES.NORMAL
var dead := false
var moving := false
var taunting := false


func _ready() -> void:
	sensetivity = Settings.senstivity *0.001
	camera.fov = Settings.fov
	giveWeapon(load("res://nodes/weapons/arcabe_gold.tscn"))
	if mulSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		playerName.hide()
		GameManager.myPlayer = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


@onready var hand1origin = hand1.position
@onready var hand2origin = hand2.position

@rpc("any_peer","call_local","reliable")
func removeWeapon():
	if weapon != null:
		weapon.queue_free()
		weapon = null


@rpc("any_peer","call_local","reliable")
func giveWeapon(newweapon):
	smirkTime = 120
	var wep = newweapon.instantiate()
	billb.add_child(wep)
	weapon = wep
	wep.player = self

func deltaify(v,delta):
	v = (v*60)*delta
	return v

func cursorLock():
	if Input.is_action_just_pressed("escape") && !cursorLocked:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cursorLocked = true
		return
	if Input.is_action_just_pressed("escape") && cursorLocked:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursorLocked = false
		return

@onready var crosshairIndicator: Sprite2D = $CROSSHAIR/crosshairIndicator
@onready var crosshair: Sprite2D = $CROSSHAIR/crosshair

func _physics_process(delta: float) -> void:
	if ouchTime > 0:
		ouchTime -= 1
	if smirkTime > 0:
		smirkTime -= 1
	moving = !(is_on_floor() && round(velocity.x) == 0 && round(velocity.y) == 0 && round(velocity.z) == 0)
	cursorLock()
	doState(state,delta)
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	blood.modulate.a = lerp(blood.modulate.a,0.0,0.05)
	crosshairIndicator.modulate.a = lerp(crosshairIndicator.modulate.a,0.0,0.1)
	playerName.hide()
	time += 1
	billb.rotation = head.rotation
	billb.rotation.x = camera.rotation.x/1.2
	billb.pixel_size = 0
	camera.current = true
	hand1.no_depth_test = true
	hand2.no_depth_test = true
	if weapon == null:
		sensetivity = Settings.senstivity *0.001
		camera.fov = Settings.fov

func doState(state,delta):
	if state == STATES.NORMAL:
		normalState(delta)
	elif state == STATES.DEAD:
		if weapon != null:
			removeWeapon.rpc()

func normalState(delta):
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		billb.animation = load(animation)
		return
	if weapon != null:
		hand1.position = lerp(hand1.position,weapon.handGuide1.position,0.7)
		hand2.position = lerp(hand2.position,weapon.handGuide2.position,0.7)
		var shoot = Input.is_action_just_pressed("fire")
		if weapon.weapon.autofire:
			shoot = Input.is_action_pressed("fire")
		if shoot:
			weapon.shoot.rpc()
		if weapon.weapon.canZoom:
			if Input.is_action_pressed("altfire"):
				camera.fov = lerp(camera.fov,float(weapon.weapon.zoomFOV),0.2)
				sensetivity = Settings.senstivity *0.00035
			else:
				sensetivity = Settings.senstivity *0.001
				camera.fov = lerp(camera.fov,float(Settings.fov),0.2)
	else:
		hand1.position = lerp(hand1.position,hand1origin,0.2)
		hand2.position = lerp(hand2.position,hand2origin,0.2)
	bop_head(delta,0.2,0.15)
	if stepDelay > 0:
		stepDelay -= 60*delta
	if moving:
		if stepDelay <= 0 && is_on_floor():
			stepDelay = 30
			emitSound.rpc("res://sounds/ct_footstep_" + str(randi_range(0,3))+ ".ogg",position,linear_to_db(Settings.stepVolume/100) ,randf_range(0.9,1.1))
	if stepDelay > 0:
		stepDelay -= 60*delta
	if not is_on_floor():
		velocity += grav * delta
		if coyote > 0:
			coyote -= 1
	else:
		coyote = maxCoyote
	if Input.is_action_just_pressed("jump") && coyote > 0:
		coyote = 0
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var spd = icyness
	if direction:
		velocity.x = move_toward(velocity.x,direction.x * SPEED,deltaify(spd,delta))
		velocity.z = move_toward(velocity.z,direction.z * SPEED,deltaify(spd,delta))
	else:
		velocity.x = move_toward(velocity.x,0.0,deltaify(spd,delta))
		velocity.z = move_toward(velocity.z,0.0,deltaify(spd,delta))
	move_and_slide()

func _input(event):
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if cursorLocked:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * sensetivity)
			camera.rotate_x(-event.relative.y * sensetivity)
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-86),deg_to_rad(86))

@rpc("any_peer","reliable","call_local")
func emitSound(sound : String,pos,volume,pitch):
	var s = snd.instantiate()
	s.stream = load(sound)
	s.volume_db = volume
	s.pitch_scale = pitch
	get_tree().current_scene.add_child(s)
	s.global_position = pos


@onready var blood: ColorRect = $CROSSHAIR/blood

func hurt(damage,knockback = -5,source = null):
	emitSound.rpc(load("res://sounds/hurt.ogg"),position)
	ouchTime = 60
	var dmg = damage
	hp -= dmg
	if source.Owner != null:
		damageIndicate.rpc_id(source.Owner.id,source.Owner.id,dmg*-1)
	if blood.modulate.a < 1:
		blood.modulate.a += 0.2
	if blood.modulate.a > 0.5:
		blood.modulate.a  = 0.5
	var k = global_position.direction_to(source.global_position)
	velocity += k*knockback

func bop_head(delta,frequency,amplitude):
	if round(velocity) != Vector3(0,0,0) && is_on_floor():
		camera.position.y =  lerp(camera.position.y,(cos(time * deltaify(frequency,delta)) * amplitude),(0.1*60)*delta)
	else:
		camera.position.y = lerp(camera.position.y,0.0,(0.1*60)*delta)

@rpc("call_local","any_peer","reliable")
func damageIndicate(owner,damage):
	GameManager.myPlayer.showDmg(damage)

@onready var damageIndicator: Label = $CROSSHAIR/damageIndicator
@onready var crosshairCanvasLayer: CanvasLayer = $CROSSHAIR

func showDmg(damage):
	var p = damageIndicator.duplicate()
	p.visible = true
	p.text = str(int(damage))
	p.time = 0
	p.dmg = damage
	p.position = crosshair.position + Vector2(0,8)
	crosshairCanvasLayer.add_child(p)
	p.add_to_group("damagelabel")
	crosshairIndicator.modulate.a = 2
