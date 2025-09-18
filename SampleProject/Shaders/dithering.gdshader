shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_tex   : source_color;
uniform float levels     = 8.0;
uniform float bright_min = 0.25;   // soglia di luminosità per iniziare il dithering
uniform float gamma      = 2.2;

void fragment() {
    // 1) Sample colore e coordinate pixel
    vec2 uv = SCREEN_UV;
    vec2 px = uv * vec2(864,480);
    vec4 col_srgb = texture(SCREEN_TEXTURE, uv);

    // 2) Passa in lineare
    vec3 col_lin = pow(col_srgb.rgb, vec3(gamma));

    // 3) Calcola luminosità e maschera
    float lum = dot(col_lin, vec3(0.2126, 0.7152, 0.0722));
    if (lum < bright_min) {
        // sotto la soglia niente dithering
        COLOR = col_srgb;
    }

    // 4) Prendi valore da blue-noise texture
    //    (cicla la noise secondo la risoluzione dello schermo)
    vec2 nuv = fract(px / vec2(64.0));
    float thr = texture(noise_tex, nuv).r;

    // 5) Quantizza in LINEARE con dithering
    //    Aggiungi thr normalizzato da [-0.5/levels … +0.5/levels]
    float d = thr - 0.5;
    col_lin = floor(col_lin * levels + d) / levels;

    // 6) Torna in sRGB
    vec3 col_out = pow(col_lin, vec3(1.0 / gamma));

    COLOR = vec4(col_out, col_srgb.a);
}
