extends CanvasLayer
func _on_jogar_novamente_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/player.tscn")
	pass

var score = 0;
var life=3;

func _ready() -> void:
	$HUD/score.text= "Score: " + str(score)
	$HUD/life.animation = str(life)
	
func count_score():
	score += 1
	$HUD/score.text= "Score: " + str(score)

func count_life():
	life-=1
	$HUD/life
