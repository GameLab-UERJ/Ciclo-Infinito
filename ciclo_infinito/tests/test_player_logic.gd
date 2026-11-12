extends Node

var player: Player
var failures: int = 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func settle() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame


func _ready() -> void:
	player = load("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await settle()
	var health: HealthComponent = player.health_component
	var fsm: EnabledPlayerStateMachineManager = player.enabled_machine_manager
	var original_mask: int = player.collision_mask
	var resistance_modifier: AttributeModifier = AttributeModifier.new()
	resistance_modifier.resistance = 2
	player.progression.add_modifier(resistance_modifier)
	check(health.max_health == player.progression.get_final_attributes().vitality * 5.0,
			"Main vitality scaling must be preserved")
	var initial_health: float = health.current_health

	fsm.happened("dash")
	await settle()
	health.take_damage(null, player.progression.get_final_attributes().resistance + 1.0)
	check(health.current_health == initial_health, "Dash must block damage")
	fsm.happened("dash_attack")
	await settle()
	health.take_damage(null, player.progression.get_final_attributes().resistance + 1.0)
	check(health.current_health == initial_health, "Spin entry must block damage")
	await get_tree().create_timer(0.12).timeout
	check(player.is_dash_attacking, "Damage test must run during the spin")
	health.take_damage(null, player.progression.get_final_attributes().resistance + 1.0)
	check(health.current_health == initial_health - 1.0, "Spin must become vulnerable")
	await get_tree().create_timer(0.65).timeout
	check(player.collision_mask == original_mask, "Collision mask must be restored exactly")

	# A short dash window must not cancel a longer post-hit window.
	health.start_invincibility(0.3)
	health.start_invincibility(0.05, true)
	await get_tree().create_timer(0.1).timeout
	check(health.is_invincible, "Dash expiry must preserve post-hit protection")
	await get_tree().create_timer(0.25).timeout
	check(not health.is_invincible, "Overlapping protection must eventually expire")
	check(player.collision_mask == original_mask, "Overlapping timers must preserve collision bits")

	# Starting and cancelling in one frame must not leave a deferred collision change behind.
	health.start_invincibility(0.2, true)
	health.end_dash_invincibility()
	await settle()
	check(player.collision_mask == original_mask, "Same-frame cancellation must restore collisions")
	player.collision_mask = 1
	health.start_invincibility(0.04, true)
	await get_tree().create_timer(0.1).timeout
	check(player.collision_mask == 1, "Protection must not add absent collision layers")
	player.collision_mask = original_mask

	# An old attack timer must not end a newer attack after a dialogue interruption.
	player.attack1_lock_time = 0.5
	player.combo_window = 0.4
	fsm.happened("attack")
	await settle()
	await get_tree().create_timer(0.2).timeout
	player.enter_dialogue()
	await settle()
	check(player.combo_step == 0, "Dialogue must cancel the combo")
	check(not player.is_in_state("Attack"), "Inactive gameplay state must not leak into queries")
	check(player.area_attack.get_node("attack_colison").disabled, "Dialogue must disable damage")
	player.exit_dialogue()
	await settle()
	fsm.happened("attack")
	await settle()
	await get_tree().create_timer(0.3).timeout
	check(player.combo_step == 1, "Stale timer must not finish the new attack")
	await get_tree().create_timer(0.4).timeout
	check(player.can_attack, "Attack must recover normally after interruption")

	fsm.happened("dash")
	await settle()
	player.enter_cutscene()
	await settle()
	check(not player.is_dashing, "Cutscene must cancel dash")
	check(player.dash_timer.is_stopped(), "Cutscene must stop dash timer")
	check(not health.is_invincible, "Cancelled dash must release its protection")
	player.exit_cutscene()
	await settle()
	check(fsm.get_current() == "Idle", "Cutscene must return to idle")
	await get_tree().create_timer(player.dash_cooldown_time + 0.1).timeout
	check(player.can_dash(), "Interrupted dash must eventually recover its cooldown")

	# The explicit timer must win over the Dash state, even with a shorter configured window.
	player.dash_invincibility_time = 0.03
	fsm.happened("dash")
	await settle()
	await get_tree().create_timer(0.04).timeout
	check(player.is_dashing, "Short protection test must still be dashing")
	initial_health = health.current_health
	health.take_damage(null, player.progression.get_final_attributes().resistance + 1.0)
	check(health.current_health == initial_health - 1.0, "Dash state cannot override its timer")
	await get_tree().create_timer(1.4).timeout

	# Pause freezes both the spin and its protection; it cannot expire offscreen.
	fsm.happened("dash")
	await settle()
	fsm.happened("dash_attack")
	await settle()
	get_tree().paused = true
	await get_tree().create_timer(0.5, true).timeout
	check(player.is_dash_attacking, "Paused spin must not finish")
	check(health.is_invincible, "Paused protection must not expire")
	get_tree().paused = false
	player.enter_dialogue()
	await settle()
	check(not player.is_dash_attacking, "Dialogue must cancel spin")
	check(not health.is_invincible, "Dialogue must clear spin protection")

	# Death while dialogue is active must still reach the terminal base state.

	player.enter_dialogue()
	await settle()
	player.die()
	check(player.is_dead, "Death must block gameplay immediately")
	await settle()
	check(player.get_current_base_state() == "Dead", "Death must transition from dialogue")
	check(not player.can_attack and not player.can_dash(), "Dead player cannot act")
	await get_tree().create_timer(0.6).timeout
	check(not player.can_attack, "Old callbacks must not revive attack permission")
	player.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	print("[TEST] PLAYER LOGIC: ", failures, " failures")
	get_tree().quit(0 if failures == 0 else 1)
