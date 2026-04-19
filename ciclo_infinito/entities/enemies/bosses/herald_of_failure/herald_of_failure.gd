extends Boss


@export var sprite: AnimatedSprite2D

func _ready() -> void:
	state_machine.state_changed.connect(_update_visuals)

func _update_visuals(new_state: String) -> void:
	print("State changed to: ", new_state)
	match new_state:
		"Idle":
			sprite.play("idle")
		"Patrol":
			sprite.play("move")
		"AttackMeteor":
			sprite.play("attack_2")
		"AttackTornado":
			sprite.play("attack_2")
