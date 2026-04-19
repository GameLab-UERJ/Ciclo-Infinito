extends CanvasLayer

@onready var color_rect := $ColorRect
@onready var animation_player := $AnimationPlayer

var is_transitioning := false

func fade_out() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	is_transitioning = false

func fade_in() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	is_transitioning = false

func fade_to_scene(scene: PackedScene) -> void:
	await fade_out()
	get_tree().change_scene_to_packed(scene)
	await get_tree().process_frame
	await fade_in()
