extends VideoStreamPlayer


var cutscene : PackedScene = preload("uid://b21qcqu4g18ab")
var creditos : PackedScene = preload("uid://c8f43sr71atgk")
var menu_de_opcoes : PackedScene = preload("uid://del2he55eywxt")

func _on_jogar_button_pressed() -> void:
	get_tree().change_scene_to_packed(cutscene)
	pass
	
func _on_creditos_button_pressed() -> void:
	get_tree().change_scene_to_packed(creditos)
	pass

func _on_sair_button_pressed() -> void:
	get_tree().quit()
	pass

func _on_opções_button_pressed() -> void:
	get_tree().change_scene_to_packed(menu_de_opcoes)
	pass

func _on_discordbutton_pressed()->void:
	OS.shell_open("https://discord.com/channels/1409169018534891644/1412147166658429038")
