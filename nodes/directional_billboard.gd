
extends Sprite3D
class_name directionalBillboard
var looker
var oldrot = 0
var sprite_frame = 0
@export var Frame = 0
@export var animationSpeed : float = 0.1
@export var animation : EightDirectionalAnimationFrameBased
@export var animationToSync = []
var an = 0
var currArr = []
#THIS IS THE BILLBOARD SCRIPT DO NOT EDIT IT
func _process(delta: float) -> void:
	if get_viewport().get_camera_3d() == null:
		return
	an += (animationSpeed*60)*delta
	if an > 1:
		an = 0
		Frame += 1
	if global_transform.origin.is_equal_approx(get_viewport().get_camera_3d().global_position):
		return
	$Node3D.look_at(get_viewport().get_camera_3d().global_position)
	$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position)
	$MeshInstance3D.global_rotation.x = 0
	sprite_frame = round($Node3D.rotation_degrees.y / 45)
	flip_h = false
	if Frame > currArr.size()-1:
		Frame = 0
	set_sprite(sprite_frame)

func set_sprite(fr):
	hframes = 8
	vframes = 5
	if animation.onlyFront:
		frame = animation.front[Frame]
		currArr = animation.front
		return
	if fr == 0: #FORWARD
		frame = animation.front[Frame]
		currArr = animation.front
	if fr == 1: #LEFT_FRONT
		frame = animation.front_left[Frame]
		currArr = animation.front_left
	if fr == 2: #LEFT
		frame = animation.left[Frame]
		currArr = animation.left
	if fr == 3: #BACK_LEFT
		frame = animation.back_left[Frame]
		currArr = animation.back_left
	if abs(fr) == 4: #BACK
		frame = animation.back[Frame]
		currArr = animation.back
	if fr == -3: #BACK_RIGHT
		frame = animation.back_right[Frame]
		currArr = animation.back_right
	if fr == -2: #RIGHT
		frame = animation.right[Frame]
		currArr = animation.right
	if fr == -1: #RIGHT_FRONT
		frame = animation.front_right[Frame]
		currArr = animation.front_right

func set_animation(anim):
	Frame = 0
	animation = anim

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z
	}
	return save_dict
