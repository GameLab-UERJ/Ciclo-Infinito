extends Node
@onready var enemies: Label = $"../player/enemies"


@export var label_contador: Label

var inimigos_mortos: int = 0

var total_inimigos: int = 0

func _ready() -> void:
	total_inimigos = get_child_count()
	
	print("Nível iniciado com ", total_inimigos, " inimigos.")

	
	_atualizar_label()

	if total_inimigos == 0:
		print("Aviso: Nenhum inimigo encontrado como filho.")
		if label_contador:
			label_contador.text = "Inimigos mortos: N/A" 
		#vitoria()
		return

	for inimigo in get_children():
		if not inimigo.has_signal("golem_defeated"):
			print("Erro: O nó ", inimigo.name, " não tem o sinal 'golem_defeated'!")
			total_inimigos -= 1
		else:
			inimigo.golem_defeated.connect(_on_inimigo_derrotado)
			

	_atualizar_label() 
	
	set_process(false)

func _on_inimigo_derrotado() -> void:
	inimigos_mortos += 1
	print("Um inimigo morreu! Contagem: ", inimigos_mortos, " / ", total_inimigos)
	if inimigos_mortos == total_inimigos:
		get_parent().proxima_missao()
	
	_atualizar_label()
	



func _atualizar_label() -> void:
	if label_contador != null:
		label_contador.text = "Inimigos mortos: %s / %s" % [inimigos_mortos, total_inimigos]
		
func vitoria() -> void:
	print("🎉 Vitória! Todos os inimigos foram derrotados!")
	get_tree().change_scene_to_file("res://scene/vitoria.tscn")
