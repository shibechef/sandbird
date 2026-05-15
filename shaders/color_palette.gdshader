shader_type spatial;
render_mode unshaded;

uniform sampler2D color_palette_tex; 

void fragment() {
	float text_width = float(textureSize(color_palette_tex, 0).x);
	ALBEDO = texture(color_palette_tex, vec2(UV.x / text_width, 0.0)).rgb;
}