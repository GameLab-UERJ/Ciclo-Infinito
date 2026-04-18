@abstract
class_name State 
extends Node


var _transitions: Array[Transition] = []

@abstract
func _on_enter() -> void
	
@abstract
func _on_exit() -> void
	
@abstract
func _update(delta: float) -> void

func _ready() -> void:
	_setup_transitions()
		
func enter() -> void:
	_on_enter()
	
func exit() -> void:
	_on_exit()
	
func process(delta: float) -> State:
	for transition in _transitions:
		var can_transition = transition.can_transition.call()
		assert(typeof(can_transition) == TYPE_BOOL, "A função can_transition deve retornar um valor booleano.")
		if can_transition:
			return transition.target_state
	_update(delta)
	return


@abstract func _setup_transitions() -> void

class Transition:
	var target_state: State
	var can_transition: Callable

	func _init(_target_state: State, _can_transition: Callable) -> void:
		self.target_state = _target_state
		self.can_transition = _can_transition
