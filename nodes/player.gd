extends CharacterBody3D
class_name Player

signal died(hp : int)
signal tookDamage(damage : int,knockback : Vector3,source)
signal gotWeapon(weapon : Weapon, heldWeapon : HeldWeapon)
signal droppedWeapon(weapon : Weapon, heldWeapon : HeldWeapon)
signal changedSkin
signal taunted
signal untaunted


@export var animationSpeed := 0.18
@onready var head: Node3D = $head

@onready var playerName: Label3D = $playerName


@export var hp := 100
@export var maxhp := 100
@onready var camera: Camera3D = $head/Camera3D

@onready var snd = preload("res://nodes/sound.tscn")

var coyote := 0 
@export var maxCoyote := 4
var id := 1
var ouchTime := 0
var smirkTime := 0
@export var canMoveMouse := true
@export var canMove := true

@export var animation = "res://resources/anim_WALK.tres"
@onready var normalAnim = "res://resources/anim_WALK.tres"
@onready var deadAnim = "res://resources/anim_DEAD.tres"
@onready var tauntAnim = "res://resources/anim_TAUNT.tres"

@onready var billb: directionalBillboard = $DirectionalBillboard

@onready var hand1: Sprite3D = $DirectionalBillboard/hand
@onready var hand2: Sprite3D = $DirectionalBillboard/hand2

const DEATH_ZONE = -40
const GIB_MARGIN = -49

var time = 0

@export var SPEED := 10.0
@export var JUMP_VELOCITY := 6.5
@export var icyness := 0.9
var sensetivity := 0.003

@export var grav := Vector3(0,-14,0)
var watergrav := Vector3(0,-4,0)
var texOld := ""
@export var textureBase64 := ""
var weapon = null
@onready var mulSync: MultiplayerSynchronizer = $MultiplayerSynchronizer
var cursorLocked := true
enum STATES {
NORMAL,
DEAD
}
var stepDelay = 0
@export var state = STATES.NORMAL
var dead := false
var deadTime := 0
var moving := false
@export var taunting := false

var lasthitby = self
var lasthitbytype = "player"

@export var displayName := "Player"

@export var mortal := true
@export var invincible := false
@export var canHoldTab := true
@export var hasCrosshair := true
@onready var canTaunt := true

@export_file("*.ogg") var deathSound = "res://sounds/die.ogg"
@export_file("*.ogg") var gibSound = "res://sounds/die_gib.ogg"
@onready var tabMenu: CanvasLayer = $PlayerMenu


@onready var gibEffect = preload("res://nodes/gib_effect.tscn")


@onready var speakingIcon: Sprite3D = $icons/speakingIcon
@onready var typingIcon: Sprite3D = $icons/typingIcon
@export var typing := false
@export var speaking := false

var nameColor : Color = Color.WHITE

func _ready() -> void:
	hp = maxhp
	var playback = voip.get_stream_playback()
	crosshairCanvasLayer.visible = hasCrosshair
	mulSync.set_multiplayer_authority(id)
	sensetivity = Settings.senstivity *0.001
	camera.fov = Settings.fov
	if mulSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		micReady()
		playerName.hide()
		GameManager.myPlayer = self
		displayName = GameManager.myName
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if Settings.defaultSkin != "":
			if FileAccess.file_exists(Settings.skinsPath + "/" + Settings.defaultSkin):
				var img = Image.load_from_file(Settings.skinsPath + "/"+ Settings.defaultSkin).save_png_to_buffer()
				textureBase64 = Marshalls.raw_to_base64(img)
		else:
			textureBase64 = Marshalls.raw_to_base64(billb.texture.get_image().save_png_to_buffer())
	else:
		crosshairCanvasLayer.hide()

@onready var hand1origin = hand1.position
@onready var hand2origin = hand2.position

@onready var blood: ColorRect = $CROSSHAIR/blood

@rpc("any_peer","call_local","reliable")
func removeWeapon():
	if weapon != null:
		weapon.preThrow()
		weapon.queue_free()
		weapon = null


@rpc("any_peer","call_local","reliable")
func giveWeapon(newweapon):
	if weapon != null:
		removeWeapon()
	smirkTime = 120
	var wep
	if newweapon is String:
		wep = load(newweapon).instantiate()
	else:
		wep = newweapon.instantiate()
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

