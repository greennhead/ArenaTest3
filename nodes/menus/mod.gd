extends Panel
@onready var preview: Sprite2D = $Preview
@onready var namelabel: Label = $Name
var modname := ""
@onready var author: RichTextLabel = $author
@onready var toggle: CheckButton = $Toggle
signal Toggled
var path
var originallyToggled := false
@onready var restart: Button = $"../../../restart"
@onready var settings: Button = $settings


func _ready() -> void:
	if originallyToggled == false:
		toggle.text = "Disabled"
		toggle.modulate = Color.RED
	if originallyToggled == true:
		toggle.button_pressed = true
		toggle.text = "Enabled"
		toggle.modulate = Color.GREEN

func _on_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on == false && originallyToggled == false:
		toggle.text = "Disabled"
		toggle.modulate = Color.RED
	if toggled_on == true && originallyToggled == true:
		toggle.text = "Enabled"
		toggle.modulate = Color.GREEN
	if toggled_on != originallyToggled:
		toggle.text = "Requires Restart"
		restart.show()
		toggle.modulate = Color.YELLOW
