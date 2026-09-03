shader_type spatial;
render_mode unshaded;

uniform sampler2D cascade_text_array; 
const int chunk_size = 96;

void fragment() {
	vec3 pos = vec4(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	int text_size = textureSize(cascade_text_array, 0).x;
	
	int index = int(pos.x) + int(pos.y) * chunk_size + int(pos.z) * chunk_size * chunk_size;
	ivec2 invocation_pos = ivec2(index % text_size, int(floor(float(index) / float(text_size))));
	
	ALBEDO = texture(cascade_text_array, vec2(invocation_pos) / float(text_size)).rgb;
}
