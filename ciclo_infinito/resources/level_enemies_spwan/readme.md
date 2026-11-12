# 🎮 Ciclo Infinito — Sistema de Ondas de Inimigos

Sistema de geração de ondas de inimigos desenvolvido na **Godot Engine**, com 
distribuição aleatória de criaturas e configuração baseada em Resources. 
A funcionalidade permite organizar os encontros, controlar a dificuldade e 
tornar cada fase mais dinâmica e desafiadora.

## ✨ Funcionalidades

- **🌊 Sistema de ondas:** 
inicia uma onda após a abertura do corredor e gera a próxima quando todos os 
inimigos da onda anterior são derrotados.
- **👾 Distribuição aleatória:** 
seleciona aleatoriamente os tipos de criaturas disponíveis em cada onda.
- **📍 Posicionamento dinâmico:** 
distribui os inimigos entre os nós `Marker2D` definidos na estrutura `Markers`.
- **⚙️ Configuração por Resources:** 
separa os dados de criaturas, ondas e fases para facilitar a configuração e a 
reutilização.
- **📈 Ajuste de dificuldade:** 
permite aumentar a quantidade de criaturas com base no nível de dificuldade da 
onda.
- **⏱️ Intervalo de surgimento:** 
define o tempo entre o aparecimento de cada criatura.
- **🎲 Reprodutibilidade:** 
utiliza uma semente (`seed`) para manter consistentes os resultados da geração 
de criaturas e suas posições.
- **📊 Acompanhamento de progresso:** 
disponibiliza um sinal para informar a quantidade de inimigos derrotados e o 
total de inimigos da fase.

## 🧩 Estrutura dos Resources

O sistema utiliza três tipos de Resources para organizar os parâmetros da 
geração de inimigos.

| Resource | Responsabilidade |
|---|---|
| `CreatureSpawnData` | Define as criaturas disponíveis e a quantidade de cada tipo a ser gerada. |
| Resource de onda | Organiza as criaturas da onda e define seu nível de dificuldade. |
| Resource de fase | Define o intervalo entre surgimentos e a semente utilizada na geração. |

A separação desses dados facilita a criação de diferentes configurações de 
fases e ondas sem exigir alterações constantes na lógica de geração.

## 🔄 Fluxo de execução

1. O corredor é aberto e a primeira onda começa.
2. O sistema seleciona as criaturas configuradas para a onda atual.
3. Cada criatura recebe uma posição escolhida entre os marcadores disponíveis.
4. Os inimigos são gerados respeitando o intervalo configurado.
5. O sistema acompanha a quantidade de criaturas derrotadas.
6. Quando todos os inimigos da onda são derrotados, a próxima onda começa.
7. O processo continua conforme a configuração da fase.

## 📊 Monitoramento dos inimigos

O sistema disponibiliza o sinal:

```gdscript
update_inimigos_derrotados(
	inimigos_mortos: float,
	total_inimigos: float
)
```

Esse sinal permite comunicar o progresso da fase a outros componentes do jogo, 
como interfaces de usuário e sistemas de acompanhamento de combate.
