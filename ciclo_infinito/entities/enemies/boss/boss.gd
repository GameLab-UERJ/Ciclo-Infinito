class_name Boss
extends Enemy

@export var state_machine: StateMachine
@export var movement_component: MovementComponent

func _physics_process(delta: float) -> void:
	velocity = movement_component.velocity
	move_and_slide()
