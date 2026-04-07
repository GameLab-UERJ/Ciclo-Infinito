class_name NPC
extends StaticBody2D

## NPC responsável por interação com o jogador e controle de diálogo baseado na missão.

# ========================
# SIGNALS
# ========================

signal dialogo_concluido
signal falou_com_pedro


# ========================
# VARIABLES
# ========================

var player_in_area: bool = false
var falando: bool = false

var falas_atuais: Array[String] = []

var dialogo: Dialogo


var falas: Dictionary = {
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
	]
}


# ========================
# ONREADY
# ========================

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interacao: Label = $Area2D/LabelInteracao
@onready var mapa: Node = get_parent()
@onready var pular_dialogo: Label = $Area2D/CanvasLayer/PularDialogo


# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	dialogo = Dialogo.new()
	add_child(dialogo)
	
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false
	pular_dialogo.visible = false


func _process(_delta: float) -> void:
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	
	elif falando and Input.is_action_just_pressed("interact"):
		dialogo.input_interact()
	
	# Detecta fim do diálogo
	if falando and not dialogo.ativo:
		encerrar_dialogo()


# ========================
# DIALOGO
# ========================

## Inicia o diálogo com base no estado atual da missão.
func iniciar_dialogo() -> void:
	falando = true
	label_interacao.visible = false
	
	falas_atuais = obter_dialogo_atual()
	
	dialogo.iniciar(
		falas_atuais,
		caixa_de_dialogo,
		texto_dialogo,
		pular_dialogo
	)


## Retorna o conjunto de falas baseado na missão atual.
func obter_dialogo_atual() -> Array[String]:
	var resultado: Array[String] = []

	var falas_brutas: Array = []

	match mapa.indice_missao_atual:
		2:
			falas_brutas = falas["primeira_conversa"]
		3:
			falas_brutas = falas["antes_de_matar"]
		4:
			falas_brutas = falas["depois_de_matar"]
		_:
			falas_brutas = []

	for fala in falas_brutas:
		resultado.append(fala)

	return resultado


## Encerra o diálogo e emite sinais necessários.
func encerrar_dialogo() -> void:
	falando = false
	
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	
	emit_signal("dialogo_concluido")
	emit_signal("falou_com_pedro")


# ========================
# AREA
# ========================

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = true
		label_interacao.text = "Pressione 'E' para interagir"
		label_interacao.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = false
		label_interacao.visible = false
		
		if falando:
			encerrar_dialogo()
