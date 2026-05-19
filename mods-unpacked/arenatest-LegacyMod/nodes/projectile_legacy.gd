# WARNING This is a really bad projectile script from an older version of the game
# and its not good dont use it
# unless youre porting something
extends Area3D


@export var tracerColor : Color
@export var speed : float
@export var onHitExplosion : bool
@export var onKillExposion : bool
@export var grav : int
@export var Lifetime : int
@export var acceleration :  float
@export var hitbox = Vector3(0.2,0.2,0.2)
@export var phantom : bool
@export var piercing : bool
@export var IsHoming : bool
@export var HomingSpeed : int
@export var Bounce  : bool
@export var MaxBounceAmount : int
@export var BounceAcceleration : float
var sticked = false
@onready var id = int(name)
var wallbounces = 0
@export var Sprite  : String
@export var SpriteSheetAnimationSpeed : float
@export var SpriteSheetFrames : int
var lasthit = ""
var gunShotFrom = ""
var wallBounceSpread = 0
@onready var hitboxNode: CollisionShape3D = $hitbox

@onready var sprite: Sprite3D = $sprite
@onready var trail2: GPUParticles3D = $trail2
var explosive = false
var explosionDamage = 0 
var infiniteLifetimeOnStick = false
var explosionKnockback = 0
var explosionRadius = 0
var explodeSound 
var explosionSprite = ""
var explosionDestroyTiles = false
var hurtDelay = 0
var raycast = false
var raycast_dist = 100
@onready var bouncewallray: RayCast3D = $bouncewallray
@onready var bounceray: RayCast3D = $bounceray
var Owner : Player
var Stick = false
var bounces = 0
var bounceOffPlayers = false
var damageSpread = false
var explosionAffectsShooterOnly = false
var knockback = 0
var animTime = 0
var spawnedRay = false
var life = 0
var explosionSpriteSpeed =0
var explosionSpriteFrames =0
var damage = 0
var hitdelay = 0
var ysp = 0
var bouncedelay = 0
@onready var instaray: RayCast3D = $instaray
@onready var trail_guide: Node3D = $trail_guide



@onready var posList = [position,position]
@onready var boom = preload("uid://dfict4ca6x38e")
var ExplodeOnHitPlayer = true
var ExplodeOnHitBlock = true
var ExplodeOnLifetimeEnd = true
var eightDirectional = false
var sprite_frame  = 0
var frameOffset = 0
var trueFrame = 0
var soundLoop = ""
var releaseClusters = false
var clusterSpread = 0
var clusterAmount = 0
var clusterWepArray = []
var clusterWeapon : Weapon
var oldPhysics = false
var totalAcceleration = 0
@onready var checks_ray: RayCast3D = $checksRay
@onready var wall_bounce_hitbox: CollisionShape3D = $wallBounceArea/wallBounceHitbox
@onready var bounce_hitbox: CollisionShape3D = $bounceArea/BounceHitbox
@onready var wall_bounce_area: Area3D = $wallBounceArea
@onready var bounce_area: Area3D = $bounceArea
var gravAcceleration = 0
var isFromTurret = false
func  _ready() -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
	if soundLoop != "":
		var path = OS.get_executable_path().replace("/arenatest.exe","") + "/SOUNDS/" + soundLoop + ".ogg"
		if GameManager.debug:
			path = 'E:/GodotExport/arenatest/SOUNDS/' + soundLoop + ".ogg"
		var file = AudioStreamOggVorbis.load_from_file(path)
		file.loop = true
		$loopSound.stream = file
		$loopSound.play()
	$instaray.target_position.z = -raycast_dist
	hitboxNode.shape = hitboxNode.shape.duplicate()
	hitboxNode.shape.size = hitbox
	trail2.draw_pass_1.material.albedo_color = tracerColor
	trail2.emitting = true
	bounceray.target_position.y = hitbox.y * -1.5
	bouncewallray.target_position.z = hitbox.z * 1.5
	if Sprite != "":
		var img = Image.new()
		img.load_png_from_buffer(Marshalls.base64_to_raw(Sprite))
		sprite.texture = ImageTexture.create_from_image(img)
		sprite.hframes = clamp(SpriteSheetFrames,1,9999)
	if eightDirectional:
		dir()

func load_image(path: String):
	var image = Image.load_from_file(path)
	if image == null:
		return
	var texture = ImageTexture.create_from_image(image)
	return texture

func setSpriteLua(sprite):
	$sprite.texture = load_image(GameManager.mappath.replace(".json","") + "/luaGraphics/" + sprite)

