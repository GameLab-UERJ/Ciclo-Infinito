extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var main_menu = preload("uid://downt2rxxaqaf")

func _on_jogar_novamente_button_pressed() -> void:
	get_tree().reload_current_scene()
	queue_free()

func _on_menu_iniciar_button_pressed() -> void:
	SceneTransition.fade_in()
	get_tree().change_scene_to_packed(main_menu)
	queue_free()
