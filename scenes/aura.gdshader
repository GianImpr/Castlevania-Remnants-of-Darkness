shader_type canvas_item;

uniform sampler2D n: repeat_enable;
uniform float min_intensity = 0.0f;
uniform float max_intensity = 0.0f;
uniform float speed = 1.0f;

void fragment(){
	vec4 tx = texture(TEXTURE, UV);
	float intensity = min_intensity + (max_intensity - min_intensity) * abs(sin(TIME));
	vec4 noise = texture(n, UV - TIME / (1.0 + speed));
	COLOR.a = clamp(tx.r * noise.r * intensity, 0.0, 1.0);
	COLOR.a = pow(COLOR.a, 2);
}