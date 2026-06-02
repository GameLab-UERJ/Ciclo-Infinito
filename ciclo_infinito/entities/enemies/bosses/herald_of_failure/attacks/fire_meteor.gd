class_name FireMeteor
extends Node2D


signal deal_damage_to_player
signal finished


@export var initial_y_position : float = -100
@export var total_drop_time : float = 1.0
@export var total_damage_time_after_drop : float = 1.0


var _final_y_position : float = -10
var _final_impact_scale : Vector2
var _player_damageable : bool = false
var _has_damaged_player : bool = false


@onready var fire_ball_sprite: AnimatedSprite2D = $FireBallSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var end_lifetime_timer: Timer = $EndLifetimeTimer
@onready var explosion: AnimatedSprite2D = $Explosion
@onready var impact_sfx: AudioStreamPlayer2D = $ImpactSfx


func _ready() -> void:
	end_lifetime_timer.wait_time = total_damage_time_after_drop
	reset()

#Only for testing. To be removed
func _physics_process(delta: float) -> void:
	if _has_damaged_player:
		return

	if _player_damageable and explosion.is_playing():
		deal_damage_to_player.emit()
		_has_damaged_player = true

func reset() -> void:
	visible = false
	shadow_sprite.scale = Vector2.ZERO
	fire_ball_sprite.play("drop")
	fire_ball_sprite.position.y = initial_y_position
	end_lifetime_timer.stop()
	_player_damageable = false

func drop(wait_time: float = 0) -> void:
	if wait_time:
		await get_tree().create_timer(wait_time).timeout
	reset()
	visible = true
	var drop_tween : Tween = create_tween()
	drop_tween.tween_property(fire_ball_sprite,"position",Vector2(fire_ball_sprite.position.x,_final_y_position),total_drop_time)
	drop_tween.parallel().tween_property(shadow_sprite,"scale",Vector2.ONE,total_drop_time)
	drop_tween.finished.connect(_on_drop_finished)


func _on_drop_finished() -> void:
	fire_ball_sprite.play("disappear")
	explosion.play("explode")
	impact_sfx.play()
	end_lifetime_timer.start()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_damageable = true


func _on_damage_area_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_damageable = false


func _on_end_lifetime_timer_timeout() -> void:
	queue_free()
	finished.emit()


func _on_explosion_frame_changed() -> void:
	if explosion.frame > 6:
		_has_damaged_player = true
