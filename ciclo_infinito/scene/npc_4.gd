extends CharacterBody2D

# --- Variáveis de Diálogo ---
# CUIDADO AQUI: Ajuste estes caminhos se sua cena for diferente!
@export var is_floating: bool = true
@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interação: Label = $"Area2D/LabelInteração" # Ou talvez $Area2D/LabelInteraçao ? Verifique sua cena.

# --- Variáveis do NPC ---
@onready var sprite: AnimatedSprite2D =  $Area2D/Sprite 
@onready var ponto_patrulha_a: Marker2D = $PontoPatrulhaA
@onready var ponto_patrulha_b: Marker2D = $PontoPatrulhaB

var player_in_area: bool = false
var falando: bool = false
var pode_avancar:bool = false
var fala_index: int = 0

var falas = ["Oi! Eu sou a Maria! Você é um calouro de engenharia?"
]

# --- Variáveis de Patrulha ---
@export var move_speed: float = 50.0
@export var distancia_segura: float = 60.0 #distancia para a npc detectar o player e parar de andar!!

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


func _physics_process(delta: float) -> void:
	
	# --- Lógica de Diálogo ---
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		proxima_fala()
		
	 ### novas alteraçoes para tentar resolver o problema do grude nos npcssss. COMEÇA AQ~!!!!!!!
	var player = get_tree().get_first_node_in_group("player")
	var muito_perto = false
		
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < distancia_segura:
			muito_perto = true
		
	if falando or muito_perto or not is_moving:
		_parar_npc()
		return

	# Lógica de Patrulha ( só executa se passar pelo if ! )
	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	
	# apaguei o if com IDLE q estava aqui pq estava atrapalhando a execuçao do if abaixo
	
	
	if sprite != null:
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
			
## isso aq tbnm é novo para o npc parar de andar
func _parar_npc():
	velocity = Vector2.ZERO # faz com q ele pare mas respeite a colisão
	if sprite:
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
		if not falando: #linha que conserta o diálogo que é atropelado
			return
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
