extends Label
@onready var ogtext = text
@export var usePercent : bool = true



func _process(delta: float) -> void:
	if usePercent:
		text = tr(ogtext) + " ("+ str(int(get_parent().value)) + "%)"
	else:
		text = tr(ogtext).replace("\n","") + " ("+ str(int(get_parent().value)) + ")"
