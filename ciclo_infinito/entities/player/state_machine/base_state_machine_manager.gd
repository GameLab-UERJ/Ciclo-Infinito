extends StateMachineManager
class_name BasePlayerStateMachineManager


@export var debug_label: Label

var current_state: String = "Entry"
var player: Player

@onready var enabled_machine_manager: EnabledPlayerStateMachineManager = get_node_or_null("EnabledStateMachineManager")


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


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func happened(trigger: String) -> void:
	set_trigger(trigger)


# TRIGGERS (Dialogue, Cutscene, Die)
func trigger_dialogue_started() -> void:
	happened("dialogue_started")


func trigger_dialogue_ended() -> void:
	happened("dialogue_ended")


func trigger_cutscene_started() -> void:
	happened("cutscene_started")


func trigger_cutscene_ended() -> void:
	happened("cutscene_ended")


func trigger_die() -> void:
	happened("die")


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
		"Enabled":
			if enabled_machine_manager:
				enabled_machine_manager.set_active(true)
				if enabled_machine_manager.get_current() == "":
					enabled_machine_manager.start()
		"Dialogue":
			if enabled_machine_manager:
				enabled_machine_manager.set_active(false)
			player.velocity = Vector2.ZERO
		"Cutscene":
			if enabled_machine_manager:
				enabled_machine_manager.set_active(false)
			player.velocity = Vector2.ZERO
		"Dead":
			if enabled_machine_manager:
				enabled_machine_manager.set_active(false)
			player.velocity = Vector2.ZERO
			player.handle_death()


func _on_updated(_state: Variant, _delta: Variant) -> void:
	pass
