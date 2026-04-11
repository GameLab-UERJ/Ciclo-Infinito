shader_type canvas_item;

uniform bool redden = false;

void fragment()
{
	vec4 texture_color = texture(TEXTURE, UV);
	
	if (redden)
	{
		vec3 red = vec3(1, 0, 0);
		vec3 reddened_texture_rgb = mix(texture_color.rgb, red, 0.6);
		COLOR = vec4(reddened_texture_rgb, texture_color.a);
	} else 
	{
		COLOR = texture_color;
	}	
}
