@tool
extends Node


var collision_layer_values : Dictionary = {}
var collision_layer_bits : Dictionary = {}


func _ready():
	# Loop through all 32 possible physics layers
	for i in range(1, 33):
		var path = "layer_names/2d_physics/layer_" + str(i)
		if ProjectSettings.has_setting(path):
			var layer_name = ProjectSettings.get_setting(path)
			if layer_name != "":
				collision_layer_bits[layer_name] = (i-1)
				collision_layer_values[layer_name] = 2**(i-1)
	print(collision_layer_bits)
	print(collision_layer_values)


func get_layer_bit(layer_name: String) -> int:
	return collision_layer_bits.get(layer_name, -1)


func get_layer_value(layer_name: String) -> int:
	return collision_layer_values.get(layer_name, -1)


func is_collision_mask_layer_set(node: CollisionObject2D, layer_name: String) -> int:
	return not not node.collision_mask & collision_layer_values[layer_name]
