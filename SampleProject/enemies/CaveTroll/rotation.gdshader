shader_type canvas_item;

uniform float rotation = 0.0;
uniform vec2 rotation_offset = vec2(0.5, 0.5);

void fragment() {
	// Make the rotation dependant on the UV. Useful to "anchor" the
	// bottom of the sprite
	float rotation_anchored = rotation * (1.0 - UV.y);
	
	// Create the rotation matrix: https://en.wikipedia.org/wiki/Rotation_matrix
	mat2 rotation_mat = mat2(vec2(cos(rotation_anchored), sin(rotation_anchored)),
							vec2(-sin(rotation_anchored), cos(rotation_anchored)));
	
	// Offset the UV to apply the rotation
	vec2 centered_uv = UV - rotation_offset;
	// Apply rotation
	vec2 rotated_uv = centered_uv * rotation_mat;
	// Offset the UV back to normal
	rotated_uv = rotated_uv + rotation_offset;
	
	COLOR = texture(TEXTURE, rotated_uv);
}