class_name Player
extends CharacterBody2D

@onready var vida_cheia = $Camera2D/VidaCheia

var vida_textures = [
	preload("uid://d04wn5x7fupjs"),#vida -1
	preload("uid://dus84fjy3186o"),#vida -2
	preload("uid://cgoamuuy1qxwt"),#vida -3
	preload("uid://c82joy0gpepr5"),#vida -4
	preload("uid://cmvmmbbynqc85"),#vida -5
	preload("uid://d1i0ebuglppq1"),#vida -6
	preload("uid://c71y8r3arh7qc")#vida cheia
]


@export_category("Attributes")
@export var is_floating: bool = true

@onready var anim  = $animacoes  
@onready var dash_timer = $dash_timer
@onready var dash_cooldown = $dash_cooldown
@export var dash_duracao  = 0.2
@onready var area_attack = $attack_area
@onready var dash_sfx = $dash_sfx


var last_facing: String = "down"
var attack_facing: String = "down"

@export var move_speed: float = 240.00
@export var acceleration: float = 0.20
@export var friction: float = 0.20

@export var dash_speed: float = move_speed * 1.5
var is_dashing := false
var can_dash := true
var dash_dir: Vector2 = Vector2.ZERO

enum State {IDLE, RUN, ATTACK, DASH}
var current_state: int = State.IDLE
var next_direction: Vector2 = Vector2(0,1)


@export var attack1_lock_time := 0.22
@export var attack2_lock_time := 0.28
@export var hit1_active_time := 0.12
@export var hit2_active_time := 0.14
@export var combo_window := 0.20
@export var attack_cooldown := 0.15
@onready var attack_sfxplay: AudioStreamPlayer = $attack_sfxplay

# --- NOVO: Variáveis de Dano ---
@export var attack1_damage: float = 10.0 # Dano do primeiro golpe
@export var attack2_damage: float = 15.0 # Dano do segundo golpe
# -----------------------------

# --- NOVO: Variáveis de Vida do Jogador ---
@export var max_health: float = 120.0
var current_health: float
# ----------------------------------------


var can_attack := true
var combo_step := 0
var combo_window_open := false
var combo_buffered := false


@export var hitbox_size_right: Vector2 = Vector2(50, 25)
@export var hitbox_size_left:  Vector2 = Vector2(50, 25)
@export var hitbox_size_up:    Vector2 = Vector2(50, 40)
@export var hitbox_size_down:  Vector2 = Vector2(50, 40)


@export var hitbox_offset_right: Vector2 = Vector2(18, 0)
@export var hitbox_offset_left:  Vector2 = Vector2(-18, 0)
@export var hitbox_offset_up:    Vector2 = Vector2(0, -18)
@export var hitbox_offset_down:  Vector2 = Vector2(0, 18)

func _ready():
	# --- novinho em folha: inicializa a vida do jogador ---
	current_health = max_health
	update_health_bar()
	# -----------------------------------------
	
	
	dash_timer.wait_time = dash_duracao
	dash_timer.one_shot = true
	if not dash_timer.timeout.is_connected(_on_dash_timer_timeout):
		dash_timer.timeout.connect(_on_dash_timer_timeout)
	if not dash_cooldown.timeout.is_connected(_on_dash_cooldown_timeout):
		dash_cooldown.timeout.connect(_on_dash_cooldown_timeout)
	area_attack.get_node("attack_colison").disabled = true
	
	# --- NOVO: Conecta o sinal de colisão para aplicar dano ---
	if not area_attack.body_entered.is_connected(_on_area_attack_body_entered):
		area_attack.body_entered.connect(_on_area_attack_body_entered)

	
	# --- NOVO: Função para receber dano ---
func take_damage(damage_amount: float, hit_direction: Vector2) -> void:
	if current_state == State.DASH:
		return

	current_health -= damage_amount
	current_health = clamp(current_health, 0.0, max_health)

	print("Player recebeu dano de ", damage_amount, ". Vida restante: ", current_health)

	# Atualiza barra de vida
	update_health_bar()

	# Efeito de knockback
	var knockback_force: float = 350.0
	velocity = hit_direction * knockback_force

	if current_health <= 0.0:
		die()

