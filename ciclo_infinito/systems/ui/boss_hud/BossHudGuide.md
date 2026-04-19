# Boss HUD

HUD responsável por exibir o estado de um boss durante combate.

Inclui:

* nome do boss
* barra de vida (instantânea)
* barra de dano atrasado
* animação de entrada/saída
* feedback de impacto (shake)

---

## Como usar

### 1. Instanciar

A HUD deve estar dentro de um `CanvasLayer`.

```gdscript
var hud_scene = preload("res://systems/ui/boss_hud/boss_hud.tscn")
var boss_hud: BossHUD = hud_scene.instantiate()

$CanvasLayer.add_child(boss_hud)
```

---

### 2. Iniciar

```gdscript
boss_hud.show_hud("Arauto da Reprovação", max_health)
```

---

### 3. Atualizar vida

```gdscript
boss_hud.update_health(current_health)
```

Chamar isso sempre que o boss tomar dano.

---

### 4. Encerrar

```gdscript
boss_hud.hide_hud()
```

---

## Estrutura

```plaintext
BossHUD (Control)
├── AnimationPlayer
├── CenterContainer
│   └── VBoxContainer
│       ├── BossName
│       └── Bars
│           ├── DamageBar
│           └── HealthBar
```

* `HealthBar`: valor instantâneo
* `DamageBar`: valor atrasado (lerp + delay)

---

## Comportamento

### Barra dupla

* vermelho: vida atual
* amarelo: vida anterior descendo com atraso

A barra atrasada só começa a descer após `damage_delay`.

---

### Feedback de dano

Quando `update_health` recebe um valor menor:

* ativa delay da barra secundária
* aplica shake na HUD

---

### Animações

Controladas via `AnimationPlayer`.

* `fade_in`: aparece (alpha 0 → 1, leve subida)
* `fade_out`: desaparece (alpha 1 → 0)

A HUD só é escondida de fato ao final do `fade_out`.

---

## Regras

* HUD não contém lógica de gameplay
* HUD não calcula dano
* HUD só reflete estado externo

---

## Integração

Evitar depender de path fixo tipo:

```gdscript
$CanvasLayer/BossHUD
```

Prefira:

* guardar referência ao instanciar
* ou injetar via sistema que controla UI

---

## Teste

Usar `test_scene.tscn` para validar comportamento isolado.
A barra de espaço retira vida.

---

## Observações

* valores visuais (shake, delay, velocidade) são configuráveis via `@export`
* sistema foi feito para ser reutilizado em qualquer boss
* não depende de nenhum sistema específico de vida
