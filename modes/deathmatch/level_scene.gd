extends Node3D
@export var PlayerScene : PackedScene
@onready var mapLoader: mapLoader = $mapLoader
var round := 0
@onready var maxRounds = 16
var noPlayerTime := 0
@onready var hud: CanvasLayer = $dmhud

@rpc("authority","call_local","reliable")
func spawnPlayers():
	for i in get_tree().get_nodes_in_group("spawnPoint"):
		i.queue_free()
	seed(GameManager.num)
	print(GameManager.num)
	GameManager.num += 1
	var idx = 0
	var order = get_tree().get_nodes_in_group("spawnPoint")
	order.shuffle()
	for i in get_tree().get_nodes_in_group("player"):
		if idx > order.size():
			idx = 0
		i.global_position = order[idx].global_position
		i.respawn()
		idx += 1

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
			currentPlayer.maxhp = GameManager.customGMProperties.get("health") # set properties
		if GameManager.customGMProperties.has("rounds"):
			maxRounds = GameManager.customGMProperties.get("rounds")
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
		hud.winText.modulate = winPlayer.playerName.modulate
		hud.showWinText(tr("ACTION_WINS") % winPlayer.displayName)
	await get_tree().create_timer(2.0).timeout
	if round < maxRounds && multiplayer.is_server():
		mapLoader.nextMap()
		return
	if round >= maxRounds:
		hud.showWinText(tr("ACTION_END"))

func _on_map_loader_map_switched() -> void:
	hud.winText.hide()
	round += 1
	spawnPlayers()
	for i in get_tree().get_nodes_in_group("player"):
		i.canMove = false
	if multiplayer.is_server():
		await get_tree().create_timer(1.0).timeout
		if GameManager.customGMProperties.get("randomizerChance") != 0:
			if GameManager.customGMProperties.has("randomizerChance"):
				if randi_range(0,100) < GameManager.customGMProperties.get("randomizerChance"): 
					announceRound.rpc("Randomized!",false)
					randomizeMap.rpc(GameManager.num)
					await get_tree().create_timer(1.0).timeout
		announceRound.rpc(GameManager.getMapData(GameManager.mapName,"name") + " by " + GameManager.getMapData(GameManager.mapName,"author"),false)
		await get_tree().create_timer(1.0).timeout
		announceRound.rpc(tr("ACTION_ROUND") + " " + str(round) + "/" + str(int(maxRounds)),false)
		await get_tree().create_timer(1.5).timeout
		announceRound.rpc(tr("ACTION_READY"),false)
		await get_tree().create_timer(0.5).timeout
		announceRound.rpc(tr("ACTION_GO"),true)
		await get_tree().create_timer(0.5).timeout
		announceRound.rpc("",false)

@rpc("authority","call_local","reliable")
func randomizeMap(seed):
	GameManager.num = seed
	seed(GameManager.num)
	var weaponReplacements = {}
	var maps = GameManager.getAllMaps()
	var guns = GameManager.getAllGuns(0)
	var gunsExplosive = GameManager.getAllGuns(1)
	var gunsOP = GameManager.getAllGuns(2)
	var gunsNone = GameManager.getAllGuns(3)
	seed(GameManager.num)
	gunsOP.shuffle()
	seed(GameManager.num)
	guns.shuffle()
	seed(GameManager.num)
	gunsExplosive.shuffle()
	seed(GameManager.num)
	gunsNone.shuffle()
	maps.erase(GameManager.mapName)
	seed(GameManager.num)
	var map = maps.pick_random()
	mapLoader.world.environment.sky.sky_material.set("panorama",mapLoader.load_image(map.path_join("skybox.png")))
	if mapLoader.world.environment.sky.sky_material.get("panorama") == load("res://images/brick.png"):
		mapLoader.world.environment.sky.sky_material.set("panorama",mapLoader.load_image(map.path_join("Skybox.png")))
	seed(GameManager.num)
	map = maps.pick_random()
	if ResourceLoader.exists(map.path_join("palette.png")):
		Palleterizer.set_palette(load(map.path_join("palette.png")))
	for i in mapLoader.get_children(): 
		if i is GunPickup:
			if !weaponReplacements.has(i.weapon):
				var wep = load(i.weapon).instantiate().weapon #shouldnt cause errors :)
				if wep.consideredOverpowered:
					weaponReplacements.set(i.weapon,gunsOP.pop_back())
				elif wep.consideredUnableToDealDamage:
					weaponReplacements.set(i.weapon,gunsNone.pop_back())
				elif wep.consideredTileRemoving:
					weaponReplacements.set(i.weapon,gunsExplosive.pop_back())
				else:
					weaponReplacements.set(i.weapon,guns.pop_back())
			i.weapon = weaponReplacements.get(i.weapon)
			i.updateGun()


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
		if round < maxRounds:
			mapLoader.nextMap()
