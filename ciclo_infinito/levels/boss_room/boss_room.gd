extends Node2D

@onready var pause_menu = $player/pause
@onready var mission_label = $player/Missions/Label
@onready var player: Player = $player
@onready var herald_of_failure: Boss = $HeraldOfFailure
@onready var cutscene_area: Area2D = $CutsceneArea
@onready var barreira_inicio: TileMapLayer = $BarreiraInicio
@onready var tension_player: AudioStreamPlayer = $TensionPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _ready():
	SceneTransition.fade_in()
	pause_menu.hide()
	configurar_label()
	_atualizar_texto_missao()


func configurar_label():
	mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD
	mission_label.add_theme_font_size_override("font_size", 24)


func _atualizar_texto_missao():
	if mission_label:
		mission_label.text = "Derrote o Arauto da Reprovação"


func _on_herald_of_failure_died() -> void:
	if mission_label:
		mission_label.text = "Todas as missões concluídas!"
	SceneTransition.fade_out()
	var victory_scene = load("res://menus/end_scenes/victory/victory_screen.tscn").instantiate()
	await get_tree().create_timer(1.5).timeout
	get_tree().root.add_child(victory_scene)
	victory_scene.set_layer(100)
	


func _on_cutscene_area_body_entered(_body: Node2D) -> void:
	create_tween().tween_property(tension_player,"volume_db",-40,2)
	await player.pan_camera_to(herald_of_failure.camera_focus)
	music_player.play()
	barreira_inicio.collision_enabled = true
	barreira_inicio.visible = true
	herald_of_failure.state_machine_manager.happened("begin_cutscene")
	cutscene_area.queue_free()
