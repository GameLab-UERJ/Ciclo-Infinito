class_name PauseScreen
extends Control

var main_menu = load("uid://downt2rxxaqaf")


@onready var resume_button = $MarginContainer/VBoxContainer/MenuPrincipal/resumebutton
@onready var options_button = $MarginContainer/VBoxContainer/MenuPrincipal/optionsbutton
@onready var quit_button = $MarginContainer/VBoxContainer/MenuPrincipal/quitbutton

@onready var menu_principal = $MarginContainer/VBoxContainer/MenuPrincipal
@onready var menu_opcoes = $MarginContainer/VBoxContainer/MenuOpcoes
@onready var volume_slider = $MarginContainer/VBoxContainer/MenuOpcoes/HBoxContainer/Label/VolumeSlider
@onready var fullscreen_button = $MarginContainer/VBoxContainer/MenuOpcoes/FullScreenButton
@onready var back_button = $MarginContainer/VBoxContainer/MenuOpcoes/BackButton

func _ready():
	menu_principal.show()
	menu_opcoes.hide()
	volume_slider.min_value = -80.0
	volume_slider.max_value = 0.0
	volume_slider.step = 0.5
	volume_slider.value = AudioServer.get_bus_volume_db(0)

func _on_resumebutton_pressed():
	get_tree().paused = false
	hide()
func _on_optionsbutton_pressed():
	menu_principal.hide()
	menu_opcoes.show()
func _on_quitbutton_pressed():
	get_tree().change_scene_to_packed(main_menu)
func _on_fullscreenbutton_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _on_volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, value)
func _on_backbutton_pressed() -> void:
	menu_opcoes.hide()
	menu_principal.show()
	pass
