extends TextureRect

func _on_jogar_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/HallDoQueijo.tscn")
	pass
	
func _on_creditos_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/creditos.tscn")
	pass

func _on_Sair_Button_pressed() -> void:
	get_tree().quit()
	pass

func _on_opções_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/menu_de_opcoes.tscn")
	pass

func _on_discordbutton_pressed()->void:
	OS.shell_open("https://discord.com/channels/1409169018534891644/1412147166658429038")
