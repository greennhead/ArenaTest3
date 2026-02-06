extends HeldWeapon
@onready var animation: AnimationPlayer = $animation
@export var damage := 20
func preBullet(bullet):
	bullet.damage = damage

func postShoot(bullet):
	animation.play("shoot")
	animation.seek(0.0)
