class_name FireMeteor
extends Node2D


signal deal_damage_to_player


@export var initial_y_position : float = -100
@export var total_drop_time : float = 1.0
@export var total_damage_time_after_drop : float = 1.0


var _final_y_position : float = -10
var _final_impact_scale : Vector2
var _player_damageable : bool = false


@onready var fire_ball_sprite: AnimatedSprite2D = $FireBallSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var impact_sprite: Sprite2D = $ImpactSprite
@onready var end_lifetime_timer: Timer = $EndLifetimeTimer


func _ready() -> void:
	_final_impact_scale = impact_sprite.scale
	end_lifetime_timer.wait_time = total_damage_time_after_drop
	reset()

#Only for testing. To be removed
func _process(_delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		drop()

func reset() -> void:
	impact_sprite.scale = Vector2.ZERO
	shadow_sprite.scale = Vector2.ZERO
	fire_ball_sprite.play("drop")
	fire_ball_sprite.position.y = initial_y_position
	end_lifetime_timer.stop()

func drop() -> void:
	reset()
	var drop_tween : Tween = create_tween()
	drop_tween.tween_property(fire_ball_sprite,"position",Vector2(fire_ball_sprite.position.x,_final_y_position),total_drop_time)
	drop_tween.parallel().tween_property(shadow_sprite,"scale",Vector2.ONE,total_drop_time)
	drop_tween.finished.connect(_on_drop_finished)


func _on_drop_finished() -> void:
	fire_ball_sprite.play("disappear")
	var temp_impact_self_modulate : Color = impact_sprite.self_modulate
	temp_impact_self_modulate.a = 1
	
	create_tween().tween_property(
		impact_sprite,
		"scale",
		_final_impact_scale,
		0.2
	)
	if _player_damageable:
		deal_damage_to_player.emit()
	end_lifetime_timer.start()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_damageable = true


func _on_damage_area_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_damageable = false


func _on_end_lifetime_timer_timeout() -> void:
	reset()
