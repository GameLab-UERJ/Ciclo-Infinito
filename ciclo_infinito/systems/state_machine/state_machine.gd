class_name StateMachine
extends Node

@export var initial_state: State

var _current_state: State

func _ready() -> void:
	if initial_state == null:
		push_error("StateMachine '%s' precisa de um estado inicial definido." % name)
		return
	_current_state = initial_state
	_current_state.enter()
	
func _process(delta: float) -> void:
	var next_state: State = _current_state.process(delta)
	if next_state:
		_current_state.exit()
		_current_state = next_state
		_current_state.enter()
		
