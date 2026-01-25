extends HeldWeapon
@onready var animation: AnimationPlayer = $animation

func postShoot():
	animation.play("shoot")
	animation.seek(0.0)
