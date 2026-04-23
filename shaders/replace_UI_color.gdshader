shader_type canvas_item;

instance uniform vec3 white_replacement = vec3(1.0, 1.0, 1.0);
instance uniform vec3 black_replacement = vec3(0.0, 0.0, 0.0); 

void fragment() {
	float white = step(.5, length(COLOR.rgb)) * COLOR.a;
	float black = step(length(COLOR.rgb), 0.5) * COLOR.a;
	vec4 col = vec4(white * white_replacement + black * black_replacement, COLOR.a);
	COLOR = COLOR * (1.0 - black - white) + col;
}