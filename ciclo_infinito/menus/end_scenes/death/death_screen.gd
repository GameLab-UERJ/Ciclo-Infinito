extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	await tween.finished

	get_tree().paused = false
	queue_free()              
	get_tree().reload_current_scene()
