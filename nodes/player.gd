extends CharacterBody3D
class_name Player

@onready var head: Node3D = $head

@onready var playerName: Label3D = $playerName


@export var hp := 100
@onready var camera: Camera3D = $head/Camera3D

@onready var snd = preload("res://nodes/sound.tscn")

var id := 1

@export var canMoveMouse := true

@export_file("*.tres") var animation : String =  "res://resources/anim_WALK.tres"
@onready var normalAnim = preload("res://resources/anim_WALK.tres")
@onready var deadAnim = preload("res://resources/anim_DEAD.tres")
@onready var tauntAnim = preload("res://resources/anim_TAUNT.tres")

@onready var billb: directionalBillboard = $DirectionalBillboard

@onready var hand1: Sprite3D = $DirectionalBillboard/hand
@onready var hand2: Sprite3D = $DirectionalBillboard/hand2

var time = 0
const SPEED := 10.0
const JUMP_VELOCITY := 6.5
var sensetivity := 0.003
var grav := Vector3(0,-14,0)
var watergrav := Vector3(0,-4,0)

@export var textureBase64 := ""

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
func _ready() -> void:
	if mulSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		playerName.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

func _physics_process(delta: float) -> void:
	sensetivity = Settings.senstivity *0.001
	moving = !(is_on_floor() && round(velocity.x) == 0 && round(velocity.y) == 0 && round(velocity.z) == 0)
	cursorLock()
	doState(state,delta)

func doState(state,delta):
	if state == STATES.NORMAL:
		normalState(delta)

func normalState(delta):
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		billb.animation = load(animation)
		return
	time += 1
	billb.rotation = head.rotation
	billb.rotation.x = camera.rotation.x/1.2
	billb.pixel_size = 0
	camera.current = true
	hand1.no_depth_test = true
	hand2.no_depth_test = true
	bop_head(delta,0.2,0.15)
	if stepDelay > 0:
		stepDelay -= 60*delta
	if moving:
		if stepDelay <= 0 && is_on_floor():
			stepDelay = 30
			emitSound.rpc("res://sounds/ct_footstep_" + str(randi_range(0,3))+ ".ogg",position,-15,randf_range(0.9,1.1))
	if stepDelay > 0:
		stepDelay -= 60*delta
	if not is_on_floor():
		velocity += grav * delta
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var spd = 0.9
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

@rpc("any_peer","reliable","call_local")
func emitSoundOgg(sound ,pos):
	var s = snd.instantiate()
	s.stream = sound
	get_tree().current_scene.add_child(s)
	s.global_position = pos

func bop_head(delta,frequency,amplitude):
	if round(velocity) != Vector3(0,0,0) && is_on_floor():
		camera.position.y =  lerp(camera.position.y,(cos(time * deltaify(frequency,delta)) * amplitude),(0.1*60)*delta)
	else:
		camera.position.y = lerp(camera.position.y,0.0,(0.1*60)*delta)
