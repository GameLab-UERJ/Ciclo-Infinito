extends Control
class_name HealthBarComponent


@export var bar_size : Vector2 = Vector2(30,5) :  set = _set_bar_size
@export var bar_position : Marker2D
@export var health_component : HealthComponent


var max_health: float : set = _set_max_health
var health_bar: ProgressBar
var hurt_bar: ProgressBar


func _ready() -> void:
	create_bars()
	max_health = health_component.max_health
	
	health_component.changed_health.connect(change_health)
	health_component.died.connect(hide)
	
	if bar_position:
		position = bar_position.position - bar_size/2


func create_bars() -> void: 	
	var bar : ProgressBar =  ProgressBar.new()
	bar.show_percentage = false
	bar.size = bar_size
	bar.value = bar.max_value
	#bar.set_anchors_preset(Control.PRESET_CENTER)
	hurt_bar = bar
	health_bar = bar.duplicate()
	add_child(hurt_bar)
	add_child(health_bar)
	
	hurt_bar.add_theme_stylebox_override("fill",load("uid://dgmg8jo5g61c7"))
	health_bar.add_theme_stylebox_override("fill",load("uid://itp11yo2g2nf"))


func change_health(new_value : float) -> void:
	if new_value > max_health:
		new_value = max_health
	if new_value < 0.0:
		new_value = 0.0
	
	health_bar.value = new_value
	await get_tree().create_timer(1).timeout
	create_tween().tween_property(hurt_bar,"value",new_value,0.2)


func _set_max_health(value : float) -> void:
	max_health = value
	if health_bar:
		var previous_max_value : float = health_bar.max_value
		health_bar.max_value = max_health
		if health_bar.value == previous_max_value:
			health_bar.value = health_bar.max_value
	if hurt_bar:
		var previous_max_value : float = hurt_bar.max_value
		hurt_bar.max_value = max_health
		if hurt_bar.value == previous_max_value:
			hurt_bar.value = hurt_bar.max_value


func _set_bar_size(value : Vector2) -> void:
	bar_size = value
	if health_bar:
		health_bar.size = value
	if hurt_bar:
		hurt_bar.size = value
