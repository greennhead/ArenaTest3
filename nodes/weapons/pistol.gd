extends Node3D
class_name HeldWeapon

@export var weaponDropEffect := true
@export var weaponDropEffectOnAmmoDepletion := true

@export var canBeThrown := true
@onready var handGuide1: Sprite3D = $hand
@onready var handGuide2: Sprite3D = $hand2
@export var weapon : Weapon
@export var player : Player
@onready var snd = preload("res://nodes/sound.tscn")
var delay := 0
@onready var sprite: Sprite3D = $gunSprite
@onready var ammo := weapon.Ammo
@export var pickupSound : AudioStream
@export var shootSound : AudioStream
@onready var projectile = load(weapon.projectile)
@onready var shootPoint: Node3D = $shootPoint
@onready var debris = preload("res://nodes/gun_debris.tscn")
## WEAPON MAKING
## --------
## To make a really simple weapon like old arenatest, base it off of the Arenatest Legacy 
## mod's weapons.
## From there, tweak all the export values just like AT2 editor
## TODO: Add source code link of the mod here.
## --------
## A weapon must contain a .tres and a .tscn file in this exact weapons folder
## The tres must be the weapon's properties 
## The tscn must contain the weapons physical appearance
## WARNING: If you copy a weapon's properties, PRESS "MAKE UNIQUE" and resave it with the
## weapon's name!!!
## -------- 
## If you want your weapon to have it's own animations and stuff, inherit this script (DONT overwrite this)
## and look at how the shotgun does it.
##
## GDscript reference:
## https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
## -------
## WARNING: Only write code here if you know what you're doing.
## If you don't, then you messed up.


func _ready() -> void:
	emitSound(pickupSound)
	handGuide1.hide()
	handGuide2.hide()
	for i in get_children():
		if i is AudioStreamPlayer3D:
			if i.bus == "Master":
				i.bus = "Sound" #ensure that it's not on master

func isHeldByLocalPlayer():
	return player.mulSync.get_multiplayer_authority() == multiplayer.get_unique_id()

func _physics_process(delta: float) -> void:
	sprite.no_depth_test = isHeldByLocalPlayer()
	if delay > 0:
		delay -= 1
		if GameManager.rules.get("ants") == 1 && delay > 0:
			delay -= 1
	if delay == 0 && ammo == 0:
		player.removeWeapon.rpc()

@rpc("any_peer","call_local","reliable")
func shoot(rot):
	if delay > 0 || ammo <= 0:
		return
	if projectile == null:
		projectile = load(weapon.projectile)
	ammo -= 1
	delay = weapon.attackSpeed
	var direction = (player.billb.get_transform().basis.z)
	player.velocity.x -= direction.x * weapon.selfKnockback
	player.velocity.z -= direction.z * weapon.selfKnockback
	player.velocity.y -= direction.y * weapon.selfKnockback/4
	GameManager.num += 1
	seed(GameManager.num)
	var bullet
	for i in weapon.projectileAmount:
		bullet = projectile.instantiate()
		bullet.team = player.team
		bullet.rotation = rot
		bullet.rotation_degrees.x += randf_range(-weapon.projectileSpread,weapon.projectileSpread)
		bullet.rotation_degrees.y += randf_range(-weapon.projectileSpread,weapon.projectileSpread)
		bullet.rotation_degrees.z += randf_range(-weapon.projectileSpread,weapon.projectileSpread)
		bullet.Owner = player
		bullet.position = shootPoint.global_position
		bullet.name = "Projectile" + weapon.name + str(GameManager.num)
		preBullet(bullet)
		GameManager.scene.add_child(bullet)
		postShoot(bullet)
	emitSound(shootSound)
	

func preBullet(bullet):
	pass

func postShoot(bullet):
	pass # you can use this for animation

func preThrow():
	if weaponDropEffect == false:
		return
	if weaponDropEffectOnAmmoDepletion == false && ammo <= 0:
		return
	var oldp = sprite.global_position
	var debr = debris.instantiate()
	debr.texture = sprite.texture
	debr.hframes = sprite.hframes
	debr.vframes = sprite.vframes
	GameManager.scene.add_child(debr)
	debr.global_position = sprite.global_position
	debr.global_rotation = sprite.global_rotation


func emitSound(sound : AudioStream,volume = 0.0,pitch = 1.0):
	var s = snd.instantiate()
	s.stream = sound
	s.position = shootPoint.global_position
	s.volume_db = volume
	s.pitch_scale = pitch + randf_range(0.1,-0.1)
	if GameManager.rules.get("ants") == 1:
		s.pitch_scale += 1.0
	GameManager.scene.add_child.call_deferred(s)
	s.source = shootPoint
