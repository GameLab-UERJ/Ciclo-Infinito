extends Area2D

@export var target_scene: PackedScene
var talk_jose = false
@onready var label_interação: Label = $LabelInteração
@onready var npc = get_node("../NPC3")
var player_in_area = false

func _falar_jose() ->void:
	talk_jose=true

func _ready() -> void:
	label_interação.visible = false
	if npc:
		npc.falou_com_jose.connect(_falar_jose)

func _process(delta) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		mudar_de_cena()

func mudar_de_cena():
	if target_scene == null:
		print("ERRO: A cena de destino (Target Scene) não foi definida no inspetor!")
		return
	var terrain_manager = get_tree().get_current_scene()
	terrain_manager.atualizar_missao("Missão: \nFale com o Pedro.")
	get_tree().change_scene_to_packed(target_scene)

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
