extends Node2D
class_name Main
@onready var scenecont: SceneContainer = $SceneContainer
var TITLESCENE = load("res://scenes/title.tscn")

@onready var windowSpot: Node2D = $windowSpot

func _ready() -> void:
	scenecont.request_scene(TITLESCENE)
	GameManager.main = self

func _physics_process(delta: float) -> void:
	scenecont.size = get_viewport_rect().size
	GameManager.scene = scenecont.main_node


func changeScene(scene):
	scenecont.request_scene(scene)
	for i in get_children():
		if i is MenuWindow:
			if i.disposable:
				i.queue_free()
