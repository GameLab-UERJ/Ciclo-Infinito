class_name BaseEnemy
extends CharacterBody2D


signal defeated ##Contador para a tela de vitória


@export_category("Animation")
@export var sprite: Sprite2D = null
@export var anim: AnimationPlayer = null

@export_category("Combat")
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 1.5


var can_attack: bool = true	
var current_health: float
var player_ref: Player = null
var player_in_attack_range : bool = false
var attack_area: Area2D
var detect_area: Area2D
var alive: bool = true

@onready var colision_shape: CollisionShape2D = $Colisiondano
@onready var attack_sfx: AudioStreamPlayer2D = $attack_sfx
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var health_component: HealthComponent = %HealthComponent
@onready var chase_component: ChaseComponent = %ChaseComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var state_machine_manager: StateMachineManager = $StateMachineManager


func _ready() -> void:
	attack_cooldown_timer.wait_time = attack_cooldown
	attack_cooldown_timer.one_shot = true
	_resolve_area2d("AttackArea")
	_resolve_area2d("detectionarea/Detectionarea")


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
	
	state_machine_manager.die()
	colision_shape.set_deferred("disabled",true)
	
	death_sfx.play()
	await get_tree().create_timer(1.0).timeout
	death_sfx.stop()
	
	sprite.material = null
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 5.0)
	tween.tween_callback(queue_free)


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
		if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
			attack_area.body_entered.connect(_on_attack_area_body_entered)
		if not attack_area.body_exited.is_connected(_on_attack_area_body_exited):
			attack_area.body_exited.connect(_on_attack_area_body_exited)
	else:
		detect_area = result
		if not detect_area.body_entered.is_connected(_on_detectionarea_body_entered):
			detect_area.body_entered.connect(_on_detectionarea_body_entered)
		if not detect_area.body_exited.is_connected(_on_detectionarea_body_exited):
			detect_area.body_exited.connect(_on_detectionarea_body_exited)


func _on_detectionarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		player_ref = body


func _on_detectionarea_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null


func _on_attack_area_body_entered(_body: Node2D) -> void:
	player_in_attack_range = true


func _on_attack_area_body_exited(_body: Node2D) -> void:
	player_in_attack_range = false


func _set_next_move_point(next_point: Vector2) -> void:
	movement_component.move_to(next_point)
