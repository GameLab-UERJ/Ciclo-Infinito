extends StaticBody2D

@onready var caixa_de_dialogo: Label = $Area2D/CanvasLayer/CaixaDeDialogo
@onready var texto_dialogo: Label = $Area2D/CanvasLayer/TextoDialogo
@onready var label_interação: Label = $Area2D/LabelInteração
signal dialogo_concluido
signal falou_com_pedro

var player_in_area: bool = false
var falando: bool = false
var pode_avancar: bool = false
var fala_index: int = 0

var falas = ["Olá, meu chapa. Você infelizmente acabou de entrar em um purgatório da UERJ." , 
"No quinto andar, moram os golems  monstros que guardam os segredos mais sombrios da engenharia.",
"Entre todos os monstros do quinto andar, há um ser místico temido por todos: o Olho da Pressão.
De seu único olhar nasce um feixe que atravessa a alma dos estudantes — símbolo da ansiedade, da cobrança e do medo de falhar.",
"Estou descansando do meu último combate, vença os mosntro restantes depois fale comigo novamente para te dar mais informações"]

func _ready() -> void:
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	label_interação.visible = false

func _process(delta) -> void:
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		proxima_fala()

func iniciar_dialogo():
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
#		if 
		var texto = falas[fala_index]
		fala_index += 1
		mostrar_texto_com_efeito(texto)
	else:
		encerrar_dialogo()

func mostrar_texto_com_efeito(texto: String):
	await get_tree().create_timer(0.1).timeout
	for letra in texto:
		if not falando: # para consertar a fala bugada do pedro quando o jogador sai de perto. O mesmo serve para os demais npcs
			return # o bug acontecia pq msm saindo de perto, o loop anterior continuava acontecendo e atropelava o novo.
		texto_dialogo.text += letra
		await get_tree().create_timer(0.02).timeout
	pode_avancar = true

func encerrar_dialogo():
	falando = false
	pode_avancar = false
	caixa_de_dialogo.visible = false
	texto_dialogo.visible = false
	emit_signal("dialogo_concluido")
	emit_signal("falou_com_pedro")  # Emite sinal para avançar missão

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