func skinStuff():
	if texOld != textureBase64:
		texOld = textureBase64
		var img = Image.new()
		img.load_png_from_buffer(Marshalls.base64_to_raw(textureBase64))
		var classic = false
		if img.get_size() != Vector2i(192,120):
			img.resize(192,144,Image.INTERPOLATE_NEAREST)
		else:
			print_rich("[color=yellow]Skin detected as classic skin")
			var real = load("res://images/default.png").get_image()
			var og = img
			var tiny = og
			tiny = tiny.get_region(Rect2i(6,6,18,18))
			tiny.resize(7,7)
			var small = og
			small = small.get_region(Rect2i(2,2,22,22))
			small.resize(11,11)
			classic = true
			var newimg = Image.create(192,144,img.has_mipmaps(),img.get_format())
			for x in newimg.get_width():
				for y in newimg.get_height():
					if y <= 119: #normal sprite
						newimg.set_pixel(x,y,og.get_pixel(x,y))
					if y >= 122 && y <= 128 && x >= 4 && x <= 10: # tiny sprite
						newimg.set_pixel(x,y,tiny.get_pixel(x-4,y-122))
					if y >= 132 && y <= 142 && x >= 4 && x <= 14: # small sprite
						newimg.set_pixel(x,y,small.get_pixel(x-4,y-132))
					if x >= 24 && x <= 47 && y >= 120 && y <= 134: # top decap
						var col = Color(og.get_pixel(x-24,y-120).r* 0.5,og.get_pixel(x-24,y-120).g* 0.5,og.get_pixel(x-24,y-120).b* 0.5)
						if og.get_pixel(x-24,y-120).a == 0:
							col.a = 0.0
						if y == 134:
							col.r = 1
						newimg.set_pixel(x,y,col)
					if x >= 48 && x <= 71 && y >= 131 && y <= 144: # bottom decap
						var col = Color(og.get_pixel(x-48,y-120).r* 0.5,og.get_pixel(x-24,y-120).g* 0.5,og.get_pixel(x-24,y-120).b* 0.5)
						if og.get_pixel(x-24,y-120).a == 0:
							col.a = 0.0
						if y == 131:
							col.r = 1
						newimg.set_pixel(x,y,col)
					if x >= 72 && x <= 119 && y >= 120 && y <= 144: # blood and guts
						newimg.set_pixel(x,y,real.get_pixel(x,y))
			img = newimg
		billb.texture = ImageTexture.create_from_image(img)
		changedSkin.emit()
		hand1.texture = billb.texture
		hand2.texture = billb.texture

func _physics_process(delta: float) -> void:
	if GameManager.Players[id].has("color"):
		playerName.modulate = GameManager.Players[id]["color"]
	skinStuff()
	billb.set_animation(animation)
	playerName.text = displayName
	if ouchTime > 0:
		ouchTime -= 1
	if smirkTime > 0:
		smirkTime -= 1
	moving = !(is_on_floor() && round(velocity.x) == 0 && round(velocity.y) == 0 && round(velocity.z) == 0)
	cursorLock()
	doState(state,delta)
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	voiceThings()
	if position.y > DEATH_ZONE:
		if not is_on_floor():
			velocity += grav * delta
			if coyote > 0:
				coyote -= 1
		else:
			coyote = maxCoyote
	blood.modulate.a = lerp(blood.modulate.a,0.0,0.05)
	crosshairIndicator.modulate.a = lerp(crosshairIndicator.modulate.a,0.0,0.1)
	playerName.hide()
	time += 1
	billb.rotation = head.rotation
	billb.rotation.x = camera.rotation.x/1.2
	if camera.current == true:
		billb.pixel_size = 0
	else:
		billb.pixel_size = 0.05
	camera.current = true
	hand1.texture = billb.texture
	hand2.texture = billb.texture
	hand1.no_depth_test = true
	hand2.no_depth_test = true
	if weapon == null:
		sensetivity = Settings.senstivity *0.001
		camera.fov = Settings.fov

@onready var collisionshape: CollisionShape3D = $CollisionShape3D
@onready var bulletDetector: BulletCollider = $bulletDetector
@onready var bulletDetShape: CollisionShape3D = $bulletDetector/CollisionShape3D

@onready var voip: AudioStreamPlayer3D = $voip
@onready var micInput: AudioStreamPlayer = $micInput
@onready var speakLabel: Label = $CROSSHAIR/crosshair/speakLabel

var playback : AudioStreamGeneratorPlayback
var idx : int
var effect : AudioEffectCapture
func micReady():
	micInput.stream = AudioStreamMicrophone.new()
	micInput.play()
	idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)


