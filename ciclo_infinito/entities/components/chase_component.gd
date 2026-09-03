extends Node
class_name ChaseComponent


signal next_chase_point_set(next_point : Vector2)
signal there_is_no_player
signal target_reached


@export var enabled : bool = true
@export var chased_node: Node2D


var can_check_target_reached : bool = false


@onready var parent: CharacterBody2D = get_parent()
@onready var path_timer: Timer = get_node_or_null("PathTimer")
@onready var navigation_agent: NavigationAgent2D = get_node_or_null("NavigationAgent2D")


func _ready() -> void:
	if not parent is CharacterBody2D:
		push_error("Error: This node must be child of a CharacterBody2D.")
		
		set_process(false)
		set_physics_process(false)
		queue_free() 
	
	if not chased_node:
		chased_node = get_tree().current_scene.find_child("Player")
	
	if not path_timer:
		path_timer = Timer.new()
		path_timer.wait_time = 0.5
		path_timer.autostart = true
		path_timer.timeout.connect(_on_path_timer_timeout)
		add_child(path_timer)
	
	if not navigation_agent:
		navigation_agent = NavigationAgent2D.new()
		navigation_agent.path_desired_distance = 3
		navigation_agent.target_desired_distance = 3
		navigation_agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
		parent.call_deferred("add_child",navigation_agent)


func _process(_delta: float) -> void:
	if not enabled:
		return
	chase()


func _on_path_timer_timeout() -> void:
	if not path_timer:
		return 
	
	if not enabled:
		return
	
	if is_instance_valid(chased_node):
		navigation_agent.target_position = chased_node.position
		can_check_target_reached = true
	else:
		path_timer.stop()
		there_is_no_player.emit()
		navigation_agent.target_position = parent.global_position


func enable() -> void:
	enabled = true


func disable() -> void:
	enabled = false


func chase() -> void:
	if (not navigation_agent or 
		not navigation_agent.get_parent()
	):
		return 
	
	if can_check_target_reached and navigation_agent.is_target_reached():
		can_check_target_reached = false
		target_reached.emit()
		return
	
	next_chase_point_set.emit(navigation_agent.get_next_path_position())
	
