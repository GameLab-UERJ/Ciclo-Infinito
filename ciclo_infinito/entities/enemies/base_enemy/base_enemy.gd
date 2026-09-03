class_name BaseEnemy
extends CharacterBody2D


signal defeated ##Contador para a tela de vitória


@export_category("Animation")
@export var sprite: Sprite2D = null
@export var anim: AnimationPlayer = null

@export_category("Movement")
@export var move_speed: float = 100.0
@export var accel: float = 0.18
@export var stop_distance: float = 40.0

@export_category("Combat")
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 1.5


var next_move_point: Vector2
var can_attack: bool = true	
var current_health: float
var player_ref: Node2D = null
var _last_facing: String = "down"
var _is_attacking: bool = false
var attack_area: Area2D
var detect_area: Area2D
var alive: bool = true


@onready var attack_sfx: AudioStreamPlayer2D = $attack_sfx
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var health_component: HealthComponent = %HealthComponent
@onready var chase_component: ChaseComponent = %ChaseComponent


func _ready() -> void:
	attack_cooldown_timer.wait_time = attack_cooldown
	if not attack_cooldown_timer.timeout.is_connected(_on_attack_cooldown_timeout):
		attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	
	if anim and not anim.animation_finished.is_connected(_on_anim_animation_finished):
		anim.animation_finished.connect(_on_anim_animation_finished)
	
	_resolve_area2d("AttackArea")
	_resolve_area2d("detectionarea/Detectionarea")
	
	_play_anim("idle_down")
	next_move_point = global_position


func _physics_process(_delta: float) -> void:
	if !alive:
		return
	
	if player_ref == null or not is_instance_valid(player_ref):
		_stop()
		return
	
	var dist := (player_ref.global_position - global_position).length()

	#if to_player != Vector2.ZERO:
	#	_last_facing = _dir_string_from_vector(to_player)

	if dist > stop_distance and not _is_attacking:
		#parent.velocity = parent.global_position.direction_to(navigation_agent.target_position)
		var desired = global_position.direction_to(next_move_point) * move_speed
		velocity = velocity.lerp(desired, accel)
		move_and_slide()
		_update_animation_from_velocity()
	else:
		_stop()
		if can_attack and not _is_attacking:
			attack()


# ======== Combate / Dano ========

func attack() -> void:
	_is_attacking = true
	can_attack = false
	attack_cooldown_timer.start()

	var atk_name := "attack_%s" % _last_facing
	if anim and anim.has_animation(atk_name):
		var a := anim.get_animation(atk_name)
		if a:
			a.loop_mode = Animation.LOOP_NONE
	_play_anim(atk_name)
	attack_sfx.play()


func apply_attack_damage() -> void:
	if attack_area == null:
		return
	var bodies_in_area := attack_area.get_overlapping_bodies()
	if bodies_in_area.is_empty():
		return
	for body in bodies_in_area:
		if body.has_node("HealthComponent"):
			var hit_direction := (body.global_position - global_position).normalized()
			body.health_component.take_damage(attack_damage, hit_direction)


func die() -> void:
	defeated.emit()
	alive = false
	chase_component.disable()
	
	_play_anim("death_%s" %_dir_string_from_vector(velocity))
	collision_layer = 0
	
	death_sfx.play()
	await get_tree().create_timer(1.0).timeout
	death_sfx.stop()
	
	sprite.material = null
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 5.0)
	tween.tween_callback(queue_free)


# ======== Movimento / Animação ========
func _stop() -> void:
	if velocity.length() < 5.0: #correçao do grude
		velocity = Vector2.ZERO
	else:
		velocity = velocity.lerp(Vector2.ZERO, accel)
	if velocity != Vector2.ZERO:
		move_and_slide()
	_update_animation_idle()


func _update_animation_from_velocity() -> void:
	if _is_attacking:
		return
	if velocity == Vector2.ZERO:
		_update_animation_idle()
		return
	var dir := _dir_string_from_vector(velocity)
	_last_facing = dir
	_play_anim("walk_%s" % dir)


func _update_animation_idle() -> void:
	if _is_attacking:
		return
	_play_anim("idle_%s" % _last_facing)


func _play_anim(animation_name: String) -> void:
	if anim == null:
		return
	if anim.has_animation(animation_name) and anim.current_animation != animation_name:
		anim.play(animation_name)


func _resolve_area2d(path: String) -> void:
	var result : Area2D = null
	
	if has_node(path):
		var n := get_node(path)
		if n is Area2D:
			result = n
		if n is CollisionShape2D and n.get_parent() is Area2D:
			result = n.get_parent() as Area2D
		if n.get_parent() and n.get_parent() is Area2D:
			result = n.get_parent() as Area2D
	
	if result == null:
		push_error(path,"não encontrada como Area2D.")
	elif "attack" in path.to_lower():
		attack_area = result
	else:
		detect_area = result
		if not detect_area.body_entered.is_connected(_on_detectionarea_body_entered):
			detect_area.body_entered.connect(_on_detectionarea_body_entered)
		if not detect_area.body_exited.is_connected(_on_detectionarea_body_exited):
			detect_area.body_exited.connect(_on_detectionarea_body_exited)


func _dir_string_from_vector(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	else:
		return "down" if v.y > 0.0 else "up"


func _on_detectionarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		player_ref = body


func _on_detectionarea_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null


func _on_attack_cooldown_timeout() -> void:
	can_attack = true


func _on_anim_animation_finished(animation_name: StringName) -> void:
	var n := String(animation_name)
	if n.begins_with("attack_"):
		_is_attacking = false
		_play_anim("idle_%s" % _last_facing)


func _set_next_move_point(next_point: Vector2) -> void:
	if not player_ref:
		chase_component.disable()
	chase_component.enable()
	next_move_point = next_point