var buffer_size  = 512
func voiceThings():
	speakLabel.hide()
	speakingIcon.hide()
	if !Settings.haveVC:
		return
	if !Input.is_action_pressed("voice"):
		return
	speakingIcon.show()
	if (effect.can_get_buffer(buffer_size)):
		print(effect.get_buffer(buffer_size))
		sendMicData.rpc(effect.get_buffer(buffer_size))
	#effect.clear_buffer()
	speakLabel.show()


@rpc("any_peer", "call_remote", "reliable")
func sendMicData(data : PackedVector2Array):
	if playback == null:
		playback = voip.get_stream_playback()
	for i in range(0, buffer_size):
		playback.push_frame(data[i])


func respawn():
	removeWeapon()
	hp = maxhp
	state = STATES.NORMAL
	dead = false
	velocity = Vector3.ZERO

func doState(state,delta):
	if taunting || dead:
		hand1.hide()
		hand2.hide()
	else:
		hand1.show()
		hand2.show()
	if state != STATES.DEAD:
		billb.show()
		bulletDetShape.disabled = false
		dead = false
		deadTime = 0
		playerName.show()
	if state == STATES.NORMAL:
		normalState(delta)
	elif state == STATES.DEAD:
		bulletDetShape.disabled = true
		dead = true
		playerName.hide()
		deathState(delta)

func deathState(delta):
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	ouchTime = 10
	var spd = icyness / 2.0
	if !is_on_floor():
		spd = icyness / 10.0
	velocity.x = move_toward(velocity.x,0.0,deltaify(spd,delta))
	velocity.z = move_toward(velocity.z,0.0,deltaify(spd,delta))
	if weapon != null:
		removeWeapon.rpc()
	deadTime += 1
	if deadTime == 1:
		died.emit(hp)
		if hp > GIB_MARGIN:
			emitSound.rpc(deathSound,position,0,randf_range(0.9,1.2))
		else:
			doGibEffect.rpc(position)
			billb.hide()
		velocity.y = JUMP_VELOCITY * 0.8
	animation = deadAnim
	move_and_slide()

@rpc("call_local","any_peer","reliable")
func doGibEffect(pos):
	emitSound(gibSound,pos,0,randf_range(0.9,1.2))
	var gib = gibEffect.instantiate()
	gib.texture = billb.texture
	gib.position = pos
	billb.hide()
	GameManager.scene.add_child(gib)

func watchForDeath():
	if hp <= 0 && mortal:
		state = STATES.DEAD

func normalState(delta):
	if mulSync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	billb.show()
	if !taunting:
		animation = normalAnim
	else:
		animation = tauntAnim
	watchForDeath()
	if position.y < DEATH_ZONE:
		hurt(3,0)
	rotation = Vector3.ZERO
	if !moving && Input.is_action_just_pressed("taunt"):
		taunting = true
	if moving || Input.is_action_just_released("taunt"):
		taunting = false
	if weapon != null:
		hand1.position = lerp(hand1.position,weapon.handGuide1.position,0.7)
		hand2.position = lerp(hand2.position,weapon.handGuide2.position,0.7)
		var shoot = Input.is_action_just_pressed("fire")
		if Input.is_action_just_pressed("throw") && weapon.canBeThrown:
			removeWeapon.rpc()
			return
		if weapon.weapon.autofire:
			shoot = Input.is_action_pressed("fire")
		if shoot:
			weapon.shoot.rpc(camera.global_rotation)
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
	if Input.is_action_just_pressed("jump") && coyote > 0:
		coyote = 0
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var spd = icyness
	if direction && canMove:
		billb.animationSpeed = animationSpeed
		velocity.x = move_toward(velocity.x,direction.x * SPEED,deltaify(spd,delta))
		velocity.z = move_toward(velocity.z,direction.z * SPEED,deltaify(spd,delta))
	else:
		billb.animationSpeed = 0
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
func emitSound(sound : String,pos,volume = 0,pitch = 1.0):
	var s = snd.instantiate()
	s.stream = load(sound)
	s.volume_db = volume
	s.pitch_scale = pitch
	GameManager.scene.add_child(s)
	s.global_position = pos




func hurt(damage,knockback = -5,source = null):
	if invincible:
		ouchTime = 15
		return
	emitSound.rpc("res://sounds/hurt.ogg",position)
	ouchTime = 60
	var dmg = damage
	hp -= dmg
	if source != null:
		if source.Owner != null:
			damageIndicate.rpc_id(source.Owner.id,source.Owner.id,dmg*-1)
	if blood.modulate.a < 1:
		blood.modulate.a += 0.3
	if blood.modulate.a > 0.4:
		blood.modulate.a  = 0.4
	if source != null:
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
