shader_type spatial;

uniform sampler2D color_palette_tex; 

void fragment() {
	ALBEDO = texture(color_palette_tex, UV).rgb;
}