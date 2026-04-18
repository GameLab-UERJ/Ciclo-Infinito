class_name Dialogo
extends Node

## Módulo responsável por controlar a exibição de diálogos com efeito de digitação.

# ========================
# VARIABLES
# ========================

var caixa: Control
var texto: Label
var skip_label: Label

var falas: Array[String] = []
var indice_atual: int = 0

var escrevendo: bool = false
var pode_avancar: bool = false
var pular: bool = false
var ativo: bool = false


# ========================
# PUBLIC METHODS
# ========================

func iniciar(_falas: Array[String], _caixa: Control, _texto: Label, _skip_label: Label) -> void:
	## Inicia a sequência de diálogo.
	
	if _falas.is_empty():
		return
	
	falas = _falas
	indice_atual = 0
	
	caixa = _caixa
	texto = _texto
	skip_label = _skip_label
	
	ativo = true
	
	caixa.visible = true
	texto.visible = true
	
	_proxima_fala()


func input_interact() -> void:
	## Processa input de avanço ou skip.
	
	if not ativo:
		return
	
	if escrevendo:
		pular = true
	elif pode_avancar:
		_proxima_fala()

func encerrar() -> void:
	ativo = false
	pode_avancar = false
	
	caixa.visible = false
	texto.visible = false
	skip_label.visible = false
	
# ========================
# PRIVATE METHODS
# ========================

func _proxima_fala() -> void:
	if indice_atual >= falas.size():
		encerrar()
		return
	
	var fala: String = falas[indice_atual]
	indice_atual += 1
	
	await _escrever(fala)


func _escrever(conteudo: String) -> void:
	escrevendo = true
	pode_avancar = false
	pular = false
	
	texto.text = ""
	
	skip_label.text = "Pressione 'E' para pular"
	skip_label.visible = true
	
	await get_tree().create_timer(0.1).timeout
	
	for letra in conteudo:
		if pular:
			texto.text = conteudo
			break
		
		texto.text += letra
		await get_tree().create_timer(0.02).timeout
	
	escrevendo = false
	pode_avancar = true
	skip_label.visible = false
