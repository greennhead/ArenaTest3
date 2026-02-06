extends Node3D
@export var PlayerScene : PackedScene
@onready var mapLoader: Node3D = $mapLoader
var round := 0
@onready var maxRounds = 16
func _ready() -> void:
	var index = 0
	for i in GameManager.Players: # spawn players
		var currentPlayer = PlayerScene.instantiate() as Player
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.id = GameManager.Players[i].id
		currentPlayer.displayName = str(GameManager.Players[i].name)
		add_child(currentPlayer)
		index += 1
		if GameManager.customGMProperties.has("health"):
			currentPlayer.hp = GameManager.customGMProperties.get("health") # set properties
		if GameManager.customGMProperties.has("rounds"):
			maxRounds = GameManager.customGMProperties.get("rounds")
