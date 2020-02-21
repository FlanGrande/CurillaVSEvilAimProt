shader_type canvas_item;

uniform float opacity = 1.0;
uniform int OCTAVES = 4;
uniform float aiming_angle = 0.0;

mat2 rotate2d(float _angle){
    return mat2(vec2(cos(_angle), -sin(_angle)),
                vec2(sin(_angle), cos(_angle)));
}

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(56, 78)) * 10.0) * 10.0);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.2;
	
	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 0.5;
		scale *= 0.8;
	}
	
	return value;
}

void fragment(){
	//vec2 coord = UV * 64.0;
	vec2 coord = UV * 256.0 / SCREEN_UV;
	
	/*coord -= vec2(0.5);
	coord = rotate2d(aiming_angle) * coord;
	coord += vec2(0.5);*/
	
	vec2 motion = vec2( fbm(coord + vec2(TIME * 0.5, TIME * -0.5)) );
	
	float final = fbm(coord);
	//vec3 color = vec3(1.0-final*6.0);
	vec3 color = vec3(1.0);
	
	COLOR = vec4(color, step(0.4, opacity - final));
}