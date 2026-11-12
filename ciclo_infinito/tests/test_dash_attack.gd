extends Node

class DamageRecorder extends Node:
	var hits: int = 0

	func take_damage(_amount: float, _direction: Vector2) -> void:
		hits += 1


func _ready() -> void:
	print("[TEST] Starting Dash Attack Unit Tests...")
	var player_scene = load("res://entities/player/player.tscn")
	assert(player_scene != null, "player.tscn must be loadable")
	
	var player: Player = player_scene.instantiate()
	add_child(player)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 1. Animations verification
	print("[TEST] 1. Checking animations in sprite_frames...")
	var sf: SpriteFrames = player.anim.sprite_frames
	assert(sf != null, "Player must have sprite_frames")
	assert(sf.has_animation("dash_attack_down"), "Must have dash_attack_down")
	assert(sf.has_animation("dash_attack_left"), "Must have dash_attack_left")
	assert(sf.has_animation("dash_attack_right"), "Must have dash_attack_right")
	assert(sf.has_animation("dash_attack_up"), "Must have dash_attack_up")
	assert(sf.has_animation("dash_attack"), "Must have dash_attack fallback")
	assert(sf.get_animation_loop("dash_attack_down") == false, "Dash attack must not loop")
	print("  -> All animations present and configured correctly.")
	
	# 2. Damage Calculation with Strength & Boons
	print("[TEST] 2. Checking damage calculation...")
	var base_dmg = player.calculate_dash_attack_damage(10.0)
	print("  -> Base damage (Str 10): ", base_dmg)
	assert(base_dmg == player.dash_attack_damage + (10.0 * player.dash_attack_strength_multiplier), "Damage formula must match base + strength * multiplier")
	
	var high_str_dmg = player.calculate_dash_attack_damage(20.0)
	assert(high_str_dmg > base_dmg, "Higher strength must produce higher damage")
	
	var atomic_weight_boon = load("res://resources/data/boons/marie_curie/atomic_weight.tres") as Boon
	assert(atomic_weight_boon != null, "atomic_weight.tres must exist")
	assert(Boon.AffectedSkill.DASH_ATTACK in atomic_weight_boon.affected_skill, "atomic_weight must affect DASH_ATTACK")
	
	player.progression.add_boon(atomic_weight_boon)
	var boon_dmg = player.calculate_dash_attack_damage(player.progression.get_final_attributes().strength)
	print("  -> Damage with Atomic Weight boon: ", boon_dmg)
	assert(boon_dmg > base_dmg, "Boon with DASH_ATTACK must increase dash attack damage")
	
	# 3. Physics and Deceleration
	print("[TEST] 3. Checking dash attack physics & deceleration...")
	player.dash_dir = Vector2.RIGHT
	player.velocity = player.dash_dir * (player.move_speed * player.dash_attack_speed_multiplier)
	var initial_v = player.velocity.length()
	assert(initial_v > 0.0, "Initial velocity must be positive")
	
	player.update_dash_attack_physics(0.1)
	var v_after_1 = player.velocity.length()
	assert(v_after_1 < initial_v, "Velocity must decelerate after physics update")
	
	player.update_dash_attack_physics(0.5)
	var v_after_2 = player.velocity.length()
	assert(v_after_2 < v_after_1, "Velocity must continue to decelerate towards zero")
	print("  -> Physics deceleration confirmed (", initial_v, " -> ", v_after_1, " -> ", v_after_2, ")")
	
	# 4. State Machine Transition: Dash -> DashAttack
	print("[TEST] 4. Testing FSM transition: Dash -> DashAttack...")
	var fsm = player.enabled_machine_manager
	assert(fsm != null, "Player must have enabled_machine_manager")
	
	# Trigger Dash
	fsm.happened("dash")
	await get_tree().physics_frame
	print("  -> FSM state after dash trigger: ", fsm.get_current())
	assert(fsm.get_current() == "Dash", "FSM must enter Dash")
	assert(player.is_dashing == true, "Player is_dashing must be true")
	
	# Trigger DashAttack during Dash
	fsm.happened("dash_attack")
	await get_tree().physics_frame
	print("  -> FSM state after dash_attack trigger: ", fsm.get_current())
	assert(fsm.get_current() == "DashAttack", "FSM must transition to DashAttack")
	assert(player.is_dash_attacking == true, "Player is_dash_attacking must be true")
	assert(player.is_dashing == false, "Player is_dashing must be false upon dash attack")
	
	# 5. Hitbox and finish
	print("[TEST] 5. Checking hitbox & attack sequence completion...")
	var col: CollisionShape2D = player.area_attack.get_node("attack_colison")
	assert(col.disabled == false, "Attack hitbox should be enabled during active window")
	
	# Wait for animation/sequence completion
	await get_tree().create_timer(player.dash_attack_duration + 0.05).timeout
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	print("  -> FSM state after dash attack finishes: ", fsm.get_current())
	assert(fsm.get_current() == "Idle" or fsm.get_current() == "Walking", "FSM must return to Idle or Walking")
	assert(player.is_dash_attacking == false, "is_dash_attacking must be false when finished")
	assert(col.disabled == true, "Hitbox must be disabled after attack")
	
	# Real input: simultaneous dash + attack must prefer the spin over a normal attack.
	await get_tree().create_timer(player.dash_cooldown_time + 0.1).timeout
	Input.action_press("dash")
	Input.action_press("attack")
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("dash")
	Input.action_release("attack")
	assert(fsm.get_current() == "DashAttack", "Simultaneous input must start spin")
	assert(col.shape is CircleShape2D, "Spin must hit around the player")
	assert(col.position == Vector2.ZERO, "Spin hitbox must be centered")

	var enemy: CharacterBody2D = CharacterBody2D.new()
	var recorder: DamageRecorder = DamageRecorder.new()
	recorder.name = "HealthComponent"
	enemy.add_child(recorder)
	add_child(enemy)
	player._on_area_attack_body_entered(enemy)
	player._on_area_attack_body_entered(enemy)
	assert(recorder.hits == 1, "A spin must damage each target only once")
	enemy.queue_free()

	Input.action_press("run_right")
	await get_tree().create_timer(0.1).timeout
	assert(player.velocity.x > 0.0, "Movement input must steer the spin")
	Input.action_release("run_right")
	await get_tree().create_timer(player.dash_attack_duration).timeout
	assert(not player.is_dash_attacking, "Spin must finish on its gameplay timer")
	assert(col.shape is RectangleShape2D, "Normal hitbox must be restored")

	# A late attack just after the dash still converts into a spin.
	await get_tree().create_timer(player.dash_cooldown_time + 0.1).timeout
	Input.action_press("dash")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("dash")
	await player.dash_timer.timeout
	await get_tree().physics_frame
	Input.action_press("attack")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("attack")
	assert(fsm.get_current() == "DashAttack", "Late attack must use dash grace window")
	await get_tree().create_timer(player.dash_attack_duration + 0.2).timeout

	# Outside the grace window, attack must remain a normal attack.
	Input.action_press("attack")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("attack")
	assert(fsm.get_current() == "Attack", "Ordinary attacks must remain available")
	await get_tree().create_timer(0.5).timeout
	print("[TEST] ALL DASH ATTACK TESTS PASSED SUCCESSFULLY!")
	await get_tree().create_timer(player.dash_cooldown_time + 0.1).timeout
	player.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(0)
