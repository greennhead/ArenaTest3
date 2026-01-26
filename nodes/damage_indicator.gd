extends Label
var time = 0
var py = -4
var dmg = 0
@onready var startposy = position.y
func _ready() -> void:
	startposy = get_viewport_rect().size.y/2.0 + 8
	if !visible:
		remove_from_group("damagelabel")
	for i in $"..".get_children():
		if i.is_in_group("damagelabel"):
			queue_free()
			i.time = 0
			i.modulate.a = 1
			i.dmg += dmg
			print(dmg)
			print(i.dmg)
			i.position.y -= 2

func _process(delta: float) -> void:
	if !visible:
		return
	text = str(round(dmg)).replace(".0","")
	position.y = lerp(position.y,startposy + py,(0.1*60)*delta)
	time += 60*delta
	if time > 90:
		modulate.a -= 0.1
	if time > 120:
		queue_free()
