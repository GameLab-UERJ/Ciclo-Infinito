class_name Player
extends CharacterBody2D

@export var max_health: float = 120:
	set(value):
		max_health = value
		if health_component:
			health_component.max_health = max_health

@export var attack1_damage: float = 5.0 ## Dano base do 1º golpe (escalará com Força)
@export var attack2_damage: float = 5.0 ## Dano base do 2º golpe (escalará com Força)
@export var move_speed: float = 240.00

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
@export var dash_cooldown_time: float = 1.0
@export var dash_speed_multiplier: float = 3.0
@export var dash_duracao := 0.2

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

var is_dead: bool = false
var last_facing: String = "down"
var attack_facing: String = "down"
var is_dashing: bool = false
var is_dash_on_cooldown: bool = false
var dash_dir: Vector2 = Vector2.ZERO
var next_direction: Vector2 = Vector2(0, 1)
var can_attack: bool = true
var combo_step: int = 0
var combo_window_open: bool = false
var combo_buffered: bool = false

var vida_textures = [
	preload("uid://d04wn5x7fupjs"), # vida -1
	preload("uid://dus84fjy3186o"), # vida -2
	preload("uid://cgoamuuy1qxwt"), # vida -3
	preload("uid://c82joy0gpepr5"), # vida -4
	preload("uid://cmvmmbbynqc85"), # vida -5
	preload("uid://d1i0ebuglppq1"), # vida -6
	preload("uid://c71y8r3arh7qc")  # vida cheia
]

@onready var state_label: Label = get_node_or_null("StateLabel")
@onready var vida_cheia = get_node_or_null("Camera2D/VidaCheia")
@onready var anim: AnimatedSprite2D = $animacoes  
@onready var dash_timer: Timer = $dash_timer
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var area_attack: Area2D = $attack_area
@onready var player_colision: CollisionShape2D = $player_colision
@onready var dash_sfx: AudioStreamPlayer2D = $SoundEffects/dash_sfx
@onready var death_sfx: AudioStreamPlayer2D = $SoundEffects/DeathSFX
@onready var attack_sfxplay: AudioStreamPlayer2D = $SoundEffects/attack_sfxplay
@onready var footsteps_sfx: AudioStreamPlayer2D = $SoundEffects/FootstepsSfx
@onready var camera: Camera2D = $Camera2D
@onready var shadow: Sprite2D = $Shadow
@onready var health_component: Node = %HealthComponent

# Nodes da Maquina de Estados
@onready var base_machine_manager: BasePlayerStateMachineManager = get_node_or_null("BaseMachineManager")
@onready var enabled_machine_manager: EnabledPlayerStateMachineManager = get_node_or_null("BaseMachineManager/EnabledStateMachineManager")

@onready var progression: ProgressionComponent = get_node_or_null("ProgressionComponent")


func _ready() -> void:
	_setup_progression_component()
	dash_timer.wait_time = dash_duracao
	
	if not dash_timer.timeout.is_connected(_on_dash_timer_timeout):
		dash_timer.timeout.connect(_on_dash_timer_timeout)
	if not dash_cooldown.timeout.is_connected(_on_dash_cooldown_timeout):
		dash_cooldown.timeout.connect(_on_dash_cooldown_timeout)
		
	if not area_attack.body_entered.is_connected(_on_area_attack_body_entered):
		area_attack.body_entered.connect(_on_area_attack_body_entered)


func _setup_progression_component() -> void:
	if progression == null:
		progression = ProgressionComponent.new()
		progression.name = "ProgressionComponent"
		add_child(progression)
	
	progression.attributes_updated.connect(_on_attributes_updated)
	_on_attributes_updated(progression.get_final_attributes())


func _on_attributes_updated(final_attrs: CharacterAttributes) -> void:
	if final_attrs and health_component:
		max_health = final_attrs.vitality * 5


func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	
	if state_label and state_label.visible:
		var base_st = get_current_base_state()
		state_label.text = get_current_gameplay_state() if base_st == "Enabled" else base_st
		
	move_and_slide()
	_update_attack_area_anchor()
	update_animation()


func get_current_base_state() -> String:
	return base_machine_manager.get_current() if base_machine_manager else ""


func get_current_gameplay_state() -> String:
	return enabled_machine_manager.get_current() if enabled_machine_manager else ""


func is_in_state(state_name: String) -> bool:
	return get_current_gameplay_state() == state_name or get_current_base_state() == state_name


func enter_dialogue() -> void:
	if base_machine_manager:
		base_machine_manager.trigger_dialogue_started()


func exit_dialogue() -> void:
	if base_machine_manager:
		base_machine_manager.trigger_dialogue_ended()


