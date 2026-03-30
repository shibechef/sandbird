shader_type spatial;
render_mode unshaded, fog_disabled, ambient_light_disabled, cull_disabled, depth_test_disabled;

// Thank you https://www.shadertoy.com/view/wdK3Dy for the guidance as I am rusty

uniform vec3 grid_size = vec3(1.0);
uniform float line_width = 0.11;
uniform vec3 grid_color = vec3(0.8, .4, 0.95);
uniform vec3 origin;

varying vec3 vertex_uv;

void vertex() {
	vertex_uv = VERTEX - origin;
}

void fragment() {
	vec3 neg_bound = mod(vertex_uv - line_width, grid_size);
	vec3 pos_bound = mod(vertex_uv + line_width, grid_size);
	vec3 diff = pos_bound - neg_bound;
	diff *= 10000.0;
	diff = clamp(diff, 0.0, 1.0);
	float match = step(1.05, length(diff));

	ALBEDO = grid_color * vec3(1.0 - match);
	ALPHA = step(match, 0.0);
}
