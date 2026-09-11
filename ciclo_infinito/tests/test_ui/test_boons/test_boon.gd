extends Control


@export var sage : Sage


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
	var chosen_boons : Array[Boon] = Util.get_random_sample(sage.boons,3)
	boon_1.text = chosen_boons[0].name
	boon_2.text = chosen_boons[1].name
	boon_3.text = chosen_boons[2].name
	#await create_tween().tween_property(boons_panel,"modulate",Color.WHITE,1.0).finished
	await create_tween().tween_property(boon_1,"self_modulate",Color.WHITE,0.5).finished
	await create_tween().tween_property(boon_2,"self_modulate",Color.WHITE,0.5).finished
	await create_tween().tween_property(boon_3,"self_modulate",Color.WHITE,0.5).finished
