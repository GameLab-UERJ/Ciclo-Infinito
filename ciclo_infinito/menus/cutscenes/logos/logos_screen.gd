extends VideoStreamPlayer

var main_menu : PackedScene = preload("uid://downt2rxxaqaf")


func _ready() -> void:
	var music : AudioStream = preload("uid://c8ag6husw1v2")
	MusicManager.play_music(music,8)
	MusicManager.increase_volume(-10)

func _on_finished() -> void:
	EasyTransition.transition_to_scene(main_menu,1.5,EasyTransition.TransitionAnim.FADE)
