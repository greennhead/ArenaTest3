extends MenuWindow
@onready var key: Panel = $ScrollContainer/VBoxContainer/key
@onready var vb: VBoxContainer = $ScrollContainer/VBoxContainer
var selectedButton : Button
var buttons = []
var lastKey
@onready var oldMappings = Settings.mappings.duplicate()
var savedMappings = {}
func _ready() -> void:
	savedMappings = oldMappings
	for i in Settings.mappings:
		var k = key.duplicate()
		k.show()
		vb.add_child(k)
		k.nam.text = i.to_pascal_case()
		k.inpName = i
		k.bt = Settings.mappings[i][0].as_text().replace("- Physical","")
		k.button.text = Settings.mappings[i][0].as_text().replace("- Physical","")
		k.button.pressed.connect(buttonPressed.bind(k.button))
		buttons.append(k.button)

func _physics_process(delta: float) -> void:
	if selectedButton != null:
		if Input.is_anything_pressed() && lastKey != null && lastKey != InputEventMouseMotion:
			if lastKey.as_text().contains("motion"):
				return
			Settings.mappings.set(selectedButton.get_parent().inpName,[lastKey])
			savedMappings = Settings.mappings
			selectedButton.text = lastKey.as_text()
			selectedButton.get_parent().bt = lastKey.as_text()
			$close2.modulate = Color.YELLOW
			$close.modulate = Color.RED
			selectedButton.modulate= Color.YELLOW
			selectedButton = null
			for i in buttons:
				i.text = i.get_parent().bt

func _on_close_pressed() -> void:
	Settings.mappings = oldMappings.duplicate()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	lastKey = event


func buttonPressed(button):
	for i in buttons:
		i.text = i.get_parent().bt
	selectedButton = button
	button.text = tr("REMAP")


func _on_close_2_pressed() -> void:
	Settings.updateMappings()
	Settings.saveSettings()
	queue_free()
