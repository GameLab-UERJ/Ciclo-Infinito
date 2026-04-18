extends State

@export var tornado_scene: PackedScene
@export var attack_windup_time: float = 1.0
@export var tornado_spawn_point: Node2D
@export var spawn_distance: float = 100.0

@export_category("Transitions")
@export var attack_recovery: State

var _attack_done: bool

var _tornado_timer: Timer

func _on_enter() -> void:
	_attack_done = false
	_tornado_timer = Timer.new()
	_tornado_timer.wait_time = attack_windup_time
	_tornado_timer.one_shot = true
	_tornado_timer.autostart = true
	add_child(_tornado_timer)
	_tornado_timer.timeout.connect(_spawn_tornado)
	
func _on_exit() -> void:
	pass
	
func _update(_delta: float) -> void:
	pass
	
func _setup_transitions() -> void:
	_transitions.append(Transition.new(attack_recovery, func (): return _attack_done))

	
func _spawn_tornado() -> void:
	var tornado_instance = tornado_scene.instantiate()
	var player_position := GameManager.player.global_position
	var direction_to_player := (player_position - tornado_spawn_point.global_position).normalized()
	var spawn_position := tornado_spawn_point.global_position + direction_to_player * spawn_distance
	tornado_instance.global_position = spawn_position
	add_child(tornado_instance)
