extends Control


var main_menu : PackedScene = load("uid://downt2rxxaqaf")


@onready var volume_slider: HSlider = $"MarginContainer/HBoxContainerGeral/volume_slider"
@onready var volume_label: Label = $"MarginContainer/HBoxContainerGeral/Volume"
@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var pressed_sfx: AudioStreamPlayer = $PressedSfx


func _ready() -> void:
	MusicManager.increase_volume(-10)
	var master_idx = AudioServer.get_bus_index("Master")

	volume_slider.min_value = 0.0
	volume_slider.max_value = 101.0
	volume_slider.step = 1.0

	var current_db = AudioServer.get_bus_volume_db(master_idx)
	var amp = db_to_linear(current_db)
	volume_slider.value = amp * 100.0
	_update_label(current_db)

	volume_slider.value_changed.connect(
		func(value): _on_volume_changed(value, master_idx)
	)


func _on_volume_changed(value: float, bus_idx: int) -> void:
	var linear = value/100
	var db = linear_to_db(linear)

	AudioServer.set_bus_volume_db(bus_idx, db)
	_update_label(db)


func _update_label(db_value: float) -> void:
	var amp = db_to_linear(db_value)
	var percent = int(round(amp * 100.0))
	volume_label.text = "Volume: %d%%" % clamp(percent, 0, 100)


func _on_voltar_button_pressed() -> void:
	pressed_sfx.play(0.15)
	MusicManager.increase_volume(10)
	EasyTransition.transition_to_scene(main_menu,1.5,EasyTransition.TransitionAnim.WIPE_LINEAR)


func _on_alternar_tela_cheia_pressed() -> void:
	pressed_sfx.play(0.15)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_button_mouse_entered() -> void:
	hover_sfx.play(0.37)
