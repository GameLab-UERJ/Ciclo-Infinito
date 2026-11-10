extends Area2D
class_name Bullet


enum PossibleTargets{ENEMY, BOSS, PLAYER}


signal hit(character : Character)
signal spawned()
signal life_ended()
signal max_range_reached()


@export var direction : Vector2:
	set(value):
		direction = value.normalized()
@export var speed : float = 100.0
@export var max_range : float = 2000.0
@export var can_hit : Array[PossibleTargets] = []: set = _set_can_hit


var _initial_position : Vector2
var _reached_limit : bool = false


#region built-in functions
func _ready() -> void:
	set_deferred("collision_layer",0)
	update_mask()
	body_entered.connect(_on_body_entered)
	_initial_position = global_position
	spawned.emit()


func _physics_process(delta: float) -> void:
	if _reached_limit:
		return
	if global_position.distance_to(_initial_position) > max_range:
		_reached_limit = true
		max_range_reached.emit()
		life_ended.emit()
	position = round(position + direction*speed*delta)
#endregion


#region setters and getters
func _set_can_hit(value) -> void:
	if not value:
		can_hit = []
		return
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


#region collision handling
func _on_body_entered(body: Character) -> void:
	hit.emit(body)
#endregion
