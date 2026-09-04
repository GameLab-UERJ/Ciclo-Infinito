extends CharacterComponent
class_name MovementComponent


const NO_TARGET_POINT : Vector2 = Vector2.INF


signal changed_direction(from : Vector2, to : Vector2)
signal moved(direction : Vector2)
signal hit_max_speed
signal stopped
signal started_to_stop


@export var max_speed: int
@export var acceleration: float
@export var hit_target_distance: float = 10


var current_direction : Vector2: set = _set_current_direction
var target_point : Vector2 = NO_TARGET_POINT : set = _set_target_point


@onready var player: CharacterBody2D = get_tree().current_scene.get_node_or_null("Player")


func _ready():
	super._ready()


func _physics_process(_delta: float) -> void:
	update_velocity()
	if has_hit_target_distance():
		stop()
	parent.move_and_slide()


func has_hit_target_distance() -> bool:
	#print("distance: ",parent.global_position.distance_to(target_point))
	return (target_point != NO_TARGET_POINT and 
			parent.global_position.distance_to(target_point) <= hit_target_distance)


func update_velocity() -> void:
	parent.velocity = lerp(parent.velocity, current_direction * max_speed, acceleration)
	if parent.velocity.distance_to(Vector2.ZERO) <= 1:
		parent.velocity = Vector2.ZERO
		stopped.emit()
	elif parent.velocity == current_direction * max_speed:
		hit_max_speed.emit()


func move(direction: Vector2) -> void:
	current_direction = direction


func stop() -> void:
	target_point = NO_TARGET_POINT


func move_to(point: Vector2) -> void:
	target_point = point


func _set_current_direction(direction : Vector2):
	direction = direction.normalized()
	if current_direction == Vector2.ZERO and direction != current_direction:
		moved.emit(direction)
	elif current_direction != Vector2.ZERO and direction == Vector2.ZERO:
		started_to_stop.emit()
	if current_direction != direction:
		changed_direction.emit(current_direction, direction)
	current_direction = direction


func _set_target_point(point : Vector2) -> void:
	target_point = point
	if target_point == NO_TARGET_POINT:
		current_direction = Vector2.ZERO
	else:
		current_direction = parent.global_position.direction_to(target_point)
