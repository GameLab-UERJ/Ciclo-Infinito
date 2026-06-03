extends VideoStreamPlayer


var cutscene : PackedScene = preload("uid://b21qcqu4g18ab")
var creditos : PackedScene = preload("uid://c8f43sr71atgk")
var menu_de_opcoes : PackedScene = preload("uid://del2he55eywxt")
var _something_was_selected : bool = false


@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var pressed_sfx: AudioStreamPlayer = $PressedSfx
@onready var discordbutton: TextureButton = $discordbutton


func _ready() -> void:
	if not MusicManager.is_playing():
		MusicManager.play_music(preload("uid://c8ag6husw1v2"),12)
		MusicManager.increase_volume(-5)
	else:
		MusicManager.increase_volume(10)


func _on_any_button_pressed() -> void:
	_something_was_selected = true
	pressed_sfx.play(0.15)
	await pressed_sfx.finished


func _on_jogar_button_pressed() -> void:
	_on_any_button_pressed()
	MusicManager.stop_music(1)
	EasyTransition.transition_to_scene(cutscene,1.5,EasyTransition.TransitionAnim.FADE)


func _on_creditos_button_pressed() -> void:
	_on_any_button_pressed()
	EasyTransition.transition_to_scene(creditos,1.5,EasyTransition.TransitionAnim.FADE)


func _on_sair_button_pressed() -> void:
	await _on_any_button_pressed()
	get_tree().quit()


func _on_opções_button_pressed() -> void:
	_on_any_button_pressed()
	EasyTransition.transition_to_scene(menu_de_opcoes,1.5,EasyTransition.TransitionAnim.WIPE_LINEAR)


func _on_discordbutton_pressed()->void:
	await _on_any_button_pressed()
	OS.shell_open("https://discord.gg/Ra9fKn3qHN")


func _on_controles_button_pressed() -> void:
	_on_any_button_pressed()
	EasyTransition.transition_to_path("res://menus/controls/menu_controles.tscn",1.5,EasyTransition.TransitionAnim.WIPE_LINEAR)


func _on_button_mouse_entered() -> void:
	if _something_was_selected:
		return
	hover_sfx.play(0.37)


func _on_discordbutton_mouse_entered() -> void:
	discordbutton.self_modulate = Color.hex(0x009dff)


func _on_discordbutton_mouse_exited() -> void:
	discordbutton.self_modulate = Color.WHITE
