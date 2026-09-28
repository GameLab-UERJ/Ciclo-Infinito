extends Status


@export var ticks_per_second : float = 0.5:
	set(value):
		ticks_per_second = value
		if apply_timer:
			apply_timer.wait_time = 1/ticks_per_second


var affected_health_components : Array


@onready var apply_timer: Timer = $ApplyTimer


func _ready() -> void:
	super._ready()
	ticks_per_second = ticks_per_second
	affected_health_components = [get_parent().health_component] if get_parent() and get_parent().has_node("HealthComponent") else []


func reduce_resistance() -> float:
	if get_parent().has_node("ProgressionComponent"):
		return ceil(get_parent().get_node("ProgressionComponent").final_attributes.resistance * (1-level * 0.1))
	
	return 1  


func _on_apply_timer_timeout() -> void:
	print(affected_health_components)
	for health_component : HealthComponent in affected_health_components:
		if  health_component.get_parent() is Player and affecting == 'Player' or \
		not health_component.get_parent() is Player and affecting == 'Enemy':
			health_component.take_damage_by_percentage(level * 0.1,false)
