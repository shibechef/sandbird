shader_type canvas_item;
render_mode world_vertex_coords;

varying float alpha;
uniform vec2 minimum_pos = vec2(0.0);
uniform float tiling_size = 2.0;
uniform float tiling_speed = 0.35;
uniform vec3 primary_color = vec3(.5, .4, .8);
uniform vec3 secondary_color = vec3(.5, .45, .9);

void vertex() {
	alpha = min(-minimum_pos.x + VERTEX.x, -minimum_pos.y + VERTEX.y);
}

void fragment() {
	vec2 pos = VERTEX + vec2(TIME) * tiling_speed;
	float dist = smoothstep(.25, .25 + 1.0 * SCREEN_PIXEL_SIZE.y, length(mod(pos, 1.0 + tiling_size / 100.0) - .5));
	COLOR.rgb = dist * primary_color + (1.0 - dist) * secondary_color;
	COLOR.a = texture(TEXTURE, UV).a * min(alpha, 1.0);
}
