extends StateMachineManager


@onready var animation_player: AnimationPlayer = parent.get_node_or_null("AnimationPlayer")


var last_facing: String = "down"


func _process(delta):
	super._process(delta)
	_update_state_machine() 


func _update_state_machine() -> void:
	set_param("is_player_detected",parent.player_ref != null)
	set_param("is_player_in_range",parent.player_in_attack_range)


func _update_animation_from_velocity() -> void:
	var dir := dir_string_from_vector(parent.velocity)
	last_facing = dir
	_play_anim("walk_%s" % dir)


func _update_animation_idle() -> void:
	_play_anim("idle_%s" % last_facing)


func _play_anim(animation_name: String) -> void:
	if animation_player == null:
		return
	if animation_player.has_animation(animation_name) and animation_player.current_animation != animation_name:
		animation_player.play(animation_name)


func attack() -> void:
	if not parent.attack_cooldown_timer.is_stopped():
		return
	parent.attack_cooldown_timer.start()
	
	var atk_name := "attack_%s" % last_facing
	if animation_player and animation_player.has_animation(atk_name):
		var animation := animation_player.get_animation(atk_name)
		if animation:
			animation.loop_mode = Animation.LOOP_NONE
	_play_anim(atk_name)
	
	parent.attack_sfx.play()
	await animation_player.animation_finished
	set_trigger("attack_finished")
	_update_animation_idle()


func _on_transited(from: Variant, to: Variant) -> void:
	print(parent.name," : ",from,'-->',to)
	match to:
		"Idle":
			(parent as BaseEnemy).chase_component.disable()
			(parent as BaseEnemy).movement_component.stop()
		"Chasing":
			(parent as BaseEnemy).chase_component.enable()
		"Attacking":
			(parent as BaseEnemy).chase_component.disable()
			(parent as BaseEnemy).movement_component.stop()


func _on_updated(state: Variant, _delta: Variant) -> void:
	match state:
		"Idle":
			_update_animation_idle()
		"Chasing":
			_update_animation_from_velocity()
		"Attacking":
			attack()


func dir_string_from_vector(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	else:
		return "down" if v.y > 0.0 else "up"


func die() -> void:
	active = false
	(parent as BaseEnemy).chase_component.disable()
	(parent as BaseEnemy).movement_component.stop()
	_play_anim("death_%s" %dir_string_from_vector(parent.velocity))
	await animation_player.animation_finished
	animation_player.active = false
