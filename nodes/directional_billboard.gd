
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
@onready var node: Node3D = $Node3D
var legacy := false
# WARNING THIS IS THE BILLBOARD SCRIPT DO NOT EDIT IT
func _process(delta: float) -> void:
	if get_viewport().get_camera_3d() == null:
		return
	an += (animationSpeed*60)*delta
	if an > 1:
		an = 0
		Frame += 1
	if global_transform.origin.is_equal_approx(get_viewport().get_camera_3d().global_position):
		return
	node.look_at(get_viewport().get_camera_3d().global_position)
	sprite_frame = round(node.rotation_degrees.y / 45)
	flip_h = false
	set_sprite(sprite_frame)

func set_sprite(fr):
	hframes = 8
	vframes = 6
	if legacy:
		vframes = 5
	if animation.onlyFront:
		currArr = animation.front
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.front[Frame]
		return
	if fr == 0: #FORWARD
		currArr = animation.front
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.front[Frame]
	if fr == 1: #LEFT_FRONT
		currArr = animation.front_left
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.front_left[Frame]
	if fr == 2: #LEFT
		currArr = animation.left
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.left[Frame]
	if fr == 3: #BACK_LEFT
		currArr = animation.back_left
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.back_left[Frame]
	if abs(fr) == 4: #BACK
		currArr = animation.back
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.back[Frame]
	if fr == -3: #BACK_RIGHT
		currArr = animation.back_right
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.back_right[Frame]
	if fr == -2: #RIGHT
		currArr = animation.right
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.right[Frame]
	if fr == -1: #RIGHT_FRONT
		currArr = animation.front_right
		if Frame >= currArr.size():
			Frame = 0
		frame = animation.front_right[Frame]

func set_animation(anim):
	if animation != load(anim):
		Frame = 0
		print_rich("[color=red]Frame 0!")
	animation = load(anim)
