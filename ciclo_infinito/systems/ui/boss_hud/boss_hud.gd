class_name BossHUD
extends Control

## HUD de boss com barra dupla e feedback de dano (delay + tremor).

# ========================
# SIGNALS
# ========================

signal hud_mostrada
signal hud_escondida

# ========================
# EXPORTS
# ========================

@export_category("Referências")

## Nome do boss.
@export var boss_name_label: Label

## Barra principal (vida atual).
@export var health_bar: ProgressBar

## Barra atrasada (dano).
@export var damage_bar: ProgressBar

@export_category("Configuração de Dano")

## Velocidade da barra atrasada.
@export_range(0.1, 20.0, 0.1)
var damage_speed: float = 5.0

## Delay antes da barra atrasada começar a descer.
@export_range(0.0, 2.0, 0.05)
var damage_delay: float = 0.4

@export_category("Feedback Visual")

## Intensidade do tremor.
@export_range(0.0, 20.0, 0.5)
var shake_intensity: float = 4.0

## Duração do tremor.
@export_range(0.05, 1.0, 0.05)
var shake_duration: float = 0.2

# ========================
# VARIABLES
# ========================

var max_health: float = 100.0
var target_health: float = 100.0

var delay_timer: float = 0.0

var shaking: bool = false
var shake_timer: float = 0.0

# ========================
# ONREADY
# ========================

@onready var original_position: Vector2 = position

# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	_update_bars(delta)
	_update_shake(delta)

# ========================
# PUBLIC METHODS
# ========================

func show_hud(boss_name: String, max_hp: float) -> void:
	boss_name_label.text = boss_name
	
	max_health = max_hp
	target_health = max_hp
	
	health_bar.max_value = max_hp
	damage_bar.max_value = max_hp
	
	health_bar.value = max_hp
	damage_bar.value = max_hp
	
	show()
	emit_signal("hud_mostrada")

func hide_hud() -> void:
	hide()
	emit_signal("hud_escondida")

func update_health(new_health: float) -> void:
	new_health = clamp(new_health, 0, max_health)
	
	if new_health < target_health:
		delay_timer = damage_delay
		
		# ativa tremor
		shaking = true
		shake_timer = shake_duration
	
	target_health = new_health
	health_bar.value = new_health

# ========================
# PRIVATE METHODS
# ========================

func _update_bars(delta: float) -> void:
	if delay_timer > 0:
		delay_timer -= delta
		return
	
	damage_bar.value = lerp(
		damage_bar.value,
		target_health,
		damage_speed * delta
	)

func _update_shake(delta: float) -> void:
	if not shaking:
		return
	
	shake_timer -= delta
	
	var offset := Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	position = original_position + offset
	
	if shake_timer <= 0:
		shaking = false
		position = original_position
