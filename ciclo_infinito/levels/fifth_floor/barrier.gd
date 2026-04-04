extends StaticBody2D
@onready var colisao: CollisionShape2D = $colisaobarreira
var liberar = false


func _ready() -> void:
	colisao.disabled = false 
	


func _on_npc_dialogo_concluido() -> void:
	liberar = true
	colisao.set_deferred("disabled",true)
