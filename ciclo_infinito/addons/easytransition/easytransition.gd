@icon("res://addons/easytransition/icon.png")
# easytransition.gd
class_name EasyTransitioner
extends Node

# ─── ANIMACIONES ──────────────────────────────────────────────────────────────
enum TransitionAnim {
	FADE                    = 0,
	WIPE_LINEAR             = 1,
	WIPE_RADIAL             = 2,
	WIPE_DIAGONAL           = 3,
	DUAL_WIPE_LINEAR        = 4,
	DUAL_WIPE_RADIAL        = 5,
	DUAL_WIPE_DIAGONAL      = 6,
	BLUR                    = 7,
	CIRCLE_CENTER_EXPAND    = 8,
	CIRCLE_CENTER_COLLAPSE  = 9,
	TEXTURE_CENTER_EXPAND   = 10,
	TEXTURE_CENTER_COLLAPSE = 11,
	CURTAIN                 = 12,
	WAVE                    = 13,
	SPIRAL                  = 14,
	TEXTURE_LUMINANCE       = 15,
}

const _SHADER_PATH := "res://addons/easytransition/transition.gdshader"

var is_transitioning: bool = false

var _color_rect: ColorRect
var _mat: ShaderMaterial


# ─── CICLO DE VIDA ────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_color_rect = $CanvasLayer/ColorRect
	_setup_rect(_color_rect)
	_mat = _setup_material(_color_rect)
	_mat.set_shader_parameter("progress", 0.0)



# ─── API PÚBLICA ──────────────────────────────────────────────────────────────


## Cubre la pantalla, cambia de escena y descubre la pantalla.
## path             — ruta de la nueva escena (.tscn)
## duration         — duración total (entrada + salida) en segundos
## animation        — tipo de animación (EasyTransition.Animation.FADE, etc.)
## color            — color de la pantalla durante la transición
## mask_texture     — textura de forma para TEXTURE_CENTER_EXPAND/COLLAPSE
## dither           — activar borde pixelado con dithering de píxeles perfectos
## dither_intensity — intensidad del borde dithereado (0–1)
## dither_scale     — tamaño de cada celda del patrón en píxeles de pantalla (1–8)
func transition_to_path(
	path: String,
	duration: float = 0.5,
	animation: TransitionAnim = TransitionAnim.FADE,
	color: Color = Color.BLACK,
	mask_texture: Texture2D = null,
	dither: bool = false,
	dither_intensity: float = 0.5,
	dither_scale: float = 2.0,
) -> void:
	var scene : PackedScene = (load(path) as PackedScene)
	transition_to_scene(
		scene,
		duration,
		animation,
		color,
		mask_texture,
		dither,
		dither_intensity,
		dither_scale,
	)


## Cubre la pantalla, cambia de escena y descubre la pantalla.
## scene            — la nueva escena (load file .tscn)
## duration         — duración total (entrada + salida) en segundos
## animation        — tipo de animación (EasyTransition.Animation.FADE, etc.)
## color            — color de la pantalla durante la transición
## mask_texture     — textura de forma para TEXTURE_CENTER_EXPAND/COLLAPSE
## dither           — activar borde pixelado con dithering de píxeles perfectos
## dither_intensity — intensidad del borde dithereado (0–1)
## dither_scale     — tamaño de cada celda del patrón en píxeles de pantalla (1–8)
func transition_to_scene(
	scene: PackedScene,
	duration: float = 0.5,
	animation: TransitionAnim = TransitionAnim.FADE,
	color: Color = Color.BLACK,
	mask_texture: Texture2D = null,
	dither: bool = false,
	dither_intensity: float = 0.5,
	dither_scale: float = 2.0,
) -> void:
	var node : Node = scene.instantiate()
	transition_to_node(
		node,
		duration,
		animation,
		color,
		mask_texture,
		dither,
		dither_intensity,
		dither_scale,
	)


## Cubre la pantalla, cambia de escena y descubre la pantalla.
## node             — instancia de la esciena
## duration         — duración total (entrada + salida) en segundos
## animation        — tipo de animación (EasyTransition.Animation.FADE, etc.)
## color            — color de la pantalla durante la transición
## mask_texture     — textura de forma para TEXTURE_CENTER_EXPAND/COLLAPSE
## dither           — activar borde pixelado con dithering de píxeles perfectos
## dither_intensity — intensidad del borde dithereado (0–1)
## dither_scale     — tamaño de cada celda del patrón en píxeles de pantalla (1–8)
func transition_to_node(
	node: Node,
	duration: float = 0.5,
	animation: TransitionAnim = TransitionAnim.FADE,
	color: Color = Color.BLACK,
	mask_texture: Texture2D = null,
	dither: bool = false,
	dither_intensity: float = 0.5,
	dither_scale: float = 2.0,
) -> void:
	if is_transitioning: return
	if not node: return

	is_transitioning = true
	_apply_params(animation, color, mask_texture, dither, dither_intensity, dither_scale)

	await _tween_progress(0.0, 1.0, duration * 0.5)
	get_tree().change_scene_to_node(node)
	await _tween_progress(1.0, 0.0, duration * 0.5)

	is_transitioning = false


## Solo cubre la pantalla. Útil para pantallas de carga manuales.
## Llama uncover() cuando la carga termine.
func cover(
	duration: float = 0.3,
	animation: TransitionAnim = TransitionAnim.FADE,
	color: Color = Color.BLACK,
	mask_texture: Texture2D = null,
	dither: bool = false,
	dither_intensity: float = 0.5,
	dither_scale: float = 2.0,
) -> void:
	if is_transitioning: return
	is_transitioning = true
	_apply_params(animation, color, mask_texture, dither, dither_intensity, dither_scale)
	await _tween_progress(0.0, 1.0, duration)


## Descubre la pantalla (par de cover()).
func uncover(duration: float = 0.3) -> void:
	await _tween_progress(1.0, 0.0, duration)
	is_transitioning = false


## Ajusta un parámetro específico del shader (wave_frequency, spiral_tightness, etc.).
func set_param(param: String, value: Variant) -> void:
	_mat.set_shader_parameter(param, value)


# ─── HELPERS INTERNOS ─────────────────────────────────────────────────────────
static func _setup_rect(color_rect: ColorRect) -> void:
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


static func _setup_material(color_rect: ColorRect) -> ShaderMaterial:
	if color_rect.material is ShaderMaterial and \
	   (color_rect.material as ShaderMaterial).shader != null:
		return color_rect.material as ShaderMaterial
	var mat := ShaderMaterial.new()
	mat.shader = load(_SHADER_PATH) as Shader
	color_rect.material = mat
	return mat


func _apply_params(
	animation: TransitionAnim,
	color: Color,
	mask_texture: Texture2D,
	dither: bool,
	dither_intensity: float,
	dither_scale: float,
) -> void:
	_mat.set_shader_parameter("animation",        animation as int)
	_mat.set_shader_parameter("transition_color", color)
	_mat.set_shader_parameter("dither_enabled",   dither)
	_mat.set_shader_parameter("dither_intensity", dither_intensity)
	_mat.set_shader_parameter("dither_scale",     dither_scale)
	if mask_texture:
		_mat.set_shader_parameter("mask_texture", mask_texture)


func _tween_progress(from: float, to: float, duration: float) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(_set_progress, from, to, duration)
	await tween.finished


func _set_progress(value: float) -> void:
	_mat.set_shader_parameter("progress", value)
