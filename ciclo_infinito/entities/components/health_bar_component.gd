extends Control
class_name HealthBarComponent


@export var bar_size : Vector2 = Vector2(30,5) :  set = _set_bar_size
@export var is_health_bar_visible : bool = true:  set = _set_is_health_bar_visible
@export var bar_position : Marker2D
@export var health_component : HealthComponent
@export var is_damage_visible : bool = true


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


func create_damage_label() -> Label:
	var damage_label: Label
	damage_label = Label.new()
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	damage_label.add_theme_font_override("font",load("uid://dboxkasdapd73"))
	damage_label.add_theme_constant_override("outline_size",5)
	
	get_tree().current_scene.add_child(damage_label)
	return damage_label


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
	
	var previous_health : float = health_bar.value 
	health_bar.value = new_value
	show_damage(previous_health-new_value)
	await get_tree().create_timer(1).timeout
	create_tween().tween_property(hurt_bar,"value",new_value,0.2)


func show_damage(damage : float) -> void:
	if not is_damage_visible:
		return
	var damage_label: Label = create_damage_label()
	var type_of_damage : String = 'NO DAMAGE'
	if damage < 0: 
		type_of_damage = 'HEAlED DAMAGE'
	elif damage > 0:  
		type_of_damage = 'TOOK DAMAGE'
	
	match type_of_damage:
		'TOOK DAMAGE':
			damage_label.add_theme_color_override("font_color",Color.WHITE)
		'NO DAMAGE':
			damage_label.add_theme_color_override("font_color",Color.WHITE)
		'HEAlED DAMAGE':
			damage_label.add_theme_color_override("font_color",Color.WEB_GREEN)
	
	damage_label.global_position = bar_position.global_position
	damage_label.text = str(int(abs(round(damage))))
	#await get_tree().create_timer(0.75).timeout
	await create_tween().tween_property(damage_label,"global_position",damage_label.global_position + Vector2(0,-15),0.5).finished
	damage_label.queue_free()


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


func _set_is_health_bar_visible(value : bool) -> void:
	is_health_bar_visible = value
	if health_bar and is_health_bar_visible:
		health_bar.show() 
	if health_bar and not is_health_bar_visible:
		health_bar.hide() 
	if hurt_bar and is_health_bar_visible:
		hurt_bar.show() 
	if hurt_bar and not is_health_bar_visible:
		hurt_bar.hide() 
