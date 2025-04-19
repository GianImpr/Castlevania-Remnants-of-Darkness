shader_type canvas_item;

// --- Uniforms --- /
uniform float influence: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec3 color: source_color = vec3(1);
uniform float speed: hint_range(0.0, 10.0, 0.1) = 1;
uniform bool enabled;
uniform int sheet_columns = 20;
uniform int sheet_rows = 20;

const float TWO_PI = 6.28318530718;

// --- Functions --- //
vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
	if (enabled) {
	vec2 sprite_sheet_size = vec2(textureSize(TEXTURE,0));
	vec2 frame_size;
	frame_size.x = sprite_sheet_size.x/float(sheet_columns);
	frame_size.y = sprite_sheet_size.y/float(sheet_rows);
	vec4 texture_color = texture(TEXTURE, UV);
	vec2 current_point = sprite_sheet_size * UV;
	float row = floor(current_point.y / frame_size.y);
	float column = floor(current_point.x / frame_size.x);
	vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
	vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	vec2 pos = vec2(new_uv.x-0.5, new_uv.y-0.6);
	COLOR.rgb += color * influence * hsv2rgb(vec3(((atan(pos.y, pos.x) + radians(360.0*TIME*speed)) / TWO_PI) + 0.5, length(pos) * 6.0, 1.0));
	}
}