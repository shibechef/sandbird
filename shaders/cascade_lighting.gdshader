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

// 2D tex array likely 96x96x96 x6 colors per face of a voxel
// it is also a square root so it can fit snugly on a 2304x2304 texture 

uniform sampler2DArray voxels;

varying vec3 vertex_uv;

vec3 get_grid_pos_from_tex() {
	return vec3(1.0);
}

void vertex() {
	vertex_uv = VERTEX;
}

void fragment() {
	
	ALBEDO = texture(voxels, vec3(VERTEX.x / 96.0, VERTEX.y / 96.0, 0.0)).rgb;
}
