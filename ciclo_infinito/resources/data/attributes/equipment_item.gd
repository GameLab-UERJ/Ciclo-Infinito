extends Resource
class_name EquipmentItem


enum Slot {HELMET, ARMOR, GAUNTLETS, PANTS, ACCESSORY}
enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

@export var name: String = ""
@export var description: String = ""
@export var slot: Slot = Slot.HELMET
@export var rarity: Rarity = Rarity.COMMON
@export var modifier: AttributeModifier
