extends Status
class_name RadiationStatus


@export var damage_ticks_per_second : float = 1:
	set(value):
		damage_ticks_per_second = value
		if damage_timer:
			damage_timer.wait_time = 1/damage_ticks_per_second


var affected_health_components : Array = []


@onready var damage_timer: Timer = $DamageTimer


func _ready() -> void:
	super._ready()
	damage_ticks_per_second = damage_ticks_per_second


func calculate_damage() -> float:
	var damage_from_magic : int = 0
	if created_by and created_by.has_node("ProgressionComponent"):
		damage_from_magic = ceil(created_by.get_node("ProgressionComponent").final_attributes.magic * level * 0.2)
	
	return max(damage_from_magic,1*level)  


func _on_body_entered(body: Node2D) -> void:
	if not body.has_node("HealthComponent"):
		return
	
	affected_health_components.append(body.health_component)


func _on_body_exited(body: Node2D) -> void:
	if not body.has_node("HealthComponent"):
		return
	
	affected_health_components.erase(body.health_component)


func _on_damage_timer_timeout() -> void:
	for health_component in affected_health_components:
		if health_component.get_parent() is Player and affecting == 'Player' or not health_component.get_parent() is Player and affecting == 'Enemy':
			health_component.take_damage(calculate_damage())
