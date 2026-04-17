class_name DialogueArea
extends Area2D

signal started_dialogue
signal dialogue_ended

@export var dialogue: Dialogue
@export var interaction_label: Label

var _active: bool = false:
	set(value):
		_active = value
		interaction_label.visible = _active

func _ready() -> void:
	interaction_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if _active and event.is_action_pressed("interact"):
		DialogueCore.start_dialogue(dialogue)
		started_dialogue.emit()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_active = true
		
		
func _on_body_exited(body: Node) -> void:
	if body is Player:
		_active = false
		DialogueCore.prematurely_end_dialogue()
		dialogue_ended.emit()
