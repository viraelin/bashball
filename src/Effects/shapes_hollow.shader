shader_type canvas_item;

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

uniform float size = 0.4;
uniform float width = 0.03;
uniform int vertices: hint_range(3, 256) = 4;

float shape(vec2 uv, float add, float dist, int num){
	float a = atan(uv.x, uv.y) + PI;
	float r = TWO_PI/float(num);
	float d = cos(floor(0.5 + a / r) * r - a) * length(uv);
	float s = (smoothstep(add, add - dist, d));
	return s;
}

void fragment(){
	vec2 uv = UV;
	uv = 0.5 - uv;
	float c;
	c += shape(uv, size, width, vertices);
	c -= shape(uv, size - width, width, vertices);
	COLOR.a = c;
}