func dir():
	sprite.vframes = 8
	$Node3D.look_at(get_viewport().get_camera_3d().global_position)
	$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position)
	$MeshInstance3D.global_rotation.x = 0
	sprite_frame = round($Node3D.rotation_degrees.y / 45)
	set_sprite(sprite_frame)

func set_sprite(fr):
	if fr == 0: #FORWARD
		frameOffset = 0
	if fr == 1: #LEFT_FRONT
		frameOffset = 7
	if fr == 2: #LEFT
		frameOffset = 6
	if fr == 3: #BACK_LEFT
		frameOffset = 5
	if abs(fr) == 4: #BACK
		frameOffset = 4
	if fr == -3: #BACK_RIGHT
		frameOffset = 3
	if fr == -2: #RIGHT
		frameOffset = 2
	if fr == -1: #RIGHT_FRONT
		frameOffset = 1

func _physics_process(delta: float) -> void:
	
	if eightDirectional:
		dir()
	if hurtDelay > 0:
		hurtDelay -= 60*delta
	if hurtDelay < 0:
		hurtDelay = 0
	var oldpos = global_position
	oldpos = global_position
	if raycast && instaray.is_colliding():
		if instaray.get_collider().get_parent() != Owner && instaray.get_collider().get_parent() != self:
			global_position = instaray.get_collision_point()
			instaray.enabled = false
	if raycast && !instaray.is_colliding() && life > 1:
		global_position = instaray.target_position
		instaray.enabled = false
	if raycast && !spawnedRay:
		spawnedRay = true
	if hitdelay > 0:
		hitdelay -= 60*delta
	if hitdelay < 0:
		hitdelay = 0
	if bouncedelay > 0:
		bouncedelay -= 60*delta
	if bouncedelay < 0:
		bouncedelay = 0
	life += 60*delta
	if infiniteLifetimeOnStick && sticked:
		life = 0
	if life > Lifetime:
		if explosive && ExplodeOnLifetimeEnd:
			explode(position)
		queue_free()
		if releaseClusters:
				var spreads = []
				var weapon = clusterWeapon
				seed(int(name))
				for i in clusterAmount:
					spreads.append(Vector3(randf_range(-clusterSpread,clusterSpread),randf_range(-clusterSpread,clusterSpread),randf_range(-clusterSpread,clusterSpread)))
				shoot.rpc(Owner.id,global_position,Owner.id,rotation_degrees,clusterAmount,null,spreads)
	animTime += (SpriteSheetAnimationSpeed*60)*delta
	if animTime > 1:
		if trueFrame  >= SpriteSheetFrames-1:
			trueFrame = 0
		else:
			trueFrame += 1
		animTime = 0
	sprite.frame = trueFrame
	if eightDirectional:
		sprite.frame = trueFrame + (sprite.hframes*frameOffset)
	if sticked == false && oldPhysics:
		ysp += (grav*60)*delta
		speed += (acceleration*60)*delta
	checkcol()
	if oldPhysics:
		if sticked == false:
			for i in -ysp:
				position.y += 0.001
			for i in ysp:
				position.y -= 0.001
				if Bounce && bouncewallray.is_colliding() && bouncewallray.get_collider() is not Player && bouncedelay == 0:
					seed(int(name)^2 + wallbounces)
					rotation_degrees.y += 180 + randi_range(-wallBounceSpread,wallBounceSpread)
					bouncedelay = 2
				if Bounce && bounceray.is_colliding() && bounceray.get_collider():
					bounces += 1
					ysp = BounceAcceleration
	if oldPhysics:
		speed = clamp(speed,-100,100)
		ysp = clamp(ysp,-100,100)
	else:
		speed = clamp(speed,-1000,1000)
		ysp = clamp(ysp,-1000,1000)
	if sticked == false:
		if oldPhysics:
			move()
		if !oldPhysics:
			move_new(delta)

