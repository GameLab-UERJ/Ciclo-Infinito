extends VideoStreamPlayer

var main_menu : PackedScene = preload("uid://downt2rxxaqaf")

func _ready() -> void:
	var music : AudioStream = preload("uid://c8ag6husw1v2")
	MusicManager.play_music(music,8)

func _on_finished() -> void:
	get_tree().change_scene_to_packed(main_menu)
	pass # Replace with function body.
