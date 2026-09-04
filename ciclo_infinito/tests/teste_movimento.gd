extends Node2D

var teste : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.camera.zoom = Vector2.ONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	teste = lerp(teste,100.0,0.15)
