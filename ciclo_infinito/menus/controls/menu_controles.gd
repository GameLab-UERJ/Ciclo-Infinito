extends Control


var main_menu : PackedScene = load("uid://downt2rxxaqaf")


@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var pressed_sfx: AudioStreamPlayer = $PressedSfx


func _ready() -> void:
	MusicManager.increase_volume(-10)

func _on_voltar_pressed() -> void:
	pressed_sfx.play(0.15)
	if get_parent() == get_tree().root:
		EasyTransition.transition_to_scene(main_menu,1.5,EasyTransition.TransitionAnim.WIPE_LINEAR)
		return
	var pause_menu = get_parent().get_node_or_null("MarginContainer")
	if pause_menu:
		pause_menu.show()
	hide()
	await pressed_sfx.finished
	queue_free()


func _on_voltar_mouse_entered() -> void:
	hover_sfx.play(0.37)
