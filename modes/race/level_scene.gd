extends Node3D
@export var PlayerScene : PackedScene
@onready var mapLoader: mapLoader = $mapLoader
var round := 0

var noPlayerTime := 0
@onready var hud: CanvasLayer = $racehud

var playerScores = {}

@rpc("authority","call_local","reliable")
func spawnPlayers():
	seed(GameManager.num)
	GameManager.num += 1
	var idx = 0
	var order = get_tree().get_nodes_in_group("spawnPoint")
	order.shuffle()
	await get_tree().create_timer(0.1).timeout
	for i in get_tree().get_nodes_in_group("player"):
		if idx > order.size():
			idx = 0
		i.global_position = order[idx].global_position
		i.respawn()
		idx += 1
	for i in get_tree().get_nodes_in_group("spawnPoint"):
		i.queue_free()


func _ready() -> void:
	var index = 0
	for i in GameManager.Players: # spawn players
		var currentPlayer = PlayerScene.instantiate() as Player
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.id = GameManager.Players[i].id
		currentPlayer.displayName = str(GameManager.Players[i].name)
		currentPlayer.GMplayerMenuDict = "playerScores"
		currentPlayer.GMscene = self
		add_child(currentPlayer)
		playerScores.set(currentPlayer.id,[["Wins",0]]) #wanna do this if you wanna have scores show up in score board
		# index 0 of array is value name and 1 is it's value
		index += 1
	await get_tree().create_timer(0.1).timeout
	if multiplayer.is_server():
		mapLoader.getMapList()
		mapLoader.nextMap()




func getAlivePlayers():
	var alive = 0
	for i in get_tree().get_nodes_in_group("player"):
		if !i.dead:
			alive +=1 
	return alive

func getAlivePlayersAsNodes():
	var alive = []
	for i in get_tree().get_nodes_in_group("player"):
		if !i.dead:
			alive.append(i)
	return alive

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return
	var cond = getAlivePlayers() <= 1
	if get_tree().get_nodes_in_group("player").size() == 1:
		cond = getAlivePlayers() <= 0
	if cond:
		noPlayerTime += 1
	else:
		noPlayerTime = 0
	if noPlayerTime == 60:
		var wonPlayer
		if getAlivePlayers() == 1:
			wonPlayer = getAlivePlayersAsNodes()[0]
		if wonPlayer == null:
			announceWin.rpc(null)
		else:
			announceWin.rpc(wonPlayer.id)

@rpc("authority","call_local","reliable")
func announceWin(winner):
	var winPlayer
	for i in get_tree().get_nodes_in_group("player"):
		if i.id == winner:
			winPlayer = i
	if winPlayer == null:
		hud.winText.modulate = Color.WHITE
		hud.showWinText(tr("ACTION_STALEMATE"))
	else:
		playerScores[winPlayer.id][0][1] += 1
		hud.winText.modulate = winPlayer.playerName.modulate
		hud.showWinText(tr("ACTION_WINS") % winPlayer.displayName)
	await get_tree().create_timer(2.0).timeout
	if round < mapLoader.mapList.size() && multiplayer.is_server():
		mapLoader.nextMap()
		return
	if round >= mapLoader.mapList.size():
		hud.showWinText(tr("ACTION_END"))

func _on_map_loader_map_switched() -> void:
	hud.winText.hide()
	round += 1
	spawnPlayers()
	for i in get_tree().get_nodes_in_group("player"):
		i.canMove = false
	if multiplayer.is_server():
		resetTimers.rpc()
		await get_tree().create_timer(1.0).timeout
		announceRound.rpc(GameManager.getMapData(GameManager.mapName,"name") + " by " + GameManager.getMapData(GameManager.mapName,"author"),false)
		await get_tree().create_timer(1.0).timeout
		announceRound.rpc(tr("ACTION_MAP") + " " + str(round) + "/" + str(int(mapLoader.mapList.size())),false)
		await get_tree().create_timer(1.5).timeout
		announceRound.rpc(tr("ACTION_READY"),false)
		await get_tree().create_timer(0.5).timeout
		announceRound.rpc(tr("ACTION_GO"),true)
		await get_tree().create_timer(0.5).timeout
		announceRound.rpc("",false)
		startTimers.rpc()


@rpc("authority","call_local","reliable")
func startTimers():
	hud.timerGoing = true

@rpc("authority","call_local","reliable")
func resetTimers():
	hud.timerGoing = false
	hud.timer = 0.0

@rpc("authority","call_local","reliable")
func announceRound(round, canMove):
	hud.winText.modulate = Color.WHITE
	hud.showWinText(round)
	if canMove:
		for i in get_tree().get_nodes_in_group("player"):
			i.canMove = true

func _on_map_loader_out_of_maps() -> void:
	if multiplayer.is_server():
		mapLoader.getMapList()
		if round < mapLoader.mapList.size():
			mapLoader.nextMap()
