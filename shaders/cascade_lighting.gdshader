shader_type spatial;
render_mode unshaded;

// https://www.shadertoy.com/view/mtlBzX
// https://www.shadertoy.com/view/M3ycWt
// https://www.shadertoy.com/view/X3XfRM
// https://jason.today/rc

// objects stored in vec3 array that has:
// AABB for lookup and offsetting, and it's starting layer #
// from the AABB size you can find how much is stored in each
// texture, and instantly math out the texture's UV coords from the 3D coords
// you would need to AABB test for every object in the scene to find out coords though

uniform sampler2DArray cascade_text_array;

vec3 get_tex_from_hit_pos(vec3 hit_pos) {
	vec3 sub_voxel = fract(hit_pos);
	vec3 main_voxel = round(hit_pos);
	float vox_num = main_voxel.z + main_voxel.y * 96.0 + main_voxel.x * 96.0 * 96.0;
	vox_num *= 6.0;
	vec2 voxel_tex_pos = vec2(float(float(int(vox_num) % 2304)) / 2304.0, floor(vox_num / 2304.0) / 2304.0);
	voxel_tex_pos += vec2(-0.0 / 2304.0, -0.0 / 2304.0);
	return vec3(voxel_tex_pos.x, voxel_tex_pos.y, 0.0);
}

vec4 sample_cascade(vec3 position) {
	vec2 text_pos = fract(vec2(cos(position.x * 151.263 + position.z * .3), sin(position.z * 52.512+ position.y * .521)));
	return texture(cascade_text_array, vec3(text_pos, 0.0));
}

void fragment() {
	ALBEDO = sample_cascade(vec3(UV.x, UV.y, 0.0)).rgb;
}