func move_new(delta):
	grav += gravAcceleration*0.01
	trail2.emit_particle(transform, Vector3.ZERO, Color.WHITE, Color.WHITE, GPUParticles3D.EMIT_FLAG_POSITION)
	totalAcceleration += (acceleration*60)*delta
	wall_bounce_hitbox.position.z = -$hitbox.shape.size.z
	wall_bounce_hitbox.shape.size = $hitbox.shape.size
	bounce_hitbox.shape.size = $hitbox.shape.size
	bounce_hitbox.position.y = -$hitbox.shape.size.z
	checks_ray.target_position.z = -(speed+1)*0.01
	checks_ray.force_raycast_update()
	$bounceArea.global_rotation = Vector3.ZERO
	if checks_ray.is_colliding():
		if checks_ray.get_collider() is GridMap:
			if Bounce && bounces < MaxBounceAmount:
				seed(int(name)^2 + wallbounces)
				rotation_degrees.y += 180 + randi_range(-wallBounceSpread,wallBounceSpread)
		if checks_ray.get_collider() is GridMap && !phantom:
				position = checks_ray.get_collision_point()
				checkcol()
		if checks_ray.get_collider() is BulletCollider:
			if checks_ray.get_collider().get_parent() != Owner:
				position = checks_ray.get_collision_point()
				checkcol()
	position += get_transform().basis.z * -(speed+totalAcceleration)*0.01
	checks_ray.target_position.z = 0
	checks_ray.target_position.y = -(ysp+1) * 0.01
	checks_ray.force_raycast_update()
	var bCol = false
	bounce_hitbox.shape.size.y =  (ysp+2)*0.01
	for i in bounce_area.get_overlapping_bodies():
		if i is GridMap && Bounce && bounces < MaxBounceAmount:
			bounces += 1
			ysp = -BounceAcceleration/10
			bCol = true
	if bCol && phantom:
		for i in bounce_area.get_overlapping_bodies():
			if i is GridMap:
				if position.y < i.position.y+1:
					position.y += 0.1
	if !bCol:
		ysp += (grav*6)*delta
	position.y -= (ysp)*0.01

func raycheck():
	$hitwallcheck.target_position.z = -speed* 0.01
	$hitwallcheck.force_raycast_update()
	if $hitwallcheck.is_colliding():
		if $hitwallcheck.get_collider() != Owner && $hitwallcheck.get_collider().get_parent() != Owner:
			if $hitwallcheck.get_collider() is StaticBody3D && !phantom:
				position = $hitwallcheck.get_collision_point()
				checkcol()
				return true
			if $hitwallcheck.get_collider() is BulletCollider:
				if $hitwallcheck.get_collider().get_parent().dead == false:
					if hitdelay == 0:
						position = $hitwallcheck.get_collision_point()
						checkcol()
						return true
	return false

func move():
	for i in round(speed):
		var a = raycheck()
		bouncewallray.target_position.z =  -speed* 0.3
		bouncewallray.force_raycast_update()
		if Bounce && bouncewallray.is_colliding() && bouncewallray.get_collider() is not Player && bouncedelay == 0:
			bouncedelay = 2
			seed(int(name)^2 + wallbounces)
			rotation_degrees.y += 180 + randi_range(-wallBounceSpread,wallBounceSpread)
			a = false
		trail2.emit_particle(transform, Vector3.ZERO, Color.WHITE, Color.WHITE, GPUParticles3D.EMIT_FLAG_POSITION)
		if !a:
			position += get_transform().basis.z * -speed * 0.01
			checkcol()

func checkcol():
	for area in get_overlapping_areas():
		if area.get_parent() is Player && area.get_parent() != Owner  && hitdelay == 0 && area is BulletCollider:
			hit(area.get_parent())
			lasthit = "player"
			hitdelay = 5
			hurtDelay = 10
			break
	for body in get_overlapping_bodies():
		if !phantom && (body is StaticBody3D || body is GridMap) && hitdelay == 0:
			if Stick:
				sticked = true
				phantom = true
				return
			hit(body)
			hitdelay = 5
			hurtDelay = 10
			lasthit = "block"
			break

func hit(body):
	if hurtDelay == 0:
		if body is Player:
			lasthit = "player"
			body.lasthitby = Owner
			body.lasthitbytype = "player"
			if isFromTurret:
				body.lasthitbytype = "turret"
			hurtDelay = 5
			$MultiplayerSynchronizer.set_multiplayer_authority(body.id)
			if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
				body.hurt(damage,knockback,self)
	if body is Player && bounceOffPlayers:
		seed(int(name)^2 + wallbounces)
		rotation_degrees.y += 180 + randi_range(-wallBounceSpread,wallBounceSpread)
		return
	if !piercing:
		trail2.reparent(GameManager.scene)
		if explosive && ExplodeOnHitBlock && body is GridMap:
			explode(position)
		if explosive && ExplodeOnHitPlayer && body is Player:
			explode(position)
		if releaseClusters:
			var spreads = []
			var weapon = clusterWeapon
			$MultiplayerSynchronizer.set_multiplayer_authority(1)
			for i in clusterAmount:
				spreads.append(Vector3(randf_range(-clusterSpread,clusterSpread),randf_range(-clusterSpread,clusterSpread),randf_range(-clusterSpread,clusterSpread)))
			if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
				shoot.rpc(Owner.id,global_position,Owner.id,rotation_degrees,clusterAmount,null,spreads)
		queue_free()


