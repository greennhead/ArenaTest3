extends Resource
class_name Weapon

@export var canRemoveTiles : bool
@export var name : String
@export var attackSpeed : int
@export var autofire : bool = false
@export_file("*.tscn") var projectile : String
@export var projectileSpread  : int
@export var projectileAmount : int = 1
@export var Ammo : int
@export var selfKnockback : int
@export var canZoom : bool
@export var zoomFOV : int

@export var singularSprite : Texture2D
@export var legacyName : String
