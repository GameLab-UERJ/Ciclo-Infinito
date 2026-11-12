extends CharacterComponent
class_name HealthComponent


enum COLOR_DAMAGE{Red, White}


signal died
signal changed_health(current_health : float)
signal changed_max_health(max_health : float)


@export var max_health: float = 120.0 : set = _set_max_health
@export var damage_taken_effect_duration: float = 0.3
@export var invinciblity_duration : float = 0
@export var color_of_damage: COLOR_DAMAGE = COLOR_DAMAGE.Red
@export var damage_recieved_sfx: AudioStreamPlayer2D
@export var sprite: CanvasItem


var current_health : float: set = _set_current_health
var is_invincible: bool = false
var _damage_invincibility_left: float = 0.0
var _dash_invincibility_left: float = 0.0
var _suppressed_collision_bits: int = 0
var _requested_collision_mask: int = -1


func _ready() -> void:
	super._ready()
	current_health = max_health


func _physics_process(delta: float) -> void:
	_damage_invincibility_left = maxf(0.0, _damage_invincibility_left - delta)
	_dash_invincibility_left = maxf(0.0, _dash_invincibility_left - delta)
	_sync_invincibility()


func take_damage(source: Character, damage_amount: float, hit_direction: Vector2 = Vector2.ZERO) -> void:
	if current_health <= 0.0:
		return
	if parent is Player and (parent.is_dead or parent.get_current_base_state() in [
			"Dead", "Dialogue", "Cutscene"]):
		return

	if is_invincible or ("is_dead" in parent and parent.is_dead):
		return

	if parent.has_node("ProgressionComponent"):
		damage_amount = parent.get_node("ProgressionComponent").apply_damage_reduction(source,damage_amount)

	current_health = clamp(current_health - damage_amount, 0.0, max_health)
	changed_health.emit(current_health)

	update_health_bar()#HAS TO BE ALTERED TO USE HEALTHBARCOMPONENT

	var knockback_force: float = 350.0
	parent.velocity = hit_direction * knockback_force

	if sprite and damage_recieved_sfx:
		applies_damage_received_effect()

	start_invincibility(invinciblity_duration)

	if current_health <= 0.0:
		die()

## Takes damage based on a 'percentage' (0.0 <= percentage <= 1.0) of the health.
## If 'from_max_health' is true, than damage == 'percentage' * max_health.
## Otherwise, damage == 'percentage' * max_health.
func take_damage_by_percentage(source : Character, percentage : float, from_max_health : bool = true) -> void:
	if percentage < 0:
		push_warning('take_damage_by_percentage received negative percentage ('+str(percentage)+')')
		return

	if percentage > 1:
		percentage = 1

	var damage : float = round(current_health * percentage)
	if from_max_health:
		damage = round(max_health *  percentage)
	take_damage(source, max(damage,1))


func applies_damage_received_effect() -> void:
	var color_name : String = "redden" if color_of_damage == COLOR_DAMAGE.Red else 'whiten'
	damage_recieved_sfx.play()

	if sprite.material and current_health > 0:
		sprite.material.set_shader_parameter(color_name, true)
		await get_tree().create_timer(damage_taken_effect_duration).timeout
		sprite.material.set_shader_parameter(color_name, false)


func update_health_bar():
	if not parent is Player or not parent.vida_cheia:
		return

	var ratio=current_health/max_health
	var filled_heart=int(round(ratio*6))
	filled_heart=clamp(filled_heart,0,6)
	parent.vida_cheia.texture = parent.vida_textures[filled_heart]


func die() -> void:
	died.emit()
	if not (parent is Player):
		return

	parent.collision_layer = 0
	parent.die()

	await get_tree().create_timer(2.0).timeout
	await SceneTransition.fade_out()

	var death_scene = preload("uid://b7qoxm33b5qxt").instantiate()#death_screen.tscn
	get_tree().root.add_child(death_scene)
	death_scene.set_layer(100)


func start_invincibility(duration: float, is_dash: bool = false) -> void:
	if is_dash:
		# O dash e a transição para o giro têm janelas independentes do dano recebido.
		_dash_invincibility_left = maxf(0.0, duration)
	else:
		_damage_invincibility_left = maxf(_damage_invincibility_left, duration)
	_sync_invincibility()


func end_dash_invincibility() -> void:
	_dash_invincibility_left = 0.0
	_sync_invincibility()


func _sync_invincibility() -> void:
	is_invincible = _damage_invincibility_left > 0.0 or _dash_invincibility_left > 0.0
	var ignored_bits: int = 0
	if is_invincible:
		ignored_bits |= int(Util.collision_layer_values.get("Enemy", 0))
	if _dash_invincibility_left > 0.0:
		ignored_bits |= int(Util.collision_layer_values.get("Static Interactive", 0))

	# Restaura apenas bits que esta proteção removeu; nunca adiciona camadas ausentes.
	var original_mask: int = parent.collision_mask | _suppressed_collision_bits
	_suppressed_collision_bits = original_mask & ignored_bits
	var next_mask: int = original_mask & ~ignored_bits
	if parent.collision_mask != next_mask or _requested_collision_mask != next_mask:
		_requested_collision_mask = next_mask
		parent.set_deferred("collision_mask", next_mask)


func _set_max_health(value : float) -> void:
	var difference : float = value - max_health
	max_health = value
	if difference > 0:
		current_health += difference
	else:
		current_health = min(current_health, max_health)
	update_health_bar()
	changed_max_health.emit(max_health)


func _set_current_health(value : float) -> void:
	#print('old current_health: ',current_health,' new current_health: ',value)
	current_health = value
