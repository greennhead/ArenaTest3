extends Control
@export var togglerMode := false
@export var canLoad := false
@export var gamemodeRestriction := ""
@onready var map: Panel = $ScrollContainer/VBoxContainer/map

func _on_close_pressed() -> void:
	queue_free()

func _ready() -> void:
	if !togglerMode:
		$ScrollContainer/VBoxContainer/map/Toggle.hide()
		$ToggleAll.hide()
