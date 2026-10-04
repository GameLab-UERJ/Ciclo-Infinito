extends Resource
class_name LevelWaves

signal update_inimigos_derrotados(inimigos_mortos: float, total_inimigos: float)

## Interval between creature spawns.
@export_range(1, 60, 1, "suffix:s", "prefer_slider")  var spawn_time: float = 1.0
## Seed used to determine enemy spawns and positions.
@export var level_seed: int = 0
## Enemy Waves
@export var waves: Array[Wave]

var inimigos_mortos: float = 0.0
var total_inimigos: float = 0.0
var random_number: RandomNumberGenerator = RandomNumberGenerator.new()


func seed_selection() -> void:
	if level_seed:
		random_number.seed = level_seed
	else:
		random_number.randomize()
	

func iniciate_level_waves() -> void:
	for i in waves:
		i.iniciate_wave(level_seed)
		total_inimigos += i.wave_size


func inimigos_derrotados() -> void:
	inimigos_mortos += 1
	
	update_inimigos_derrotados.emit(inimigos_mortos, total_inimigos)
