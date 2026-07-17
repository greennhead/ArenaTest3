extends Control
class_name MenuWindow
@export var snapToCenter := true
@export var sizePanel : Panel
@export var disposable := true
@export var clearable := true
func snap():
	if snapToCenter && sizePanel != null:
		global_position = get_viewport_rect().size/2 - sizePanel.size/2


func _ready() -> void:
	if sizePanel == null:
		for i in get_children():
			if i is Panel:
				sizePanel = i
				continue
	if snapToCenter:
		snap()

func _process(delta: float) -> void:
	if snapToCenter:
		snap()
