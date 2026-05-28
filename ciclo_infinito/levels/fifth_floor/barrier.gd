extends StaticBody2D


var liberado : bool = false


@onready var colisao: CollisionShape2D = $colisaobarreira


func _physics_process(_delta: float) -> void:
	if liberado:
		queue_free()
	if GameState.fifth_floor_state > GameState.FifthFloorState.FIRST_TALK:
		liberado = true
		colisao.set_deferred("disabled",true)
