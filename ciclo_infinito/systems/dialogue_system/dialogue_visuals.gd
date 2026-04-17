extends CanvasLayer
class_name DialogueVisuals

signal line_finished

@export var characters_per_second: float

var _current_time: float = 0.0

@onready var time_per_character: float = 1.0 / characters_per_second


func _ready() -> void:
	%DialogueLabel.visible_ratio = 0.0


func _process(delta: float) -> void:
	_current_time += delta
	
	%DialogueLabel.visible_characters += int(_current_time / time_per_character)
	_current_time = fmod(_current_time, time_per_character)
	if %DialogueLabel.visible_ratio == 1.0:
		%DialogueLabel.visible_ratio = 0.0
		line_finished.emit()
	

func set_line(line: String) -> void:
	%DialogueLabel.visible_characters = 0
	%DialogueLabel.text = line
	
