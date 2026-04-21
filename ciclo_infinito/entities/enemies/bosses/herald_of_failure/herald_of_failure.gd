class_name Boss
extends CharacterBody2D


enum State {OUT_OF_SIGHT, WAITING_PLAYER, IDLE, RUN, ATTACK1, DEAD}


# --- NOVO: Constante de duração de efeito de dano recebido ---
const DAMAGE_TAKEN_EFFECT_DURATION: float = 0.15


@export var speed = 100.0
@export var player : Player
@export var max_health: float = 1600.0
@export var attack_damage: float = 20
@export_range(0,1,0.01) var chance_of_attacking_after_moving: float = 0.5
@export_category("Moving Limits")
@export var top_left_corner : Marker2D
@export var bottom_right_corner : Marker2D


var current_health : float
var _initial_position : Vector2
var _moving_limits : Rect2
var _next_position : Vector2 
var _state : State = State.OUT_OF_SIGHT:
	set(value):
		_state = value
		print("state changed to " + State.find_key(value))
var _first_time_on_screen : bool = true


@onready var sprites: AnimatedSprite2D = $Sprites
@onready var boss_hud: BossHUD = $BossHUD
@onready var shadow: Sprite2D = $Shadow
@onready var fire_meteor: FireMeteor = $FireMeteor
@onready var fire_meteor_2: FireMeteor = $FireMeteor2
@onready var fire_meteor_3: FireMeteor = $FireMeteor3


func _ready() -> void:
	_initial_position = global_position
	current_health = max_health
	if not top_left_corner:
		_moving_limits = Rect2(global_position-Vector2.ONE,Vector2.ONE)
	else:
		_moving_limits = Rect2(top_left_corner.global_position,Vector2.ONE)
	if bottom_right_corner:
		_moving_limits.end = bottom_right_corner.global_position
	current_health = max_health
	
	call_deferred("remove_child",fire_meteor)
	get_parent().call_deferred("add_child",fire_meteor)
	fire_meteor.connect("deal_damage_to_player",apply_attack_damage)
	
	call_deferred("remove_child",fire_meteor_2)
	get_parent().call_deferred("add_child",fire_meteor_2)
	fire_meteor_2.connect("deal_damage_to_player",apply_attack_damage)
	
	call_deferred("remove_child",fire_meteor_3)
	get_parent().call_deferred("add_child",fire_meteor_3)
	fire_meteor_3.connect("deal_damage_to_player",apply_attack_damage)


func _physics_process(delta: float) -> void:
	move_and_slide()
	if Input.is_action_just_released("ui_accept"):
		_state = State.RUN
	match _state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state()
		State.ATTACK1:
			_attack_1_state()
		State.OUT_OF_SIGHT:
			_out_of_sight_state()
		State.WAITING_PLAYER:
			_waiting_player_state()


	# --- NOVO: Função para receber dano ---
func take_damage(damage_amount: float, hit_direction: Vector2) -> void:
	hit_direction = Vector2.ZERO
	current_health -= damage_amount
	current_health = clamp(current_health, 0.0, max_health)

	print("Player recebeu dano de ", damage_amount, ". Vida restante: ", current_health)

	# Atualiza barra de vida
	boss_hud.update_health(current_health)

	# Efeito de knockback
	var knockback_force: float = 350.0
	velocity = hit_direction * knockback_force
	
	# --- NOVO: Aplica efeito de dano recebido ---
	applies_damage_received_effect()
	
	
	if current_health <= 0.0:
		die()


# --- NOVA FUNÇÃO: Aplica efeito visual e sonoro ao receber dano ---
func applies_damage_received_effect() -> void:
	#damage_recieved_sfx.play()
	
	sprites.material.set_shader_parameter("redden", true)
	await get_tree().create_timer(DAMAGE_TAKEN_EFFECT_DURATION).timeout
	sprites.material.set_shader_parameter("redden", false)



func apply_attack_damage() -> void:
	if not player:
		return
	player.take_damage(attack_damage, Vector2.ZERO)


