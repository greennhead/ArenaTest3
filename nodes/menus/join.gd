extends MenuWindow
@export var lobbyWindow : PackedScene
@onready var pname: LineEdit = $name
@onready var ip: LineEdit = $ip

func _ready() -> void:
	pname.text = Settings.playerName


func _on_connect_pressed() -> void:
	if pname.text.replace(" ","") == "":
		return
	GameManager.myName = pname.text
	GameManager.address = ip.text
	var l = lobbyWindow.instantiate()
	l.hosted = false
	GameManager.main.add_child(l)
	queue_free()


func _on_close_pressed() -> void:
	queue_free()
