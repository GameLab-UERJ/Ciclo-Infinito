# EasyTransition for Godot 4 🎬

[![Godot 4](https://img.shields.io/badge/Godot-4.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Version](https://img.shields.io/badge/version-1.0.0-5aafff)](./plugin.cfg)

EasyTransition is a lightweight screen transition addon for **Godot 4** that lets you create smooth, stylized scene changes with a single call. Works as an autoloaded singleton: no setup per scene, no boilerplate.

- ✅ 16 ready-to-use transition animations
- ✅ Customizable transition color
- ✅ Pixel-perfect dithering on the edge of every animation
- ✅ Support for custom mask textures
- ✅ Simple API with native `await`
- ✅ Parameters adjustable in real time from the editor Inspector

---

## ✨ Features

- **Global access** from any script via the `EasyTransition` singleton
- **16 animations** — wipe, radial, diagonal, circular, blur, spiral, curtain, and more
- **Mask textures** to create transitions with fully custom shapes
- **Ordered dithering** (Bayer 4×4) with pixel-perfect edges on the transition border
- **Per-call transition color** configuration
- **Manual mode** (`cover` / `uncover`) for controlled loading screens
- **Editor preview**: open the autoload scene and tweak shader parameters in the Inspector to see animations in real time

---

## 📦 Installation (Godot 4)

### 1) Place the addon in your project

Make sure your project contains this structure:

```text
res://addons/easytransition/
  plugin.cfg
  plugin.gd
  easytransition.tscn
  easytransition.gd
  transition.gdshader
```

> If you cloned the repository, copy or keep the files under `res://addons/easytransition/`.

### 2) Enable the plugin

In Godot:

1. Open **Project → Project Settings...**
2. Go to the **Plugins** tab
3. Find **EasyTransition**
4. Click **Enable**

When enabled, the plugin automatically registers the autoload singleton:

- **Name:** `EasyTransition`
- **Scene:** `res://addons/easytransition/easytransition.tscn`

From that point you can call `EasyTransition` from any script in the project.

---

## 🚀 Basic usage

### Simple scene transition

```gdscript
# Black fade, 0.5 s total duration (0.25 s cover + 0.25 s uncover)
EasyTransition.transition_to("res://scenes/game.tscn")
```

### With parameters

```gdscript
await EasyTransition.transition_to(
	"res://scenes/menu.tscn",
	duration          = 0.8,
	animation         = EasyTransition.TransitionAnim.WIPE_RADIAL,
	color             = Color.WHITE,
	dither            = true,
	dither_intensity  = 0.7,
	dither_scale      = 3.0,
)
```

> Use `await` if you need to run code **after** the transition completes.

---

## 📖 API Reference

### `transition_to()`

Covers the screen, changes scene, then uncovers the screen.

```gdscript
EasyTransition.transition_to(
	path:             String,
	duration:         float           = 0.5,
	animation:        TransitionAnim  = TransitionAnim.FADE,
	color:            Color           = Color.BLACK,
	mask_texture:     Texture2D       = null,
	dither:           bool            = false,
	dither_intensity: float           = 0.5,
	dither_scale:     float           = 2.0,
) -> void
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `path` | `String` | — | Path to the destination scene (`.tscn`) |
| `duration` | `float` | `0.5` | Total duration in seconds (cover + uncover) |
| `animation` | `TransitionAnim` | `FADE` | Animation type (see Animations section) |
| `color` | `Color` | `BLACK` | Screen color during the transition |
| `mask_texture` | `Texture2D` | `null` | Shape texture for `TEXTURE_*` animations (see below) |
| `dither` | `bool` | `false` | Enables pixel-perfect dithered edge |
| `dither_intensity` | `float` | `0.5` | Dithered edge intensity (0–1) |
| `dither_scale` | `float` | `2.0` | Size of each pattern cell in screen pixels (1–8) |

---

### `cover()`

Covers the screen only (does not change scene). Useful for manual loading screens.

```gdscript
EasyTransition.cover(
	duration:         float           = 0.3,
	animation:        TransitionAnim  = TransitionAnim.FADE,
	color:            Color           = Color.BLACK,
	mask_texture:     Texture2D       = null,
	dither:           bool            = false,
	dither_intensity: float           = 0.5,
	dither_scale:     float           = 2.0,
) -> void
```

---

### `uncover()`

Uncovers the screen. Always call this after `cover()`.

```gdscript
EasyTransition.uncover(duration: float = 0.3) -> void
```

---

### `set_param()`

Adjusts a shader parameter at runtime (useful for animations like `WAVE` or `SPIRAL`).

```gdscript
EasyTransition.set_param(param: String, value: Variant) -> void
```

**Examples:**

```gdscript
EasyTransition.set_param("wave_frequency", 12.0)
EasyTransition.set_param("spiral_tightness", 3.5)
EasyTransition.set_param("wave_amplitude", 0.12)
```

---

### `is_transitioning`

Read-only property. Returns `true` while a transition is active. New calls to `transition_to()` or `cover()` are ignored while it is `true`.

```gdscript
if not EasyTransition.is_transitioning:
	EasyTransition.transition_to("res://scenes/game.tscn")
```

---

## 🎭 Available animations

All animations are selected via the `EasyTransition.TransitionAnim` enum.

| ID | Name | Description |
|---|---|---|
| `0` | `FADE` | Smooth alpha fade. With dither enabled it becomes an ordered dissolve (each pixel appears on its Bayer turn). |
| `1` | `WIPE_LINEAR` | Sweeps the screen left to right with a vertical edge. |
| `2` | `WIPE_RADIAL` | Clockwise angular sweep from the right, like clock hands. |
| `3` | `WIPE_DIAGONAL` | Sweeps from the top-left corner to the bottom-right. |
| `4` | `DUAL_WIPE_LINEAR` | Two vertical bars advance from both edges (left and right) and meet in the center. |
| `5` | `DUAL_WIPE_RADIAL` | Two circles grow from the left and right edge centers until they meet in the middle. |
| `6` | `DUAL_WIPE_DIAGONAL` | Top-left and bottom-right corners are covered simultaneously toward the anti-diagonal. |
| `7` | `BLUR` | The scene progressively blurs before fading into the transition color. Requires access to the screen texture. |
| `8` | `CIRCLE_CENTER_EXPAND` | A circle grows from the center of the screen toward the edges. |
| `9` | `CIRCLE_CENTER_COLLAPSE` | Screen edges are covered first and the circle closes toward the center (reverse iris effect). |
| `10` | `TEXTURE_CENTER_EXPAND` | Like Circle Expand but the shape is defined by the texture assigned to `mask_texture`. White areas of the texture are the last to be covered. |
| `11` | `TEXTURE_CENTER_COLLAPSE` | Inverse of `TEXTURE_CENTER_EXPAND`. White areas of the texture are covered first. |
| `12` | `CURTAIN` | The screen falls from above like a curtain. |
| `13` | `WAVE` | Like `WIPE_LINEAR` but with a vertically wavy edge. Configurable with `wave_frequency` and `wave_amplitude`. |
| `14` | `SPIRAL` | A multi-arm spiral expands from the center. Configurable with `spiral_tightness`. |
| `15` | `TEXTURE_LUMINANCE` | Uses any standard greyscale transition texture. **Black** areas are covered first; **white** areas last. The most flexible way to create custom transitions. |

---

## 🖼️ Mask textures (`mask_texture`)

The `TEXTURE_CENTER_EXPAND`, `TEXTURE_CENTER_COLLAPSE`, and `TEXTURE_LUMINANCE` animations use a greyscale texture to define the reveal order:

- **Black** (`0.0`) → that pixel is covered at the start of the transition
- **White** (`1.0`) → that pixel is covered at the end of the transition
- Mid-grey values create a gradient of coverage order

You can use any black-and-white image: radial gradients, noise, geometric shapes, etc. With dithering enabled, the edge between covered and uncovered areas takes on the characteristic pixel-art look.

```gdscript
var my_mask: Texture2D = preload("res://assets/transitions/star_mask.png")

EasyTransition.transition_to(
	"res://scenes/level2.tscn",
	animation    = EasyTransition.TransitionAnim.TEXTURE_LUMINANCE,
	mask_texture = my_mask,
	dither       = true,
)
```

> **Tip:** enable **Import → Filter** on the mask texture for soft edges, or disable it for hard edges. With dithering active, filtering matters less.

---

## ✏️ Shader parameters

The `transition.gdshader` shader exposes the following uniforms. You can adjust them from code with `set_param()` or directly from the **Inspector** in the editor (see the preview section).

### Core parameters

| Uniform | Type | Range | Default | Description |
|---|---|---|---|---|
| `animation` | `int` | 0–15 | `0` | Index of the active animation |
| `progress` | `float` | 0.0–1.0 | `0.0` | Transition progress. `0` = transparent, `1` = screen fully covered |
| `transition_color` | `vec4` | — | `(0,0,0,1)` | Screen color during the transition |

### Animation parameters

| Uniform | Type | Range | Default | Used by |
|---|---|---|---|---|
| `wave_frequency` | `float` | 1.0–20.0 | `8.0` | `WAVE` — Number of waves along the vertical edge |
| `wave_amplitude` | `float` | 0.0–0.3 | `0.08` | `WAVE` — Wave depth (higher = more curved edges) |
| `spiral_tightness` | `float` | 0.5–5.0 | `2.0` | `SPIRAL` — Number of spiral arms (higher = denser) |

### Dithering parameters

| Uniform | Type | Range | Default | Description |
|---|---|---|---|---|
| `dither_enabled` | `bool` | — | `false` | Enables the pixel-art dithered edge |
| `dither_intensity` | `float` | 0.0–1.0 | `0.5` | Effect intensity. `0` = clean edge, `1` = fully pixelated edge |
| `dither_scale` | `float` | 1.0–8.0 | `2.0` | Size of each Bayer pattern cell in screen pixels. Higher values produce a chunkier retro look |

---

## 🎨 Dithering system

The dithering uses a pixel-perfect **Bayer 4×4 matrix** to create a pixel-art style edge on every transition animation.

**How it works:**

Instead of a smooth anti-aliased edge, each Bayer pattern cell decides whether the pixel in the transition zone should appear covered or uncovered. This creates the characteristic pixelated border of retro games.

| `dither_scale` | Visual result |
|---|---|
| `1.0` | Individual pixel-level pattern (subtle grain) |
| `2.0` | 2×2 px cells (balanced retro look) |
| `4.0` | 4×4 px cells (chunky, very blocky look) |
| `8.0` | Very large cells, strong effect |

The system guarantees that:
- At `progress = 0.0` → no pixel is covered, regardless of the pattern
- At `progress = 1.0` → every pixel is covered, with no residual gaps
- Between `0` and `1` → the pixelated edge progresses continuously without any abrupt jumps

---

## 🧪 Editor preview

You can test all animations and settings **directly in the Godot editor** without running the game:

1. Open `res://addons/easytransition/easytransition.tscn` in the editor
2. Select the **ColorRect** node in the scene tree
3. In the **Inspector**, expand the **ShaderMaterial → Shader Parameters** section
4. Adjust the **`progress`** parameter to see the transition advance
5. Change **`animation`** to try different types
6. Enable **`dither_enabled`** and adjust **`dither_scale`** to see the pixelated effect
7. Modify **`wave_frequency`**, **`spiral_tightness`**, or other animation parameters in real time

> This is especially useful for calibrating `dither_scale`, `wave_frequency`, and `spiral_tightness` before using them in your project.

---

## 💡 Practical examples

### Simple fade (black)

```gdscript
EasyTransition.transition_to("res://scenes/game.tscn")
```

### White wipe with chunky dithering

```gdscript
EasyTransition.transition_to(
	"res://scenes/level_2.tscn",
	duration          = 1.0,
	animation         = EasyTransition.TransitionAnim.WIPE_LINEAR,
	color             = Color.WHITE,
	dither            = true,
	dither_intensity  = 1.0,
	dither_scale      = 4.0,
)
```

### Tuned spiral

```gdscript
EasyTransition.set_param("spiral_tightness", 4.0)

await EasyTransition.transition_to(
	"res://scenes/boss.tscn",
	duration  = 1.2,
	animation = EasyTransition.TransitionAnim.SPIRAL,
	color     = Color(0.1, 0.0, 0.05),
)
```

### Manual loading screen

```gdscript
# 1. Cover the screen
await EasyTransition.cover(
	0.4,
	EasyTransition.TransitionAnim.CIRCLE_CENTER_EXPAND,
	Color.BLACK,
)

# 2. Load resources while the screen is covered
ResourceLoader.load_threaded_request("res://assets/world.tscn")
while ResourceLoader.load_threaded_get_status("res://assets/world.tscn") != ResourceLoader.THREAD_LOAD_LOADED:
	await get_tree().process_frame

# 3. Switch to the new scene
get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://assets/world.tscn"))

# 4. Uncover the screen
await EasyTransition.uncover(0.4)
```

### Transition with a custom texture

```gdscript
var mask := preload("res://assets/masks/star.png") as Texture2D

await EasyTransition.transition_to(
	"res://scenes/menu.tscn",
	duration     = 0.9,
	animation    = EasyTransition.TransitionAnim.TEXTURE_LUMINANCE,
	color        = Color(0.05, 0.05, 0.1),
	mask_texture = mask,
	dither       = true,
	dither_scale = 2.0,
)
```

---

## 🧩 Addon components

| File | Description |
|---|---|
| `plugin.gd` | Registers and removes the autoload when the plugin is enabled/disabled. On enable, verifies the scene has the shader assigned. |
| `easytransition.tscn` | Autoload scene. Contains a `CanvasLayer` (layer 128) with a fullscreen `ColorRect`. |
| `easytransition.gd` | Main logic: tween management, public API, and shader configuration. |
| `transition.gdshader` | `canvas_item` shader with 16 animations, mask texture support, and a Bayer 4×4 dithering system. |

---

## ⚙️ How it works internally

1. When `transition_to()` is called, the singleton configures the shader parameters and starts a **Tween** that animates `progress` from `0.0 → 1.0` (cover phase).
2. When the Tween finishes, `get_tree().change_scene_to_file()` is called.
3. A second Tween immediately animates `progress` from `1.0 → 0.0` (uncover phase).
4. The `CanvasLayer` at layer `128` ensures the `ColorRect` renders above every element in the active scene, including other `CanvasLayer` nodes.
5. `process_mode = PROCESS_MODE_ALWAYS` ensures the transition is not interrupted if the scene tree is paused.

---

## 🛠️ Notes

- Designed for **Godot 4**.
- The singleton is named `EasyTransition` and is accessible from any script without `preload`.
- Multiple calls to `transition_to()` or `cover()` while `is_transitioning == true` are automatically ignored.
- For the `BLUR` effect the `ColorRect` samples the screen buffer; make sure the node renders after the scene (the `CanvasLayer 128` guarantees this).
- Mask textures for `TEXTURE_LUMINANCE` should be imported with **Compress Mode: Lossless** to preserve exact luminance values.

---

## 📄 License

MIT License © 2026 IUX Games, Isaackiux.
