uniform sampler2DArray cascade_text_array;

vec4 sample_cascade(vec3 position) {
	return texture(cascade_text_array, vec3(position.x, position.y, 0.0));
}