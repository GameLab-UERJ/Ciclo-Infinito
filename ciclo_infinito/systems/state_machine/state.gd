@abstract
class_name State 
extends Node

@export var tt: Callable

var _transitions: Array[StateTransition] = []

@abstract
func _on_enter() -> void
	
@abstract
func _on_exit() -> void
	
@abstract
func _update(delta: float) -> void

func _ready() -> void:
	var children: Array[Node] = get_children()
	if children.size() == 0:
		push_warning("State '%s' não tem transições válidas como filhos." % name)
		return
	for child in children:
		if child is StateTransition:
			_transitions.append(child)
		else:
			push_warning("Filho '%s' de State '%s' não é uma StateTransition." % [child.name, name])
	if _transitions.size() == 0:
		push_warning("State '%s' não tem transições válidas como filhos." % name)
		
func enter() -> void:
	_on_enter()
	
func exit() -> void:
	_on_exit()
	
func process(delta: float) -> State:
	for transition in _transitions:
		if transition.can_transition():
			return transition.target_state
	_update(delta)
	return
	
