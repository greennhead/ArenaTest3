extends Area3D
class_name LegacyBillboard #THIS BILLBOARD IS FROM ARENATEST2
@onready var sprite: Sprite3D = $Sprite3D
var sprite_frame = 0
var frameOffset = 0
var speed = 0
var animTime = 0
var trueFrame = 0
var frames = 1
var texture = ""
var scrollToCamera = false

var rotation_x = 0.0
var rotation_y = 0.0
var rotation_z = 0.0

func _ready() -> void:
	if texture  != "":
		var textureBase = texture 
		var img = Image.new()
		img.load_png_from_buffer(Marshalls.base64_to_raw(textureBase))
		$Sprite3D.texture = ImageTexture.create_from_image(img)
		$Sprite3D.hframes = frames
	if scrollToCamera == false:
		sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	else:
		sprite.vframes = 8
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rotation = Vector3(rotation_x,rotation_y,rotation_z)

func _process(delta: float) -> void:
	sprite.hframes = frames
	if scrollToCamera:
		dir()
	animTime += (speed*60)*delta
	if animTime > 1:
		if trueFrame  >= frames-1:
			trueFrame = 0
		else:
			trueFrame += 1
		animTime = 0
	sprite.frame = trueFrame + (sprite.hframes*frameOffset)

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

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"texture" : texture,
		"rotation_x" : rotation.x,
		"rotation_y" : rotation.y,
		"rotation_z" : rotation.z,
		"frames" : frames,
		"speed" : speed,
		"scrollToCamera" : scrollToCamera,
		"trueFrame" : trueFrame,
		"animTime" : animTime
	}
	return save_dict


func _on_timer_timeout() -> void:
	if texture  != "":
		var textureBase = texture 
		var img = Image.new()
		img.load_png_from_buffer(Marshalls.base64_to_raw(textureBase))
		$Sprite3D.texture = ImageTexture.create_from_image(img)
		$Sprite3D.hframes = frames
	if scrollToCamera == false:
		sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	else:
		sprite.vframes = 8
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
