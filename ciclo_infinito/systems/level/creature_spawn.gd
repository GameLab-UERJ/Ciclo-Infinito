extends Resource
class_name CreatureSpawn

## Creature to spawn
@export var creature_scene: PackedScene
## Maximum number of creatures to spawn.
@export_range(1, 128, 1, "prefer_slider") var creature_amount: float = 1.0
