extends Node2D
@onready var enemies: Label = $"../Player/enemies"


@export var label_contador: Label

var inimigos_mortos: int = 0

var total_inimigos: int = 0

func _ready() -> void:
	total_inimigos = get_child_count()
	
	_atualizar_label()

	if total_inimigos == 0:
		if label_contador:
			label_contador.text = "Inimigos mortos: N/A" 
		return

	for inimigo in get_children():
		if not inimigo.has_signal("defeated"):
			print("Erro: O nó ", inimigo.name, " não tem o sinal 'defeated'!")
			total_inimigos -= 1
		else:
			inimigo.defeated.connect(_on_inimigo_derrotado)
			

	_atualizar_label() 
	
	set_process(false)

func _on_inimigo_derrotado() -> void:
	inimigos_mortos += 1
	if inimigos_mortos == total_inimigos:
		get_parent().proxima_missao()
	
	_atualizar_label()


func _atualizar_label() -> void:
	if label_contador != null:
		label_contador.text = "Inimigos mortos: %s / %s" % [inimigos_mortos, total_inimigos]


func vitoria() -> void:
	get_tree().change_scene_to_file("res://scene/vitoria.tscn")
