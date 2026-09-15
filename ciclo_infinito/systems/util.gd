@tool
extends Node

var collision_layer_values : Dictionary = {}
var collision_layer_bits : Dictionary = {}


func _ready():
	for i in range(1, 33):
		var path = "layer_names/2d_physics/layer_" + str(i)
		if ProjectSettings.has_setting(path):
			var layer_name = ProjectSettings.get_setting(path)
			if layer_name != "":
				collision_layer_bits[layer_name] = (i-1)
				collision_layer_values[layer_name] = 2**(i-1)
	#print(collision_layer_bits)
	#print(collision_layer_values)


func get_layer_bit(layer_name: String) -> int:
	return collision_layer_bits.get(layer_name, -1)


func get_layer_value(layer_name: String) -> int:
	return collision_layer_values.get(layer_name, -1)


func is_collision_mask_layer_set(node: CollisionObject2D, layer_name: String) -> int:
	return not not node.collision_mask & collision_layer_values[layer_name]

#region randomness

func sum(array : Variant) -> float:
	var result : float = 0
	for value in array:
		result += value
	return result


func get_random_sample(source_array: Array, sample_size: int) -> Array:
	sample_size = min(sample_size, source_array.size())
	
	var temp_array = source_array.duplicate()
	temp_array.shuffle()
	
	return temp_array.slice(0, sample_size)


## Choses one from 'choices' according to 'chances'. If they do not have the 
## same size or the total in 'choices' do not amount to 100, picks on from 
## 'choices' at random.  
func choice(choices : Array, chances : Array = []) -> Variant:
	if len(choices) != len(chances) or abs(sum(chances) - 100) > 0.0001:
		return Util.get_random_sample(choices,1)[0]
	
	var aux : float = randf_range(0,100)
	
	var acumulated_chance : float = 0
	for i in len(chances):
		if aux <= acumulated_chance + chances[i]:
			return choices[i]
		acumulated_chance += chances[i]
	
	push_error("choice() did not chose something valid for some unknown reason") 
	return Util.get_random_sample(choices,1)[0]

#endregion randomness
