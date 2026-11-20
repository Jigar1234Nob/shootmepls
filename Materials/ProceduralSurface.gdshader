shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.3, 0.4, 0.5, 1.0);
uniform float pattern_scale : hint_range(2.0, 80.0) = 28.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.72;
uniform float metallic_value : hint_range(0.0, 1.0) = 0.12;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 p = UV * pattern_scale;
	float grain = hash21(floor(p * 3.0));
	float fine_grain = hash21(floor(p * 19.0));
	float seam = smoothstep(0.47, 0.50, abs(fract(p.y * 0.45) - 0.5));
	float variation = 0.88 + grain * 0.12 + fine_grain * 0.045;
	ALBEDO = base_color.rgb * variation * (1.0 - seam * 0.055);
	ROUGHNESS = roughness_value;
	METALLIC = metallic_value;
}
