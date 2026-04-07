class_name NPC
extends StaticBody2D

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interação: Label = $Area2D/LabelInteração
@onready var mapa = get_parent()
@onready var pular_dialogo = $Area2D/CanvasLayer/PularDialogo


signal dialogo_concluido
signal falou_com_pedro

var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0
var falas_atuais = []
var escrevendo = false
var texto_completo = ''
var skip_animacao = false


var falas = {
	"primeira_conversa": [
		"Olá, meu chapa. Você infelizmente acabou de entrar em um purgatório da UERJ.",
		"No quinto andar, moram os golems monstros que guardam os segredos mais sombrios da engenharia.",
		"Entre todos os monstros do quinto andar, há um ser místico temido por todos: o Olho da Pressão.",
		"Elimine os inimigos e fale comigo novamente."
	],
	"antes_de_matar": [
		"Você ainda não derrotou os monstros.",
		"Elimine os inimigos e fale comigo novamente."
	],
	"depois_de_matar": [
		"Nada mal.",
		"Venha, vou te explicar mais sobre o que está acontecendo."
	]}
	
func _ready() -> void:
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interação.visible = false
	pular_dialogo.visible = false
	
	
	
	
func _process(_delta) -> void:
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	elif falando  and Input.is_action_just_pressed("interact"):
		if escrevendo:
			skip_animacao = true
		elif pode_avancar:
			proxima_fala()
		
		
func iniciar_dialogo():
	falando = true
	label_interação.visible = false
	caixa_de_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	falas_atuais = obter_dialogo_atual()
	proxima_fala()
	
	
func obter_dialogo_atual():
	match mapa.indice_missao_atual:
		2:
			return falas["primeira_conversa"]
			print(mapa.indice_missao_atual)
		3:
			return falas["antes_de_matar"]
			print(mapa.indice_missao_atual)
		4:
			return falas["depois_de_matar"]
			print(mapa.indice_missao_atual)
	
	
	
func proxima_fala():
	if fala_index < falas_atuais.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas_atuais[fala_index]
		fala_index += 1
		mostrar_texto_com_efeito(texto)
	else:
		encerrar_dialogo()
		
		
func mostrar_texto_com_efeito(texto: String):
	texto_completo = texto
	escrevendo = true
	skip_animacao = false
	pode_avancar  = false
	texto_dialogo.text = ""
	pular_dialogo.text = "Pressione 'E' para pular"
	pular_dialogo.visible = true
	
	await get_tree().create_timer(0.1).timeout
	for letra in texto:
		if skip_animacao:
			texto_dialogo.text = texto
			break
		texto_dialogo.text += letra
		await get_tree().create_timer(0.02).timeout
	escrevendo = false
	pode_avancar = true
	pular_dialogo.visible = false
	
	
func encerrar_dialogo():
	falando = false
	pode_avancar = false
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	emit_signal("dialogo_concluido")
	emit_signal("falou_com_pedro")  # Emite sinal para avançar missão
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = true
		label_interação.text = "Pressione 'E' para interagir"
		label_interação.visible = true
		
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = false
		label_interação.visible = false
		if falando:
			encerrar_dialogo()
