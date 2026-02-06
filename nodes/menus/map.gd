extends Panel
@onready var namelabel: Label = $Name
@onready var preview: Sprite2D = $Preview
@onready var author: Label = $author
@onready var switchto: Button = $SwitchTo
var path := ""
var mapname := ""
var gamemode := ""
@onready var toggle: CheckButton = $Toggle
@onready var mapp: mapPicker = $"../../.."
@onready var checkmark = preload("res://images/mapIncluded.png")
@onready var x = preload("res://images/mapExcluded.png")
func _ready() -> void:
	if mapp.joinMode:
		hide()

func _physics_process(delta: float) -> void:
	if mapp.joinMode:
		visible = toggle.button_pressed
