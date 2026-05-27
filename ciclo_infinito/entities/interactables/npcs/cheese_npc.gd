class_name CheeseNpc
extends CharacterBody2D


signal was_talked_to(npc : CheeseNpc)


@export var dialogo : DialogueResource
@export var move_speed: float = 50.0


var player_in_area: bool = false
var falando: bool = false
var player_has_talked_with: bool = false
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
@onready var sprite: AnimatedSprite2D = $Area2D/Sprite
@onready var ponto_patrulha_a: Marker2D = get_node("PontoPatrulhaA") if has_node("PontoPatrulhaA") else null
@onready var ponto_patrulha_b: Marker2D = get_node("PontoPatrulhaB") if has_node("PontoPatrulhaB") else null
@onready var player : Player = get_tree().get_first_node_in_group("player")


# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(encerra_dialogo)
	
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


func _physics_process(_delta: float) -> void:

	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		inicia_dialogo()
	
	if falando or not is_moving or not ponto_patrulha_a:
		return
	
	var direction: Vector2 = (target_position - global_position).normalized()
	velocity = direction * move_speed
	
	if sprite:
		sprite.flip_h = velocity.x < 0
	
	move_and_slide()
	
	if global_position.distance_to(target_position) < 10.0:
		target_position = pos_b if target_position == pos_a else pos_a


# ========================
# DIALOGO
# ========================

func inicia_dialogo() -> void:
	falando = true
	DialogueManager.show_example_dialogue_balloon(dialogo,"start")
	if player:
		player._on_dialogo_iniciado()


func encerra_dialogo(_dialogue : DialogueResource) -> void:
	falando = false
	if player:
		player._on_dialogo_encerrado()
		player_has_talked_with = true
		was_talked_to.emit(self)

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
