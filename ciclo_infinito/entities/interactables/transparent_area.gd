extends Area2D
class_name BehindTileArea

var tile : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_parent() is TileMapLayer:
		push_error("Parent has to be TileMapLayer")
	tile = get_parent()
	collision_mask = 2 #Player Layer
	body_entered.connect(_on_behind_tile_area_body_entered)
	body_exited.connect(_on_behind_tile_area_body_exited)

func _on_behind_tile_area_body_entered(_body: Node2D) -> void:
	tile.modulate = 0xffffff3f


func _on_behind_tile_area_body_exited(_body: Node2D) -> void:
	tile.modulate = 0xffffffff
