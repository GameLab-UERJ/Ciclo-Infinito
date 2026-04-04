extends CharacterBody2D



@export var max_health: float = 30.0
var current_health: float = max_health

var player

# Esta é a função que o ataque do jogador vai chamar

func take_damage(damage: float, hit_direction: Vector2) -> void:
	current_health -= damage
	print("Inimigo recebeu dano de ", damage, ". Vida restante: ", current_health)
	
	# Exemplo simples de Knockback
	var knockback_force: float = 300.0
	velocity = hit_direction * knockback_force
	
	if current_health <= 0:
		die()

func die():
	# Coloque aqui a lógica de morte (animação, pontuação, etc.)
	print("Inimigo foi derrotado!")
	queue_free()
	
	
