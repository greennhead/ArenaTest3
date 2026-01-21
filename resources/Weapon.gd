extends Resource
class_name Weapon
@export var name : String
@export var attackSpeed : int
@export_file("*.tscn") var projectile : String
@export var projectileSpread  : int
@export var projectileAmount : int = 1
@export var Ammo : int
@export var maxAmmo : int
@export var ammoRegen : bool
@export var ammoRegenRate  : int
@export var selfKnockback : int
@export var damage : int
@export var DamageSpreads : bool #(if true, multiply damage by 0.9,1.1) 
@export var Knockback : int
@export var idleAnimationPosition : Vector3 = Vector3(0.489,-0.14,-1.074)
@export var IdleAnimationRotation : Array[float]
@export var IdleAnimationHand1Position : Array[Vector3]
@export var IdleAnimationHand2 : Array[Vector3]
@export var FireAnimationRotation : float
@export var FireAnimationHand1Position : Array[Vector3]
@export var FireAnimationHand2 : Array[Vector3]
@export var sprite : String #base64
@export var SpriteSheetAnimationSpeed : float
@export var SpriteSheetFrames : int
@export var hasCrosshair : bool
@export var canZoom : bool
@export var zoomFOV : int
@export var zoomCircle : bool
#projectile
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
@export var Stick : bool
@export var MaxBounceAmount : int
@export var BounceAcceleration : float
@export var Sprite  : String
@export var ProjectileSpriteSheetAnimationSpeed : float
@export var ProjectileSpriteSheetFrames : int
@export var raycast : bool
@export var raycast_dist : int
@export var pickSound : String
@export var shootSound : String
@export var explosive : bool = false
@export var explosionDamage : float = 0 
@export var explosionKnockback : float = 0
@export var explosionRadius : float = 0
@export var explodeSound : String
@export var explosionSprite : String = ""
@export var explosionSpriteSpeed : float
@export var explosionSpriteFrames : float
@export var ExplodeOnHitPlayer : bool = true
@export var ExplodeOnHitBlock : bool = true
@export var ExplodeOnLifetimeEnd : bool = true
@export var explosionDestroyTiles : bool = false
@export var explosionAffectsShooterOnly : bool = false
@export var eightRotational : bool = false
#back to weapon
@export var shootSprite  : String 
@export var shootSpriteSheetAnimationSpeed : float
@export var shootSpriteSheetFrames : int
@export var spriteRotation : Vector3 = Vector3(0,90,0)

@export var altFire : bool = false
@export var altFireDetonate : bool = false
@export var altFireGun : String
@export var altFireAmmoCost : int

@export var infiniteLifetimeOnStick : bool = false

@export var dropOnAmmoDepletion : bool = true

@export var projectileSoundLoop : String = ""

@export var releaseClusters : bool = false
@export var clusterSpread : int = 0
@export var clusterAmount : int = 0
@export var clusterGun : String

@export var oldProjectilePhysics : bool = true
@export var lockToYAxis : bool = false

@export var gravAcceleration : float = 0
@export var initialYSpeed : float = 0
@export var bounceOffPlayers : bool = false

@export var wallBounceSpread : int = 0
