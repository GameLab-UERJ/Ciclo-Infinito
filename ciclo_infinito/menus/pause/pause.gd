class_name PauseScreen
extends Control

var main_menu = load("uid://downt2rxxaqaf")
var master_idx: int

@onready var resume_button = $MarginContainer/VBoxContainer/MenuPrincipal/resumebutton
@onready var options_button = $MarginContainer/VBoxContainer/MenuPrincipal/optionsbutton
@onready var quit_button = $MarginContainer/VBoxContainer/MenuPrincipal/quitbutton

@onready var menu_principal = $MarginContainer/VBoxContainer/MenuPrincipal
@onready var menu_opcoes = $MarginContainer/VBoxContainer/MenuOpcoes
@onready var volume_slider = $MarginContainer/VBoxContainer/MenuOpcoes/HBoxContainer/VolumeSlider
@onready var fullscreen_button = $MarginContainer/VBoxContainer/MenuOpcoes/FullScreenButton
@onready var back_button = $MarginContainer/VBoxContainer/MenuOpcoes/BackButton
@onready var volume_label = $MarginContainer/VBoxContainer/MenuOpcoes/HBoxContainer/Label

func _ready():	
	master_idx = AudioServer.get_bus_index("Master")
	
	menu_principal.show()
	menu_opcoes.hide()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0
	_update_volume_slider()

func _on_resumebutton_pressed():
	get_tree().paused = false
	hide()
func _on_optionsbutton_pressed():
	menu_principal.hide()
	menu_opcoes.show()
func _on_quitbutton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu)
func _on_fullscreenbutton_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _on_volume_changed(value: float)-> void:
	var linear = value / 100.0
	var db = linear_to_db(linear)
	_update_volume_label(value)

	AudioServer.set_bus_volume_db(master_idx, db)
func _on_backbutton_pressed() -> void:
	menu_opcoes.hide()
	menu_principal.show()
	pass
	
func _update_volume_slider()-> void:
	var current_db = AudioServer.get_bus_volume_db(master_idx)
	var amp = db_to_linear(current_db)
	volume_slider.value = amp * 100.0
	
func _update_volume_label(value: float) -> void:
	var percent = int(value)
	volume_label.text = "Volume: %d%%" % clamp(percent, 0, 100)


func _on_full_screen_button_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass # Replace with function body.
