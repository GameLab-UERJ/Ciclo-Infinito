extends ScrollContainer

@export_range(1,10000,0.1) var credits_time : float = 28.0
@export_range(0,10000,0.1) var margin_increment : float = 0

var main_menu : PackedScene = load("uid://downt2rxxaqaf")

@onready var margin : MarginContainer = $MarginContainer

func _ready() -> void:
	var text_node := margin.get_node_or_null("RichTextLabel")
	if text_node == null:
		text_node = _find_first_richtextlabel(margin)
	if text_node == null:
		push_error("RichTextLabel não encontrado dentro de MarginContainer. Certifique-se de que existe um RichTextLabel como filho.")
		return

	await get_tree().process_frame
	await get_tree().create_timer(0.01).timeout

	var text_box_size = text_node.size.y
	var window_size = DisplayServer.window_get_size().y
	margin.add_theme_constant_override("margin_top", window_size + margin_increment)
	margin.add_theme_constant_override("margin_bottom", window_size + margin_increment)

	var scroll_amount : int = ceil(text_box_size * 3/4 + window_size * 2 + margin_increment)

	var tween = create_tween()
	tween.tween_property(self, "scroll_vertical", scroll_amount, credits_time)
	tween.finished.connect(_acabou)
	tween.play()

func _acabou() -> void:
	print("acabou!")
	get_tree().change_scene_to_packed(main_menu)
	pass

func _find_first_richtextlabel(node: Node) -> RichTextLabel:
	for child in node.get_children():
		if child is RichTextLabel:
			return child
		var found := _find_first_richtextlabel(child)
		if found:
			return found
	return null
