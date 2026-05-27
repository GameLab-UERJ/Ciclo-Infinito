class_name Lift
extends Area2D


var player_in_area = false


@onready var label_interação: Label = $LabelInteração
@onready var cheese_hall : Cheesehall = $".."


func _ready() -> void:
	label_interação.visible = false

func _process(_delta) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		cheese_hall.mudar_de_cena()

func _on_body_entered(body: Node2D) -> void:
	print("---ALGO ENTROU NO ELEVADOR!---")
	print("Nome do corpo detectado: ", body.name)
	
	if body.is_in_group("player") and cheese_hall.jose.player_has_talked_with: 
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
