extends HeldWeapon
@onready var animation: AnimationPlayer = $animation

func postShoot(bullet):
	animation.play("shoot")
	animation.seek(0.0)
