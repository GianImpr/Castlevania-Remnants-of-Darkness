shader_type canvas_item;

// The amplitude of the wave.
uniform float waveAmplitude: hint_range(0.0, 1.0) = 0.25;
// If true corrects the Vertexes to adjust for the UV displacement
uniform bool correctVertex = true;
// The frequency of the wave.
uniform float waveFrequency: hint_range(0.0, 100.0) = 10.0;
// If true the texture waves vertically otherwise horizontally.
uniform bool verticalWave = true;
// If true the sprite will deform to match the waves, otherwise we keep the background color clamped.
uniform bool keepTransparency = true;
// If true the TIME constant is used, otherwise progress is used to move the wave.
uniform bool useTime = true;
// If useTime is true then use this as a multiplier for the wave speed.
uniform float waveSpeed: hint_range(0.0, 100.0) = 1.0;
// If useTime is false then use this as a multiplier for the wave progress.
uniform float progress: hint_range(0.0, 1.0) = 0.0;
// How much of the left or top half of the texture is modified.
uniform float firstHalf: hint_range(0.0, 1.0) = 0.5;
// How much of the right or bottom half of the texture is modified.
uniform float secondHalf: hint_range(0.0, 1.0) = 0.5;
// Keeps one half stuck. Useful for things like flags.
uniform bool freezeFirstHalf = false;
// Keeps one half stuck. Useful for things like flags.
uniform bool freezeSecondHalf = false;

void vertex() {
	if (correctVertex) {
		VERTEX = (verticalWave ? vec2(VERTEX.x, VERTEX.y * (1.0 + waveAmplitude)): vec2(VERTEX.x * (1.0 + waveAmplitude), VERTEX.y));
	}
}

void fragment() {
	vec2 uv = UV;
	float waveUv = (verticalWave ? uv.x : uv.y);
	float againstWaveUv = (verticalWave ? uv.y: uv.x);
	float freezeFactor = 1.0;
	if (freezeFirstHalf) {freezeFactor = waveUv;} else if (freezeSecondHalf) {freezeFactor = 1.0 - waveUv;}
	if (againstWaveUv < firstHalf || againstWaveUv > 1.0 - secondHalf) {
		float wave;
		// Progress based on time or progress variable.
		if (useTime) {
			wave = freezeFactor * sin(waveUv * waveFrequency + TIME * waveSpeed) * (waveAmplitude / 4.0);
		} else {
			wave = freezeFactor * sin(waveUv * waveFrequency + progress * 2.0 * PI) * (waveAmplitude / 4.0);
		}
		vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y, 1.0);
	    vec2 center = 0.5 * aspect;
		// Wave the UV.
		uv -= center;
		if (verticalWave) {
		    uv.y += wave;
			uv.y += uv.y * waveAmplitude;
		} else {
		    uv.x += wave;
			uv.x += uv.x * waveAmplitude;
		}
		uv += center;
		// Clamp the UVs to prevent texture wrapping.
		uv = clamp(uv, vec2(0.0), vec2(1.0));
		againstWaveUv = (verticalWave ? uv.y : uv.x);
		vec4 texColor = texture(TEXTURE, uv);
		// Apply the calculated color.
		if (keepTransparency) {
			if (againstWaveUv <= 0.0 || againstWaveUv >= 1.0) {
				COLOR.a = 0.0;
			} else {
				COLOR = texColor;
			}
		} else {
			COLOR = texColor;
		}
	}
}