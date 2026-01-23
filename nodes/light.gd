extends OmniLight3D

var color_r := 0.0
var color_g := 0.0
var color_b := 0.0



func post_ready():
	light_color.r = color_r
	light_color.g = color_g
	light_color.b = color_b
