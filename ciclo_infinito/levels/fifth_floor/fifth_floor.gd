class_name FifthFloor
extends Node2D

var victory_screen : PackedScene = preload("uid://5ijqxhw23bqd")

@onready var pause_menu = $player/pause
@onready var mission_label = $player/TextureRect/Label
@onready var pedro: CheeseNpc = $Pedro
@onready var barreira: StaticBody2D = $TerrainManager/Barreira

var missoes = [
	"Fale com o Pedro no 5° andar",
	"Mate os monstros que aparecerem",
	"Fale com pedro",
	"Missões Concluídas"
]

var inimigos_totais = 0
var inimigos_derrotados = 0

func _ready():
	SceneTransition.fade_in()
	pause_menu.hide()
	inimigos_totais = $player/enemies.get_child_count() if $player/enemies else 0
	configurar_label()
	_atualizar_texto_missao()
	conectar_sinais()
	
	
func configurar_label():
	mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD
	mission_label.add_theme_font_size_override("font_size", 24)
	
	
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
	
	if GameState.fifth_floor_state == GameState.FifthFloorState.FINISHED:
		mission_label.text = "Todas as missões concluídas!"
		SceneTransition.fade_out()
		GameState.fifth_floor_state = GameState.FifthFloorState.FIRST_TALK
		var victory_scene = preload("res://menus/end_scenes/victory/victory_screen.tscn").instantiate()
		await get_tree().create_timer(1.5).timeout
		get_tree().root.add_child(victory_scene)
		victory_scene.set_layer(100)
		
func proxima_missao():
	GameState.fifth_floor_state += 1
	_atualizar_texto_missao()
	
	
func conectar_sinais():
	if pedro:
		pedro.was_talked_to.connect(_on_falou_com_pedro)
	var enemies = $player/enemies
	if enemies:
		for enemy in enemies.get_children():
			enemy.inimigo_derrotado.connect(_on_inimigo_derrotado)


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
		print("vasco")
		print("Todos os inimigos derrotados — avançando missão.")
		proxima_missao()
