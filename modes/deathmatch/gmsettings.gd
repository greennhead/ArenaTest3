extends Panel
@onready var rounds: SpinBox = $ScrollContainer/VBoxContainer/rounds
@onready var health: SpinBox = $ScrollContainer/VBoxContainer/health
@onready var rand_chance: SpinBox = $ScrollContainer/VBoxContainer/randChance
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer



func _physics_process(delta: float) -> void:
	GameManager.customGMProperties.set("rounds",rounds.value) # set properties
	GameManager.customGMProperties.set("health",health.value)
	GameManager.customGMProperties.set("randomizerChance",rand_chance.value)
	if !multiplayer.is_server(): # if not host, disallow editing of the properties
		for i in v_box_container.get_children():
			if i is SpinBox or i is LineEdit or i is TextEdit:
				i.editable = false
			if i is Button:
				i.disabled = true
