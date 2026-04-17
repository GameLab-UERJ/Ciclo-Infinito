extends Node

signal dialogue_finished

const DIALOGUE_PATH: = "res://systems/dialogue_system/dialogue_visuals.tscn"

var dialogue_scene: PackedScene = preload(DIALOGUE_PATH)
var dialogue_container: DialogueVisuals

var _current_dialogue: Dialogue:
	set(value):
		if _current_dialogue:
			_current_dialogue.reset()
		_current_dialogue = value
		if not _current_dialogue:
			dialogue_container.visible = false
		else:
			dialogue_container.visible = true
			dialogue_container.set_line(_current_dialogue.line)
	

func _ready():
	GameManager.scene_changed.connect(_setup_dialogue_container)
	_setup_dialogue_container()


func start_dialogue(dialogue: Dialogue):
	_current_dialogue = dialogue
	
func prematurely_end_dialogue():
	_current_dialogue = null


func act(dialogue: Dialogue):
	if _current_dialogue != dialogue:
		_current_dialogue = dialogue
	pass
	
		
func _setup_dialogue_container() -> void:
	var scene = dialogue_scene.instantiate()
	if dialogue_container:
		dialogue_container.queue_free()
	if scene is DialogueVisuals:
		dialogue_container = scene
		dialogue_container.line_finished.connect(_on_line_done_writing)
		get_tree().root.add_child.call_deferred(dialogue_container)
		dialogue_container.visible = true
	else:
		print("Error: Dialogue scene is not a CanvasLayer.")
		
	
func _on_line_done_writing():
	if not _current_dialogue:
		return
		## aqui precisa poppar o input para ir para próximo dialogo
	if _current_dialogue.next():
		dialogue_container.set_line(_current_dialogue.line)
	else:
		_current_dialogue = null
		dialogue_finished.emit()
	
