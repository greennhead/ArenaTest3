extends CharacterBody3D
class_name Player

signal died(hp : int, killer,id )
signal tookDamage(damage : int,knockback : Vector3,source, id)
signal gotWeapon(weapon : Weapon, heldWeapon : HeldWeapon, id)
signal droppedWeapon(weapon : Weapon, heldWeapon : HeldWeapon, id)
signal changedSkin(id)
signal taunted(id)
signal untaunted(id)
@onready var pause_vbox: VBoxContainer = $PAUSE/VBoxContainer
var spawnPoint := Vector3.ZERO
var tabdictold = {}
@export var animationSpeed := 0.18
@onready var head: Node3D = $head

@onready var playerName: Label3D = $playerName
@export var canChat := true
@onready var chatBox: LineEdit = $CROSSHAIR/crosshair/chatBox

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
@onready var headlessAnim = "res://resources/anim_DECAP.tres"
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
@export_file("*.ogg") var decapSound = "res://sounds/die_sliced.ogg"
@export_file("*.ogg") var headshotSound = "res://sounds/die_headshot.ogg"
@onready var tabMenu: CanvasLayer = $PlayerMenu


@onready var gibEffect = preload("res://nodes/gib_effect.tscn")


@onready var speakingIcon: Sprite3D = $icons/speakingIcon
@onready var typingIcon: Sprite3D = $icons/typingIcon
@export var typing := false
@export var speaking := false

var nameColor : Color = Color.WHITE

@onready var playerMenu: CanvasLayer = $PlayerMenu

@export var playermenuOpenable := true
var GMplayerMenuDict = ""
var GMscene = null

var bSPEED = SPEED # speed used for bhops
var tookDamageFrom
var tookDamageType := 0

@export var team := -1 #team -1 can damage any team and own team
@export var respawnFall := false
func _ready() -> void:
	GameManager.connect("messageSent",self.addChatMessage)
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
@onready var pauseMenu: CanvasLayer = $PAUSE

func cursorLock():
	if Input.is_action_just_pressed("escape") && !cursorLocked:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cursorLocked = true
		pauseMenu.hide()
		return
	if Input.is_action_just_pressed("escape") && cursorLocked:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursorLocked = false
		pauseMenu.show()
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

@onready var pmvb: VBoxContainer = $PlayerMenu/MenuWindow/ScrollContainer/VBoxContainer
@onready var pmpog: Panel = $PlayerMenu/MenuWindow/ScrollContainer/VBoxContainer/player

var pmenutime := 0

func playerMenuStuff():
	pmenutime += 1
	if playermenuOpenable:
		playerMenu.visible = Input.is_action_pressed("tab")
	if pmenutime % 60 == 0:
		pmenutime = 0
		updatePlayerMenu()


func updatePlayerMenu():
	for i in pmvb.get_children():
		if i != pmpog:
			i.queue_free()
	for i in get_tree().get_nodes_in_group("player"):
		var p = pmpog.duplicate()
		p.show()
		pmvb.add_child(p)
		p.tiedTo = i
		p.pname.text = "[color=#" + i.nameColor.to_html(false) + "]" +  i.displayName + "[/color] "
		p.icon.texture = i.billb.texture
		if GMplayerMenuDict != null && GMscene != null:
			for j in GMscene.get(GMplayerMenuDict)[i.id].size():
				p.pscores.text += str(GMscene.get(GMplayerMenuDict)[i.id][j][0]) + ": " + str(GMscene.get(GMplayerMenuDict)[i.id][j][1])
				if j < GMscene.get(GMplayerMenuDict)[i.id].size()-1:
					p.pscores.text += " - "


@onready var chat: CanvasLayer = $CHAT
@onready var chatMessage: RichTextLabel = $CHAT/chatMessage
@onready var chat_vbox: VBoxContainer = $CHAT/chatContainer/VBoxContainer
var inactiveChatTime := 0
func addChatMessage(text):
	inactiveChatTime = 600
	if chat_vbox.get_children().size() > 10:
		chat_vbox.get_children()[0].queue_free()
	var c = chatMessage.duplicate()
	chat_vbox.add_child(c)
	c.text = text
	c.show()

