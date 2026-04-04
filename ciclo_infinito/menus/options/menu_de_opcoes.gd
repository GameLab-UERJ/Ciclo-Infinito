extends Control

var main_menu : PackedScene = load("uid://downt2rxxaqaf")

@onready var volume_slider: HSlider = $"MarginContainer/HBoxContainerGeral/volume_slider"
@onready var volume_label: Label = $"MarginContainer/HBoxContainerGeral/Volume"

func _ready() -> void:
	var master_idx = AudioServer.get_bus_index("Master")

	volume_slider.min_value = -30.0
	volume_slider.max_value = 0.0
	volume_slider.step = 1

	var current_db = AudioServer.get_bus_volume_db(master_idx)
	volume_slider.value = current_db
	_update_label(current_db)

	volume_slider.value_changed.connect(
		func(value): _on_volume_changed(value, master_idx)
	)

func _on_volume_changed(value: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_db(bus_idx, value)
	_update_label(value)

func _update_label(db_value: float) -> void:
	var amp = pow(10.0, db_value / 20.0)
	var percent = int(round(amp * 100.0))
	volume_label.text = "Volume: %d%%" % clamp(percent, 0, 100)


func _on_voltar_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
	pass
