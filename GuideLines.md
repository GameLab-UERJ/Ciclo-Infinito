# Guia de Projeto

## Introdução

esse arquivo tem como finalidade ser um ponto de consulta rápido durante o processo de desenvolvimento do Ciclo Infinito

Para Feedback e sugestões, entre em contato com os Líderes de Programação do seu Projeto

## Git Commit

### Boas práticas

Para seguirmos um padrão de commit, um template foi disponibilizado abaixo.

Todo commit deve especificar o tipo (detalhado abaixo), escopo (player, level, main_menu...) e um resumo do que foi feito.

O rodapé deve ser usado sempre que o commit finaliza uma issue.

A descrição deve ser usada sempre que o resumo não deixe claro o que o commit muda.

### Tipos de commit

| Tipo     | Quando usar?                                                                |
|----------|-----------------------------------------------------------------------------|
| feat     | Nova funcionalidade (ex: novo poder, novo sistema de diálogo).              |
| fix      | Correção de bugs ou comportamentos inesperados.                             |
| assets   | Adição/alteração de sprites, sons, modelos ou fontes.                       |
| scene    | Alterações específicas em arquivos .tscn (árvore de nós).                   |
| refactor | Mudança no código que não altera o comportamento (limpeza).                 |
| perf     | Melhoria de performance (ex: otimização de shaders ou sinais).              |
| style    | Mudanças de formatação ou guia de estilo (sem lógica alterada).             |
| docs     | Alterações no README, Wiki ou comentários de código.                        |
| chore    | Tarefas de manutenção (ex: atualizar .gitignore ou configurações do Godot). |

### Commit Template

\<tipo>(\<escopo>): <resumo curto em minúsculas>

[corpo opcional: descrição mais detalhada do que foi feito e por quê]

[rodapé opcional: links para issues ou avisos de mudanças que quebram o código]

## Git Branch

### Boas práticas

Nós juntaremos os trabalhos feitos por cada um por meio de Pull Requests (PRs). Para seguirmos um padrão de PR, um template foi disponibilizado abaixo.

Lembre-se de manter sua branch atualizada com a master branch.

### Nomenclatura da branch



### PR Template

```
# :notebook_with_decorative_cover: Descrição Geral
>Relacionado a: # (Link da issue/task)

descreva de forma geral

# :open_file_folder: Alterações de Arquivos
  
>Marque com :heavy_check_mark: ou :x:

[ ] Lógica (.gd): Scripts alterados/adicionados.

[ ] Cenas (.tscn): Mudanças na árvore de nós ou herança.

[ ] Recursos (.tres / .res): Novos materiais, temas ou configurações.

[ ] Assets: Sprites, áudios ou modelos.

# :gear: Checklist Técnico
[ ] Estilo de Código: As alterações seguem rigorosamente o Guia de Estilo do Projeto.

[ ] Sinais e Memória: Garanti que sinais desconectam corretamente ou não criam referências cíclicas que impedem o free().

[ ] Export Vars: Variáveis @export estão organizadas e com nomes legíveis e descrição para os designers no Inspector.

# :globe_with_meridians: Compatibilidade (Web & Desktop)
[ ] Testado no Editor (Desktop).

[ ] Testado via Web Export (ou verificado se utiliza funções não suportadas em HTML5, como Threads específicas ou shaders complexos).
```

## Formatting
Formatação é uma questão com muitas regras, fazendo com que esse bloco ficaria muito extenso para cobrir todas as regras.  
Como GDscript é inspirado em python, seu style guide também é inspirado no PEP 8, então será apontado apenas as principais regras.

- use tabs e não spaces para identação
- a identação deve ser sempre de 1 nível do bloco que o contém.
- Linhas não devem conter mais que 100 characters
- A continuação da linha deve apresentar 2 níveis de identação para destinguir de blocos de código.

## Order
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. doc comment

05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
	1. _init()
	2. _enter_tree()
	3. _ready()
	4. _process()
	5. _physics_process()
	6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. inner classes

>public methods and variables before private ones.

## Naming

| Type         | Convention    | Example                   |
|--------------|---------------|---------------------------|
| File names   | snake_case    | yaml_parser.gd            |
| Class names  | PascalCase    | class_name YAMLParser     |
| Node names   | PascalCase    | Camera3D, Player          |
| Functions    | snake_case    | func load_level():        |
| Variables    | snake_case    | var particle_effect       |
| Signals      | snake_case    | signal door_opened        |
| Constants    | CONSTANT_CASE | const MAX_SPEED = 200     |
| Enum names   | PascalCase    | enum Element              |
| Enum members | CONSTANT_CASE | {EARTH, WATER, AIR, FIRE} |

>Prepend a single underscore (_) to virtual methods functions the user must override, private functions, and private variables. ex: `func _load_file()`

## Tipagem

### Declared types
To declare a variable's type, use "\<variable\>: \<type>".

`var health: int = 0`

To declare the return type of a function, use "-> \<type>":

`func heal(amount: int) -> void:`

## Estrutura de arquivos
Seguindo conceitos de projetos de software, os arquivos não serão divididos pelo seu tipo (.gd, .tscn, .tres) e sim por funcionalidade/escopo.

Seguiremos a seguintes estrutura:

```
project/
├── entities/
│   ├── enemies/
|   |   └── golem/
|   |       ├── golem.gd
|   |       └── golem.tscn
│   └── player/
├── levels/
│   ├── dungeons/
│   ├── world/
|   └── shared/
├── menus/
│   ├── pause/
│   ├── main/
│   └── shared/ (theme, buttons_style, buttons_actions)
├── systems/
│   ├── health_system/
│   └── level_system/
├── assets/
│   ├── sfx/
│   ├── art/
│   └── music/
├── resources/ (TBD)
└── project.godot
```

# Referências
[Style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#gdscript-style-guide)  
[Conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)