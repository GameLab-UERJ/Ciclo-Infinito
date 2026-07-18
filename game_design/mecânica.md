# Mecânicas Gerais

## Objetivo do Sistema
O sistema foi projetado para privilegiar decisões estratégicas em detrimento da complexidade mecânica. Em vez de uma grande quantidade de atributos, o jogador deve compreender rapidamente como cada equipamento e Dádiva afetam seu desempenho, incentivando experimentação e diferentes estilos de jogo a cada run.

## 1. Visão Geral
O sistema de progressão de **Ciclo Infinito** é dividido em duas camadas:
- **Equipamentos:** Progressão permanente durante a partida.
- **Dádivas:** Progressão temporária adquirida a cada loop.

Os equipamentos definem os atributos básicos do personagem e permanecem até o fim da run. Já as Dádivas modificam habilidades, concedem novos efeitos e alteram a forma como o jogador enfrenta os desafios daquele loop. Essa divisão permite que cada partida tenha diferentes estratégias sem eliminar a importância da coleta de equipamentos.

## 2. Status do Personagem
O jogador possui cinco atributos principais:

| Status | Descrição |
| :--- | :--- |
| **Força** | Aumenta o dano de ataques e habilidades físicas. |
| **Magia** | Aumenta o dano de habilidades mágicas. |
| **Resistência** | Reduz o dano recebido. |
| **Vida** | Determina a quantidade máxima de HP. |
| **Velocidade de Movimento** | Aumenta a velocidade de deslocamento e possíveis *frames* de invencibilidade ao usar Dash. |

Todos esses atributos podem ser aumentados através dos equipamentos ou dádivas encontradas durante a exploração.

## 3. Sistema de Combate
O combate de Ciclo Infinito utiliza um sistema de cálculo simples e intuitivo, baseado na interação entre o atributo ofensivo do atacante e a Resistência do alvo.

### Dano Físico
Ataques físicos utilizam o atributo **Força**.
- **Fórmula:** `Dano Final = Força - Resistência do alvo`
- **Exemplo:** Jogador possui 40 de Força e Inimigo possui 15 de Resistência ($40 - 15 = 25$). O inimigo recebe 25 de dano.

### Dano Mágico
Habilidades mágicas utilizam o atributo **Magia**.
- **Fórmula:** `Dano Final = Magia - Resistência do alvo`
- **Exemplo:** Jogador possui 85 de Magia e Inimigo possui 30 de Resistência ($85 - 30 = 55$). O inimigo recebe 55 de dano.

> **Observação:** Os atributos de Magia possuem valores-base superiores aos de Força como forma de balanceamento. Enquanto a Força influencia ataques básicos de uso contínuo, a Magia afeta habilidades com tempo de recarga e menor frequência de utilização, exigindo maior impacto individual para manter a competitividade entre estilos de jogo.

### Vida
A Vida representa a quantidade máxima de HP do personagem. Após o cálculo do dano final, esse valor é subtraído diretamente da Vida do alvo.
- **Exemplo:** Vida: 150 | Dano recebido: 25 ($150 - 25 = 125$ HP restantes).

### 3.1 Justificativa Técnica sobre o Sistema de Combate
O sistema de atributos foi desenvolvido com foco na simplicidade, clareza e escalabilidade. A utilização de um conjunto reduzido de status (Força, Magia, Resistência, Vida e Velocidade de Movimento) e de fórmulas diretas de combate torna o funcionamento do jogo intuitivo para o jogador, facilitando a compreensão do impacto de cada equipamento e Dádiva obtidos durante a run.

Além de beneficiar a experiência do jogador, essa abordagem também favorece o desenvolvimento do projeto na Godot Engine. Como os equipamentos e Dádivas modificam apenas os atributos básicos do personagem ou adicionam efeitos específicos, novos conteúdos podem ser implementados de forma modular, sem a necessidade de alterar o funcionamento central do sistema de combate.

Essa estrutura permite que novos equipamentos, inimigos, Dádivas e até novos atributos sejam incorporados ao jogo com baixo custo de desenvolvimento e manutenção, contribuindo para a escalabilidade do projeto e facilitando futuros processos de balanceamento.

## 4. Equipamentos
O personagem pode utilizar cinco equipamentos simultaneamente. Apenas um equipamento de cada categoria pode ser equipado simultaneamente. Cada equipamento possui raridade e valores diferentes de atributos, variando conforme os andares e inimigo derrotado.

| Slot | Descrição |
| :--- | :--- |
| **Capacete** | Bônus defensivos ou mágicos. |
| **Armadura** | Principal fonte de Vida e Resistência. |
| **Manoplas** | Principal fonte de Força ou Magia. |
| **Calças** | Mobilidade e defesa. |
| **Acessório** | Efeitos especiais e bônus híbridos. |

## 5. Exemplos de Equipamentos

| Equipamento | Força | Magia | Resistência | Vida | Velocidade |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Capacete de Tesla** | 0 | +18 | +5 | 0 | 0 |
| **Armadura Leve** | 0 | 0 | +12 | +80 | 0 |
| **Manoplas de Ferro** | +25 | 0 | 0 | 0 | 0 |
| **Calças Leves** | 0 | 0 | +10 | 0 | +5% |
| **Medalha da Atlética** | +5 | +5 | +3 | +20 | 0 |

## 6. Atributos Base do Personagem
O personagem principal, Uriam, inicia cada nova run com um conjunto fixo de atributos base, que servem como referência para toda a progressão durante a partida.

- **Força:** 10
- **Magia:** 0
- **Resistência:** 5
- **Vida:** 100
- **Velocidade:** 100%

Esses valores representam o estado inicial do personagem antes da obtenção de equipamentos ou Dádivas. Ao longo da exploração, os atributos podem ser ampliados por meio dos sistemas de progressão da run. Além disso, determinadas recompensas permanentes, como missões, relíquias ou melhorias específicas, podem aumentar esses valores-base de forma definitiva, refletindo a evolução do personagem ao longo do jogo.

---

## Referências
O desenvolvimento deste sistema foi baseado em estudos e análises de diferentes obras e sistemas de jogos, utilizados como referência para compreender mecânicas, progressão, balanceamento e estrutura de combate.

- **3D&T Alpha:** Referência para a construção de sistemas de atributos, progressão de personagens e conceitos de RPG.
- **League of Legends:** Referência para balanceamento entre atributos, itens, estilos de jogo e diversidade de builds.
- **Taskbar Hero (TBH):** Referência para o conceito de progressão durante a partida, aquisição de equipamentos e evolução do personagem ao longo de cada run.
- **Hades:** (E outros roguelikes modernos) Referência para ciclos de run.

*Todas as mecânicas, regras, fórmulas, valores e decisões de design presentes neste documento foram adaptadas, reinterpretadas ou desenvolvidas especificamente para o projeto Ciclo Infinito, não representando reprodução direta dos sistemas das obras citadas, mas sim referências conceituais utilizadas durante o processo de desenvolvimento.*

---

### Errata: Uso de Inteligência Artificial
Este documento foi concebido a partir de ideias, conceitos, mecânicas e decisões de design desenvolvidos pelo autor. A Inteligência Artificial foi utilizada exclusivamente como ferramenta de apoio para revisão gramatical, organização do texto, padronização da formatação e aprimoramento da clareza da escrita.

Nenhuma das propostas de gameplay, sistemas, regras ou justificativas técnicas apresentadas foi gerada de forma autônoma pela ferramenta. Todo o conteúdo técnico e criativo reflete as decisões de projeto do autor, cabendo à IA apenas o papel de assistência editorial, sem substituir a autoria intelectual do trabalho.