# Padrão de Documentação de @exports

Regras básicas para documentar variáveis exportadas no Inspector do Godot 4.

## Regra Básica

Use `##` logo acima da variável.
A primeira linha é o resumo (aparece ao passar o mouse). O resto é a descrição detalhada (aparece ao clicar na variável).

**Nunca quebre a primeira linha.** Escreva o resumo em uma frase só.

## Formatação útil

Dentro do `##`, você pode usar essas tags BBCode para organizar o texto no Inspector:

* `[br]` -> Pula linha.
* `[b]texto[/b]` -> Deixa em **negrito**.
* `[i]texto[/i]` -> Deixa em *itálico*.
* `[code]texto[/code]` -> Destaca como `código`.

---

## Exemplos por Tipo

### Números
Sempre coloque a unidade (segundos, pixels, etc.) e o que acontece se o valor for pro extremo.

```gdscript
## Velocidade máxima de corrida.
## [br]
## [b]Unidade:[/b] Pixels por segundo.
## [b]Aviso:[/b] Passar de 600 faz o personagem atravessar paredes finas.
@export_range(100.0, 800.0, 50.0)
var velocidade_corrida: float = 300.0
```

### Recursos (Resources)
Deixe claro qual arquivo arrastar pra lá e o que acontece se ficar vazio.

```gdscript
## Dados de vida e dano do inimigo.
## [br]
## [b]Formato:[/b] Arraste um [InimigoStats] aqui.
## [b]Se vazio:[/b] O inimigo usa 100 de vida e 10 de dano.
@export var stats: InimigoStats
```

### Enums / Flags
Explique o que cada opção significa na prática, pois o nome do enum costuma ser curto.

```gdscript
## O que a IA faz quando perde o jogador de vista.
## [br]
## [code]VOLTAR[/code]: Volta para o ponto de patrulha.
## [code]BUSCAR[/code]: Vai até o último lugar onde viu o jogador.
@export var comportamento_perda: ComportamentoIA = ComportamentoIA.VOLTAR
```

### NodePath
Diga exatamente que tipo de nó deve ser arrastado.

```gdscript
## Ponto de saída dos projéteis.
## [br]
## [b]Esperado:[/b] Um [Marker2D] filho deste personagem.
@export var spawn_projeteis: NodePath
```

---

## Organização (Categorias)

Caso existam exports para diferentes fins, você pode usar categorias para separar os assuntos no Inspector. Isso facilita a visualização.

```gdscript
@export_category("Movimento")

	## Velocidade ao andar.
	@export var velocidade: float = 200.0
	
	## Força do pulo.
	@export_range(-1000.0, -100.0)
	var forca_pulo: float = -450.0

@export_subgroup("Gravidade")

	## Multiplicador de queda.
	@export_range(1.0, 5.0, 0.5)
	var multiplicador_queda: float = 2.0

@export_category("Combate")

	## Vida máxima.
	@export_range(1, 999)
	var vida_maxima: int = 100

@export_category("") # Reseta o agrupamento
```

---

## O que fazer e o que evitar

**Faça:**
* Fale o impacto da variável no jogo.
* Declare o tipo sempre (`: float`, `: int`).
* Deixe um valor padrão que funcione caso ninguém mexa nela.

**Evite:**
* Repetir o nome da variável. (Ex: `## Vida: A vida do personagem`).
* Explicar como foi feito no código (Ex: `## Usa lerp com delta`).
* Escrever um resumo gigante na primeira linha.

---

## Templates

### Template Genérico (Para qualquer variável)
```gdscript
## [Resumo curto do que é].
## [br]
## [b]Detalhes:[/b] [Como isso afeta o jogo ou o sistema].
@export var nome_variavel: Tipo = valor_padrao
```

### Template para Números (Float / Int)
```gdscript
## [Resumo curto do que é].
## [br]
## [b]Unidade:[/b] [Pixels, segundos, pontos, etc].
## [b]Aviso:[/b] [O que acontece se o valor for muito alto/baixo].
@export_range([valor_min], [valor_max], [passo])
var nome_variavel: float = [valor_padrao]
```

### Template para Recursos (Resources)
```gdscript
## [Resumo curto do que é].
## [br]
## [b]Formato:[/b] Arraste um recurso do tipo [NomeDoResource] aqui.
## [b]Se vazio:[/b] [O que o código faz comoallbackup].
@export var nome_variavel: NomeDoResource
```

### Template para Enums / Flags
```gdscript
## [Resumo curto do que é].
## [br]
## [code]OPCAO_1[/code]: [O que essa opção faz na prática].
## [code]OPCAO_2[/code]: [O que essa opção faz na prática].
@export var nome_variavel: NomeDoEnum = NomeDoEnum.OPCAO_PADRAO
```

### Template para NodePaths
```gdscript
## [Resumo curto do que é].
## [br]
## [b]Esperado:[/b] Um nó do tipo [TipoDeNode] filho deste objeto.
@export var nome_variavel: NodePath
```

---

**Fontes:** 
* [GDScript documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)
* [GDScript exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)
