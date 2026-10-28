# Refatoração do Player: ya-FSM e Sistema de Progressão

Este documento registra a refatoração da arquitetura do Player para a máquina de estados **ya-FSM** e a implementação do **Sistema de Progressão em Camadas** com base em `Resources`.

---

## 1. Visão Geral da Arquitetura

O Player anteriormente operava através de um `enum State` procedural e blocos `match` dentro do `_physics_process`. Toda essa lógica legada foi removida.

A nova estrutura opera com separação estrita de responsabilidades:
- **`Player` ([player.gd](entities/player/player.gd)):** Entidade física (`CharacterBody2D`), hitboxes, colisões e execução direta de comandos.
- **`BasePlayerStateMachineManager` ([base_state_machine_manager.gd](entities/player/state_machine/base_state_machine_manager.gd)):** Máquina de ciclo de vida macro (`Enabled`, `Dialogue`, `Cutscene`, `Dead`).
- **`EnabledPlayerStateMachineManager` ([enabled_state_machine_manager.gd](entities/player/state_machine/enabled_state_machine_manager.gd)):** Máquina de gameplay e combate (`Idle`, `Walking`, `Attack`, `Dash`, `DashAttack`).
- **`ProgressionComponent` ([progression_component.gd](entities/components/progression_component.gd)):** Pipeline de cálculo de atributos e gerenciador de equipamentos e Dádivas.

---

## 2. Máquina de Estados (ya-FSM)

### Hierarquia de Nós na Cena (`player.tscn`)
```text
Player (CharacterBody2D)
├── BaseMachineManager (BasePlayerStateMachineManager)
│   └── EnabledStateMachineManager (EnabledPlayerStateMachineManager)
└── ProgressionComponent (ProgressionComponent)
```

### Grafo Base: Ciclo de Vida (`BaseMachineManager`)
Recurso: `Resource_qwspa`
- **Estados:** `Entry` ➔ `Enabled`, `Dialogue`, `Cutscene`, `Dead`.
- **Transições:**
  - `Enabled` ➔ `Dialogue`: Disparado por `player.enter_dialogue()` (gatilho `dialogue_started`).
  - `Dialogue` ➔ `Enabled`: Disparado por `player.exit_dialogue()` (gatilho `dialogue_ended`).
  - `Enabled` ➔ `Cutscene`: Disparado por `player.enter_cutscene()` (gatilho `cutscene_started`).
  - `Cutscene` ➔ `Enabled`: Disparado por `player.exit_cutscene()` (gatilho `cutscene_ended`).
  - `Enabled` ➔ `Dead`: Disparado por `player.die()` (gatilho `die`).
- **Comportamento:** Ao entrar em `Dialogue`, `Cutscene` ou `Dead`, a máquina filha `EnabledStateMachineManager` é desativada (`set_active(false)`) e a velocidade é zerada. Ao retornar a `Enabled`, a máquina filha é reativada.

### Grafo de Ações: Gameplay (`EnabledStateMachineManager`)
Recurso: [enabled_player_state_machine_player.tres](resources/state_machine_players/enabled_player_state_machine_player.tres)
- **Estados:** `Entry` ➔ `Idle`, `Walking`, `Attack`, `Dash`, `DashAttack`.
- **Condições e Gatilhos:**
  - `Idle` ➔ `Walking`: Gatilho `walk` (enviado quando `input_direction != Vector2.ZERO`).
  - `Walking` ➔ `Idle`: Condição booleana `stopped_walking == true` (enviada quando `input_direction == Vector2.ZERO`).
  - `*` ➔ `Attack`: Gatilho `attack` (executa combo 1 e 2).
  - `*` ➔ `Dash`: Gatilho `dash` (aplica multiplicador de velocidade, áudio e invencibilidade).
  - `Dash` ➔ `DashAttack`: Gatilho `dash_attack` (acionado se o jogador atacar durante o dash). A função `start_dash_attack_sequence()` e a física `update_dash_attack_physics()` já estão preparadas para receber a animação própria de giro (`dash_attack`) e lógica de dano em área assim que os assets visuais forem adicionados ao `AnimatedSprite2D`.
  - `Attack` / `Dash` / `DashAttack` ➔ `Idle`: Booleanas `attack_finished`, `dash_finished` e `dash_attack_finished`.

---

## 3. Sistema de Progressão e Atributos

### Estrutura em Camadas
$$\text{Status Base} \longrightarrow \text{Equipamentos (5 slots)} \longrightarrow \text{Dádivas (Escolas)} \longrightarrow \text{Modificadores} \longrightarrow \text{Status Finais}$$