#@rpc("any_peer","reliable","call_local")
#func emitSoundOgg(sound ,pos):
	#var s = load("res://nodes/sound.tscn").instantiate()
	#s.stream = sound
	#get_tree().current_scene.add_child(s)
	#s.global_position = pos


func explode(position):
	var a = boom.instantiate()
	a.damage = explosionDamage
	a.knockback = explosionKnockback
	a.radius = explosionRadius
	a.sprite = explosionSprite
	a.frames = explosionSpriteFrames
	a.speed = explosionSpriteSpeed
	a.Owner = Owner
	a.explosionAffectsShooterOnly = explosionAffectsShooterOnly
	a.destroyTiles = explosionDestroyTiles
	GameManager.scene.add_child(a) 
	a.position = position
	emitSound(explodeSound,position,0.0,randf_range(0.9,1.1))
	#var path = OS.get_executable_path().replace("/arenatest.exe","") + "/SOUNDS/" + explodeSound + ".ogg"
	#if GameManager.debug:
		#path = 'E:/GodotExport/arenatest/SOUNDS/' + explodeSound + ".ogg"
	#emitSoundOgg(AudioStreamOggVorbis.load_from_file(path),position)
@onready var snd = preload("res://nodes/sound.tscn")

@rpc("any_peer","reliable","call_local")
func emitSound(sound : String,pos,volume,pitch):
	var s = snd.instantiate()
	s.stream = load(sound)
	s.volume_db = volume
	s.pitch_scale = pitch
	GameManager.scene.add_child(s)
	s.global_position = pos

func _on_loop_sound_finished() -> void:
	$loopSound.play()

@rpc("authority","reliable","call_local")
func shoot(id ,pos : Vector3,owner,rotation,amount,shootSound,spreadArr,alt : bool = false):
	var idx = 0
	for x in amount:
		var proj = load("res://nodes/LegacyMod/projectileLegacy.tscn").instantiate()
		proj.rotation = rotation + Vector3(deg_to_rad(spreadArr[idx].x),deg_to_rad(spreadArr[idx].y),deg_to_rad(spreadArr[idx].z))
		idx += 1
		var own
		for i in get_tree().get_nodes_in_group("player"):
			if i.id == owner:
				own = i
		if clusterWepArray.size() == 0:
			clusterWepArray = own.clusterWepArray
		if clusterWepArray == null:
			return
		var wep = clusterWepArray
		proj.Owner = own
		proj.damage = wep[0]
		proj.knockback = wep[1]
		proj.tracerColor  = wep[2]
		proj.speed = wep[3]
		proj.onHitExplosion = wep[4]
		proj.onKillExposion = wep[5]
		proj.grav = wep[6]
		proj.Lifetime  = wep[7]
		proj.acceleration  = wep[8]
		proj.hitbox  = wep[9]
		proj.phantom  = wep[10]
		proj.piercing = wep[11]
		proj.IsHoming  = wep[12]
		proj.HomingSpeed  = wep[13]
		proj.Bounce   = wep[14]
		proj.MaxBounceAmount  = wep[15]
		proj.BounceAcceleration  = wep[16]
		proj.Sprite  = wep[17]
		proj.SpriteSheetAnimationSpeed  = wep[18]
		proj.SpriteSheetFrames  = wep[19]
		proj.damageSpread = wep[20]
		proj.raycast = wep[21]
		proj.raycast_dist = wep[22]
		proj.explosive = wep[23]
		proj.explosionDamage = wep[24]
		proj.explosionKnockback = wep[25]
		proj.explosionRadius = wep[26]
		proj.explodeSound = wep[27]
		proj.explosionSprite = wep[28]
		proj.explosionSpriteSpeed = wep[29]
		proj.explosionSpriteFrames = wep[30]
		proj.ExplodeOnHitPlayer = wep[31]
		proj.ExplodeOnHitBlock = wep[32]
		proj.ExplodeOnLifetimeEnd = wep[33]
		proj.explosionDestroyTiles = wep[34]
		proj.explosionAffectsShooterOnly = wep[35]
		proj.Stick = wep[36]
		proj.infiniteLifetimeOnStick = wep[37]
		proj.eightDirectional = wep[38]
		proj.gunShotFrom = wep[39]
		proj.soundLoop = wep[40]
		proj.releaseClusters = false
		proj.clusterSpread = wep[42]
		proj.clusterAmount = wep[43]
		proj.oldPhysics = wep[44]
		proj.gravAcceleration = wep[45]
		proj.ysp = wep[46]
		proj.bounceOffPlayers = wep[47]
		if GameManager.myPlayer.id == multiplayer.get_unique_id():
			GameManager.num += 1
			proj.name = str(GameManager.num)
		GameManager.scene.add_child(proj)
		proj.global_position = pos
