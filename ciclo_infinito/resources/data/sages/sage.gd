extends Resource
class_name Sage


@export var name : String
@export var description : String
@export var splash : Texture2D
@export var boons_path : String


var boons : Array[Boon] = [] : get = _get_boons


func _set_boons_path(value : String) -> void:
	boons_path = value
	_get_boons() 


func _get_boons() -> Array[Boon]:
	if not boons.is_empty():
		return boons
	
	var boon_files : PackedStringArray = DirAccess.get_files_at(boons_path)
	for file_name in boon_files:
		boons.append(ResourceLoader.load(boons_path + file_name))
	return boons
