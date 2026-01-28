extends Node3D
@export var PlayerScene : PackedScene
@onready var mapLoader: Node3D = $mapLoader

func _ready() -> void:
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.id = GameManager.Players[i].id
		currentPlayer.displayName = str(GameManager.Players[i].name)
		add_child(currentPlayer)
		index += 1
