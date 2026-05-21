extends Panel
@onready var pname: RichTextLabel = $pname
@onready var icon: Sprite2D = $icon
@onready var cross: Sprite2D = $icon/cross
var tiedTo : Player

func _ready() -> void:
	if tiedTo != null:
		cross.visible = tiedTo.hp < 1
