extends Node
class_name HealthComponent


enum COLOR_DAMAGE{Red, White}


signal died
signal lost_health(amount : float)


@export var max_health: float = 120.0
@export var damage_taken_effect_duration: float = 0.3
@export var invinciblity_duration : float = 0
@export var color_of_damage: COLOR_DAMAGE = COLOR_DAMAGE.Red
@export var damage_recieved_sfx: AudioStreamPlayer2D
@export var sprite: CanvasItem


var current_health : float
var is_invincible = false


@onready var entity : Node2D = get_parent()


func _ready() -> void:
	current_health = max_health


func take_damage(damage_amount: float, hit_direction: Vector2) -> void:
	if entity is Player and (entity.current_state == entity.State.DASH or 
							 entity.current_state == entity.State.DEATH or 
							 entity.current_state == entity.State.DIALOG):
		return 
	
	if is_invincible:
		return
	
	var original_health : float = current_health
	current_health = clamp(current_health - damage_amount, 0.0, max_health)
	lost_health.emit(original_health - current_health)
	
	update_health_bar()
	
	var knockback_force: float = 350.0
	entity.velocity = hit_direction * knockback_force
	
	applies_damage_received_effect()
	
	start_invincibility(invinciblity_duration)
	
	if current_health <= 0.0:
		die()


func applies_damage_received_effect() -> void:
	var color_name : String = "redden" if color_of_damage == COLOR_DAMAGE.Red else 'whiten'
	damage_recieved_sfx.play()
	
	if sprite.material and current_health > 0:
		sprite.material.set_shader_parameter(color_name, true)
		await get_tree().create_timer(damage_taken_effect_duration).timeout
		sprite.material.set_shader_parameter(color_name, false)


func update_health_bar():
	if not entity is Player or not entity.vida_cheia:
		return
	
	var ratio=current_health/max_health
	var filled_heart=int(round(ratio*6))
	filled_heart=clamp(filled_heart,0,6)
	entity.vida_cheia.texture = entity.vida_textures[filled_heart]


func die() -> void:
	died.emit()
	if not (entity is Player):
		return
	
	entity.is_dead = true
	entity.current_state = entity.State.DEATH
	entity.collision_layer = 0
	
	entity.update_animation()
	entity.death_sfx.play(0.3)
	
	await get_tree().create_timer(2.0).timeout
	await SceneTransition.fade_out()
	
	var death_scene = preload("uid://b7qoxm33b5qxt").instantiate()#death_screen.tscn
	get_tree().root.add_child(death_scene)
	death_scene.set_layer(100)


func start_invincibility(duration: float, is_dash : bool = false) -> void:
	is_invincible = true
	
	if Util.is_collision_mask_layer_set(entity,"Enemy"):
		entity.set_deferred("collision_mask",entity.collision_mask^Util.collision_layer_values["Enemy"])
	if is_dash and Util.is_collision_mask_layer_set(entity,"Static Interactive"):
		entity.set_deferred("collision_mask",entity.collision_mask^16)
	
	await get_tree().create_timer(duration).timeout
	
	if not Util.is_collision_mask_layer_set(entity,"Enemy"):
		entity.set_deferred("collision_mask",entity.collision_mask^Util.collision_layer_values["Enemy"])
	if is_dash and not Util.is_collision_mask_layer_set(entity,"Static Interactive"):
		entity.set_deferred("collision_mask",entity.collision_mask^24)
	
	is_invincible = false
