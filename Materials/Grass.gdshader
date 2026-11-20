shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 p = UV * 95.0;
	float broad = noise(p * 0.11);
	float blades = noise(p * 2.8);
	float flecks = hash(floor(p * 5.0));
	vec3 dark_grass = vec3(0.055, 0.25, 0.075);
	vec3 bright_grass = vec3(0.20, 0.48, 0.12);
	vec3 grass_color = mix(dark_grass, bright_grass, broad * 0.65 + blades * 0.35);
	grass_color *= mix(0.82, 1.12, flecks);
	ALBEDO = grass_color;
	ROUGHNESS = 1.0;
}