#Função para fazer os corações da HUD
func update_health_bar():
	var ratio=current_health/max_health
	var filled_heart=int(round(ratio*6))
	filled_heart=clamp(filled_heart,0,6)
	vida_cheia.texture=vida_textures[filled_heart]
	
# --- NOVO: Função de morte ---
func die() -> void:
	print("O jogador foi derrotado!")
	var death_scene = preload("uid://b7qoxm33b5qxt").instantiate()#death_screen.tscn
	get_tree().root.add_child(death_scene)
	death_scene.set_layer(100)


func _physics_process(delta: float):
	match current_state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state(delta)
		State.ATTACK:
			_attack_state()
		State.DASH:
			_dash_state()
	move_and_slide()
	_update_attack_area_anchor()
	update_animation()
	#last_facing = get_direction_string(get_input_direction())
	#print(last_facing)
	
	%ProgressBar.value = current_health
	%ProgressBar.max_value = 100.0
	

func get_input_direction() -> Vector2:
	return Input.get_vector("run_left","run_right","run_up","run_down")

func can_start_attack() -> bool:
	return current_state != State.DASH and can_attack

func _idle_state() -> void:
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("attack"):
		if can_start_attack():
			_start_attack1()
	elif Input.is_action_just_pressed("dash"):
		current_state = State.DASH
	elif get_input_direction() != Vector2.ZERO:
		current_state = State.RUN

func _run_state(_delta: float) :    
	var input_direction: Vector2 = get_input_direction()
	
	if Input.is_action_just_pressed("attack"):
		if can_start_attack():
			_start_attack1()
	elif Input.is_action_just_pressed("dash"):
		current_state = State.DASH

	if input_direction == Vector2.ZERO:
		current_state = State.IDLE
		return
	next_direction = input_direction
	velocity = input_direction.normalized() * move_speed

func _attack_state():
	var input_direction: Vector2 = get_input_direction()
	if input_direction != Vector2.ZERO:
		next_direction = input_direction
		velocity = input_direction.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("attack") and combo_step == 1 and combo_window_open:
		combo_buffered = true


func _dash_state():
	dash_sfx.play()
	if dash_timer.is_stopped():
		dash_timer.start()
		var dash_direction: Vector2 = next_direction
		var in_dir: Vector2 = get_input_direction()
		if in_dir != Vector2.ZERO:
			dash_direction = in_dir
			next_direction = in_dir
		dash_dir = dash_direction.normalized()
		velocity = dash_dir * dash_speed
	else:
		velocity = dash_dir * dash_speed

func _on_dash_timer_timeout() -> void:
	$player_colision.disabled = false
	velocity = Vector2.ZERO
	if  get_input_direction() != Vector2.ZERO:
		current_state = State.RUN
	else:
		current_state = State.IDLE
	if dash_cooldown and dash_cooldown.is_stopped():
		dash_cooldown.start()

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

# --- NOVA FUNÇÃO: Aplica dano ao CharacterBody atingido ---
func _on_area_attack_body_entered(body: Node2D) -> void:
	# Verifica se o alvo é um CharacterBody2D e tem a função 'take_damage'
	if body is CharacterBody2D and body.has_method("take_damage"):
		var damage_amount: float = 0.0

		# Determina o dano baseado no combo atual
		if combo_step == 1:
			damage_amount = attack1_damage
		elif combo_step == 2:
			damage_amount = attack2_damage
		
		# Garante que o dano só seja aplicado quando o golpe está ATIVO
		if damage_amount > 0.0:
			# Calcula a direção do knockback (do atacante para o alvo)
			var knockback_direction: Vector2 = (body.global_position - global_position).normalized()
			
			# Chama a função take_damage no script do alvo (ex: inimigo)
			body.take_damage(damage_amount, knockback_direction)
# --------------------------------------------------------


