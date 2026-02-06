extends Transition
@onready var progress: ProgressBar = $loadingWindow/ProgressBar
@onready var window: Panel = $loadingWindow

func _on_load_start(scene_container: SceneContainer) -> bool:
	window.show()
	progress.value = 0 
	return true


func _on_load_end(scene_container: SceneContainer) -> bool:
	window.hide()
	return true


func _on_progress_update(progress_ratio: float) -> void:
	progress.value = progress_ratio * 100
