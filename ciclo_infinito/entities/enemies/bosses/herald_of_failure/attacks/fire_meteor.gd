class_name FireMeteor
extends Node2D


signal finished_drop


@export var initial_y_position : float = -100
@export var total_drop_time : float = 1.0


var final_y_position : float = -14


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_ball_sprite: AnimatedSprite2D = $FireBallSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite


func _ready() -> void:
	reset()


func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		reset()
		drop()

func reset() -> void:
	shadow_sprite.scale = Vector2.ZERO
	fire_ball_sprite.position.y = initial_y_position

func drop() -> void:
	var drop_tween : Tween = create_tween()
	drop_tween.tween_property(fire_ball_sprite,"position",Vector2(fire_ball_sprite.position.x,final_y_position),total_drop_time)
	drop_tween.parallel().tween_property(shadow_sprite,"scale",Vector2.ONE,total_drop_time)
	drop_tween.finished.connect(finished_drop.emit)
