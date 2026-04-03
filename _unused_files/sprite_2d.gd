extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 1.0) # azul
	style.corner_radius_all = 8
	pass # Replace with function body.

func _on_link_button_pressed() ->void:
	OS.shell_open("https://discord.com/channels/1409169018534891644/1412147166658429038")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
