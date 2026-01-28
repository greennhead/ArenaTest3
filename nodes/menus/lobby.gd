extends MenuWindow

var mapsEnabled : Array[bool]
@onready var gamemodeSelector: ItemList = $gamemodeSelector
@onready var mapPicker: Control = $MapPicker
var selectedMode = ""


@export var Adress ="127.0.0.1"
@export var port = 8914
var peer

var hosted = false


var joined = false

@export var hostChecksum := ""
var checksum := ""

@rpc("any_peer")
func SendPlayerInfo(name,id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score" : 0,
			"team" : 0,
			"checksum" : checksum,
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInfo.rpc(GameManager.Players[i].name,i)

func _ready() -> void:
	if GameManager.myName == "":
		GameManager.myName = Settings.playerName
		if GameManager.myName == "":
			GameManager.myName = "TestGuy" + str(randi_range(1,99))
	checksum = getChecksum()
	loadMaps()
	print_rich("[color=yellow]Checksum: " + checksum)
	if hosted: # host game
		peer = ENetMultiplayerPeer.new()
		var error = peer.create_server(port,8)
		if error != OK:
			print_rich("[color=red][shake]Cannot host! " + str(error))
			return
		hosted = true
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)
		print("waiting for players!")
		hostChecksum = checksum
		SendPlayerInfo(GameManager.myName,multiplayer.get_unique_id())
	else: # join game
		print("joining game..")
		mapPicker.joinMode = true
		peer = ENetMultiplayerPeer.new()
		Adress = GameManager.address
		peer.create_client(Adress,port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		joined = true
		multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func connected_to_server():
	print("Connected to server" )
	SendPlayerInfo.rpc_id(1,GameManager.myName,multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed")

func peer_connected(id):
	print("Player connected " + str(id))

func peer_disconnected(id):
	print("Player disconnected " + str(id))
	for i in get_tree().get_nodes_in_group("player"):
		if i.id == id:
			i.queue_free()
	GameManager.Players.erase(id)

func getChecksum():
	var path = "res://maps/"
	var dir = DirAccess.open(path)
	var c = ""
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				c += str(file_name[1])
			file_name = dir.get_next()
	path = "res://nodes/weapons/"
	dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			c += str(file_name.length())
			file_name = dir.get_next()
	path = "res://modes/"
	dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				c += str(file_name[0])
			file_name = dir.get_next()
	return c


func loadMaps():
	var path = "res://modes/"
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
	gamemodeSelector.select(0)

func _on_close_pressed() -> void:
	peer.close()
	queue_free()

@rpc("authority","reliable","call_local")
func selectGM(idx):
	selectedMode = gamemodeSelector.get_item_text(idx).to_lower()
	gamemodeSelector.select(idx)
	mapPicker.gamemodeRestriction = gamemodeSelector.get_item_text(idx).to_lower()
	mapPicker.reSpawn()


func _on_gamemode_selector_item_selected(index: int) -> void:
	if hosted:
		selectGM.rpc(index)


@onready var players: ItemList = $players

func _physics_process(delta: float) -> void:
	if joined:
		for i in get_tree().get_nodes_in_group("disableIfClient"):
			i.disabled = true
	players.clear()
	for i in GameManager.Players:
		if GameManager.Players[i]["checksum"] != hostChecksum:
			players.add_item(GameManager.Players[i]["name"] + " (Checksum Mismatch)")
			players.set_item_icon(players.item_count,load("res://images/questionableChecksum.png"))
		else:
			players.add_item(GameManager.Players[i]["name"])

@rpc("authority","call_local","reliable")
func start(maps):
	var path = "res://modes/"
	var ppath
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name == selectedMode.to_lower():
					ppath = path + file_name + "/mode.tres"
			file_name = dir.get_next()
	GameManager.enabledMaps = maps
	if maps.size() > 0:
		get_tree().change_scene_to_file(load(ppath).levelScene)


func _on_start_pressed() -> void:
	var mapList = []
	var path = "res://maps/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var config = ConfigFile.new()
				var err = config.load(path + file_name + "/config.cfg")
				if err == OK:
					if config.get_value("data","gamemode") == GameManager.gmName && mapEnabled(config.get_value("data","name")):
						mapList.append(file_name)
			file_name = dir.get_next()
	if hosted:
		start.rpc(mapList)

func mapEnabled(name):
	for i in mapPicker.vb.get_children():
		if i.mapname == name && i.toggle.button_pressed:
			return true
	return false
