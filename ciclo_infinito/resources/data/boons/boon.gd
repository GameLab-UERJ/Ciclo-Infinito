extends Resource
class_name Boon


enum AffectedSkill {PASSIVE, ATTACK1, ATTACK2, DASH, DASH_ATTACK, RANGED, ULTIMATE}


@export var name : String
@export var description : String
@export var sage : Sage
@export var affected_skill : Array[AffectedSkill]
@export var common_modifier : AttributeModifier
@export var uncommon_modifier : AttributeModifier
@export var rare_modifier : AttributeModifier
@export var legendary_modifier : AttributeModifier
