extends Area3D
class_name Explosion
var radius = 1
@onready var c: CollisionShape3D = $CollisionShape3D
var damage = 0
var knockback = 0
var sprite = ""
var speed = 0
var frames = 0
var p = 0
var destroyTiles = false
var damageSpread = false
var Owner
var time = 0
var explosionAffectsShooterOnly = false
@onready var rubble = preload("res://nodes/LegacyMod/tile_rubble.tscn")
func _ready() -> void:
	if radius <= 0:
		c.queue_free()
	else:
		c.shape.radius = radius
	if sprite != "":
		var textureBase = sprite
		var img = Image.new()
		img.load_png_from_buffer(Marshalls.base64_to_raw(textureBase))
		$Sprite3D.texture = ImageTexture.create_from_image(img)
		$Sprite3D.hframes = frames



@rpc("reliable","authority","call_local")
func breakTile(position,gridmap):
	var gr = GameManager.scene.find_child(gridmap)
	gr.set_cell_item(Vector3i(position),-1)
	#print(position)
	#print("ID: " + str(GameManager.myPlayer.id))
	#var i = null
	#for j in get_tree().get_nodes_in_group("block"):
		#if j.position == position:
			#i = j
	#if i == null:
		#return
	#var a = rubble.instantiate()
	#a.position = i.position
	#a.texture = i.texture
	#get_tree().current_scene.add_child(a)
	#i.queue_free()

func _process(delta: float) -> void:
	if time == 0:
		for i in get_overlapping_bodies():
			if i.is_in_group("destructible"):
				i.queue_free()
			if i is GridMap && destroyTiles:
				var p : GridMap = i
				for cell in p.get_used_cells():
					if p.to_global(cell).distance_to(global_position) < radius:
						if multiplayer.get_unique_id() == 1:
							breakTile.rpc(cell,p.name)
			if i is Player:
				if explosionAffectsShooterOnly && i != Owner:
					return
				if Owner != null:
					i.lasthitby = Owner
					i.lasthitbytype = "player"
				else:
					i.lasthitbytype = "turret"
				$MultiplayerSynchronizer.set_multiplayer_authority(i.id)
				if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
					i.hurt(round(damage),0,self)
				var k = i.global_position.direction_to(global_position)
				i.velocity += k*knockback
				time = 1
	p += (speed*60)*delta
	if p >= 1:
		p = 0
		$Sprite3D.frame += 1
	if $Sprite3D.frame >= frames - 1:
		queue_free()


func _on_timer_timeout() -> void:
	if c != null:
		c.disabled = true
