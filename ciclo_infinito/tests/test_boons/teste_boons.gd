extends Node2D


var teste : float = 0
var boon_picker : BoonPicker


@onready var player: Player = $Player
@onready var boon_picker_layer: CanvasLayer = $CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.camera.zoom = Vector2.ONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	teste = lerp(teste,100.0,0.15)


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		if boon_picker:
			return
		boon_picker = load("res://menus/boons/boon_picker.tscn").instantiate()
		boon_picker.debug = true
		boon_picker.guaranteed_boons = [load("res://resources/data/boons/marie_curie/radioactive_strike.tres")]
		boon_picker.guaranteed_boons.append(load("res://resources/data/boons/marie_curie/radium_blade.tres"))
		boon_picker.boon_picked.connect(_on_boon_picked)
		boon_picker_layer.add_child(boon_picker)


func _on_boon_picked(boon : Boon, rarity : String) -> void:
	player.progression.add_boon(boon,rarity)
	boon_picker.queue_free()
