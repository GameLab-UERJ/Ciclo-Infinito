extends Node
class_name LevelEnemies

## Level waves
@export var level_waves: Array[Wave]
## Interval between creature spawns.
@export_range(1, 60, 1, "suffix:s", "prefer_slider")  var spawn_time: float = 1.0
@export var label_contador: Label

var timer: Timer
var wave_count: float = 0.0
var marker: Marker2D
var inimigos_mortos: int = 0
var total_inimigos: int = 0
var creature: BaseEnemy
var new_creature_location: float = 0.0
var old_creature_location: float = 0.0

@onready var markers: Node = $Markers


func _ready() -> void:
	_iniciate_level_waves()
	_atualizar_label()
	
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(spawn_time)


func _on_timer_timeout() -> void:
	# spawn creature
	creature = level_waves[wave_count].wave_creature_spawn()
	
	if creature == null:
		return
	
	creature.defeated.connect(_on_inimigo_derrotado)
	add_child(creature)
	
	# choose creature location
	marker = markers.get_child(marker_selection())
	creature.global_position = marker.global_position


func wave_change() -> void:
	if wave_count < level_waves.size():
		wave_count += 1
		level_waves[wave_count].wave_end.connect(wave_change)
	else:
		timer.stop()


func marker_selection() -> float:
	while new_creature_location == old_creature_location:
		new_creature_location = randi_range(0, markers.get_child_count() - 1)
	
	old_creature_location = new_creature_location
	
	return float(new_creature_location)


func _iniciate_level_waves() -> void:
	for i in level_waves:
		i.iniciate_wave()
		total_inimigos += i.wave_size


func _on_inimigo_derrotado() -> void:
	inimigos_mortos += 1
	
	if inimigos_mortos == total_inimigos:
		get_parent().proxima_missao()
	
	_atualizar_label()


## Ser movido para UI scene
func _atualizar_label() -> void:
	if label_contador != null:
		if total_inimigos == 0:
			label_contador.text = "Inimigos mortos: N/A" 
		else:
			label_contador.text = "Inimigos mortos: %s / %s" % [inimigos_mortos, total_inimigos]
