shader_type spatial;

uniform float transparency = 1.0;
uniform float metalicness = 1.0;
uniform float roughness = 1.0; 

void fragment() {
	ALPHA = transparency;
	ROUGHNESS = roughness;
	METALLIC = metalicness;
}
