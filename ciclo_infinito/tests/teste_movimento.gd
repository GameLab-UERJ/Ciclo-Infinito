extends Node2D


var teste : float = 0


@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.camera.zoom = Vector2.ONE
	player.progression.add_boon(load("res://resources/data/boons/marie_curie/radium_blade.tres"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	teste = lerp(teste,100.0,0.15)


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		var radiation : RadiationStatus = load("res://entities/status/radiation_status.tscn").instantiate()
		radiation.duration = 10
		radiation.level = 1
		radiation.affecting = "Enemy"
		radiation.created_by = $Player
		$BeholderOrange.add_child(radiation)
