shader_type canvas_item;
render_mode unshaded;

uniform vec2 direction = vec2(0.0, -1.0);
uniform vec4 start_color : source_color;
uniform vec4 end_color : source_color;

float vmax(vec4 vec)
{
	return max(vec.x, max(vec.y, max(vec.z, vec.w)));
}

float random(vec2 seed, float pmin, float pmax)
{
	return pmin + fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123) * (pmax - pmin);
}

float get_color_count(float range)
{
	return ceil(clamp(range, 0.0, 1.0) * 255.0);
}

float get_delta(vec2 uv)
{
	vec2 dir = normalize(direction);
	return (dir.x < 0.0 ? (1.0 - uv.x) : uv.x) * dir.x * dir.x + (dir.y < 0.0 ? (1.0 - uv.y) : uv.y) * dir.y * dir.y;
}

void fragment()
{
	float color_count = get_color_count(vmax(abs(end_color - start_color)));
	float inv_color_count = 1.0 / color_count;

	float color_index = floor(get_delta(UV) * color_count);
	vec4 color1 = mix(start_color, end_color, color_index / color_count);
	vec4 color2 = mix(start_color, end_color, (color_index + 1.0) / color_count);

	float ratio = clamp(mod(get_delta(UV), inv_color_count) * color_count + random(UV, -0.5, 0.5), 0.0, 1.0);
	COLOR = color1 * (1.0 - ratio) + color2 * ratio;
}