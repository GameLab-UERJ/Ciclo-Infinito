extends Node2D

# Caminho para a sua cena de vitória. Crie uma se ainda não tiver.
@export var victory_scene_path: String = "res://caminho/para/sua/cena_de_vitoria.tscn"

# Você pode arrastar o nó da mensagem de vitória aqui pelo editor
@export var victory_message_node: CanvasLayer = null

var total_enemies: int = 0
var enemies_defeated: int = 0

func _ready() -> void:
	# Esconde a mensagem de vitória no início, se ela existir
	if victory_message_node:
		victory_message_node.hide()

	# Atrasar a contagem por um frame para garantir que todos os inimigos foram carregados
	await get_tree().create_timer(0.01).timeout
	
	# Encontra todos os nós no grupo "enemies"
	var enemies = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemies.size()
	
	print("Nível iniciado com ", total_enemies, " inimigos.")

	# Se não houver inimigos, não faz nada.
	if total_enemies == 0:
		return

	# Conecta o sinal de cada inimigo a uma função neste script
	for enemy in enemies:
		if not enemy.golem_defeated.is_connected(_on_golem_defeated):
			enemy.golem_defeated.connect(_on_golem_defeated)

# Esta função será chamada toda vez que um golem emitir o sinal "golem_defeated"
func _on_golem_defeated() -> void:
	enemies_defeated += 1
	print("Inimigo derrotado! Faltam ", total_enemies - enemies_defeated)

	if enemies_defeated >= total_enemies:
		win_game()

func win_game() -> void:
	print("TODOS OS INIMIGOS FORAM DERROTADOS! VOCÊ VENCEU!")
	
	# --- ESCOLHA UMA DAS OPÇÕES ABAIXO ---

	# Opção A: Mostrar uma mensagem na tela
	if victory_message_node:
		victory_message_node.show()
		# Opcional: Pausar o jogo
		get_tree().paused = true

	# Opção B: Mudar para uma cena de vitória
	# Descomente a linha abaixo para usar esta opção
	# get_tree().change_scene_to_file(victory_scene_path)
