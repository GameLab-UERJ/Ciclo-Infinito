class_name Jose
extends StaticBody2D

## NPC José com diálogo simples

# ========================
# SIGNALS
# ========================

signal dialog_started
signal dialog_finished
signal falou_com_jose


# ========================
# VARIABLES
# ========================

var player_in_area: bool = false
var falando: bool = false
var ja_falou: bool = false

var dialogo: Dialogo

var falas: Array[String] = [
	"E aí!",
	"Já falou com a Maria?",
	"Boa sorte na jornada!"
]


# ========================
# ONREADY
# ========================

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interacao: Label = $Area2D/LabelInteracao
@onready var pular_dialogo: Label = $Area2D/CanvasLayer/PularDialogo

# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	dialogo = Dialogo.new()
	add_child(dialogo)
	
	var player = get_tree().get_first_node_in_group("player")

	if player:
		dialogo.dialogo_iniciado.connect(player._on_dialogo_iniciado)
		dialogo.dialogo_encerrado.connect(player._on_dialogo_encerrado)
	
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false


func _process(_delta: float) -> void:

	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()

	elif falando and Input.is_action_just_pressed("interact"):
		dialogo.input_interact()

	if falando and not dialogo.ativo:
		encerrar_dialogo()


# ========================
# DIALOGO
# ========================

func iniciar_dialogo() -> void:
	falando = true
	label_interacao.visible = false

	dialogo.iniciar(falas, caixa_de_dialogo, texto_dialogo, pular_dialogo)


func encerrar_dialogo() -> void:
	falando = false
	
	dialogo.encerrar()
	
	# evita emitir múltiplas vezes
	if not ja_falou:
		ja_falou = true
		emit_signal("falou_com_jose")


# ========================
# AREA
# ========================

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		label_interacao.text = "Pressione 'E'"
		label_interacao.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		label_interacao.visible = false

		if falando:
			encerrar_dialogo()
