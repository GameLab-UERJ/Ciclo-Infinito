extends Control
class_name BoonPicker


const COMMON_COLOR = Color.WHITE_SMOKE
const UNCOMMON_COLOR = Color.PALE_GREEN
const RARE_COLOR = Color.STEEL_BLUE
const LEGENDARY_COLOR = Color.DARK_GOLDENROD


signal boon_picked(boon : Boon, rarity : String)


@export var sage : Sage
@export_range(0,100,0.5) var common_chance : float		= 40
@export_range(0,100,0.5) var uncommon_chance : float	= 30
@export_range(0,100,0.5) var rare_chance : float		= 20
@export_range(0,100,0.5) var legendary_chance : float 	= 10

var chosen_boons : Array[Boon]
var chosen_rarity : Array[String]


@onready var boon_buttons_parent: VBoxContainer = $BoonsPanel/MarginContainer/VBoxContainer
@onready var splash_art: TextureRect = %SplashArt
@onready var boons_panel: PanelContainer = %BoonsPanel
@onready var boon_1: Button = %Boon1
@onready var boon_2: Button = %Boon2
@onready var boon_3: Button = %Boon3



func _ready() -> void:
	await _animate_splash_art()
	await _set_boons()


func _animate_splash_art() -> void:
	splash_art.texture = sage.splash
	await create_tween().tween_property(splash_art,"self_modulate",Color.WHITE,1.0).finished
	await get_tree().create_timer(1.0).timeout
	await create_tween().tween_property(splash_art,"position",Vector2.ZERO,1.0).finished


func _set_boons() -> void:
	chosen_boons = Util.get_random_sample(sage.boons,3)
	for i in 3:
		chosen_rarity.append(Util.choice(['common','uncommon','rare','legendary'],[common_chance, uncommon_chance, rare_chance, legendary_chance]))
	
	for i in len(chosen_boons):
		await _enable_boon(boon_buttons_parent.get_child(i),i)


func _enable_boon(boon_button : Button, boon_number : int) -> void:
	boon_button.text = chosen_boons[boon_number].name
	match chosen_rarity[boon_number]:
		'common':
			boon_button.get_theme_stylebox("normal").border_color = COMMON_COLOR
		'uncommon':
			boon_button.get_theme_stylebox("normal").border_color = UNCOMMON_COLOR
		'rare':
			boon_button.get_theme_stylebox("normal").border_color = RARE_COLOR
		'legendary':
			boon_button.get_theme_stylebox("normal").border_color = LEGENDARY_COLOR
	await create_tween().tween_property(boon_button,"self_modulate",Color.WHITE,0.5).finished
	boon_button.disabled = false


func _disable_boon(boon_button : Button) -> void:
	boon_button.text = ''
	boon_button.disabled = true


func pick_boon(position : int) -> Boon:
	if position < 0 or position >= len(chosen_boons):
		push_error("Out of range for pick_boon in "+str(self))
		return null
	boon_picked.emit(chosen_boons[position],chosen_rarity[position])
	return chosen_boons[position]


func _on_boon_1_pressed() -> void:
	pick_boon(0)


func _on_boon_2_pressed() -> void:
	pick_boon(1)


func _on_boon_3_pressed() -> void:
	pick_boon(2)
