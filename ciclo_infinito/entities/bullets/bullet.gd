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


#region setters and getters
func _set_can_hit(value) -> void:
	can_hit = value
	for target : PossibleTargets in can_hit:
		while can_hit.count(target) > 1:
			can_hit.erase(target)
#endregion
