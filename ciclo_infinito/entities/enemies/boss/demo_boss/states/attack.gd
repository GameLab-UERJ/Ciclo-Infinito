extends State

@export_category("Transitions")
@export var tornado_attack_state: State
@export var fireball_attack_state: State

var _decision: float 

func _on_enter() -> void:
	_decision = randf()
	
func _on_exit() -> void:
	pass
	
func _update(delta: float) -> void:
	pass
	
func _setup_transitions() -> void:
	_transitions.append(Transition.new(tornado_attack_state, func (): return _decision < 0.5))
	_transitions.append(Transition.new(fireball_attack_state, func (): return _decision >= 0.5))