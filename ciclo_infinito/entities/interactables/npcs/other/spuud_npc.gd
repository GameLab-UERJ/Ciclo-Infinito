class_name SpuudNpc
extends CharacterBody2D

# --- Variáveis de Diálogo ---
# CUIDADO AQUI: Ajuste estes caminhos se sua cena for diferente!
@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interação: Label = $"Area2D/LabelInteraçao" 

# --- Variáveis do NPC ---
@onready var sprite: AnimatedSprite2D =  $Area2D/Sprite # 
@onready var ponto_patrulha_a: Marker2D = $PontoPatrulhaA
@onready var ponto_patrulha_b: Marker2D = $PontoPatrulhaB

@export_category("Attributes")
@export var is_floating: bool = true


var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0



var falas = ["Você já segue a página do SPUUD?" , "Lá você consegue achar a gatinha que tanto procura rsrs"
, "Ou também pode me passar o seu número rs"
]

# --- Variáveis de Patrulha ---
@export var move_speed: float = 50.0
@export var distancia_segura: float = 55.0

var pos_a: Vector2
var pos_b: Vector2
var target_position: Vector2
var is_moving: bool = false


func _ready() -> void:
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interação.visible = false
	
	if ponto_patrulha_a != null and ponto_patrulha_b != null:
		pos_a = ponto_patrulha_a.global_position
		pos_b = ponto_patrulha_b.global_position
		target_position = pos_a
		is_moving = true
	else:
		print("Aviso: Pontos de patrulha A e B não foram configurados no Inspetor do NPC.")
		is_moving = false


func _physics_process(_delta: float) -> void:
	
	# --- Lógica de Diálogo ---
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		proxima_fala()
	
	#Lógica de parar para conversar
	var player = get_tree().get_first_node_in_group("player")
	var muito_perto: bool = false
	
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < distancia_segura:
			muito_perto = true
			
	if falando or muito_perto or not is_moving:
		_parar_npc()
		return

	# Lógica de Patrulha
	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	
	if sprite != null:
		# <<<< ADICIONEI ANIMAÇÃO DE WALK AQUI >>>>
		sprite.play("walk") # Troque "walk" pelo nome da sua animação de andar
		if velocity.x > 0.1: 
			sprite.flip_h = false 
		elif velocity.x < -0.1:
			sprite.flip_h = true 

	move_and_slide()

	if global_position.distance_to(target_position) < 10.0:
		if target_position == pos_a:
			target_position = pos_b
		else:
			target_position = pos_a

func _parar_npc() -> void:
	velocity = Vector2.ZERO
	if sprite != null:
		sprite.play("idle")
	move_and_slide()
	
# --- Funções de Diálogo (sem mudanças) ---

func iniciar_dialogo():
	falando = true 
	label_interação.visible = false
	caixa_de_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	proxima_fala()

func proxima_fala():
	if fala_index < falas.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas[fala_index]
		fala_index += 1
		mostrar_texto_com_efeito(texto)
	else:
		encerrar_dialogo()

func mostrar_texto_com_efeito(texto: String):
	await get_tree().create_timer(0.1).timeout
	for letra in texto:
		texto_dialogo.text += letra
		await get_tree().create_timer(0.02).timeout
	pode_avancar = true

func encerrar_dialogo():
	falando = false 
	pode_avancar = false
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false

# --- Funções de Sinal (sem mudanças) ---

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
