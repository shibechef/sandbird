shader_type spatial;
render_mode vertex_lighting;

uniform sampler2D color_palette_tex; 

void vertex() {
	// I guess cache every directional light's angle + brightness
	// and every point light's position and brightness
	// and then every cone light's angle, position, and brightness
	// also attenuation and light colors i guess
	// this will not have shadows but it'll look interesting
	//COLOR += dot(vec3(0.0, -1.0, 0.0), NORMAL);
}

void fragment() {
	float text_width = float(textureSize(color_palette_tex, 0).x);
	ALBEDO = texture(color_palette_tex, vec2(UV.x / text_width, 0.0)).rgb + COLOR.rgb;
}

//void light() {
	//float brightness = dot(LIGHT, NORMAL) * ATTENUATION;
	//DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * brightness;
//}
