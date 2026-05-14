shader_type spatial;

uniform sampler2DArray color_palette_tex; 

void fragment() {
	float text_num = 0.0;
	float text_width = float(textureSize(color_palette_tex, 0).x);
	ALBEDO = texture(color_palette_tex, vec3(UV.x / text_width, 0, text_num)).rgb;
}