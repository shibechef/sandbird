shader_type spatial;
render_mode unshaded;

// https://www.shadertoy.com/view/mtlBzX
// https://www.shadertoy.com/view/M3ycWt
// https://www.shadertoy.com/view/X3XfRM
// https://www.shadertoy.com/view/wfyyDz
// https://jason.today/rc

uniform sampler2D cascade_text_array; 
uniform sampler2D color_palette_tex; 
const int chunk_size = 96;
varying vec3 normal;

void vertex() {
	// NORMAL in fragment and vertex are different values
	normal = normalize(NORMAL);
}

// basically an if else chain but using step
int face_num_from_normal(vec3 vert_normal) {
	vec3 abs_normal = abs(vert_normal);
	
	// only the biggest axis is 1.0, others are 0.0
	vec3 step_normal = vec3(
		step(1.5, step(abs_normal.y, abs_normal.x) + step(abs_normal.z, abs_normal.x)),
		step(1.5, step(abs_normal.x, abs_normal.y) + step(abs_normal.z, abs_normal.y)),
		step(1.5, step(abs_normal.x, abs_normal.z) + step(abs_normal.y, abs_normal.z))
		);
	
	int dir_num = int(step_normal.x) + int(step_normal.y) * 2 + int(step_normal.z) * 4;
	// find the sign of the biggest axis (the one that isn't 0.0 in step_normal)
	float axis_sign = sign(vert_normal.x * step_normal.x + vert_normal.y * step_normal.y + vert_normal.z * step_normal.z);
	// add 1 if the sign is negative
	dir_num += 1 - int(axis_sign / 2.0 + .5);
	return dir_num;
}

void fragment() {
	vec3 pos = vec4(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	int text_size = textureSize(cascade_text_array, 0).x;
	
	int dir_num = face_num_from_normal(normal); 
	
	ivec3 voxel_pos = ivec3(pos += normal / 1000.0);
	ivec3 sample_pos = voxel_pos;
	switch (dir_num) {
		case 0:
			sample_pos += ivec3(1, 0, 0);
		case 1:
			sample_pos += ivec3(-1, 0, 0);
		case 2:
			sample_pos += ivec3(0, 1, 0);
		case 3:
			sample_pos += ivec3(0, -1, 0);
		case 4:
			sample_pos += ivec3(0, 0, 1);
		case 5:
			sample_pos += ivec3(0, 0, -1);
	};
	
	int index = sample_pos.x + sample_pos.y * chunk_size + sample_pos.z * chunk_size * chunk_size;
	index *= 6;
	vec3 total = vec3(0.0);
	int b = int(TIME) % 6;
	for (int i = 0; i < 6; i++) {
		vec2 invocation_pos = vec2(float((index + i) % text_size), floor(float(index + i) / float(text_size)));
		invocation_pos += .5;
		//total = max(total, texture(cascade_text_array, vec2(invocation_pos) / float(text_size)).rgb);
		total += texture(cascade_text_array, vec2(invocation_pos) / float(text_size)).rgb;
	}
	
	// sample the actual texture for it's color
	float palette_text_size = float(textureSize(color_palette_tex, 0).x);
	ALBEDO = texture(color_palette_tex, vec2(UV.x / palette_text_size, 0.0)).rgb;
	
	ALBEDO += total / 6.0;
}
