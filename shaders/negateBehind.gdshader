shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR == vec4(0.0,0.0,0.0,1.0))
	{
		COLOR.a = 0.2;
	}
	COLOR.rgb = COLOR.rgb - texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
}
