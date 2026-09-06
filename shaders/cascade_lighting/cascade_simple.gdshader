shader_type spatial;
render_mode unshaded;

uniform sampler2D cascade_text_array; 
const int chunk_size = 96;
varying vec3 john_normal;

void vertex() {
	// NORMAL in fragment and vector are different values
	john_normal = NORMAL;
}

void fragment() {
	vec3 pos = vec4(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	pos += john_normal / 1000.0;
	int text_size = textureSize(cascade_text_array, 0).x;
	
	int index = int(pos.x) + int(pos.y) * chunk_size + int(pos.z) * chunk_size * chunk_size;
	vec3 total = vec3(0.0);
	for (int i = 0; i < 6; i++) {
		ivec2 invocation_pos = ivec2((index + i) % text_size, int(floor(float(index) / float(text_size))));
		total += texture(cascade_text_array, vec2(invocation_pos) / float(text_size)).rgb;
	}
	
	ALBEDO = total / 6.0;
}
