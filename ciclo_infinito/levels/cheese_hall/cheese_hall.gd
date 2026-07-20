extends Node2D
class_name Cheesehall

@export var target_scene: PackedScene


var indice_missao_atual = 0
var missoes = [
	"Fale com José próximo aos elevadores no Hall do Queijo",
	"Entre no elevador e suba até o 5° andar"
]


@onready var pause_menu = $player/pause
@onready var mission_label = $Hud/TextureRect/Label
@onready var fade_in_component: FadeComponent = $player/FadeInComponent
@onready var jose: CheeseNpc = $Jose
@onready var left: Marker2D = $CameraLimits/Left
@onready var right: Marker2D = $CameraLimits/Right
@onready var top: Marker2D = $CameraLimits/Top
@onready var bottom: Marker2D = $CameraLimits/Bottom
@onready var player: Player = $player

func _ready():
	await get_tree().process_frame
	GameState.fifth_floor_state = GameState.FifthFloorState.FIRST_TALK
	player.set_camera_limits(left,right,bottom,top)
	player.camera.zoom = Vector2.ONE*2
	pause_menu.hide()
	configurar_label()
	atualizar_missao()
	fade_in_component.fade()


func configurar_label():
	mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD
	mission_label.add_theme_font_size_override("font_size", 24)


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()


func _pause_game():
	get_tree().paused = true
	pause_menu.show()


func _resume_game():
	get_tree().paused = false
	pause_menu.hide()


func atualizar_missao():
	if mission_label:
		mission_label.text = missoes[indice_missao_atual]


func proxima_missao():
	if indice_missao_atual < missoes.size() - 1:
		indice_missao_atual += 1
		atualizar_missao()


func mudar_de_cena():
	if target_scene == null:
		print("ERRO: A cena de destino (Target Scene) não foi definida no inspetor!")
	EasyTransition.transition_to_scene(target_scene,1.5,EasyTransition.TransitionAnim.FADE)


func _on_jose_was_talked_to(_npc: CheeseNpc) -> void:
	proxima_missao()
