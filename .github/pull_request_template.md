# Descrição da Mudança

*[Explique brevemente o que este Pull Request faz. O que foi adicionado, alterado ou consertado?]*

## Tipo de PR

- [ ] Bugfix (Correção de erro)
- [ ] Feature (Nova mecânica/funcionalidade)
- [ ] Cena/Nodes (Ajuste na hierarquia da cena `.tscn`)
- [ ] Assets (Sprites, Áudio, Recursos `.tres`)
- [ ] Refatoração (Melhoria de GDScript)

## Screenshots ou Vídeos (Obrigatório para mecânicas/visuais)

*[Se o seu PR altera a UI, visuais ou mecânicas jogáveis, anexe um GIF, vídeo curto ou print da tela rodando na engine. Ajuda muito quem for revisar!]*

## Checklist Específico - Godot Engine

Para evitar conflitos na engine e referências quebradas, verifique:

- [ ] **Erros e Warnings:** O jogo roda sem estourar erros vermelhos ou avisos amarelos (warnings) novos na aba Debugger/Output da Godot.
- [ ] **Caminhos de Arquivos:** Se eu movi ou renomeei algum arquivo/asset, fiz isso *por dentro do FileSystem da Godot* para não quebrar dependências (UIDs).
- [ ] **Configurações do Projeto:** Não há alterações acidentais no arquivo `project.godot` (como novos Inputs ou Autoloads) misturadas neste PR, ou, se houver, elas são intencionais e avisadas.
- [ ] **Sinais (Signals):** Se criei novos Signals pela interface gráfica (Editor), os métodos conectados existem no script e não causarão erro de "Method not found".
- [ ] **Variáveis Exportadas:** Variáveis `@export` possuem valores padrão (default) lógicos na cena.

## Checklist do Desenvolvedor

- [ ] Testei a feature jogando a cena e o jogo não está crashando.
- [ ] Não estou comitando a pasta `.godot/` (garantido pelo `.gitignore`).
- [ ] Meu código segue o padrão de nomenclatura (ex: `snake_case` para variáveis/funções, `PascalCase` para Classes/Nós).

## Issues Relacionadas

*[Se este PR fecha uma tarefa específica, cite-a aqui. Ex: Closes #12]*