func enter_cutscene() -> void:
	if base_machine_manager:
		base_machine_manager.trigger_cutscene_started()


func exit_cutscene() -> void:
	if base_machine_manager:
		base_machine_manager.trigger_cutscene_ended()


func die() -> void:
	if base_machine_manager:
		base_machine_manager.trigger_die()
	else:
		handle_death()

func get_input_direction() -> Vector2:
	return Input.get_vector("run_left", "run_right", "run_up", "run_down")


func can_start_attack() -> bool:
	return not is_dashing and can_attack and not is_dead and (base_machine_manager == null or base_machine_manager.get_current() in ["Enabled", "Entry"])


func can_dash() -> bool:
	return not is_dash_on_cooldown and not is_dashing and not is_dead and (base_machine_manager == null or base_machine_manager.get_current() in ["Enabled", "Entry"])


# COMBATE E DANO (Agora utilizando os atributos Força, Magia e Resistencia)
func _on_area_attack_body_entered(body: Node2D) -> void:
	if not body.has_node("HealthComponent"):
		return
	
	var final_strength: float = 10.0
	if progression:
		final_strength = progression.get_final_attributes().strength
		for boon in progression.boons:
			if boon.affected_skill.has(Boon.AffectedSkill.ATTACK):
				boon.apply_statuses_to(body,self,10,1)
		
	var damage_amount: float = 0.0
	if combo_step == 1:
		damage_amount = attack1_damage + (final_strength * 1.0)
	elif combo_step == 2:
		damage_amount = attack2_damage + (final_strength * 1.3)
	elif combo_step == 3:
		damage_amount = attack1_damage + (final_strength * 1.5)
	
	if damage_amount > 0.0:
		var knockback_direction: Vector2 = (body.global_position - global_position).normalized()
		body.get_node("HealthComponent").take_damage(damage_amount, knockback_direction)


func cast_magic_skill(skill_name: String, _target_direction: Vector2 = Vector2.ZERO) -> float:
	if progression == null:
		return 0.0
	var magic_dmg = progression.get_magic_damage(15.0, 1.0)
	if progression.has_skill(skill_name):
		var skill_info = progression.get_skill(skill_name)
		var school = skill_info.get("school", "Tesla")
		match school:
			"Tesla":
				pass
			"Newtoniana":
				pass
			"Curie":
				pass
	return magic_dmg


func apply_damage_with_resistance(incoming_damage: float, knockback: Vector2 = Vector2.ZERO) -> void:
	var final_res: float = 0.0
	if progression:
		final_res = progression.get_final_attributes().resistance
		
	var final_damage: float = max(1.0, incoming_damage - final_res)
	if health_component and health_component.has_method("take_damage"):
		health_component.take_damage(final_damage, knockback)


# ACOES DA MAQUINA DE ESTADOS (EnabledStateMachineManager)
func start_attack_sequence() -> void:
	attack_facing = get_direction_string(next_direction)
	can_attack = false
	combo_step = 1
	combo_buffered = false

	_apply_attack_hitbox_for_facing(attack_facing)
	_enable_attack_hitbox_for(hit1_active_time)

	var a := "attack1_" + attack_facing
	if anim.animation != a:
		anim.stop()
		anim.frame = 0
		anim.play(a)
		attack_sfxplay.play()

	_open_combo_window()
	_end_attack1_after_lock()


func _open_combo_window() -> void:
	combo_window_open = true
	await get_tree().create_timer(combo_window).timeout
	combo_window_open = false
	if combo_step == 1 and combo_buffered:
		_start_attack2()


func _end_attack1_after_lock() -> void:
	await get_tree().create_timer(attack1_lock_time).timeout
	if combo_step == 1:
		_finish_attack_sequence()


func _start_attack2() -> void:
	combo_step = 2
	_apply_attack_hitbox_for_facing(attack_facing)
	_enable_attack_hitbox_for(hit2_active_time)

	var a := "attack2_" + attack_facing
	if anim.animation != a:
		attack_sfxplay.play()
		anim.stop()
		anim.frame = 0
		anim.play(a)

	await get_tree().create_timer(attack2_lock_time).timeout
	_finish_attack_sequence()


