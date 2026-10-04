extends Node
class_name LevelEnemiesSpawn

@export var level_waves: LevelWaves
@export var label_contador: Label

var timer: Timer
var marker: Marker2D
var creature: BaseEnemy
var new_creature_location: int = 0
var old_creature_location: int = 0
var wave_count: float = 0.0
var pause: bool = false
var inimigos_spawend: float = 0.0

@onready var markers: Node = $Markers
@onready var barreira: Barrier = $"../Barreira"


func _ready() -> void:
	level_waves.iniciate_level_waves()
	level_waves.seed_selection()
	wave_change()
	level_waves.update_inimigos_derrotados.connect(_atualizar_label)
	barreira.finished_opening.connect(add_timer)
	
	_atualizar_label(level_waves.inimigos_mortos, level_waves.total_inimigos) # Mover para UI scene


func add_timer() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(level_waves.spawn_time)


func _on_timer_timeout() -> void:
	if pause:
		spawn_pause()
		return
	
	# spawn creature
	creature = level_waves.waves[wave_count - 1].wave_creature_spawn()
	
	if creature == null:
		return
	
	creature.defeated.connect(level_waves.inimigos_derrotados)
	add_child(creature)
	# choose creature location
	creature.global_position = marker_selection().global_position


func spawn_pause() -> void:
	if level_waves.inimigos_mortos == inimigos_spawend:
		wave_change()
		pause = false
	else:
		pause = true


func wave_change() -> void:
	if wave_count < level_waves.waves.size():
		level_waves.waves[wave_count].wave_end.connect(spawn_pause)
		inimigos_spawend += level_waves.waves[wave_count].wave_size
		wave_count += 1
	else:
		timer.stop()


func marker_selection() -> Node:
	while new_creature_location == old_creature_location:
		new_creature_location = level_waves.random_number.randi_range(0, markers.get_child_count() - 1)
	
	old_creature_location = new_creature_location
	
	return markers.get_child(new_creature_location)


# Ser movido para UI scene
func _atualizar_label(inimigos_derrotados: float, total_inimigos: float) -> void:
	if label_contador != null:
		if total_inimigos == 0:
			label_contador.text = "Inimigos mortos: N/A" 
		else:
			label_contador.text = "Inimigos mortos: %d / %d" % [inimigos_derrotados, total_inimigos]
			
	if inimigos_derrotados == total_inimigos:
		get_parent().proxima_missao()
