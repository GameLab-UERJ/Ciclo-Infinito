extends Node2D


@onready var camera_spot_end_cutscene: Marker2D = $Entrada/CameraSpotEndCutscene
@onready var pause_menu = $player/pause
@onready var mission_label = $player/Missions/Label
@onready var player: Player = $player
@onready var herald_of_failure: Boss = $HeraldOfFailure
@onready var cutscene_area: Area2D = $CutsceneArea
@onready var barreira_inicio: TileMapLayer = $BarreiraInicio
@onready var tension_player: AudioStreamPlayer = $TensionPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var fire_meteor: FireMeteor = $Entrada/FireMeteor
@onready var fire_meteor_2: FireMeteor = $Entrada/FireMeteor2
@onready var fire_meteor_3: FireMeteor = $Entrada/FireMeteor3
@onready var fire_meteor_4: FireMeteor = $Entrada/FireMeteor4
@onready var fire_meteor_5: FireMeteor = $Entrada/FireMeteor5
@onready var fire_meteor_6: FireMeteor = $Entrada/FireMeteor6
@onready var fire_meteor_7: FireMeteor = $Entrada/FireMeteor7
@onready var fire_meteor_8: FireMeteor = $Entrada/FireMeteor8
@onready var pilarmuro: TileMapLayer = $Pilarmuro

func _ready():
	SceneTransition.fade_in()
	pause_menu.hide()
	configurar_label()
	_atualizar_texto_missao()
	mission_label.get_parent().reparent(player.camera)


func configurar_label():
	mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD
	mission_label.add_theme_font_size_override("font_size", 24)


func _atualizar_texto_missao():
	if mission_label:
		mission_label.text = "Derrote o Arauto da Reprovação"


func _on_herald_of_failure_died() -> void:
	await player.pan_camera_to(camera_spot_end_cutscene)
	fire_meteor.drop(randf_range(0,0.5))
	fire_meteor_2.drop(randf_range(0,0.5))
	fire_meteor_3.drop(randf_range(0,0.5))
	fire_meteor_4.drop(randf_range(0,0.5))
	fire_meteor_5.drop(randf_range(0,0.5))
	fire_meteor_6.drop(randf_range(0,0.5))
	fire_meteor_7.drop(randf_range(0,0.5))
	fire_meteor_8.drop(randf_range(0,0.5))
	create_tween().tween_property(pilarmuro,"modulate",Color.TRANSPARENT,1)
	await get_tree().create_timer(3).timeout
	pilarmuro.collision_enabled = false
	await player.pan_camera_back()
	await create_tween().tween_property(music_player,"volume_db",-50,3).finished
	music_player.stop()


func end_game() -> void:
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


func _on_end_cutscene_area_body_entered(body: Node2D) -> void:
	if body is Player:
		end_game()
