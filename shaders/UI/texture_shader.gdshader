shader_type canvas_item;

uniform sampler2D text;

void fragment() {
	COLOR = texture(text, UV);
}
