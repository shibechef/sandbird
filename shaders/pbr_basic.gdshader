shader_type spatial;

uniform float metalicness = 1.0;
uniform float roughness = 1.0; 

uniform sampler2D color_palette_tex; 

void fragment() {
	ROUGHNESS = roughness;
	METALLIC = metalicness;
	
	float text_width = float(textureSize(color_palette_tex, 0).x);
	ALBEDO = texture(color_palette_tex, vec2(UV.x / text_width, 0.0)).rgb;
}
