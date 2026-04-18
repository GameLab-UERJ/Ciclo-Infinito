# State Machine

O sistema de máquina de estados é uma implementação que permite a criação e gerenciamento de estados para objetos dentro do Godot Engine.
Ele é composto por três componentes principais: `StateMachine`, `State` e `Transition`.

## Componentes

### StateMachine
O componente `StateMachine` é responsável por gerenciar os estados de um objeto.
Ele é um nó a ser adicionado a um objeto e pode conter vários estados.
Deve ser indicado o estado inicial.

### State
O componente `State` representa um estado específico dentro de uma máquina de estados.
> para a criação de transições, o estado deve possuir referencias para os possiveis estados futuros.

Deve ser implementado 4 funções:
- `_on_enter`: chamada quando o estado é ativado.
- `_on_exit`: chamada quando o estado é desativado.
- `_update`: chamada a cada process enquanto o estado estiver ativo.
- `_setup_transitions`: usada para configurar as transições para outros estados.

### Transition
O componente `Transition` representa uma transição entre dois estados.

Este componente deve ser inicializado na função `_setup_transitions` do estado, onde as transições são configuradas.

As transições devem ser armazenadas no array `_transitions`

A transição leva 2 args na inicialização:
1. o estado para o qual a transição leva. esperado o tipo `State`. 
1. uma função que retorna um booleano, usada para determinar quando a transição ocorrerá. esperado o tipo `Callable` (como em um connect do sinal)

## Como usar

Considerações para o passo a passo:
- Possuir um objeto para o qual a máquina de estados será adicionada.
- Entendimento mínimo de o que é uma máquina de estados.
- Conhecimento de OOP.

1. objeto > add child node > StateMachine 
2. na pasta do objeto, criar um folder chamado "states", lá estarão os scripts dos estados desse objeto.
3. botão direito no folder "states" > new script > Inherits: State
4. implementar a função `_on_enter`, `_on_exit` e `_update` com a lógica do nescessária considerando o ciclo de vida do estado.
    1. considerando que o estado será de atacar, a função `_on_enter` pode ser usada para iniciar uma animação de ataque, a função `_update` pode ser usada para verificar se o ataque atingiu o alvo e a função `_on_exit` pode ser usada para resetar a animação ou limpar variáveis relacionadas ao ataque.
5. implementar a função `_setup_transitions` para configurar as transições para outros estados.
   1. considerando o estado de atacar, se os próximos estados possíveis forem "atordoado" se o ataque for bloqueado e "andar" se o ataque for bem sucedido, teremos 2 transições.
   2. transition_1 = Transition.new(stunned_state, _is_attack_blocked)
   3. function _is_attack_blocked() -> bool:
        # lógica para determinar se o ataque foi bloqueado
        return true ou false
   4. transition_2 = Transition.new(walk_state, _is_attack_successful)
   5. function _is_attack_successful() -> bool:
        # lógica para determinar se o ataque foi bem sucedido
        return true ou false
   6. adicionar as transições ao array de transições do estado: `_transitions`
   7. _transitions.append(transition_1)
   8. repetir o processo para cada estado criado, configurando as transições de acordo com a lógica do jogo.

Código de exemplo para um estado de ataque:

```gdscript
extends State

@export var timer: Timer

@export_category("States")
@export var stunned_state: State
@export var walk_state: State

var _attack_finished: bool = false

func _on_enter():
    # iniciar animação de ataque
    timer.timeout.connect(_on_timer_timeout)
    timer.start()
    pass

func _on_exit():
    # resetar animação ou limpar variáveis relacionadas ao ataque
    timer.stop()
    timer.timeout.disconnect(_on_timer_timeout)
    pass

func _update(delta):
    # verificar se o ataque atingiu o alvo
    if hit_target:
        _attack_finished = true
    pass

func _setup_transitions():
    _transitions.append(Transition.new(stunned_state, _is_attack_blocked))
    _transitions.append(Transition.new(walk_state, func(): return _attack_finished))

func _is_attack_blocked() -> bool:
    # lógica para determinar se o ataque foi bloqueado
    return true ou false

func _on_timer_timeout():
    _attack_finished = true
```