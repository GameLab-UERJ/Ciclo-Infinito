extends Area2D
class_name Bullet


enum PossibleTargets{ENEMY, BOSS, PLAYER}


signal hit(character : Character)
signal spawned()
signal life_ended()
signal max_range_reached()


@export var direction : Vector2
@export var speed : float = 2000
@export var max_range : float = 2000
@export var can_hit : Array[PossibleTargets] = []: set = _set_can_hit


func _ready() -> void:
	set_deferred("collision_layer",0)
	update_mask()


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		print(collision_mask)

#region setters and getters
func _set_can_hit(value) -> void:
	can_hit = value
	for target : PossibleTargets in can_hit:
		while can_hit.count(target) > 1:
			can_hit.erase(target)
	
	update_mask()


func update_mask() -> void:
	var mask : int = 0
	for target : PossibleTargets in can_hit:
		match target:
			PossibleTargets.ENEMY:
				mask ^= Util.get_layer_value("Enemy")
			PossibleTargets.BOSS:
				mask ^= Util.get_layer_value("Boss")
			PossibleTargets.PLAYER:
				mask ^= Util.get_layer_value("Player")
	
	set_deferred("collision_mask",mask)
#endregion
