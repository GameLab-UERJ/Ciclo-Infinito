class_name BossHUD
extends Control

## HUD de boss com barra dupla, delay de dano, tremor e animações.

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

# ========================
# CONFIGURAÇÃO DE DANO
# ========================

@export_category("Dano")

## Velocidade da barra atrasada.
@export_range(0.1, 20.0, 0.1)
var damage_speed: float = 5.0

## Delay antes da barra atrasada descer.
@export_range(0.0, 2.0, 0.05)
var damage_delay: float = 0.4

# ========================
# FEEDBACK VISUAL
# ========================

@export_category("Feedback")

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

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var original_position: Vector2 = position

# ========================
# LIFECYCLE
# ========================

func _ready() -> void:
	modulate.a = 0.0
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
	animation_player.play("fade_in")
	
	emit_signal("hud_mostrada")

func hide_hud() -> void:
	animation_player.play("fade_out")


func damage_health(damage_amount: float) -> void:
	update_health(health_bar.value-damage_amount)

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

# ========================
# SIGNAL CALLBACKS
# ========================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		hide()
		emit_signal("hud_escondida")
