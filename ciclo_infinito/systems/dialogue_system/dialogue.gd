extends Resource
class_name Dialogue

@export var lines: Array[String] = []

var line:
	get: return lines[_current]

var _current: int = 0

func next() -> bool:
	if _current < lines.size() - 1:
		_current += 1
		return true
	else:
		_current = 0
		return false
		
func reset() -> void:
	_current = 0