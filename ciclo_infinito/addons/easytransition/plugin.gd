# plugin.gd
@tool
extends EditorPlugin

const AUTOLOAD_NAME := "EasyTransition"
const AUTOLOAD_PATH := "res://addons/easytransition/easytransition.tscn"

const EasyTransitionScript = preload("res://addons/easytransition/easytransition.gd")


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	_ensure_scene_ready()


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


# Verifica que el ColorRect de la escena tenga el shader asignado.
# Solo escribe al disco si falta el material (instalación limpia).
func _ensure_scene_ready() -> void:
	var packed := load(AUTOLOAD_PATH) as PackedScene
	if not packed:
		return

	var root := packed.instantiate()
	var rect  := root.get_node_or_null("ColorRect") as ColorRect

	if rect and not (rect.material is ShaderMaterial):
		EasyTransitionScript._setup_rect(rect)
		EasyTransitionScript._setup_material(rect)

		var updated := PackedScene.new()
		updated.pack(root)
		ResourceSaver.save(updated, AUTOLOAD_PATH)

	root.free()
