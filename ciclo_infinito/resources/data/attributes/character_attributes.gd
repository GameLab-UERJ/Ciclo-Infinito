extends Resource
class_name CharacterAttributes


@export var strength: float = 10.0
@export var magic: float = 0.0
@export var resistance: float = 0.0
@export var vitality: float = 25.0


func duplicate_attributes() -> CharacterAttributes:
	var copy = CharacterAttributes.new()
	copy.strength = strength
	copy.magic = magic
	copy.resistance = resistance
	copy.vitality = vitality
	return copy


func apply_modifier(mod: AttributeModifier) -> void:
	if mod == null:
		return
	
	# Suporta tanto 'resistence' quanto 'resistance' no resource mod
	var mod_res = mod.get("resistance") if "resistance" in mod else (mod.get("resistence") if "resistence" in mod else 0)
	
	if mod.type == AttributeModifier.Type.ADDEND:
		#print('addend')
		strength += mod.strength
		magic += mod.magic
		resistance += mod_res
		vitality += mod.vitality
	elif mod.type == AttributeModifier.Type.MULTIPLIER:
		#print('multiplier')
		@warning_ignore("incompatible_ternary")
		strength *= mod.strength if mod.strength != 0 else 1.0
		@warning_ignore("incompatible_ternary")
		magic *= mod.magic if mod.magic != 0 else 1.0
		resistance *= mod_res if mod_res != 0 else 1.0
		@warning_ignore("incompatible_ternary")
		vitality *= mod.vitality if mod.vitality != 0 else 1.0


func reset_to(other: CharacterAttributes) -> void:
	if other == null:
		return
	strength = other.strength
	magic = other.magic
	resistance = other.resistance
	vitality = other.vitality
