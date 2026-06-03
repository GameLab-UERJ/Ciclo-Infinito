shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D mask_texture   : hint_default_white,  filter_linear_mipmap, repeat_enable;

// ─── CORE ─────────────────────────────────────────────────────────────────────
//  0  FADE                     8  CIRCLE_CENTER_EXPAND
//  1  WIPE_LINEAR               9  CIRCLE_CENTER_COLLAPSE
//  2  WIPE_RADIAL              10  TEXTURE_CENTER_EXPAND
//  3  WIPE_DIAGONAL            11  TEXTURE_CENTER_COLLAPSE
//  4  DUAL_WIPE_LINEAR         12  CURTAIN
//  5  DUAL_WIPE_RADIAL         13  WAVE
//  6  DUAL_WIPE_DIAGONAL       14  SPIRAL
//  7  BLUR                     15  TEXTURE_LUMINANCE
uniform int   animation        : hint_range(0, 15, 1) = 0;
uniform float progress         : hint_range(0.0, 1.0) = 0.0;
uniform vec4  transition_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// ─── PARÁMETROS POR ANIMACIÓN ─────────────────────────────────────────────────
uniform float wave_frequency   : hint_range(1.0, 20.0, 0.5)  = 8.0;
uniform float wave_amplitude   : hint_range(0.0, 0.3,  0.005) = 0.08;
uniform float spiral_tightness : hint_range(0.5, 5.0,  0.1)   = 2.0;

// ─── DITHERING ────────────────────────────────────────────────────────────────
uniform bool  dither_enabled   = false;
uniform float dither_intensity : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float dither_scale     : hint_range(1.0, 8.0, 0.5)  = 2.0;

const mat4 bayer = mat4(
	vec4(0.0,        0.5333333, 0.1333333, 0.6666667),
	vec4(0.8,        0.2666667, 0.9333333, 0.4),
	vec4(0.2,        0.7333333, 0.0666667, 0.6),
	vec4(1.0,        0.4666667, 0.8666667, 0.3333333)
);

float bayer4(vec2 px) {
	int cx = int(mod(px.x, 4.0));
	int cy = int(mod(px.y, 4.0));
	return bayer[cy][cx];
}

// Devuelve d ∈ [0,1]: el píxel se cubre cuando progress > d.
float get_mask(vec2 uv) {
	vec2 c = uv - vec2(0.5);

	if (animation == 1) {
		return uv.x;
	}
	if (animation == 2) {
		return mod(atan(c.y, c.x) / (PI * 2.0) + 1.0, 1.0);
	}
	if (animation == 3) {
		return (uv.x + uv.y) * 0.5;
	}
	if (animation == 4) {
		return min(uv.x, 1.0 - uv.x) * 2.0;
	}
	if (animation == 5) {
		float dl = length(uv - vec2(0.0, 0.5));
		float dr = length(uv - vec2(1.0, 0.5));
		return min(dl, dr) / 0.707;
	}
	if (animation == 6) {
		return 1.0 - abs(uv.x + uv.y - 1.0);
	}
	if (animation == 8) {
		return length(c) / 0.707;
	}
	if (animation == 9) {
		return 1.0 - length(c) / 0.707;
	}
	if (animation == 10) {
		float lum = dot(texture(mask_texture, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
		return 1.0 - lum;
	}
	if (animation == 11) {
		return dot(texture(mask_texture, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	}
	if (animation == 12) {
		return uv.y;
	}
	if (animation == 13) {
		return clamp(uv.x + sin(uv.y * wave_frequency * PI * 2.0) * wave_amplitude, 0.0, 1.0);
	}
	if (animation == 14) {
		float angle = mod(atan(c.y, c.x) / (PI * 2.0) + 1.0, 1.0);
		float dist  = length(c) / 0.707;
		return mod(angle + dist * spiral_tightness, 1.0);
	}
	if (animation == 15) {
		// TEXTURE_LUMINANCE: negro = cubierto primero, blanco = cubierto último.
		// Usa cualquier textura de transición estándar en escala de grises.
		return dot(texture(mask_texture, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	}
	return 0.5;
}

vec3 blur_screen(vec2 uv, float radius) {
	vec3 col = vec3(0.0);
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			col += texture(screen_texture, uv + vec2(float(x), float(y)) * radius).rgb;
		}
	}
	return col / 25.0;
}

void fragment() {
	float alpha   = 0.0;
	vec3  out_rgb = transition_color.rgb;
	vec2  dither_px = FRAGCOORD.xy / dither_scale;

	// ── Fade ──────────────────────────────────────────────────────────────────
	if (animation == 0) {
		if (progress >= 1.0) {
			alpha = 1.0;
		} else if (progress <= 0.0) {
			alpha = 0.0;
		} else if (dither_enabled) {
			// Remapear el umbral Bayer a [half_m, 1-half_m] garantiza que no haya
			// huecos ni rellenos abruptos en los extremos del dissolve.
			float half_m = dither_intensity * 0.175;
			float b_safe = half_m + bayer4(dither_px) * (1.0 - 2.0 * half_m);
			alpha = step(b_safe, progress);
		} else {
			alpha = progress;
		}
	}
	// ── Blur ──────────────────────────────────────────────────────────────────
	else if (animation == 7) {
		vec3 blurred = blur_screen(UV, progress * 0.025);
		out_rgb = mix(blurred, transition_color.rgb, smoothstep(0.35, 0.75, progress));
		alpha   = min(progress * 5.0, 1.0);
	}
	// ── Resto de animaciones ──────────────────────────────────────────────────
	else {
		float d = get_mask(UV);

		if (progress >= 1.0) {
			alpha = 1.0;
		} else if (progress <= 0.0) {
			alpha = 0.0;
		} else if (dither_enabled) {
			// Remapear d a [half_m, 1-half_m] garantiza que d_safe + perturb ∈ [0, 1].
			// Esto elimina los huecos que se veían cerca de progress = 1 y el relleno
			// abrupto al llegar exactamente a 1.0: el borde dithereado progresa de
			// forma continua hasta cubrir el último píxel sin saltos.
			float half_m  = dither_intensity * 0.175;
			float d_safe  = half_m + d * (1.0 - 2.0 * half_m);
			float perturb = (bayer4(dither_px) - 0.5) * dither_intensity * 0.35;
			alpha = step(d_safe + perturb, progress);
		} else {
			alpha = step(d, progress);
		}
	}

	COLOR = vec4(out_rgb, alpha * transition_color.a);
}
