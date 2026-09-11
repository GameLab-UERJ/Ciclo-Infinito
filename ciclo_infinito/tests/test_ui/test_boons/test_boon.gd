extends Control


@export var sage : Sage


@onready var texture_button: TextureButton = $TextureButton


func _ready() -> void:
	texture_button.texture_normal = sage.splash
	await create_tween().tween_property(texture_button,"self_modulate",Color.WHITE,1.0).finished
	await get_tree().create_timer(1.0).timeout
	await create_tween().tween_property(texture_button,"position",Vector2.ZERO,1.0).finished
