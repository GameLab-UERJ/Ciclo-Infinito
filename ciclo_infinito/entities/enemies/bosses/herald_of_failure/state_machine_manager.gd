extends Node


@export var debug_label : Label


var current_state : String


@onready var boss : Boss = get_parent()
@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer
@onready var timer: Timer = $Timer


func _physics_process(_delta: float) -> void:
	set_state_machine()


func set_state_machine() -> void:
	state_machine_player.set_param("distance_to_initial",boss.global_position.distance_to(boss.initial_position))
	state_machine_player.set_param("died",boss.is_dead)
	state_machine_player.set_param("player_is_close", not boss.first_time_on_screen)
	state_machine_player.set_param("distance_to_next_position",boss.global_position.distance_to(boss.next_position))


func happened(trigger : String) -> void:
	state_machine_player.set_trigger(trigger)


func _on_state_machine_player_transited(_from: Variant, to: Variant) -> void:
	current_state = to
	debug_label.text = to
	
	if to != "Running":
		boss.current_direction = Vector2.ZERO
	
	match to:
		"WaitingPlayer":
			boss.sprites.play("idle")
		"Idle":
			boss.sprites.play("idle")
			timer.start(1-0.8*randi_range(0,1))
			await timer.timeout
			happened("wait_time_passed")
		"Attacking":
			var attack : String = "attack_"+str(1+1*randi_range(0,1))
			for i in randi_range(1,4):
				boss.sprites.play(attack)
				await boss.sprites.animation_finished
				if attack == "attack_2":
					boss.spawn_meteor_at_player(3, 1)
				else:
					boss.spawn_meteor_at_player(1)
			happened("attack_ended")
		"Running":
			boss.get_valid_next_position()
			boss.current_direction = boss.global_position.direction_to(boss.next_position)
		"TryAttacking":
			if randf() <= boss.chance_of_attacking_after_moving:
				happened("chose_to_attack")
			else:
				happened("chose_not_to_attack")
		"Dead":
			boss.die()


func _on_state_machine_player_updated(_state: Variant, _delta: Variant) -> void:
	pass
