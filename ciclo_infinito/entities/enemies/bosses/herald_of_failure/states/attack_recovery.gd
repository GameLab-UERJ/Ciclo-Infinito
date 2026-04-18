extends State

@export var recovery_time: float = 2.0

@export_category("Transitions")
@export var patrol_state: State

var _attack_timer: Timer


func _on_enter() -> void:
	_attack_timer = Timer.new()
	_attack_timer.wait_time = recovery_time
	_attack_timer.one_shot = true
	_attack_timer.autostart = true
	add_child(_attack_timer)
	
func _on_exit() -> void:
	_attack_timer.stop()
	_attack_timer.queue_free()
	
func _update(_delta: float) -> void:
	pass
	
func _setup_transitions() -> void:
	_transitions.append(Transition.new(patrol_state, func (): return _attack_timer.time_left <= 0))
