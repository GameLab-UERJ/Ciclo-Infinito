extends Node
class_name CharacterComponent


@onready var parent: CharacterBody2D = get_parent()


func _ready() -> void:
	if not parent is CharacterBody2D:
		push_error("Error: This node must be child of a CharacterBody2D.")
		
		set_process(false)
		set_physics_process(false)
		queue_free()
