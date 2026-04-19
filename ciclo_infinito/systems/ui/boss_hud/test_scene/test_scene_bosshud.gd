extends Node2D

@onready var boss_hud: BossHUD = $CanvasLayer/BossHUD

func _ready() -> void:
	boss_hud.show_hud("Arauto da Reprovação", 100)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		boss_hud.damage_health(10)