func _start_attack1() -> void: # Inicia a animação do ataque 1 e ajusta as variáveis de controle
	attack_facing = get_direction_string(next_direction)  
	current_state = State.ATTACK
	can_attack = false
	combo_step = 1
	combo_buffered = false

	_apply_attack_hitbox_for_facing(attack_facing)
	_enable_attack_hitbox_for(hit1_active_time)

	var a := "attack1_" + attack_facing
	if anim.animation != a:
		anim.stop(); anim.frame = 0; anim.play(a)
		attack_sfxplay.play()

	_open_combo_window()
	_end_attack1_after_lock()

func _open_combo_window() -> void: # Espera a janela de combo e, se houve um ataque, inicia o ataque 2
	combo_window_open = true
	await get_tree().create_timer(combo_window).timeout
	combo_window_open = false
	if combo_step == 1 and combo_buffered:
		_start_attack2()

func _end_attack1_after_lock() -> void: # Se após a janela de combo não houver ataque, finaliza o estado de ataque
	await get_tree().create_timer(attack1_lock_time).timeout
	if combo_step == 1:
		_finish_attack_sequence()

func _start_attack2() -> void: # Mesma lógica do ataque 1
	combo_step = 2

	_apply_attack_hitbox_for_facing(attack_facing)
	_enable_attack_hitbox_for(hit2_active_time)

	var a := "attack2_" + attack_facing
	if anim.animation != a:
		attack_sfxplay.play()
		anim.stop(); anim.frame = 0; anim.play(a)

	await get_tree().create_timer(attack2_lock_time).timeout
	_finish_attack_sequence()

func _finish_attack_sequence() -> void: # Restaura variáveis de controle e devolve para outro estado
	combo_step = 0
	if get_input_direction() != Vector2.ZERO:
		current_state = State.RUN
	else:
		current_state = State.IDLE
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _enable_attack_hitbox_for(dur: float) -> void: # Ativa a colisão de ataque durante o tempo do golpe
	var col: CollisionShape2D = area_attack.get_node("attack_colison")
	col.disabled = false
	await get_tree().create_timer(dur).timeout
	col.disabled = true


func _apply_attack_hitbox_for_facing(facing: String) -> void: # Ajusta a hitbox conforme a direção em que o personagem está olhando
	var col: CollisionShape2D = area_attack.get_node("attack_colison")
	var rect := col.shape as RectangleShape2D
	if rect == null:
		return
	match facing:
		"right":
			rect.size = hitbox_size_right
			col.position = hitbox_offset_right
		"left":
			rect.size = hitbox_size_left
			col.position = hitbox_offset_left
		"up":
			rect.size = hitbox_size_up
			col.position = hitbox_offset_up
		_:
			rect.size = hitbox_size_down
			col.position = hitbox_offset_down

# Mantém a hitbox “apontando” para onde o personagem está olhando
func _update_attack_area_anchor() -> void:
	if current_state == State.ATTACK:
		_apply_attack_hitbox_for_facing(attack_facing)
		return
	# Fora do ATTACK, ancora pela direção atual (ou última) para o retângulo ficar sempre alinhado.
	var input_dir: Vector2 = get_input_direction()
	var facing: String = get_direction_string(input_dir) if input_dir != Vector2.ZERO else last_facing
	_apply_attack_hitbox_for_facing(facing)


func update_animation() -> void:
	var anim_name := ""
	var direction_str: String = attack_facing if current_state == State.ATTACK else get_direction_string(next_direction)
	match current_state:
		State.IDLE:
			anim_name = "idle_" + direction_str
		State.RUN:
			anim_name = "run_" + direction_str
		State.ATTACK:
			anim_name = ( "attack2_" if combo_step == 2 else "attack1_" ) + attack_facing
		State.DASH:
			anim_name = "dash_" + direction_str
	if anim.animation != anim_name:
		if current_state == State.ATTACK:
			anim.stop(); anim.frame = 0
		anim.play(anim_name)

func get_direction_string(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right"  if v.x > 0.0 else "left"
	else:
		return "down"  if v.y > 0.0 else "up"
