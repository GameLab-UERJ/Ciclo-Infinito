extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_voltar_pressed() -> void:
	if get_parent() != get_tree().root:
		var pause_menu = get_parent().get_node_or_null("MarginContainer")
		if pause_menu:
			pause_menu.show()
		queue_free()
	else:
		get_tree().change_scene_to_file("res://menus/main/main_menu.tscn")
	pass
