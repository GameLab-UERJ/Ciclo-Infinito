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
	
	if body.is_in_group("player") and cheese_hall.jose.player_has_talked_with: 
		player_in_area = true
		label_interação.text = "Pressione 'E' para usar"
		label_interação.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		label_interação.visible = false
