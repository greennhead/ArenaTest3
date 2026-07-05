
extends "res://nodes/weapons/pistol.gd"
# LEGACY WEAPON
@export_category("Damage Type")
@export_enum("Normal","Headshot","Decapitation") var damageType := 0
@export_category("Animation")
@export var animationPlayer : AnimationPlayer
@export_category("LegacyProjectile properties")
@export var oldPhysics := false
@export var damage : int
@export var damageSpread : bool
@export var knockback : float
@export var FireAnimationRotation : float
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
@export var Bounce  : bool
@export var Stick : bool
@export var MaxBounceAmount : int
@export var BounceAcceleration : float
@export_category("vvv Projectile sprite")
@export var Sprite  : String
@export var ProjectileSpriteSheetAnimationSpeed : float
@export var ProjectileSpriteSheetFrames : int
@export var raycast : bool
@export var raycast_dist : int
@export var explosive : bool = false
@export var explosionDamage : float = 0 
@export var explosionKnockback : float = 0
@export var explosionRadius : float = 0
@export_file("*.ogg") var explodeSound : String
@export var explosionSprite : String = ""
@export var explosionSpriteSpeed : float
@export var explosionSpriteFrames : float
@export var ExplodeOnHitPlayer : bool = true
@export var ExplodeOnHitBlock : bool = true
@export var ExplodeOnLifetimeEnd : bool = true
@export var explosionDestroyTiles : bool = false
@export var explosionAffectsShooterOnly : bool = false
@export var eightRotational : bool = false


#func generateFromL():
    #if originalRes == null:
        #return
    #
    #print("Parameters set! Put sprite info, sounds and legacy name manually...")
    #weapon.name = originalRes.name
    #weapon.attackSpeed = originalRes.attackSpeed
    #if weapon.attackSpeed < 60: # i guess
        #weapon.autofire = true
    #weapon.projectile = "res://mods-unpacked/arenatest-LegacyMod/nodes/projectileLegacy.tscn"
    #weapon.projectileSpread = originalRes.projectileSpread
    #weapon.projectileAmount = originalRes.projectileAmount
    #weapon.Ammo = originalRes.Ammo
    #weapon.selfKnockback = originalRes.selfKnockback
    #weapon.canZoom = originalRes.canZoom
    #weapon.zoomFOV = originalRes.zoomFOV
    #oldPhysics = originalRes.oldProjectilePhysics
    #damage = originalRes.damage
    #damageSpread = originalRes.DamageSpreads
    

func preBullet(bullet):
    if animationPlayer != null:
        animationPlayer.play("shoot")
    if bullet.script != load("res://mods-unpacked/arenatest-LegacyMod/nodes/projectile_legacy.gd"): #because modloader doesnt support class_name
        return
    bullet.team = player.team
    bullet.killType = damageType
    bullet.oldPhysics = oldPhysics
    bullet.damage = damage
    bullet.knockback = knockback
    bullet.damageSpread = damageSpread
    bullet.tracerColor = tracerColor
    bullet.speed = speed
    bullet.onHitExplosion = onHitExplosion
    bullet.onKillExposion = onKillExposion
    bullet.grav = grav
    bullet.Lifetime = Lifetime
    bullet.acceleration = acceleration
    bullet.hitbox = hitbox
    bullet.phantom = phantom
    bullet.piercing = piercing
    bullet.Bounce = Bounce
    bullet.Stick = Stick
    bullet.MaxBounceAmount = MaxBounceAmount
    bullet.BounceAcceleration = BounceAcceleration
    bullet.Sprite = Sprite
    bullet.SpriteSheetAnimationSpeed = ProjectileSpriteSheetAnimationSpeed
    bullet.SpriteSheetFrames = ProjectileSpriteSheetFrames
    bullet.raycast = raycast
    bullet.raycast_dist = raycast_dist
    bullet.explosive = explosive
    bullet.explosionDamage = explosionDamage
    bullet.explosionRadius = explosionRadius
    bullet.explodeSound = explodeSound
    bullet.explosionSprite = explosionSprite
    bullet.explosionSpriteFrames = explosionSpriteFrames
    bullet.explosionSpriteSpeed = explosionSpriteSpeed
    bullet.ExplodeOnHitBlock = ExplodeOnHitBlock
    bullet.ExplodeOnHitPlayer = ExplodeOnHitPlayer
    bullet.ExplodeOnLifetimeEnd = ExplodeOnLifetimeEnd
    bullet.explosionDestroyTiles = explosionDestroyTiles
    bullet.explosionKnockback = explosionKnockback
    bullet.explosionAffectsShooterOnly = explosionAffectsShooterOnly
    bullet.eightDirectional = eightRotational



func postShoot(bullet):
    sprite.rotation_degrees.z = FireAnimationRotation


func _physics_process(delta: float) -> void:
    super(delta)
    sprite.rotation_degrees.z = lerp(sprite.rotation_degrees.z,0.0,0.1)
