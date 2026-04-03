extends Node2D

@onready var pause_menu = $player/pause
@onready var mission_label = $player/TextureRect/Label

var missoes = [
	"Fale com José próximo aos elevadores no Hall do Queijo",
	"Entre no elevador e suba até o 5° andar",
	"Fale com o Pedro no 5° andar",
	"Mate os monstros que aparecerem",
	"Fale com pedro"
]

var indice_missao_atual = 2 
var inimigos_totais = 0
var inimigos_derrotados = 0

func _ready():
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
	if mission_label and indice_missao_atual < missoes.size():
		mission_label.text = missoes[indice_missao_atual]
	else:
		mission_label.text = "Todas as missões concluídas!"
		get_tree().change_scene_to_file("res://scene/vitoria.tscn")
func proxima_missao():
	indice_missao_atual += 1
	_atualizar_texto_missao()
func conectar_sinais():
	var npc = $NPC
	if npc:
		npc.falou_com_pedro.connect(_on_falou_com_pedro)
	var enemies = $player/enemies
	if enemies:
		for enemy in enemies.get_children():
			enemy.inimigo_derrotado.connect(_on_inimigo_derrotado)
func _on_falou_com_pedro():

	if indice_missao_atual  == 2:
		proxima_missao()
	elif indice_missao_atual ==4:
		proxima_missao()
	else:
		print(missoes[indice_missao_atual])
func _on_inimigo_derrotado():
	inimigos_derrotados += 1
	if indice_missao_atual ==3 and inimigos_derrotados >= inimigos_totais:
		print("vasco")
		print("Todos os inimigos derrotados — avançando missão.")
		proxima_missao()
