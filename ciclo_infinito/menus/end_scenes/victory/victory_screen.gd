extends CanvasLayer


var main_menu = load("uid://downt2rxxaqaf")
var _something_was_selected : bool = false


@onready var color_rect: ColorRect = $ColorRect
@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var pressed_sfx: AudioStreamPlayer = $PressedSfx


func _on_any_button_pressed() -> void:
	_something_was_selected = true
	pressed_sfx.play(0.15)
	await pressed_sfx.finished


func _on_jogar_novamente_button_pressed() -> void:
	await _on_any_button_pressed()
	EasyTransition.transition_to_scene(load("uid://bgv1wic2ps8oa"),1.5,EasyTransition.TransitionAnim.FADE)


func _on_menu_iniciar_button_pressed() -> void:
	await _on_any_button_pressed()
	EasyTransition.transition_to_scene(main_menu,1.5,EasyTransition.TransitionAnim.FADE)


func _on_button_mouse_entered() -> void:
	if _something_was_selected:
		return
	hover_sfx.play(0.37)
