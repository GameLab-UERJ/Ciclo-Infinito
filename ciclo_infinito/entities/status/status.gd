extends Node2D
class_name Status


@export var created_by : CharacterBody2D
@export_enum("Player", "Enemy") var affecting : String
@export var duration : float
@export var level : int:
	set(value):
		level = value
		if not level:
			queue_free()


var duration_timer : Timer


@warning_ignore("shadowed_variable")
func init(created_by : CharacterBody2D,affecting : String, duration : float, level : int) -> void:
	self.created_by = created_by
	self.affecting = affecting
	self.duration = duration
	self.level = level


func _ready() -> void:
	duration_timer = Timer.new()
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.timeout.connect(_on_duration_timer_timeout)
	duration_timer.start(duration)


func _on_duration_timer_timeout() -> void:
	queue_free()
