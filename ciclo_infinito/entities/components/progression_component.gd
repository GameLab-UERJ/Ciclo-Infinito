extends Node
class_name ProgressionComponent


signal attributes_updated(final_attributes: CharacterAttributes)
signal skill_unlocked(skill_name: String)
signal skill_modified(skill_name: String, key: String, value: Variant)

# Status Base padrao
@export var base_attributes: CharacterAttributes:
	set(value):
		if not value: 
			return
		
		base_attributes = value.duplicate_attributes()
		recalculate_final_attributes()
# Equipamentos, configuraveis via Inspector para testes
@export_group("Equipamentos")
@export var initial_helmet: EquipmentItem
@export var initial_armor: EquipmentItem
@export var initial_gauntlets: EquipmentItem
@export var initial_pants: EquipmentItem
@export var initial_accessory: EquipmentItem

# Lista de modificadores diretos (Resources de AttributeModifier)
@export_group("Modificadores")
@export var modifiers: Array[AttributeModifier] = []

# Slots de Equipamentos
var equipped_items: Dictionary = {
	EquipmentItem.Slot.HELMET: null,
	EquipmentItem.Slot.ARMOR: null,
	EquipmentItem.Slot.GAUNTLETS: null,
	EquipmentItem.Slot.PANTS: null,
	EquipmentItem.Slot.ACCESSORY: null
}

var boons: Array[Boon] = []
var rarities: Array[String] = [] ## Each is a tring os either 'common','uncommon','rare' or 'legendary'
var bonuses : Array[Bonus] = []

var final_attributes: CharacterAttributes: get = get_final_attributes

var skills: Dictionary = {}


const DEFAULT_BASE_ATTRIBUTES = preload("res://resources/data/uriam_base_attributes.tres")


#region built-in functions
func _init() -> void:
	if base_attributes == null:
		base_attributes = DEFAULT_BASE_ATTRIBUTES
	if base_attributes != null:
		final_attributes = base_attributes.duplicate_attributes()
	else:
		final_attributes = CharacterAttributes.new()


func _ready() -> void:
	if initial_helmet:
		equipped_items[EquipmentItem.Slot.HELMET] = initial_helmet
	if initial_armor:
		equipped_items[EquipmentItem.Slot.ARMOR] = initial_armor
	if initial_gauntlets:
		equipped_items[EquipmentItem.Slot.GAUNTLETS] = initial_gauntlets
	if initial_pants:
		equipped_items[EquipmentItem.Slot.PANTS] = initial_pants
	if initial_accessory:
		equipped_items[EquipmentItem.Slot.ACCESSORY] = initial_accessory
	
	recalculate_final_attributes()
#endregion

#region CALCULO DOS ATRIBUTOS: Status Base -> Equipamentos -> Dádivas -> Status Finais
func recalculate_final_attributes() -> CharacterAttributes:
	var result = base_attributes.duplicate_attributes()
	
	#print('result(vit) pre-equips: ',result.vitality)
	# Equipamentos:
	for slot in equipped_items:
		var item: EquipmentItem = equipped_items[slot]
		if item and item.modifier:
			result.apply_modifier(item.modifier)
	
	#print('result(vit) pre-boons: ',result.vitality)
	# Dadivas:
	var boon : Boon 
	var rarity : String	
	for i in len(boons):
		boon = boons[i]
		rarity = rarities[i]
		if boon:
			#print('applied boon(vit): ',boon.common_modifier.vitality)
			# Aplica o modificador correspondente (padrão ou raridade definida)
			match rarity:
				'common':
					result.apply_modifier(boon.common_modifier)
				'uncommon':
					result.apply_modifier(boon.uncommon_modifier)
				'rare':
					result.apply_modifier(boon.rare_modifier)
				'legendary':
					result.apply_modifier(boon.legendary_modifier)
	
	#print('result(vit) pre-mods: ',result.vitality)
	# Modificadores Avulsos / Temporarios:
	for mod in modifiers:
		if mod:
			result.apply_modifier(mod)
			
	final_attributes = result
	attributes_updated.emit(final_attributes)
	#print("[",get_parent().name,"] final_attributes: ",final_attributes.vitality)
	if get_parent() is Player:
		print("final_attributes:")
		print("strength: ",final_attributes.strength)
		print("magic: ",final_attributes.magic)
		print("resistance: ",final_attributes.resistance)
		print("vitality: ",final_attributes.vitality)
	
	return final_attributes


func get_final_attributes() -> CharacterAttributes:
	if final_attributes == null:
		recalculate_final_attributes()
	return final_attributes


func apply_damage_reduction(source : Character, damage_amount : float) -> float:
	damage_amount -= final_attributes.resistance
	if source:
		for bonus : Bonus in bonuses:
			if bonus is BonusAgainstStatus:
				for status_data : StatusData in bonus.statuses:
					if source.has_status(status_data):
						damage_amount -= bonus.attribute_bonus.resistance
	return max(0,damage_amount)
#endregion

#region GERENCIAMENTO DE EQUIPAMENTOS
func equip_item(item: EquipmentItem) -> EquipmentItem:
	if item == null:
		return null
	var old_item = equipped_items.get(item.slot, null)
	equipped_items[item.slot] = item
	recalculate_final_attributes()
	return old_item


func unequip_item(slot: EquipmentItem.Slot) -> EquipmentItem:
	var old_item = equipped_items.get(slot, null)
	equipped_items[slot] = null
	recalculate_final_attributes()
	return old_item
#endregion

#region GERENCIAMENTO DE DADIVAS E MODIFICADORES
func add_boon(boon: Boon, rarity : String = 'common') -> void:
	if boon == null:
		return
	boons.append(boon)
	rarities.append(rarity)
	bonuses += boon.added_bonuses
	print('added ',boon.name.to_upper())
	recalculate_final_attributes()


func add_modifier(mod: AttributeModifier) -> void:
	if mod == null:
		return
	modifiers.append(mod)
	recalculate_final_attributes()


func remove_modifier(mod: AttributeModifier) -> void:
	modifiers.erase(mod)
	recalculate_final_attributes()
#endregion

#region SISTEMA DE HABILIDADES
func register_skill(skill_name: String, skill_data: Dictionary) -> void:
	skills[skill_name] = skill_data
	skill_unlocked.emit(skill_name)


func has_skill(skill_name: String) -> bool:
	return skills.has(skill_name)


func get_skill(skill_name: String) -> Dictionary:
	return skills.get(skill_name, {})


func modify_skill(skill_name: String, key: String, value: Variant) -> void:
	if skills.has(skill_name):
		skills[skill_name][key] = value
		skill_modified.emit(skill_name, key, value)
#endregion
