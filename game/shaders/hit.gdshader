shader_type canvas_item;
render_mode blend_mix;

uniform vec4 flash_color: source_color = vec4(1.0);
uniform float flash_amount: hint_range(0.0, 1.0) = 1;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a == 1.0) {
	color = mix(color, flash_color, flash_amount);
	}
	COLOR = color;
}
