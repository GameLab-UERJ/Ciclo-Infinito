extends Resource
class_name Wave

signal wave_end

## List of creatures to spawn
@export var wave_creatures: Array[CreatureSpawn] = []

var creatures_amounts: Array[float]
var wave_size: float = 0.0
var creature_chosen: float


func wave_creature_spawn() -> BaseEnemy:
	if wave_size < 1:
		wave_end.emit()
		return
		
	## Select Creature to Spawn
	while true:
		creature_chosen = randi_range(0, wave_creatures.size() - 1)
		
		if wave_creatures[creature_chosen].creature_amount < 1:
			continue
		else:
			break
	
	creatures_amounts[creature_chosen] -= 1
	wave_size -= 1
	return wave_creatures[creature_chosen].creature_scene.instantiate()


func iniciate_wave() -> void:
	creatures_amounts = []
	
	for i in wave_creatures:
		creatures_amounts.append(i.creature_amount)
		wave_size += i.creature_amount
