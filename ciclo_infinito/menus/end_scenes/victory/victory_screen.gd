extends CanvasLayer


var fifth_floor : PackedScene = load("uid://c1t0cprxobugr")
var main_menu : PackedScene = load("uid://downt2rxxaqaf")

func _on_jogar_novamente_button_pressed() -> void:
	get_tree().change_scene_to_packed(fifth_floor)
	pass 


func _on_menu_iniciar_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
	pass