func _finish_attack_sequence() -> void:
	combo_step = 0
	if enabled_machine_manager:
		enabled_machine_manager.notify_attack_finished()
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func update_attack_physics(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	if input_direction != Vector2.ZERO:
		next_direction = input_direction
		velocity = input_direction.normalized() * (move_speed * 0.3)
	else:
		velocity = Vector2.ZERO

func start_dash_sequence() -> void:
	is_dashing = true
	anim.play("dash_" + get_direction_string(next_direction))
	dash_sfx.play(0.4)
	dash_timer.start()
	is_dash_on_cooldown = true
	
	var dash_direction: Vector2 = next_direction
	var in_dir: Vector2 = get_input_direction()
	if in_dir != Vector2.ZERO:
		dash_direction = in_dir
		next_direction = in_dir
	dash_dir = dash_direction.normalized()
	
	if health_component and health_component.has_method("start_invincibility"):
		await health_component.start_invincibility(dash_timer.wait_time, true)


func update_dash_physics(_delta: float) -> void:
	velocity = dash_dir * move_speed * dash_speed_multiplier


func start_dash_attack_sequence() -> void:
	# Preparado para a animacao dash_attack)
	var anim_spin := "dash_attack"
	if anim.sprite_frames and anim.sprite_frames.has_animation(anim_spin):
		anim.play(anim_spin)
		await anim.animation_finished
	else:
		# Nao executa nada ainda
		await get_tree().process_frame

	if enabled_machine_manager:
		enabled_machine_manager.notify_dash_attack_finished()


func update_dash_attack_physics(_delta: float) -> void:
	# Preparado para controlar a fisica durante o giro do Dash Attack
	pass


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	is_dash_on_cooldown = true
	dash_cooldown.start(dash_cooldown_time)
	if enabled_machine_manager:
		enabled_machine_manager.notify_dash_finished()


func _on_dash_cooldown_timeout() -> void:
	is_dash_on_cooldown = false


# ==============================================================================
# HITBOXES DE ATAQUE
# ==============================================================================
func _enable_attack_hitbox_for(dur: float) -> void:
	var col: CollisionShape2D = area_attack.get_node("attack_colison")
	col.disabled = false
	await get_tree().create_timer(dur).timeout
	col.disabled = true


func _apply_attack_hitbox_for_facing(facing: String) -> void:
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
	if combo_step > 0:
		_apply_attack_hitbox_for_facing(attack_facing)
		return
	var input_dir: Vector2 = get_input_direction()
	var facing: String = get_direction_string(input_dir) if input_dir != Vector2.ZERO else last_facing
	_apply_attack_hitbox_for_facing(facing)


# ==============================================================================
# DIALOGOS, CUTSCENES E MORTE
# ==============================================================================
func _on_dialogo_iniciado() -> void:
	enter_dialogue()


func _on_dialogo_encerrado() -> void:
	exit_dialogue()


func pan_camera_to(node: Node2D) -> void:
	enter_cutscene()
	await create_tween().tween_property(camera, "global_position", node.global_position, 1).finished


func pan_camera_back() -> void:
	await pan_camera_to(self)
	exit_cutscene()


func set_camera_limits(left: Node2D, right: Node2D, bottom: Node2D, top: Node2D) -> void:
	camera.limit_bottom = ceil(bottom.global_position.y)
	camera.limit_top = ceil(top.global_position.y)
	camera.limit_left = ceil(left.global_position.x)
	camera.limit_right = ceil(right.global_position.x)


func handle_death() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	player_colision.set_deferred("disabled", true)
	if death_sfx:
		death_sfx.play()
	var dir_str = get_direction_string(next_direction)
	anim.play("death_" + dir_str)


func update_animation() -> void:
	var base_st := get_current_base_state()
	var gp_st := get_current_gameplay_state()
	var direction_str: String = get_direction_string(next_direction)
	var anim_name := ""
	
	match base_st:
		"Dialogue":
			anim_name = "idle_" + direction_str
		"Cutscene":
			anim_name = "run_" + direction_str
		"Dead":
			anim_name = "death_" + direction_str
		_:
			match gp_st:
				"Idle", "Entry", "":
					anim_name = "idle_" + direction_str
				"Walking":
					anim_name = "run_" + direction_str
				"Attack":
					anim_name = ("attack2_" if combo_step == 2 else "attack1_") + attack_facing
				"Dash", "DashAttack":
					return
					
	if anim.animation != anim_name:
		if gp_st == "Attack":
			anim.stop()
			anim.frame = 0
		anim.play(anim_name)


func get_direction_string(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	else:
		return "down" if v.y > 0.0 else "up"


func _on_animacoes_frame_changed() -> void:
	if not anim:
		return
	if anim.animation.begins_with("run"):
		match anim.frame:
			3, 7:
				footsteps_sfx.play()


func _on_animacoes_animation_finished() -> void:
	if anim.animation.begins_with("dash"):
		if enabled_machine_manager:
			enabled_machine_manager.notify_dash_finished()
