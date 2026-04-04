extends VideoStreamPlayer

var main_menu : PackedScene = preload("uid://downt2rxxaqaf")

func _on_finished() -> void:
	get_tree().change_scene_to_packed(main_menu)
	pass # Replace with function body.
