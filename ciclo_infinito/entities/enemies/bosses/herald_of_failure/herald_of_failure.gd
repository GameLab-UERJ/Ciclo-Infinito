extends CharacterBody2D
class_name Boss


const DAMAGE_TAKEN_EFFECT_DURATION: float = 0.15
const FIRE_METEOR = preload("uid://dyjwfrwsly7lx")


signal died


@export var speed = 100.0
@export var player : Player
@export var max_health: float = 1600.0
@export var attack_damage: float = 20
@export_range(0,1,0.01) var chance_of_attacking_after_moving: float = 0.1
@export_category("Moving Limits")
@export var top_left_corner : Marker2D
@export var bottom_right_corner : Marker2D


var current_health : float
var initial_position : Vector2
var next_position : Vector2 
var current_direction : Vector2 
var first_time_on_screen : bool = true
var is_dead : bool = false
var _moving_limits : Rect2


@onready var sprites: AnimatedSprite2D = $Sprites
@onready var boss_hud: BossHUD = $BossHUD
@onready var shadow: Sprite2D = $Shadow
@onready var state_machine_manager: Node = $StateMachineManager
@onready var meteor_timer: Timer = $MeteorTimer
@onready var noises_sfx: AudioStreamPlayer2D = $NoisesSfx
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSfx
@onready var death_sfx: AudioStreamPlayer2D = $DeathSfx
@onready var attack_1_sfx: AudioStreamPlayer2D = $Attack1Sfx
@onready var attack_2_sfx: AudioStreamPlayer2D = $Attack2Sfx
@onready var camera_focus: Marker2D = $CameraFocus
@onready var attack_sfx : Dictionary = {"attack_1":attack_1_sfx,"attack_2":attack_2_sfx}


func _ready() -> void:
	initial_position = global_position
	current_health = max_health
	if not top_left_corner:
		_moving_limits = Rect2(global_position-Vector2.ONE,Vector2.ONE)
	else:
		_moving_limits = Rect2(top_left_corner.global_position,Vector2.ONE)
	if bottom_right_corner:
		_moving_limits.end = bottom_right_corner.global_position
	current_health = max_health


func _physics_process(_delta: float) -> void:
	velocity = current_direction * speed
	move_and_slide()


func take_damage(damage_amount: float, _hit_direction: Vector2 = Vector2.ZERO) -> void:
	current_health -= damage_amount
	current_health = clamp(current_health, 0.0, max_health)
	boss_hud.update_health(current_health)
	
	applies_damage_received_effect()
	
	if current_health <= 0.0:
		is_dead = true


func applies_damage_received_effect() -> void:	
	hurt_sfx.play(0.01)
	sprites.material.set_shader_parameter("redden", true)
	await get_tree().create_timer(DAMAGE_TAKEN_EFFECT_DURATION).timeout
	sprites.material.set_shader_parameter("redden", false)


func die() -> void:
	sprites.play("death")
	death_sfx.play()
	create_tween().tween_property(shadow,"self_modulate",Color.TRANSPARENT,sprites.sprite_frames.get_frame_count("death")/sprites.sprite_frames.get_animation_speed("death"))


func get_valid_next_position(minimum_distance : float = 50) -> void:
	var candidate_next_position : Vector2
	for i in 20:
		candidate_next_position = Vector2(	randf_range(_moving_limits.position.x,_moving_limits.end.x),
											randf_range(_moving_limits.position.y,_moving_limits.end.y))
											
		if not _moving_limits.has_point(candidate_next_position):
			continue
		if global_position.distance_to(candidate_next_position) <= minimum_distance:
			continue
		next_position = candidate_next_position
		return
	
	next_position = candidate_next_position
	push_warning("Tried 20 times to find next_position within minimum distance but was not able. Kept the last try")


func _on_entered_visible_on_screen() -> void:
	if first_time_on_screen:
		boss_hud.show_hud("Arauto da Reprovação", max_health)
		first_time_on_screen = false
	boss_hud.visible = true


func _on_exited_visible_on_screen() -> void:
	pass


func _on_sprites_animation_finished() -> void:
	if sprites.animation.begins_with("attack"):
		pass
	if sprites.animation == "death":
		shadow.visible = false
		_on_exited_visible_on_screen()
		died.emit()
		queue_free()

func spawn_meteor_at_player(amount : float = 1, time_to_drop : float = 0.3, offset : Vector2 = Vector2.ZERO) -> void:
	var meteor : FireMeteor
	
	for i in amount:
		meteor = FIRE_METEOR.instantiate()
		get_tree().current_scene.call_deferred("add_child",meteor)
		meteor.deal_damage_to_player.connect(damage_player)
		meteor.set_deferred("global_position",player.global_position + offset)
		meteor.call_deferred("drop")
		meteor_timer.start(time_to_drop)
		await meteor_timer.timeout


func damage_player() -> void:
	player.take_damage(attack_damage,Vector2.ZERO)


func make_noise() -> void:
	noises_sfx.play()


func _on_sprites_frame_changed() -> void:
	if not sprites:
		return 
	
	match sprites.animation:
		"attack_1":
			match sprites.frame:
				7: 
					attack_1_sfx.play()
		"attack_2":
			match sprites.frame:
				4: 
					attack_2_sfx.play()