func chatStuff():
	inactiveChatTime -= 1
	if inactiveChatTime < 0:
		chat_vbox.modulate.a = 0.3
	else:
		chat_vbox.modulate.a = 1.0
	if !canChat || Console.is_visible():
		return
	typingIcon.visible = chatBox.visible
	if Input.is_action_just_pressed("chat") && !chatBox.visible:
		chatBox.show()
		chatBox.grab_focus()
		return
	if Input.is_action_just_pressed("chat") && chatBox.visible:
		if chatBox.text.replace(" ", "") != "":
			GameManager.message.rpc(chatBox.text,false,"[color=#" + nameColor.to_html() + "]<" + displayName +  ">[/color] "  )
		chatBox.hide()
		chatBox.text = ""
		return


var canActuallyMove = true
func _physics_process(delta: float) -> void:
	if GameManager.rules.get("ants") == 1:
		scale = Vector3(0.4,0.4,0.4)
	if GameManager.Players[id].has("color"):
		playerName.modulate = GameManager.Players[id]["color"]
	nameColor = playerName.modulate
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
	canActuallyMove = canMove && Console.is_visible() == false && chatBox.visible == false && pauseMenu.visible == false
	playerMenuStuff()
	chatStuff()
	if GameManager.rules.get("bhop") == 1:
		update_frame_timer()
	voiceThings()
	if position.y > DEATH_ZONE:
		if not is_on_floor():
			if GameManager.rules.get("bhop") == 0:
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
	scale = Vector3.ONE
	hp = maxhp
	state = STATES.NORMAL
	dead = false
	velocity = Vector3.ZERO
	spawnPoint = global_position

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
		doSignal.rpc("died",[hp,tookDamageFrom,id])
		if hp > GIB_MARGIN:
			if tookDamageType == GameManager.deathAnimation.NORMAL:
				animation = deadAnim
				emitSound.rpc(deathSound,position,0,randf_range(0.9,1.2))
			elif tookDamageType == GameManager.deathAnimation.HEADSHOT:
				animation = headlessAnim
				emitSound.rpc(headshotSound,position,0,randf_range(0.9,1.2))
				doGibEffect.rpc(position,8,false)
			elif tookDamageType == GameManager.deathAnimation.SLICED:
				animation = headlessAnim
				emitSound.rpc(decapSound,position,0,randf_range(0.9,1.2))
				doGibEffect.rpc(position,4,false)
				doDecapEffect.rpc(position)
		else:
			emitSound.rpc(gibSound,position,0,randf_range(0.9,1.2))
			doGibEffect.rpc(position)
			billb.hide()
		velocity.y = JUMP_VELOCITY * 0.8
	
	move_and_slide()

@onready var decapEffect = preload("res://nodes/player_head.tscn")

@rpc("call_local","any_peer","reliable")
func doDecapEffect(pos):
	var gib = decapEffect.instantiate()
	gib.position = pos
	gib.texture = billb.texture
	GameManager.scene.add_child(gib)

@rpc("call_local","any_peer","reliable")
func doGibEffect(pos,power := 32,hide := true):
	var gib = gibEffect.instantiate()
	gib.power = power
	gib.texture = billb.texture
	gib.position = pos
	if hide:
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
		if respawnFall:
			global_position = spawnPoint
			respawn()
		else:
			hurt(3,0)
	rotation = Vector3.ZERO
	if !moving && Input.is_action_just_pressed("taunt"):
		taunting = true
	if moving || Input.is_action_just_released("taunt"):
		taunting = false
	if weapon != null:
		hand1.position = lerp(hand1.position,weapon.handGuide1.position,0.7)
		hand2.position = lerp(hand2.position,weapon.handGuide2.position,0.7)
		var shoot = Input.is_action_just_pressed("fire") && canActuallyMove
		if Input.is_action_just_pressed("throw") && weapon.canBeThrown:
			removeWeapon.rpc()
			return
		if weapon.weapon.autofire:
			shoot = Input.is_action_pressed("fire")
		if shoot && canMove:
			weapon.shoot.rpc(camera.global_rotation)
		if weapon.weapon.canZoom:
			if Input.is_action_pressed("altfire") && canActuallyMove:
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
	var jump = Input.is_action_just_pressed("jump")
	if GameManager.rules.get("autobhop") == 1:
		jump = Input.is_action_pressed("jump") && coyote > 0
	if !canActuallyMove:
		jump = false
	if jump && coyote > 0 && canActuallyMove && GameManager.rules.get("bhop") == 0:
		coyote = 0
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var spd = icyness
	if GameManager.rules.get("bhop") == 0:
		if direction && canActuallyMove:
			billb.animationSpeed = animationSpeed
			velocity.x = move_toward(velocity.x,direction.x * SPEED,deltaify(spd,delta))
			velocity.z = move_toward(velocity.z,direction.z * SPEED,deltaify(spd,delta))
		else:
			billb.animationSpeed = 0
			velocity.x = move_toward(velocity.x,0.0,deltaify(spd,delta))
			velocity.z = move_toward(velocity.z,0.0,deltaify(spd,delta))
	else:
		billb.animationSpeed = (abs(velocity.x) + abs(velocity.z))*0.02
		velocity = get_next_velocity(velocity,delta,jump)
	move_and_slide()

