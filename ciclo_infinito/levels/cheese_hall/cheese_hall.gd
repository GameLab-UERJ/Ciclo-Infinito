extends Node2D

@export var target_scene: PackedScene

@onready var pause_menu = $player/pause
@onready var mission_label = $CanvasLayer/TextureRect/Label
@onready var fade_in_component: FadeComponent = $player/FadeInComponent
@onready var fade_out_component: FadeComponent = $player/FadeOutComponent

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
	fade_in_component.fade()


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


func mudar_de_cena():
	if target_scene == null:
		print("ERRO: A cena de destino (Target Scene) não foi definida no inspetor!")
		return
	var terrain_manager = get_tree().get_current_scene()
	terrain_manager.atualizar_missao("Missão: \nFale com o Pedro.")
	fade_out_component.fade()


func _on_falou_com_jose():
	proxima_missao()


func _on_fade_out_component_fade_finished() -> void:
	get_tree().change_scene_to_packed(target_scene)
