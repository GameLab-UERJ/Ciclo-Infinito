extends Node2D

@onready var pause_menu = $player/pause
@onready var mission_label = $CanvasLayer/TextureRect/Label

var missoes = [
	"Fale com José próximo aos elevadores no Hall do Queijo",
	"Entre no elevador e suba até o 5° andar",
	"Fale com o Pedro no 5° andar",
	"Mate os monstros que aparecerem"
]

var indice_missao_atual = 0

func _ready():
	await get_tree().process_frame
	pause_menu.hide()
	configurar_label()
	atualizar_missao()
	var npc3 = get_node_or_null("npc3")
	if npc3:
		npc3.falou_com_jose.connect(_on_falou_com_jose)


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
func atualizar_missao(novo_texto: String = ""):
	if novo_texto == "":
		if indice_missao_atual < missoes.size():
			mission_label.text = missoes[indice_missao_atual]
		else:
			mission_label.text = "Todas as missões concluídas!"
	else:
		mission_label.text = "Missão: \n" + novo_texto
func proxima_missao():
	if indice_missao_atual < missoes.size() - 1:
		indice_missao_atual += 1
		atualizar_missao()
func _on_falou_com_jose():
	proxima_missao()
