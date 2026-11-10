extends Area2D
class_name Bullet


const MAX_RANGE = 2000


enum PossibleTargets{ENEMY, BOSS, PLAYER}


signal hit(character : Character)


@export var direction : Vector2
@export var speed : float = 1000
@export var range : float = MAX_RANGE
@export var can_hit : Array[PossibleTargets] = []