# credit to bhop3d by birdt https://github.com/BirDt/bhop3d/blob/main/addons/bhop3d/src/bhop3d.gd
#region bhop
@export_group("setrule bhop settings")
@export var bhop_frames : int = 3
@export var additive_bhop : bool = true
@export var friction : float = 6
@export var air_accelerate : float = 85
## Max velocity on the ground
@export var ground_accelerate : float = 250
@export var max_ground_velocity : float = 10.0
## Max velocity in the air
@export var max_air_velocity : float = 1.5
func get_next_velocity(previousVelocity, delta,jump):
	var grounded = is_on_floor()
	
	# Apply friction if player is grounded, and if the frame_timer indicates it should be applied
	if grounded and (frame_timer >= bhop_frames):
		var speed = previousVelocity.length()
		if speed != 0:
			var drop = speed * friction * delta
			previousVelocity *= max(speed - drop, 0) / speed
	else:
		# If bunnyhopping is additive, we should use the air velocity and accelerate values for all frames
		# that the bunnyhop is possible
		if not additive_bhop:
			grounded = false
	var max_vel = SPEED *0.6 if grounded else  max_air_velocity
	var accel = ground_accelerate if grounded else air_accelerate
	
	# Calculate velocity for next frame
	var velocity = accelerate(get_wishdir(), previousVelocity, accel, max_vel, delta)
	# Apply gravity
	velocity += grav * delta
	
	# Apply jump if desired
	if (jump && canActuallyMove && coyote > 0):
		coyote = 0
		velocity.y = JUMP_VELOCITY
	# Return the new velocity
	return velocity

## Count of frames since last grounded
var frame_timer = bhop_frames
## Update frame timer if necessary
func update_frame_timer():
	if is_on_floor():
		frame_timer += 1
	else:
		frame_timer = 0

func accelerate(accelDir, prevVelocity, acceleration, max_vel, delta):
	# Calculate projected velocity for the next frame
	var projectedVel = prevVelocity.dot(accelDir)
	# Calculate the accelerated velocity given the maximum velocity, projected velocity, and current acceleration
	var accelVel = clamp(max_vel - projectedVel, 0, acceleration * delta)
	# Return the previous velocity in addition to the new velocity post acceleration
	return prevVelocity + accelDir * accelVel

func get_wishdir():
	if !canActuallyMove:
		return Vector3.ZERO
	if GameManager.rules.get("bhopwiggle") == 0:
		return Vector3.ZERO + \
				(head.global_transform.basis.z * Input.get_axis("up", "down")) +\
				(head.global_transform.basis.x * Input.get_axis("left", "right"))
	else:
				return Vector3.ZERO + \
				(camera.global_transform.basis.z * Input.get_axis("up", "down")) +\
				(camera.global_transform.basis.x * Input.get_axis("left", "right"))
#endregion

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
	if GameManager.rules.get("ants") == 1:
		s.pitch_scale += 1.0
	GameManager.scene.add_child(s)
	s.global_position = pos


@rpc("any_peer","reliable","call_local")
func doSignal(signalName, args : Array = []):
	var call_args = [signalName]
	for i in args:
		call_args.append(i)
	emit_signal.callv(call_args)


func hurt(damage,knockback = -5,source = null, damageType : int = GameManager.deathAnimation.NORMAL):
	if invincible:
		ouchTime = 15
		return
	if source != null:
		if source.team == team && team != -1:
			return
	doSignal.rpc("tookDamage",[damage,knockback,source,id])
	emitSound.rpc("res://sounds/hurt.ogg",position)
	ouchTime = 60
	var dmg = damage
	hp -= dmg
	tookDamageType = damageType
	if source != null:
		if source.Owner != null && source.Owner is Player:
			tookDamageFrom = source.Owner.id
			damageIndicate.rpc_id(source.Owner.id,source.Owner.id,dmg*-1)
	if tookDamageFrom == null || source == null:
		tookDamageFrom = "Shenanigans"
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
