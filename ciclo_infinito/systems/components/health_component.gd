extends Node
class_name HealthComponent


@export var max_health: float = 120.0


var current_health : float
var is_invincible = false


@onready var player : Player = get_parent()


func _ready() -> void:
	current_health = max_health


func take_damage(damage_amount: float, hit_direction: Vector2) -> void:
	if (player.current_state == player.State.DASH or 
		player.current_state == player.State.DEATH or 
		player.current_state == player.State.DIALOG or 
		is_invincible):
		return
	
	current_health -= damage_amount
	current_health = clamp(current_health, 0.0, max_health)

	update_health_bar()

	var knockback_force: float = 350.0
	player.velocity = hit_direction * knockback_force

	player.applies_damage_received_effect()

	start_invincibility(player.invinciblity_duration)
	
	if current_health <= 0.0:
		die()


func update_health_bar():
	if not player.vida_cheia:
		return
	
	var ratio=current_health/max_health
	var filled_heart=int(round(ratio*6))
	filled_heart=clamp(filled_heart,0,6)
	player.vida_cheia.texture = player.vida_textures[filled_heart]


func die() -> void:
	player.is_dead = true
	player.current_state = player.State.DEATH
	player.collision_layer = 0
	
	player.update_animation()
	player.death_sfx.play(0.3)
	
	await get_tree().create_timer(2.0).timeout
	await SceneTransition.fade_out()
	
	var death_scene = preload("uid://b7qoxm33b5qxt").instantiate()#death_screen.tscn
	get_tree().root.add_child(death_scene)
	death_scene.set_layer(100)


func start_invincibility(duration: float, is_dash : bool = false) -> void:
	is_invincible = true
	if Util.is_collision_mask_layer_set(player,"Enemy"):
		player.set_deferred("collision_mask",player.collision_mask^Util.collision_layer_values["Enemy"])
	if is_dash and Util.is_collision_mask_layer_set(player,"Static Interactive"):
		player.set_deferred("collision_mask",player.collision_mask^16)
	player.state_label.set_deferred("text","%x" % (player.collision_mask))
	
	await get_tree().create_timer(duration).timeout
	
	if not Util.is_collision_mask_layer_set(player,"Enemy"):
		player.set_deferred("collision_mask",player.collision_mask^Util.collision_layer_values["Enemy"])
	if is_dash and not Util.is_collision_mask_layer_set(player,"Static Interactive"):
		player.set_deferred("collision_mask",player.collision_mask^24)
	player.state_label.set_deferred("text","%x" % (player.collision_mask))
	is_invincible = false
