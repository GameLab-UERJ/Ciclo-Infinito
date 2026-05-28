class_name FadeComponent
extends ColorRect


signal fade_finished


@export var is_fade_out : bool = true
@export var fade_color : Color = Color.BLACK:
	set(value):
		var pre_alpha : float = fade_color.a
		fade_color = value
		fade_color.a = pre_alpha
@export_range(0,100,0.1) var fade_time : float = 1.0
@export var preferred_size : Vector2
@export var offset : Vector2 = Vector2.ZERO


func _ready() -> void:
	if not preferred_size:
		size = get_viewport_rect().size
	else:
		size = preferred_size
	position += offset
	color = fade_color
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_fade_out:
		color.a = 0
	else:
		color.a = 1.0


func fade():
	var full_color : Color = fade_color
	if is_fade_out:
		fade_color.a = 0.0
		full_color.a = 1.0
	else:
		fade_color.a = 1.0
		full_color.a = 0.0
		
	var tween : Tween = create_tween()
	tween.tween_property(self,"color",full_color,fade_time)
	tween.finished.connect(fade_finished.emit)
