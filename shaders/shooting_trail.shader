shader_type canvas_item;

uniform float opacity = 1.0;

void fragment()
{
	
	
	COLOR = vec4(COLOR.r, COLOR.g, COLOR.b, opacity);
}