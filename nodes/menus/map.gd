extends Panel
@onready var namelabel: Label = $Name
@onready var preview: Sprite2D = $Preview
@onready var author: Label = $author
@onready var switchto: Button = $SwitchTo
var path := ""
var mapname := ""
var gamemode := ""
@onready var toggle: Button = $Toggle
@onready var mapp: mapPicker = $"../../.."

func _ready() -> void:
	if mapp.joinMode:
		hide()

func _physics_process(delta: float) -> void:
	if mapp.joinMode:
		visible = toggle.button_pressed
