shader_type canvas_item;

const float FACTOR = 32.0;
const float SCALE = 0.003;

uniform vec3 xyz = vec3(0.0);

void fragment(){
	vec2 uv = SCREEN_UV;
	float z = xyz.z * SCALE;
	uv.x += sin(FACTOR * xyz.x) * z;
	uv.y += cos(FACTOR * xyz.y) * z;
	vec4 color = texture(SCREEN_TEXTURE, uv);
	COLOR = color;
}
