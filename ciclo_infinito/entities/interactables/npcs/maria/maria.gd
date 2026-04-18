class_name Maria
extends CharacterBody2D

## NPC Maria com diálogo simples

# ========================
# VARIABLES
# ========================

var player_in_area: bool = false
var falando: bool = false

var dialogo: Dialogo

var falas: Array[String] = [
	"Oi! Eu sou a Maria.",
	"Esse lugar é meio estranho, né?",
	"Toma cuidado por aí."
]

# ---- PATRULHA ----
@export var move_speed: float = 50.0

var pos_a: Vector2
var pos_b: Vector2
var target_position: Vector2
var is_moving: bool = false

# ========================
# ONREADY
# ========================

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interacao: Label = $Area2D/LabelInteracao
@onready var pular_dialogo: Label = $Area2D/CanvasLayer/PularDialogo

@onready var ponto_patrulha_a: Marker2D = $PontoPatrulhaA
@onready var ponto_patrulha_b: Marker2D = $PontoPatrulhaB

# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	dialogo = Dialogo.new()
	add_child(dialogo)

	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false
	
	if ponto_patrulha_a and ponto_patrulha_b:
		pos_a = ponto_patrulha_a.global_position
		pos_b = ponto_patrulha_b.global_position
		target_position = pos_a
		is_moving = true
	else:
		is_moving = false


func _process(_delta: float) -> void:

	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()

	elif falando and Input.is_action_just_pressed("interact"):
		dialogo.input_interact()

	if falando and not dialogo.ativo:
		encerrar_dialogo()

func _physics_process(_delta: float) -> void:

	# PARA SE ESTIVER FALANDO
	if falando or not is_moving:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# MOVIMENTO
	var direction: Vector2 = (target_position - global_position).normalized()
	velocity = direction * move_speed

	move_and_slide()

	# TROCA DE PONTO
	if global_position.distance_to(target_position) < 10.0:
		target_position = pos_b if target_position == pos_a else pos_a

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


# ========================
# AREA
# ========================

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = true
		label_interacao.text = "Pressione 'E'"
		label_interacao.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = false
		label_interacao.visible = false

		if falando:
			encerrar_dialogo()