func die() -> void:
	sprites.play("death")
	create_tween().tween_property(shadow,"self_modulate",Color.TRANSPARENT,sprites.sprite_frames.get_frame_count("death")/sprites.sprite_frames.get_animation_speed("death"))
	_state = State.DEAD


func _set_flip_h() -> void:
	sprites.flip_h = false
	
	match _state:
		State.IDLE:
			if not player:
				return
			if global_position.direction_to(player.global_position).x < 0:
				sprites.flip_h = true
		State.RUN:
			if global_position.direction_to(_next_position).x < 0:
				sprites.flip_h = true

func _out_of_sight_state() -> void: 
	sprites.play("idle")
	if global_position.distance_to(_initial_position) < 10:
		_state = State.WAITING_PLAYER 
	else:
		sprites.play("move")
		velocity = global_position.direction_to(_initial_position)*speed*2
	_set_flip_h()


func _waiting_player_state() -> void: 
	sprites.play("idle")


func _idle_state() -> void: 
	sprites.play("idle")
	velocity = Vector2.ZERO
	_set_flip_h()
	await get_tree().create_timer(1).timeout
	_go_run()


func _run_state() -> void:  
	if not _next_position:  
		get_valid_next_position()
		
	sprites.play("move")
	_set_flip_h()
	
	var direction : Vector2 = global_position.direction_to(_next_position)
	if is_on_wall():
		print("hit wall")
		return
	if (global_position.distance_to(_next_position)) < 10.0:
		if randf() <= chance_of_attacking_after_moving:
			_state = State.ATTACK1
			print("ATTACK")
		else:
			_state = State.IDLE
		_next_position = Vector2.ZERO
		return
	
	velocity = direction * speed


func _attack_1_state() -> void:
	if sprites.animation == "attack_1" and sprites.is_playing():
		return
	sprites.play("attack_1")
	velocity = Vector2.ZERO
	_set_flip_h()
	if not player:
		_state = State.IDLE
		return
		
	fire_meteor.global_position = player.global_position
	fire_meteor.drop()
	fire_meteor_2.global_position = Vector2(randf_range(_moving_limits.position.x,_moving_limits.end.x),
											randf_range(_moving_limits.position.y,_moving_limits.end.y))
	fire_meteor_2.drop()
	fire_meteor_3.global_position = Vector2(randf_range(_moving_limits.position.x,_moving_limits.end.x),
											randf_range(_moving_limits.position.y,_moving_limits.end.y))
	fire_meteor_3.drop()


func _go_run() -> void:
	_state = State.RUN


func get_valid_next_position(minimum_distance : float = 50) -> void:
	var candidate_next_position : Vector2
	for i in 20:
		candidate_next_position = Vector2(	randf_range(_moving_limits.position.x,_moving_limits.end.x),
											randf_range(_moving_limits.position.y,_moving_limits.end.y))
											
		if not _moving_limits.has_point(candidate_next_position):
			continue
		if global_position.distance_to(candidate_next_position) <= minimum_distance:
			continue
		_next_position = candidate_next_position
		return
	print("curr: " + str(_next_position))
	print("next: " + str(candidate_next_position))
	_next_position = candidate_next_position
	push_warning("Tried 20 times to find next_position within minimum distance but was not able. Kept the last try")


func _on_entered_visible_on_screen() -> void:
	if _first_time_on_screen:
		boss_hud.show_hud("Arauto da Reprovação", max_health)
		_first_time_on_screen = false
	_state = State.RUN
	boss_hud.visible = true
	


func _on_exited_visible_on_screen() -> void:
	#_state = State.OUT_OF_SIGHT
	#boss_hud.visible = false
	pass


func _on_sprites_animation_finished() -> void:
	if sprites.animation.begins_with("attack"):
		_state = State.IDLE
	if sprites.animation == "death":
		shadow.visible = false
		_on_exited_visible_on_screen()
		print("VICTORY")
		queue_free()
		
