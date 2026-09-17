extends Status
class_name RadiationStatus


var created_by : CharacterBody2D
@export_enum("Player", "Enemy") var affecting : String


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player and affecting == 'Player' or not body is Player and affecting == 'Enemy':
		(body as Player).health_component.take_damage(5)
