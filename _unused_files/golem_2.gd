extends CharacterBody2D

@export_category("objects")
@export var sprite: Sprite2D = null
@export var anim: AnimationPlayer = null

@export_category("Movement")
@export var move_speed: float = 100.0
@export var accel: float = 0.18
@export var stop_distance: float = 40.0
@onready var attack_sfx: AudioStreamPlayer = $attack_sfx
@export_category("Combat")
@export var attack_damage: float = 15.0
@export var attack_cooldown: float = 1.5
var can_attack: bool = true

@export_category("Health")
@export var max_health: float = 50.0
var current_health: float

var player_ref: Node2D = null
var _last_facing: String = "down"
var _is_attacking: bool = false

@onready var attack_cooldown_timer: Timer = $AttackCooldown
var attack_area: Area2D
var detect_area: Area2D

func _ready() -> void:
	current_health = max_health
	attack_cooldown_timer.wait_time = attack_cooldown

	if sprite == null and has_node("texture"):
		sprite = $texture
	if anim == null and has_node("AnimationPlayer"):
		anim = $AnimationPlayer

	attack_area = _resolve_area2d("AttackArea")
	if attack_area == null:
		push_error("AttackArea não encontrada como Area2D.")

	detect_area = _resolve_area2d("detectionarea/Detectionarea")
	if detect_area == null:
		push_error("Detectionarea não encontrada como Area2D.")

	if not attack_cooldown_timer.timeout.is_connected(_on_attack_cooldown_timeout):
		attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)

	if anim and not anim.animation_finished.is_connected(_on_anim_animation_finished):
		anim.animation_finished.connect(_on_anim_animation_finished)

	if detect_area:
		if not detect_area.body_entered.is_connected(_on_detectionarea_body_entered):
			detect_area.body_entered.connect(_on_detectionarea_body_entered)
		if not detect_area.body_exited.is_connected(_on_detectionarea_body_exited):
			detect_area.body_exited.connect(_on_detectionarea_body_exited)

	_play_anim("idle_down")


func _physics_process(_delta: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		_stop()
		return

	var to_player := player_ref.global_position - global_position
	var dist := to_player.length()

	if to_player != Vector2.ZERO:
		_last_facing = _dir_string_from_vector(to_player)

	if dist > stop_distance and not _is_attacking:
		var desired := to_player.normalized() * move_speed
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

	# Toca a animação do ataque e garante que não vai loopar
	var atk_name := "attack_%s" % _last_facing
	if anim and anim.has_animation(atk_name):
		var a := anim.get_animation(atk_name)
		if a:
			a.loop_mode = Animation.LOOP_NONE
	_play_anim(atk_name)
	print("Golem ataca!")

# Aplica o dano apenas no final da animação de ataque
func apply_attack_damage() -> void:
	if attack_area == null:
		return
	var bodies_in_area := attack_area.get_overlapping_bodies()
	if bodies_in_area.is_empty():
		print("  -> AttackArea vazia no momento do golpe.")
		return
	for body in bodies_in_area:
		if body.has_method("take_damage"):
			var hit_direction := (body.global_position - global_position).normalized()
			body.take_damage(attack_damage, hit_direction)
			print("Dano aplicado em ", body.name)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_anim_animation_finished(name: StringName) -> void:
	var n := String(name)
	if n.begins_with("attack_"):
		# Primeiro aplica o dano (se o alvo ainda estiver na área), depois destrava
		apply_attack_damage()
		_is_attacking = false
		_play_anim("idle_%s" % _last_facing)


# ======== Vida / Morte ========

func take_damage(damage: float, hit_direction: Vector2) -> void:
	current_health -= damage
	print("Inimigo recebeu dano de ", damage, ". Vida restante: ", current_health)

	var knockback_force: float = 300.0
	velocity = hit_direction * knockback_force

	if current_health <= 0:
		die()

func die() -> void:
	print("Inimigo foi derrotado!")
	queue_free()
	


# ======== Movimento / Animação ========

func _stop() -> void:
	velocity = velocity.lerp(Vector2.ZERO, accel)
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

func _play_anim(name: String) -> void:
	if anim == null:
		return
	if anim.has_animation(name) and anim.current_animation != name:
		anim.play(name)


# ======== Detecção do Player ========

func _on_detectionarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		player_ref = body

func _on_detectionarea_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null


# ======== Util ========

func _dir_string_from_vector(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	else:
		return "down" if v.y > 0.0 else "up"

func _resolve_area2d(path: String) -> Area2D:
	if not has_node(path):
		return null
	var n := get_node(path)
	if n is Area2D:
		return n
	if n is CollisionShape2D and n.get_parent() is Area2D:
		return n.get_parent() as Area2D
	if n.get_parent() and n.get_parent() is Area2D:
		return n.get_parent() as Area2D
	return null
