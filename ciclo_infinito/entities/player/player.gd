class_name Player
extends CharacterBody2D


enum State {IDLE, RUN, ATTACK, DASH, DEATH, DIALOG, CUTSCENE}


@export var max_health: float = 120.0:
	set(value):
		max_health = value
		if health_component:
			health_component.max_health = max_health
@export var attack1_damage: float = 15.0 ## Dano do primeiro golpe
@export var attack2_damage: float = 15.0 ## Dano do segundo golpe
@export var move_speed: float = 240.00
@export var invinciblity_duration : float  = 0.3
@export_group("Attack")
@export var attack_cooldown := 0.15
@export var combo_window := 0.21
@export_subgroup("Attack 1")
@export var hit1_active_time := 0.12
@export var attack1_lock_time := 0.22
@export_subgroup("Attack 2")
@export var hit2_active_time := 0.14
@export var attack2_lock_time := 0.28
@export_group("Dash")
@export var dash_cooldown_time: float = 1
@export var dash_speed_multiplier: float = 3
@export var dash_duracao  = 0.2
@export_group("Hitboxes")
@export_subgroup("Hitbox sizes")
@export var hitbox_size_right: Vector2 = Vector2(50, 25)
@export var hitbox_size_left:  Vector2 = Vector2(50, 25)
@export var hitbox_size_up:    Vector2 = Vector2(50, 40)
@export var hitbox_size_down:  Vector2 = Vector2(50, 40)
@export_subgroup("Hitbox offsets")
@export var hitbox_offset_right: Vector2 = Vector2(18, 0)
@export var hitbox_offset_left:  Vector2 = Vector2(-18, 0)
@export var hitbox_offset_up:    Vector2 = Vector2(0, -18)
@export var hitbox_offset_down:  Vector2 = Vector2(0, 18)


var is_dead : bool = false
var last_facing: String = "down"
var attack_facing: String = "down"
var is_dashing : bool = false
var is_dash_on_cooldown : bool = false
var dash_dir: Vector2 = Vector2.ZERO
var current_state: int = State.IDLE
var next_direction: Vector2 = Vector2(0,1)
var can_attack : bool = true
var combo_step : int = 0
var combo_window_open := false
var combo_buffered := false
var vida_textures = [
	preload("uid://d04wn5x7fupjs"),#vida -1
	preload("uid://dus84fjy3186o"),#vida -2
	preload("uid://cgoamuuy1qxwt"),#vida -3
	preload("uid://c82joy0gpepr5"),#vida -4
	preload("uid://cmvmmbbynqc85"),#vida -5
	preload("uid://d1i0ebuglppq1"),#vida -6
	preload("uid://c71y8r3arh7qc")#vida cheia
]

@onready var state_label: Label = $StateLabel
@onready var vida_cheia = $Camera2D/VidaCheia
@onready var anim : AnimatedSprite2D  = $animacoes  
@onready var dash_timer = $dash_timer
@onready var dash_cooldown = $dash_cooldown
@onready var area_attack = $attack_area
@onready var player_colision: CollisionShape2D = $player_colision
@onready var dash_sfx = $SoundEffects/dash_sfx
@onready var damage_recieved_sfx: AudioStreamPlayer = $SoundEffects/DamageRecievedSFX
@onready var death_sfx: AudioStreamPlayer = $SoundEffects/DeathSFX
@onready var attack_sfxplay: AudioStreamPlayer = $SoundEffects/attack_sfxplay
@onready var footsteps_sfx: AudioStreamPlayer2D = $SoundEffects/FootstepsSfx
@onready var camera: Camera2D = $Camera2D
@onready var shadow: Sprite2D = $Shadow
@onready var health_component: Node = %HealthComponent


func _ready():
	max_health = max_health
	health_component.update_health_bar()
	dash_timer.wait_time = dash_duracao


func _physics_process(delta: float):
	if is_dead:
		return
	state_label.text = State.find_key(current_state)
	match current_state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state(delta)
		State.ATTACK:
			_attack_state()
		State.DASH:
			_dash_state()
		State.DIALOG:
			_dialog_state()
	if combo_buffered and combo_step == 0 and can_start_attack():
		combo_buffered = false
		_start_attack1()
	move_and_slide()
	_update_attack_area_anchor()
	update_animation()


func get_input_direction() -> Vector2:
	return Input.get_vector("run_left","run_right","run_up","run_down")


func can_start_attack() -> bool:
	return current_state != State.DASH and current_state != State.DIALOG and can_attack


func can_dash() -> bool:
	return current_state == State.RUN and not is_dash_on_cooldown and not is_dashing


