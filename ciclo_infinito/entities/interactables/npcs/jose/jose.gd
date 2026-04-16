class_name Jose
extends StaticBody2D

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interação: Label = $Area2D/LabelInteração

signal dialog_started
signal dialog_finished
signal falou_com_jose
var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0

var falas = ["Ora, seja bem-vindo à UERJ! Então você é o novo calouro de Engenharia, não é?
", 
"Pois prepare-se, o quinto andar será praticamente sua segunda casa durante esse ciclo",
"É lá que tudo acontece — aulas, projetos, noites viradas e muita cafeína!",
"Ah, e se encontrar o Pedro, o veterano, fale com ele.
Ele vai te orientar sobre os primeiros passos e talvez até te dar umas boas dicas de sobrevivência por aqui" 
]

func _ready() -> void:
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interação.visible = false


func _process(_delta) -> void:
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
		
	elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		proxima_fala()


func iniciar_dialogo():
	print("NPC: emitindo dialog_started")
	emit_signal("dialog_started")
	falando = true
	label_interação.visible = false
	caixa_de_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	proxima_fala()


func proxima_fala():
	if fala_index < falas.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas[fala_index]
		fala_index += 1
		mostrar_texto_com_efeito(texto)
	else:
		encerrar_dialogo()


func mostrar_texto_com_efeito(texto: String):
	await get_tree().create_timer(0.1).timeout
	for letra in texto:
		texto_dialogo.text += letra
		await get_tree().create_timer(0.02).timeout
	pode_avancar = true


func encerrar_dialogo():
	print("NPC: emitindo dialog_finished")
	falando = false
	pode_avancar = false
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	emit_signal("falou_com_jose")
	emit_signal("dialog_finished")
	var terrain_manager = get_tree().get_current_scene()
	terrain_manager.atualizar_missao("Missão: \\nEntre no elevador \\ne suba até o 5° andar.")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = true
		label_interação.text = "Pressione 'E' para interagir"
		label_interação.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = false
		label_interação.visible = false
		if falando:
			encerrar_dialogo()
		
