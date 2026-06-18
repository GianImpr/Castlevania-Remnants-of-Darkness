shader_type canvas_item;

uniform vec3 target_color: source_color = vec3(1);
uniform float strength = 1.0;
uniform vec3 luminosity: source_color = vec3(0.299, 0.587, 0.114);

void fragment() {
    vec3 base = COLOR.rgb;
    float lum = dot(base, luminosity);
    vec3 colored = lum * target_color;
    COLOR.rgb = mix(base, colored, strength);
}
