extends State

@export var patrol_around: Node2D
@export var patrol_radius: float = 100.0
@export var patrol_range: float = 10.0 # range to consider the patrol point reached


@onready var _patrol_point: Vector2 = patrol_around.global_position

@export_category("Helper Components")
@export var movement_component: MovementComponent
@export var detection_area: Area2D

@export_category("Transitions")
@export var attack_state: State

func _on_enter() -> void:
	pass
	
func _on_exit() -> void:
	pass
	
func _update(delta: float) -> void:
	_define_patrol_point()
	var direction = (_patrol_point - movement_component.global_position).normalized()
	movement_component.velocity = direction * movement_component.speed
	
	
func _define_patrol_point() -> void:
	while movement_component.global_position.distance_to(_patrol_point) <= patrol_range:
		var rho = randf_range(0, patrol_radius)
		var theta = randf_range(0, 2 * PI)
		_patrol_point = Vector2.RIGHT.rotated(theta) * rho + patrol_around.global_position
	

# maybe here it will have performance issues
# to refact: use signals
func _can_transition_to_attack() -> bool:
	var bodies := detection_area.get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			return true
	return false
	

func _setup_transitions() -> void:
	_transitions.append(Transition.new(attack_state, _can_transition_to_attack))