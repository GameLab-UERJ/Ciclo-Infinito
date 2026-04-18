extends State

@export_category("Transitions")
@export var attack_recovery: State

var _attack_done: bool


func _on_enter() -> void:
	_attack_done = false

func _on_exit() -> void:
	pass

func _update(_delta: float) -> void:
	pass

func _setup_transitions() -> void:
	_transitions.append(Transition.new(attack_recovery, func (): return _attack_done))
