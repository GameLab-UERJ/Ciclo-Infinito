extends Resource
class_name Boon


enum AffectedSkill {PASSIVE, ATTACK, DASH, DASH_ATTACK, RANGED, SPECIAL}
enum StatusName {RADIATION, DECAY}


@export var name : String
@export var description : String
@export var sage : Sage
@export var affected_skill : Array[AffectedSkill]
@export var applied_statuses : Array[StatusName]
@export var common_modifier : AttributeModifier
@export var uncommon_modifier : AttributeModifier
@export var rare_modifier : AttributeModifier
@export var legendary_modifier : AttributeModifier


func apply_statuses_to(	body : CharacterBody2D, 
						creator : Node = null,
						duration : float = 5,
						level : int = 1,
						) -> void:
	if applied_statuses.is_empty():
		return
	
	var status : Status
	var affecting : String
	
	for status_name in applied_statuses:
		status = get_status_scene(status_name)
		if creator:
			if not creator is Player:
				affecting = "Player"
			else:
				affecting = "Enemy"
		status.init(creator, affecting, duration, level)
		#print(status.name)
		var aux = body.get_node_or_null(""+status.name)
		#print("aux: ",aux)
		if aux:
			aux.level += 1
		else:
			body.call_deferred("add_child",status)


func get_status_scene(status_name : StatusName) -> Status:
	match status_name:
		StatusName.RADIATION:
			return load("uid://cl836qfutxtxw").instantiate()
		StatusName.DECAY:
			return load("uid://j4ehnh8camj8").instantiate()
	push_error("status_name: ",status_name, " not known to Boon.get_status_scene")
	return null
