extends StaticBody2D
class_name Barrier


signal started_opening
signal finished_opening


@export var opener_node : Node
@export var opener_method_name : String
@export var silenced : bool = false


var liberado : bool = false
var is_open : bool = false


@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite")
@onready var rumbling_sfx: AudioStreamPlayer2D = $RumblingSfx
@onready var open_sfx: AudioStreamPlayer2D = $OpenSfx


func _physics_process(_delta: float) -> void:
	if liberado:
		open()
	if (opener_node and 
		opener_node.has_method(opener_method_name) and 
		opener_node.call(opener_method_name) ):
		liberado = true


func open() -> void:
	if is_open:
		return
	is_open = true
	started_opening.emit()
	animated_sprite.play("open")
	if not silenced and not rumbling_sfx.playing:
		rumbling_sfx.play()


func _on_animated_sprite_animation_finished() -> void:
	rumbling_sfx.stop()
	visible = false
	collision_shape.disabled = true
	if not silenced:
		open_sfx.play(0.36)
	await get_tree().create_timer(1).timeout
	finished_opening.emit()
