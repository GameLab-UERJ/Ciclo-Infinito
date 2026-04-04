extends VideoStreamPlayer

var hall_do_queijo : PackedScene = preload("uid://bgv1wic2ps8oa")

func _on_finished() -> void:
	get_tree().change_scene_to_packed(hall_do_queijo)
