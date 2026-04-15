class_name Lift
extends Area2D


var talk_jose = false
var player_in_area = false


@onready var label_interação: Label = $LabelInteração
@onready var npc = get_node("../NPC3")
@onready var cheese_hall: Node2D = $".."


func _falar_jose() ->void:
	talk_jose=true

func _ready() -> void:
	label_interação.visible = false
	if npc:
		npc.falou_com_jose.connect(_falar_jose)

func _process(_delta) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		cheese_hall.mudar_de_cena()

func _on_body_entered(body: Node2D) -> void:
	print("---ALGO ENTROU NO ELEVADOR!---")
	print("Nome do corpo detectado: ", body.name)
	
	if body.is_in_group("player") and talk_jose: 
		print("... e é o jogador!")
		player_in_area = true
		label_interação.text = "Pressione 'E' para usar"
		label_interação.visible = true
	else:
		print("... mas NÃO é o jogador. Grupo do corpo: ", body.get_groups())

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		label_interação.visible = false
