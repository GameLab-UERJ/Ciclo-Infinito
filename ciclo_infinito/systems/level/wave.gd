extends Resource
class_name Wave

signal wave_end

## Defines the wave difficulty.
## [br]Example:
## [br]creature_amount = creature_amount + wave_difficulty
@export_range(1, 10, 1, "prefer_slider")  var wave_difficulty: float = 1.0
## List of creatures to spawn.
@export var wave_creatures: Array[WaveCreatures] = []

var creatures_amounts: Array[float]
var wave_size: float = 0.0
var creature_chosen: float
var random_number: RandomNumberGenerator = RandomNumberGenerator.new()


func wave_creature_spawn() -> BaseEnemy:
	if wave_size < 1:
		wave_end.emit()
		return
		
	## Select Creature to Spawn
	while true:
		creature_chosen = random_number.randi_range(0, wave_creatures.size() - 1)
		
		if creatures_amounts[creature_chosen] < 1:
			continue
		else:
			break
	
	creatures_amounts[creature_chosen] -= 1.0
	wave_size -= 1.0
	return wave_creatures[creature_chosen].creature_scene.instantiate()


func iniciate_wave(level_enemies_seed: int) -> void:
	creatures_amounts = []
	
	if level_enemies_seed != 1:
		random_number.seed = level_enemies_seed
	else:
		random_number.randomize()
	
	for i in wave_creatures:
		creatures_amounts.append(i.creature_amount + wave_difficulty)
		wave_size += i.creature_amount + wave_difficulty
