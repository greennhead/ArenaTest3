extends MenuWindow

var mapsEnabled : Array[bool]
@onready var gamemodeSelector: ItemList = $gamemodeSelector
@onready var mapPicker: Control =  $Panel/MapPicker
var selectedMode = ""
@export var errorWindow : PackedScene
var started = false
@export var Adress ="127.0.0.1"
@export var port = 8914
var peer
var oldPlayers = {}
var hosted = false
var selectedModeIdx := -1
var joining = false
var joined = false

@export var hostChecksum := ""
var checksum := ""
@onready var warning: RichTextLabel = $warning

@rpc("any_peer")
func SendPlayerInfo(name,id,checksum,color):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score" : 0,
			"team" : 0,
			"checksum" : checksum,
			"color" : color
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInfo.rpc(GameManager.Players[i].name,i,GameManager.Players[i].checksum,GameManager.Players[i].color)
	updatePList()

@rpc("authority")
func sendGameInfo(started : bool,gamemode : int = -1):
	if gamemode != -1:
		selectGM(gamemode)
	if started:
		var p = errorWindow.instantiate()
		get_tree().current_scene.add_child(p)
		p.toptext.text = "Error!"
		p.intext.text = "Game in progress!"
		queue_free()

func _ready() -> void:
	GameManager.Players = {}
	if GameManager.myName == "":
		GameManager.myName = Settings.playerName
		if GameManager.myName == "":
			GameManager.myName = "TestGuy" + str(randi_range(1,99))
	checksum = getChecksum()
	loadMaps()
	print_rich("[color=yellow]Checksum: " + checksum)
	if hosted: # host game
		GameManager.myName = Settings.playerName
		peer = ENetMultiplayerPeer.new()
		var error = peer.create_server(port,8)
		if error != OK:
			var p = errorWindow.instantiate()
			get_tree().current_scene.add_child(p)
			p.toptext.text = "Error!"
			p.intext.text = "Can't host: Error " + str(error)
			if error == 20:
				p.intext.text += "\nYou seem to have already hosted!"
			print_rich("[color=red][shake]Cannot host! " + str(error))
			queue_free()
			return
		hosted = true
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)
		print("waiting for players!")
		hostChecksum = checksum
		SendPlayerInfo(GameManager.myName,multiplayer.get_unique_id(),checksum,Settings.nameColor)
		updatePList()
	else: # join game
		print("joining game..")
		mapPicker.joinMode = true
		peer = ENetMultiplayerPeer.new()
		Adress = GameManager.address
		peer.create_client(Adress,port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		joined = true
		joining = true
		multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	await get_tree().create_timer(2.0).timeout
	if joining == true:
		var p = errorWindow.instantiate()
		get_tree().current_scene.add_child(p)
		p.toptext.text = "Error!"
		p.intext.text = "Connection timeout..."
		queue_free()

func connected_to_server():
	joining = false
	print("Connected to server" )
	SendPlayerInfo.rpc_id(1,GameManager.myName,multiplayer.get_unique_id(),checksum,Settings.nameColor)
	await get_tree().create_timer(0.5).timeout
	updatePList()

func connection_failed():
	var p = errorWindow.instantiate()
	get_tree().current_scene.add_child(p)
	p.toptext.text = "Error!"
	p.intext.text = "Connection failed..."
	queue_free()
	print("Connection failed")

func peer_connected(id):
	sendGameInfo.rpc_id(id,started,selectedModeIdx)
	print("Player connected " + str(id))
	if !started && GameManager.Players.has(str(id)):
		GameManager.message(GameManager.Players[str(id)]["name"] + " connected!",true)

func peer_disconnected(id):
	if id == 1:
		var p = errorWindow.instantiate()
		if GameManager.main.scenecont.main_node != load("res://scenes/title.tscn"):
			GameManager.main.changeScene("res://scenes/title.tscn")
		GameManager.main.add_child(p)
		p.toptext.text = "Lobby Closed"
		p.intext.text = "The host has left the game!"
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		queue_free()
	print("Player disconnected " + str(id))
	for i in get_tree().get_nodes_in_group("player"):
		if i.id == id:
			i.queue_free()
	GameManager.Players.erase(id)
	updatePList()

func getChecksum():
	var dir
	var c = ""
	for path in GameManager.mapPaths:
		dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					c += str(file_name[1])
				file_name = dir.get_next()
	for path in GameManager.gunPaths:
		dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				c += str(file_name.length())
				file_name = dir.get_next()
	for path in GameManager.gamemodePaths:
		dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					c += str(file_name[0])
				file_name = dir.get_next()
	for i in Settings.enabledMods:
		c += i
	return c 


func loadMaps():
	for path in GameManager.gamemodePaths:
		var dir = DirAccess.open(path)
		var fir = null
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					if fir == null:
						fir = file_name.to_pascal_case()
					gamemodeSelector.add_item(file_name.to_pascal_case())
				file_name = dir.get_next()
		selectedMode = fir

func _on_close_pressed() -> void:
	queue_free()

@rpc("authority","reliable","call_local")
func selectGM(idx):
	selectedModeIdx = idx
	GameManager.customGMProperties = {}
	selectedMode = gamemodeSelector.get_item_text(idx).to_lower()
	gamemodeSelector.select(idx)
	mapPicker.gamemodeRestriction = gamemodeSelector.get_item_text(idx).to_lower()
	mapPicker.reSpawn()
	var ppath
	for path in GameManager.gamemodePaths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					if file_name == gamemodeSelector.get_item_text(idx).to_lower():
						ppath = path.path_join(file_name).path_join("/gmsettings.tscn")
				file_name = dir.get_next()
	for i in $settings.get_children():
		i.queue_free()
	if ResourceLoader.exists(ppath):
		var st = load(ppath).instantiate()
		st.name = "settings"
		$settings.add_child(st)
	else:
		var st = load("res://nodes/gmsettingsMissing.tscn").instantiate()
		st.name = "settings"
		$settings.add_child(st)


func _on_gamemode_selector_item_selected(index: int) -> void:
	if hosted:
		selectGM.rpc(index)


@onready var players : VBoxContainer = $players/VBoxContainer
@onready var ogplayerName: RichTextLabel = $players/VBoxContainer/playerName

func _physics_process(delta: float) -> void:
	if joined:
		for i in get_tree().get_nodes_in_group("disableIfClient"):
			i.disabled = true
@onready var startB: Button = $start


func updatePList():
	var checksumMismatches = 0
	oldPlayers = GameManager.Players
	for i in players.get_children():
		if i != ogplayerName:
			i.queue_free()
	for i in GameManager.Players:
		if GameManager.Players[i].checksum != hostChecksum:
			checksumMismatches += 1
			var j = ogplayerName.duplicate()
			j.text = ("[img]res://images/questionableChecksum.png[/img][pulse color=red] " + GameManager.Players[i]["name"]) 
			players.add_child(j)
			j.show()
		else:
			var j = ogplayerName.duplicate()
			j.text = ""
			if i == 1:
				j.text += "[img]res://images/host.png[/img] "
			j.text += "[color=" + GameManager.Players[i]["color"] + "]" + GameManager.Players[i]["name"] 
			j.show()
			players.add_child(j)
	if multiplayer.is_server():
		warning.visible =  checksumMismatches > 0

@rpc("authority","call_local","reliable")
func start(maps):
	hide()
	startB.disabled = true
	var ppath
	for path in GameManager.gamemodePaths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					if file_name == selectedMode.to_lower():
						ppath = path.path_join(file_name).path_join("/mode.tres") 
				file_name = dir.get_next()
	GameManager.enabledMaps = maps
	if maps.size() > 0:
		started = true
		GameManager.main.changeScene(load(ppath).levelScene)


func _on_start_pressed() -> void:
	var mapList = []
	for path in GameManager.mapPaths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					var config = ConfigFile.new()
					var err = config.load(path.path_join(file_name).path_join("config.cfg"))
					if err == OK:
						if config.get_value("data","gamemode") == GameManager.gmName && mapEnabled(config.get_value("data","name")):
							mapList.append(file_name)
				file_name = dir.get_next()
	if hosted:
		if mapList.size() >= 1:
			start.rpc(mapList)
		else:
			GameManager.popup("Hold on","Select at least 1 map!")
	else:
		GameManager.popup("Hold on","You are not the host!")

func mapEnabled(name):
	for i in mapPicker.vb.get_children():
		if i.mapname == name && i.toggle.button_pressed:
			return true
	return false


func _on_tree_exiting() -> void:
	peer.close()
