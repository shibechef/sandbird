shader_type canvas_item;
render_mode world_vertex_coords;

varying float alpha;
uniform vec2 minimum_pos = vec2(0.0);

void vertex() {
	alpha = min(-minimum_pos.x + VERTEX.x, -minimum_pos.x + VERTEX.y);
}

void fragment() {
	COLOR.a = texture(TEXTURE, UV).a * min(alpha, 1.0);
}
