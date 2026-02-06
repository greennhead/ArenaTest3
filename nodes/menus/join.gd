extends MenuWindow
@export var lobbyWindow : PackedScene
@onready var pname: LineEdit = $name
@onready var ip: LineEdit = $ip

func _ready() -> void:
	pname.text = Settings.playerName


func _on_connect_pressed() -> void:
	GameManager.myName = pname.text
	GameManager.address = ip
	


func _on_close_pressed() -> void:
	queue_free()
