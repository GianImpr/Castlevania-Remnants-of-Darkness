shader_type canvas_item;

uniform sampler2D n: repeat_enable;
uniform float min_intensity = 0.0f;
uniform float max_intensity = 0.0f;
uniform float speed_x = 1.0f; // Velocità del movimento orizzontale
uniform float speed_y = 1.0f; // Velocità del movimento verticale
uniform float fade_start = 0.3;
uniform float fade_end = 0.8;

void fragment(){
    vec4 tx = texture(TEXTURE, UV);
    float intensity = min_intensity + (max_intensity - min_intensity) * abs(sin(TIME));

    // Movimento differenziato su X e Y
    vec2 offset = vec2(TIME / (1.0 + speed_x), TIME / (1.0 + speed_y));
    vec4 noise = texture(n, UV - offset);

    // Dissolvenza progressiva in base alla posizione Y
    float fade_factor = smoothstep(fade_start, fade_end, UV.y);

    COLOR.a *= clamp(tx.r * noise.r * intensity * (1.0 - fade_factor), 0.0, 1.0);
    COLOR.a *= pow(COLOR.a, 2);
}
