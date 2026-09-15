extends StateMachineManager
class_name EnabledPlayerStateMachineManager


@export var debug_label: Label

var current_state: String = "Entry"
var player: Player


func _ready() -> void:
	update_process_mode = UpdateProcessMode.PHYSICS
	_resolve_player_ref()
	if not transited.is_connected(_on_transited):
		transited.connect(_on_transited)
	if not updated.is_connected(_on_updated):
		updated.connect(_on_updated)
	super._ready()


func _resolve_player_ref() -> void:
	if owner is Player:
		player = owner
	elif get_parent() is Player:
		player = get_parent()
	elif get_parent() and get_parent().get_parent() is Player:
		player = get_parent().get_parent()


func happened(trigger: String) -> void:
	set_trigger(trigger)


func _physics_process(delta: float) -> void:
	if not active or player == null or player.is_dead:
		return
	
	_update_fsm_parameters()
	_handle_input_triggers()
	
	super._physics_process(delta)


func _update_fsm_parameters() -> void:
	var input_dir: Vector2 = player.get_input_direction()
	set_param("stopped_walking", input_dir == Vector2.ZERO)


func _handle_input_triggers() -> void:
	var input_dir: Vector2 = player.get_input_direction()
	var state_str: String = get_current()
	if state_str == "":
		state_str = current_state
		
	match state_str:
		"Entry":
			pass
		"Idle":
			if Input.is_action_just_pressed("attack") and player.can_start_attack():
				happened("attack")
			elif Input.is_action_just_pressed("dash") and player.can_dash():
				happened("dash")
			elif input_dir != Vector2.ZERO:
				happened("walk")
		
		"Walking":
			if Input.is_action_just_pressed("attack") and player.can_start_attack():
				happened("attack")
			elif Input.is_action_just_pressed("dash") and player.can_dash():
				happened("dash")
					
		"Dash":
			if Input.is_action_just_pressed("attack"):
				happened("dash_attack")
				
		"Attack":
			if Input.is_action_just_pressed("attack") and player.combo_step == 1 and player.combo_window_open:
				player.combo_buffered = true


# TRANSICAO DE ESTADOS
func _on_transited(_from: Variant, to: Variant) -> void:
	current_state = str(to)
	if debug_label:
		debug_label.text = current_state
		
	if player == null:
		_resolve_player_ref()
	if player == null:
		return

	match str(to):
		"Idle":
			set_param("attack_finished", false)
			set_param("dash_finished", false)
			set_param("dash_attack_finished", false)
			player.velocity = Vector2.ZERO
			
			# Se o jogador estiver segurando movimento ao retornar a Idle, transita para Walking
			if player.get_input_direction() != Vector2.ZERO:
				happened("walk")
				
		"Walking":
			var dir = player.get_input_direction()
			if dir != Vector2.ZERO:
				player.next_direction = dir
				player.last_facing = player.get_direction_string(dir)
				player.velocity = dir.normalized() * player.move_speed
			
		"Attack":
			player.start_attack_sequence()
			
		"Dash":
			player.start_dash_sequence()
			
		"DashAttack":
			player.start_dash_attack_sequence()


# ATUALIZAÇÃO DO ESTADO
func _on_updated(state: Variant, delta: Variant) -> void:
	if player == null or player.is_dead:
		return

	match str(state):
		"Walking":
			var dir = player.get_input_direction()
			if dir != Vector2.ZERO:
				player.next_direction = dir
				player.last_facing = player.get_direction_string(dir)
				player.velocity = dir.normalized() * player.move_speed
			else:
				player.velocity = Vector2.ZERO
				
		"Dash":
			player.update_dash_physics(delta)
			
		"Attack":
			player.update_attack_physics(delta)
			
		"DashAttack":
			player.update_dash_attack_physics(delta)
			
		"Idle":
			player.velocity = Vector2.ZERO


func notify_attack_finished() -> void:
	set_param("attack_finished", true)


func notify_dash_finished() -> void:
	set_param("dash_finished", true)


func notify_dash_attack_finished() -> void:
	set_param("dash_attack_finished", true)
