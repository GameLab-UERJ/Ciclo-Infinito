extends Control


@onready var health_component: HealthComponent = %HealthComponent
@onready var health_bar_component: HealthBarComponent = %HealthBarComponent


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		health_component.take_damage(10)