func _idle_state() -> void:
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("attack"):
		if can_start_attack():
			_start_attack1()
	elif Input.is_action_just_pressed("dash"):
		if can_dash():
			current_state = State.DASH
	elif get_input_direction() != Vector2.ZERO:
		if current_state != State.DASH:
			current_state = State.RUN


func _run_state(_delta: float) :    
	var input_direction: Vector2 = get_input_direction()
	
	if Input.is_action_just_pressed("attack"):
		if can_start_attack():
			_start_attack1()
	elif Input.is_action_just_pressed("dash"):
		if can_dash():
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
	if not is_dashing:
		is_dashing = true
		anim.play( "dash_" + get_direction_string(next_direction))
		dash_sfx.play(0.4)
		dash_timer.start()
		is_dash_on_cooldown = true
		
		var dash_direction: Vector2 = next_direction
		var in_dir: Vector2 = get_input_direction()
		if in_dir != Vector2.ZERO:
			dash_direction = in_dir
			next_direction = in_dir
		dash_dir = dash_direction.normalized()
		
		await health_component.start_invincibility(dash_timer.wait_time,true)
	
	velocity = dash_dir * move_speed * dash_speed_multiplier


func _dialog_state():
	velocity = Vector2.ZERO


func _on_dash_timer_timeout() -> void:
	if  get_input_direction() != Vector2.ZERO:
		current_state = State.RUN
	else:
		current_state = State.IDLE
	is_dashing = false
	is_dash_on_cooldown = true
	dash_cooldown.start(dash_cooldown_time)


func _on_dash_cooldown_timeout() -> void:
	is_dash_on_cooldown = false


func _on_area_attack_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D and body.has_method("take_damage")):
		return
	
	var damage_amount: float
	if combo_step == 1:
		damage_amount = attack1_damage
	elif combo_step == 2:
		damage_amount = attack2_damage
	else:
		damage_amount = 0
		
	if damage_amount > 0.0:
		var knockback_direction: Vector2 = (body.global_position - global_position).normalized()
		body.take_damage(damage_amount, knockback_direction)


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
		combo_buffered = false
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
	if current_state == State.DIALOG:
		pass
	elif get_input_direction() != Vector2.ZERO:
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


func _update_attack_area_anchor() -> void:
	if current_state == State.ATTACK:
		_apply_attack_hitbox_for_facing(attack_facing)
		return
	var input_dir: Vector2 = get_input_direction()
	var facing: String = get_direction_string(input_dir) if input_dir != Vector2.ZERO else last_facing
	_apply_attack_hitbox_for_facing(facing)


func _on_dialogo_iniciado():
	current_state = State.DIALOG


func _on_dialogo_encerrado():
	current_state = State.IDLE


func update_animation() -> void:
	var anim_name := ""
	var direction_str: String = get_direction_string(next_direction)
	match current_state:
		State.IDLE,State.DIALOG:
			anim_name = "idle_" + direction_str
		State.RUN,State.CUTSCENE:
			anim_name = "run_" + direction_str
		State.ATTACK:
			anim_name = ( "attack2_" if combo_step == 2 else "attack1_" ) + attack_facing
		State.DEATH:
			anim_name = "death_" + direction_str
		State.DASH:
			return
	if anim.animation != anim_name:
		if current_state == State.ATTACK:
			anim.stop(); anim.frame = 0
		if anim_name.begins_with("dash") and not dash_cooldown.is_stopped():
			anim.animation = anim_name
			return
		anim.play(anim_name)


func applies_damage_received_effect() -> void:
	damage_recieved_sfx.play()
	
	anim.material.set_shader_parameter("whiten", true)
	await get_tree().create_timer(invinciblity_duration).timeout
	anim.material.set_shader_parameter("whiten", false)


func get_direction_string(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right"  if v.x > 0.0 else "left"
	else:
		return "down"  if v.y > 0.0 else "up"


func pan_camera_to(node : Node2D) -> void:
	current_state = State.DIALOG
	await create_tween().tween_property(camera,"global_position",node.global_position,1).finished


func pan_camera_back() -> void:
	await pan_camera_to(self)
	current_state = State.IDLE


func set_camera_limits(left : Node2D, right : Node2D, bottom : Node2D, top : Node2D) -> void:
	camera.limit_bottom = ceil(bottom.global_position.y)
	camera.limit_top 	= ceil(top.global_position.y)
	camera.limit_left 	= ceil(left.global_position.x)
	camera.limit_right 	= ceil(right.global_position.x)


func _on_animacoes_frame_changed() -> void:
	if not anim:
		return
	
	if anim.animation.begins_with("run"):
		match anim.frame:
			3,7:
				footsteps_sfx.play()


func _on_animacoes_animation_finished() -> void:
	if anim.animation.begins_with("dash"):
		current_state = State.IDLE
