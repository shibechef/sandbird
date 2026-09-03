shader_type spatial;
render_mode unshaded;

uniform sampler2D color_palette_tex; 
const int chunk_size = 96;

void fragment() {
	vec3 pos = vec4(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	int text_size = textureSize(color_palette_tex, 0).x;
	
	int index = int(pos.x) + int(pos.y) * chunk_size + int(pos.z) * chunk_size * chunk_size;
	ivec2 invocation_pos = ivec2(index % text_size, int(floor(float(index) / float(text_size))));
	
	ALBEDO = texture(color_palette_tex, vec2(invocation_pos) / float(text_size)).rgb;
}
