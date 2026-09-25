extends Node
class_name Level

## List of waves
@export var waves: Array[Wave] = []
## Interval between creature spawns.
@export_range(1, 60, 1, "suffix:s", "prefer_slider")  var spawn_time: float = 1.0

var timer: Timer
var wave_count: float = 1.0


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.stat()
# enconstrução
func _on_timer_timeout() -> void:
	waves[wave_count].wave_start()
	add_child(waves[wave_count].wave_creature_spawn())

func wave_change() -> void:
	wave_count += 1
#enconstrução
