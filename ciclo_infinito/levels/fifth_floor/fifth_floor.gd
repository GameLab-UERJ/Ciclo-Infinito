class_name FifthFloor
extends Node2D


var victory_screen : PackedScene = preload("uid://5ijqxhw23bqd")


@onready var pause_menu = $Player/pause
@onready var mission_label = $Player/Missions/Label
@onready var pedro: CheeseNpc = $Pedro
@onready var player: Player = $Player
@onready var barreira: Barrier = $Barreira
@onready var barreira_boss: Barrier = $BarreiraBoss
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var enemies: Label = $Player/enemies
@onready var camera_focus: Marker2D = $Barreira/CameraFocus


var missoes = [
	"Fale com o Pedro no 5° andar",
	"Mate os monstros que aparecerem",
	"Fale com pedro",
	"Entre na sala do Arauto da Reprovação"
]

var inimigos_totais = 0
var inimigos_derrotados = 0

func _ready():
	SceneTransition.fade_in()
	pause_menu.hide()
	inimigos_totais = $Player/enemies.get_child_count() if $Player/enemies else 0
	configurar_label()
	_atualizar_texto_missao()
	conectar_sinais()
	mission_label.get_parent().reparent(player.camera)
	enemies.reparent(player.camera)


func configurar_label():
	mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD
	mission_label.add_theme_font_size_override("font_size", 24)


func conectar_sinais():
	if pedro:
		pedro.was_talked_to.connect(_on_falou_com_pedro)
	if enemies:
		for enemy in enemies.get_children():
			enemy.inimigo_derrotado.connect(_on_inimigo_derrotado)


func _process(_delta):
	
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()
			
			
func _pause_game():
	get_tree().paused = true
	pause_menu.show()
	
	
func _resume_game():
	get_tree().paused = false
	pause_menu.hide()
	
	
func _atualizar_texto_missao():
	if mission_label:
		mission_label.text = missoes[GameState.fifth_floor_state]


func proxima_missao():
	GameState.fifth_floor_state += 1
	_atualizar_texto_missao()


func libera_barreira() -> bool:
	return GameState.fifth_floor_state > GameState.FifthFloorState.FIRST_TALK


func libera_barreira_boss() -> bool:
	return GameState.fifth_floor_state == GameState.FifthFloorState.GO_BOSS


func _on_falou_com_pedro(npc : CheeseNpc):
	if npc.name != "Pedro":
		return
	if GameState.fifth_floor_state == GameState.FifthFloorState.FIRST_TALK:
		proxima_missao()
	elif GameState.fifth_floor_state == GameState.FifthFloorState.BEFORE_KILLING:
		pass
	elif GameState.fifth_floor_state == GameState.FifthFloorState.AFTER_KILLING:
		proxima_missao()


func _on_inimigo_derrotado():
	inimigos_derrotados += 1
	if GameState.fifth_floor_state == GameState.FifthFloorState.BEFORE_KILLING and inimigos_derrotados >= inimigos_totais:
		proxima_missao()


func _on_barreira_started_opening() -> void:
	await player.pan_camera_to(camera_focus)


func _on_any_barreira_finished_opening() -> void:
	await player.pan_camera_back()
	enemies.show()


func _on_barreira_boss_started_opening() -> void:
	await player.pan_camera_to(barreira_boss)


func _on_cutscene_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player.current_state = player.State.CUTSCENE	
	mission_label.text = "Todas as missões concluídas!"
	var tween : Tween = create_tween()
	tween.tween_property(player.anim,"scale",Vector2.ZERO,1)
	tween.parallel().tween_property(player.shadow,"scale",Vector2.ZERO,1)
	await tween.parallel().tween_property(player.footsteps_sfx,"volume_db",-50,1).finished
	player.current_state = player.State.DIALOG
	SceneTransition.fade_out()
	var boss_scene = load("uid://laif38pcjfq7").instantiate()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_node(boss_scene)
	
