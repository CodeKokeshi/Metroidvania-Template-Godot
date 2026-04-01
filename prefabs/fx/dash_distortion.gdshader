shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 flow_dir = vec2(1.0, 0.0);
uniform float strength : hint_range(0.0, 0.08) = 0.018;
uniform float energy : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale : hint_range(1.0, 80.0) = 20.0;
uniform float tail_stretch : hint_range(0.0, 2.0) = 0.7;
uniform float time_offset = 0.0;

float hash12(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 34.45);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	vec2 uv = UV;
	vec2 centered = uv - vec2(0.5);
	vec2 flow = normalize(flow_dir);
	if (length(flow) < 0.001) {
		flow = vec2(1.0, 0.0);
	}

	vec2 stretched = vec2(centered.x * (1.85 + tail_stretch), centered.y * 1.1);
	float ellipse_mask = 1.0 - smoothstep(0.23, 0.52, length(stretched));
	float tail_mask = 1.0 - smoothstep(0.1, 1.05, uv.x);
	float mask = clamp(ellipse_mask * tail_mask, 0.0, 1.0);

	vec2 perp = vec2(-flow.y, flow.x);
	float n1 = value_noise((uv * noise_scale) + vec2(time_offset * 4.2, time_offset * 2.5));
	float n2 = value_noise((uv * (noise_scale * 0.55)) - vec2(time_offset * 2.7, time_offset * 3.1));
	float swirl = ((n1 - 0.5) + (n2 - 0.5)) * 2.0;
	float flow_push = (1.0 - uv.x) * 1.05;
	vec2 offset = ((flow * flow_push) + (perp * swirl * 0.85)) * strength * energy * mask;

	vec4 base = texture(screen_tex, SCREEN_UV);
	vec2 sample_uv = clamp(SCREEN_UV + offset, vec2(0.0), vec2(1.0));
	vec4 refracted = texture(screen_tex, sample_uv);
	float mix_amount = clamp(mask * energy, 0.0, 1.0);
	COLOR = mix(base, refracted, mix_amount);
}
