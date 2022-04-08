shader_type canvas_item;

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

uniform vec2 pos = vec2(0.5);
uniform int vertices = 4;
uniform float force = 0.01;
uniform float size = 0.0;
uniform float width = 0.05;
uniform float rotation = 0.0;
uniform float alpha = 2.0;

vec2 rotate_uv(vec2 uv, float rot){
	float mid = 0.5;
	return vec2(
		cos(rot) * (uv.x - pos.x) + sin(rot) * (uv.y - pos.y) + pos.x,
		cos(rot) * (uv.y - pos.y) - sin(rot) * (uv.x - pos.x) + pos.y
	);
}

float shape(vec2 uv, float add, float dist, int num){
	float a = atan(uv.x, uv.y) + PI;
	float r = TWO_PI/float(num);
	float d = cos(floor(0.5 + a / r) * r - a) * length(uv);
	float s = (smoothstep(add, add - dist, d));
	return s;
}

void fragment(){
	vec2 uv = SCREEN_UV;
	float aspect = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	uv = (uv - vec2(0.5, 0.0)) / vec2(aspect, 1.0) + vec2(0.5, 0.0);
	uv = rotate_uv(uv, rotation);
	uv -= pos;
	
	float mask;
	mask += shape(uv, size, width, vertices);
	mask -= shape(uv, size - width, width, vertices);
	mask *= alpha;
	
	vec2 disp = normalize(uv) * force * mask;
	vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	COLOR = c;
	// uncomment to preview mask
//	COLOR.rgb = vec3(mask);
}
