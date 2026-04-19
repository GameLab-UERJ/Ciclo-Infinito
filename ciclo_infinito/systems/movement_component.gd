class_name MovementComponent
extends Node


@export var speed: float = 200.0


var velocity: Vector2 = Vector2.ZERO
var _parent: CharacterBody2D

func _ready() -> void:
	if self == get_tree().root or not get_parent() is CharacterBody2D:
		push_error("MovementComponent cannot be root or have a non CharacterBody2D parent")
		return
	_parent = get_parent()


func _physics_process(_delta: float) -> void:
	_parent.velocity = velocity
	_parent.move_and_slide()
