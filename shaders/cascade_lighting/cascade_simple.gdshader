shader_type spatial;
render_mode unshaded;

// https://www.shadertoy.com/view/mtlBzX
// https://www.shadertoy.com/view/M3ycWt
// https://www.shadertoy.com/view/X3XfRM
// https://www.shadertoy.com/view/wfyyDz
// https://jason.today/rc

global uniform sampler2DArray cascade_text_array; 
uniform sampler2D color_palette_tex; 
const int chunk_size = 96;
varying vec3 normal;

void vertex() {
	// NORMAL in fragment and vertex are different values
	normal = normalize(NORMAL);
}

int face_num_from_normal(vec3 vert_normal) {
	vec3 abs_normal = abs(vert_normal);
	float biggest_axis = max(max(abs_normal.x, abs_normal.y), abs_normal.z);
	
	int dir_num = 0;
	dir_num += vert_normal.x == biggest_axis ? 1 : 0;
	dir_num += vert_normal.y == biggest_axis ? 3 : 0;
	dir_num += vert_normal.z == biggest_axis ? 5 : 0;
	dir_num += vert_normal.x == -biggest_axis ? 0 : 0;
	dir_num += vert_normal.y == -biggest_axis ? 2 : 0; 
	dir_num += vert_normal.z == -biggest_axis ? 4 : 0;

	return dir_num;
}

void fragment() {
	vec3 pos = vec4(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	int text_size = textureSize(cascade_text_array, 0).x;
	
	int dir_num = face_num_from_normal(normal); 
	
	ivec3 voxel_pos = ivec3(pos += normal / 1000.0);
	
	int index = voxel_pos.x + voxel_pos.y * chunk_size + voxel_pos.z * chunk_size * chunk_size;
	index *= 6;
	vec3 total = vec3(0.0);
	vec2 invocation_pos = vec2(float((index + dir_num) % text_size), floor(float(index + dir_num) / float(text_size)));
	invocation_pos += 0.5;
	vec4 radiance_color = texture(cascade_text_array, vec3(invocation_pos, 0.0) / float(text_size));
	
	// sample the actual texture for it's color
	float palette_text_size = float(textureSize(color_palette_tex, 0).x);
	vec4 material_color = texture(color_palette_tex, vec2(UV.x / palette_text_size, 0.0));
	
	ALBEDO = radiance_color.rgb / 2.5 + material_color.rgb / 1.2;
}
