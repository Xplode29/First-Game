shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D vignette;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 vignette_color = texture(vignette, SCREEN_UV).rgb;
	
	COLOR.rgb = textureLod(screen_texture, SCREEN_UV, (1.0 - vignette_color.r) * 4.0).rgb;
	COLOR.rgb *= texture(vignette, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