### Arquivos de Recursos Criados

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [character_attributes.gd](resources/data/character_attributes.gd) | `Resource` | Classe com `strength`, `magic`, `resistance` e `vitality`. Suporta soma (`ADDEND`) e multiplicador (`MULTIPLIER`). |
| [uriam_base_attributes.tres](resources/data/uriam_base_attributes.tres) | Recurso (`.tres`) | Status base padrão de Uriam: Força 10.0, Magia 0.0, Resistência 0.0, Vida 25.0. |
| [equipment_item.gd](resources/data/equipment_item.gd) | `Resource` | Itens de equipamento com os 5 slots (`HELMET`, `ARMOR`, `GAUNTLETS`, `PANTS`, `ACCESSORY`) e raridades. |
| [progression_component.gd](entities/components/progression_component.gd) | `Node` | Componente responsável pelo recálculo de status e registro de habilidades. |

### Integração com o Combate do Player
- **Força:** `_on_area_attack_body_entered` calcula o dano base dos golpes físicos somando a Força final do personagem (`final_strength`).
- **Magia:** `cast_magic_skill()` e `progression.get_magic_damage()` utilizam a Magia final (`final_magic`) como base multiplicadora.
- **Resistência:** `apply_damage_with_resistance()` reduz o dano recebido antes da aplicação no `HealthComponent`.
- **Vida:** O `max_health` do `HealthComponent` sincroniza automaticamente com o atributo `vitality` recalculado (25 base).

### Gerenciamento de Equipamentos

#### 1. Configuração Inicial pelo Inspector (Debug / Builds)
O `ProgressionComponent` expõe 5 slots na categoria **Equipamentos Iniciais**:
- `initial_helmet` (Capacete)
- `initial_armor` (Armadura)
- `initial_gauntlets` (Manoplas)
- `initial_pants` (Calças)
- `initial_accessory` (Acessório)

Qualquer recurso [EquipmentItem](resources/data/equipment_item.gd) arrastado para esses campos no Inspector do Godot é automaticamente equipado ao iniciar a cena.

#### 2. Equipando e Desequipando em Tempo de Execução (Gameplay)
Para equipar um item encontrado durante a exploração (baú, drop ou NPC):
```gdscript
# Equipa o item (identifica o slot automaticamente pelo recurso)
var item_antigo: EquipmentItem = player.progression.equip_item(novo_item)

# Se quiser desequipar um slot específico:
var item_removido: EquipmentItem = player.progression.unequip_item(EquipmentItem.Slot.ARMOR)
```
Ao equipar ou desequipar, o `ProgressionComponent` recalcula os status finais automaticamente, atualizando a vida máxima e o dano do Player instantaneamente.

### Extensibilidade de Dádivas (Tesla, Newtoniana, Curie)
O `ProgressionComponent` possui os métodos:
- `register_skill(skill_name, skill_data)`
- `modify_skill(skill_name, key, value)`
- `has_skill(skill_name)`

Isso permite que Dádivas concedam novos ataques ou modifiquem habilidades existentes dinamicamente, sem alterar a estrutura da máquina de estados do Player.

---

## 4. Refatorações e Eliminação de Código Legado

A retrocompatibilidade com o antigo `enum State` foi completamente eliminada. Todos os sistemas dependentes foram refatorados para a interface nativa da ya-FSM:

### [player.gd](entities/player/player.gd)
- Removidos: `enum State`, `var current_state`, `var _current_state_fallback`.
- Adicionados métodos semânticos:
  - `is_in_state(state_name: String) -> bool`
  - `get_current_base_state() -> String`
  - `get_current_gameplay_state() -> String`
  - `enter_dialogue()` / `exit_dialogue()`
  - `enter_cutscene()` / `exit_cutscene()`
  - `die()`

### [health_component.gd](entities/components/health_component.gd)
- Substituída a verificação por enum pela consulta direta ao estado da FSM:
  ```gdscript
  if parent is Player and (parent.is_in_state("Dash") or 
                           parent.is_in_state("DashAttack") or 
                           parent.is_in_state("Dead") or 
                           parent.is_in_state("Dialogue")):
      return
  ```
- No evento de morte, chama diretamente `parent.die()`.

### [boss_room.gd](levels/boss_room/boss_room.gd) e [fifth_floor.gd](levels/fifth_floor/fifth_floor.gd)
- Substituídas as atribuições `player.current_state = player.State.CUTSCENE` e `player.State.DIALOG` por `player.enter_cutscene()` e `player.enter_dialogue()`.

### [state_machine_manager.gd](systems/state_machine_manager/state_machine_manager.gd)
- Tipagem de `@onready var parent: Node2D` corrigida para `@onready var parent: Node = get_parent()`, viabilizando o aninhamento de `StateMachineManager` dentro de outro `Node` na árvore da cena.
