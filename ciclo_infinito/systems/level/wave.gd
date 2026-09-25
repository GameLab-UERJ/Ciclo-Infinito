extends Resource
class_name Wave

signal wave_end

## List of creatures to spawn
@export var wave_creatures: Array[CreatureSpawn] = []
## Number of wave repetitions.
@export_range(1, 10, 1, "prefer_slider") var wave_repeats: float = 1.0

var creatures_amounts: Array[float]
var wave_size: float
var creature_chosen: float
var creature: BaseEnemy


func wave_creature_spawn() -> BaseEnemy:
	if wave_size < 1:
		wave_repeats -= 1
		
		if wave_repeats:
			wave_start()
		else:
			wave_end.emit()
			return
	
	while true:
		creature_chosen = randi_range(0, wave_creatures.size())
		
		if wave_creatures[creature_chosen].creature_amount < 1:
			continue
		else:
			break
	
	creature = wave_creatures[creature_chosen].creature_scene.instantiate()
	creatures_amounts[creature_chosen] -= 1
	wave_size -= 1
	return creature

func wave_start() -> void:
	creatures_amounts = []
	
	for i in wave_creatures:
		creatures_amounts.append(i.creature_amount)
		wave_size += i.creature_amount
